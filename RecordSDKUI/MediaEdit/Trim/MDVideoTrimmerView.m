//
//  MDVideoTrimmerView.m
//  MDChat
//
//  Created by Jc on 17/2/7.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDVideoTrimmerView.h"
#import <POP/POP.h>
#import "MDRecordHeader.h"

#define kPerFrameWidth              32.f
#define kPerFrameHeight             48.f
#define kTrimmerMinSeconds          2.f
#define KTrimmerMaxSeconds          60.f
#define kTrimmerThumbViewWidth      10.f
#define kExpandScrollThreshold      (kPerFrameWidth * 2.f)

#define kOverlayBackgroudColor      [UIColor colorWithRed:95/255.f green:95/255.f blue:95/255.f alpha:0.85]
#define kBorderColor                [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:255.f/255.f alpha:1.f]

typedef enum : NSUInteger {
    MDVideoTrimmerRangePanState_Idle,
    MDVideoTrimmerRangePanState_Left,
    MDVideoTrimmerRangePanState_Center,
    MDVideoTrimmerRangePanState_Right,
} MDVideoTrimmerRangePanState;

#pragma mark - MDVideoTrimmerView

@interface MDVideoTrimmerView () <UIScrollViewDelegate, MDVideoTrimmerRangeViewDelegate>
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) UIView *pointerView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *frameView;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) NSMutableArray *trimmerRanges;
@property (nonatomic, strong) NSMutableArray *trimmerRangeViews;
@property (nonatomic, strong) MDVideoTrimmerRangeView *selectedTrimmerRangeView;
@property (nonatomic, strong) UIView *defaultOverlayView;
@property (nonatomic, assign) NSTimeInterval imageTimeInterval;
@property (nonatomic, assign) CGFloat frameWidth;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) id timeObserver;
@end

@implementation MDVideoTrimmerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.selectedTrimmerRangeView) {
        CGPoint convertedPoint =  [self.selectedTrimmerRangeView convertPoint:point fromView:self];
        
        UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(-kPerFrameWidth/2.f, -kPerFrameWidth/2.f, -kPerFrameWidth/2.f, -kPerFrameWidth/2.f);
        
        CGRect relativeFrame = self.selectedTrimmerRangeView.bounds;
        CGRect hitTestFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);

        if (CGRectContainsPoint(hitTestFrame, convertedPoint)) {
            UIView *resultView = [self.selectedTrimmerRangeView hitTest:convertedPoint withEvent:event];
            if (resultView) {
                return resultView;
            }
        }
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)dealloc
{
    if (self.timeObserver && self.player) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
        self.player = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset
{
    return [self initWithFrame:frame asset:asset imageTimeInterval:0.5];
}

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset imageTimeInterval:(NSTimeInterval)timeInterval
{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(timeInterval > 0, @"imageTimeInterval can not be <= 0");
        self.imageTimeInterval = timeInterval;
        self.asset = [asset copy];
        self.trimmerRanges = [NSMutableArray array];
        self.trimmerRangeViews = [NSMutableArray array];
        [self configureSubViews];
    }
    return self;
}

- (void)configureSubViews
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, (int)CGRectGetWidth(self.frame)/2, 0, (int)CGRectGetWidth(self.frame)/2);
    self.scrollView.clipsToBounds = NO;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(self.scrollView.frame))];
    [self.scrollView addSubview:self.contentView];
    
    self.frameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(self.contentView.frame))];
    self.frameView.clipsToBounds = YES;
    [self.contentView addSubview:self.frameView];
    
    [self configureFrames];
    
    self.defaultOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frameWidth, CGRectGetHeight(self.contentView.frame))];
    self.defaultOverlayView.backgroundColor = kOverlayBackgroudColor;
    [self.contentView addSubview:self.defaultOverlayView];
    
    self.pointerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2.f-1, -10, 2, CGRectGetHeight(self.frame)+20)];
    self.pointerView.backgroundColor = [UIColor whiteColor];
    self.pointerView.userInteractionEnabled = NO;
    [self addSubview:self.pointerView];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -30, 0, 20)];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.text = @"00:00";
    [self.timeLabel sizeToFit];
    self.timeLabel.center = CGPointMake(self.pointerView.center.x, self.timeLabel.center.y);
    [self addSubview:self.timeLabel];
}

- (void)configureFrames
{
    CGFloat perFrameWidth = kPerFrameWidth;
    
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    self.imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    self.imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    self.imageGenerator.maximumSize = CGSizeMake(kPerFrameWidth * 2.f, kPerFrameHeight * 2.f);
    
    Float64 duration = CMTimeGetSeconds(self.asset.duration);
    Float64 frameCount = ceil(duration / (Float64)self.imageTimeInterval);
    self.frameWidth = perFrameWidth * (duration / (Float64)self.imageTimeInterval);
    
    // resize
    CGRect frame;
    
    frame = self.contentView.frame;
    frame.size.width = self.frameWidth;
    self.contentView.frame = frame;
    self.scrollView.contentSize = frame.size;
    
    frame = self.frameView.frame;
    frame.size.width = self.frameWidth;
    self.frameView.frame = frame;
    
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:frameCount];
    for (int i = 0; i < frameCount; i++) {
        CMTime time = CMTimeMakeWithSeconds(i * self.imageTimeInterval, self.asset.duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*perFrameWidth, 0, kPerFrameWidth, kPerFrameHeight)];
        imgView.tag = i+1;
        imgView.backgroundColor = [UIColor blackColor];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        [self.frameView addSubview:imgView];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 0; i < times.count; i++) {
            CMTime requestTime = [times[i] CMTimeValue];
            CGImageRef imageRef = [self.imageGenerator copyCGImageAtTime:requestTime actualTime:NULL error:NULL];
            UIImage *image = [UIImage imageWithCGImage:imageRef scale:2.0 orientation:UIImageOrientationUp];
            CGImageRelease(imageRef);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imgView = [self.frameView viewWithTag:i+1];
                imgView.image = image;
            });
        }
    });
}

- (void)scrollToTime:(CMTime)time animated:(BOOL)animated
{
    if (!CMTIME_IS_VALID(time)) {
        return;
    }
    
    Float64 second = CMTimeGetSeconds(time);
    CGFloat offsetX = (second / self.imageTimeInterval) * kPerFrameWidth;
    
    CGFloat frameWidth = self.frameWidth;
    
    if (offsetX > frameWidth) {
        offsetX = frameWidth;
    }
    
    offsetX = offsetX - self.scrollView.contentInset.left;
    [self.scrollView setContentOffset:CGPointMake(offsetX, self.scrollView.contentOffset.y) animated:animated];
}

- (CMTime)currentPointerTime
{
    CGFloat offsetX = self.scrollView.contentOffset.x + self.scrollView.contentInset.left;
    // temp fix
    if (offsetX + 1 == self.scrollView.contentSize.width) {
        offsetX = self.scrollView.contentSize.width;
    }
    // temp fix
    Float64 second = offsetX / kPerFrameWidth * self.imageTimeInterval;
    return CMTimeMakeWithSeconds(second, self.asset.duration.timescale);
}

- (BOOL)isCurrentPointerInSelectedRange
{
    CGFloat offsetX = self.scrollView.contentOffset.x + self.scrollView.contentInset.left;
    // temp fix
    if (offsetX + 1 == self.scrollView.contentSize.width) {
        offsetX = self.scrollView.contentSize.width;
    }
    // temp fix

    if (self.selectedTrimmerRangeView) {
        NSInteger index = [self.trimmerRangeViews indexOfObject:self.selectedTrimmerRangeView];
        if (index == NSNotFound) {
            return NO;
        }
        
        NSValue *rangeValue = self.trimmerRanges[index];
        MDLRRange trimmerRange;
        [rangeValue getValue:&trimmerRange];
        
        if (offsetX >= (trimmerRange.left-kTrimmerThumbViewWidth) && offsetX <= (trimmerRange.right+kTrimmerThumbViewWidth)) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (BOOL)insertTimeRange:(CMTimeRange)timeRange
{
    if (!CMTIMERANGE_IS_VALID(timeRange)) {
        return NO;
    }
    
    if (CMTimeGetSeconds(timeRange.duration) < kTrimmerMinSeconds) {
        return NO;
    }
    
    CMTime start = timeRange.start;
    CMTime end = CMTimeRangeGetEnd(timeRange);
    
    Float64 startSecond = CMTimeGetSeconds(start);
    Float64 endSecond = CMTimeGetSeconds(end);
    
    CGFloat left = startSecond / self.imageTimeInterval * kPerFrameWidth;
    CGFloat right = endSecond / self.imageTimeInterval * kPerFrameWidth;
    
    MDLRRange range = MDLRRangeMake(left, right);
    return [self insertTrimmerRange:range];
}

- (BOOL)insertTrimmerRange:(MDLRRange)trimmerRange
{
    NSInteger insertIndex = [self canInsertTrimmerRange:trimmerRange];
    if (insertIndex == NSNotFound) {
        return NO;
    }
    NSValue *insertTrimmerRangeValue = [NSValue valueWithBytes:&trimmerRange objCType:@encode(MDLRRange)];
    [self.trimmerRanges insertObject:insertTrimmerRangeValue atIndex:insertIndex];

    MDLRRange limitRange = [self getLimitRangeWithTrimmerRangeAtIndex:insertIndex];
    
    CGRect frame = CGRectMake(limitRange.left, 0, limitRange.right-limitRange.left, CGRectGetHeight(self.contentView.frame));
    
    NSTimeInterval maxTrimmerSeconds = self.maxVideoSesonds > 0 ? self.maxVideoSesonds : KTrimmerMaxSeconds;
    
    CGFloat mininum = kTrimmerMinSeconds / self.imageTimeInterval * kPerFrameWidth;
    CGFloat maximum = maxTrimmerSeconds / self.imageTimeInterval * kPerFrameWidth;
    
    MDVideoTrimmerRangeView *trimmerRangeView = [[MDVideoTrimmerRangeView alloc] initWithFrame:frame trimmerRange:trimmerRange limitRange:limitRange minimum:mininum maximum:maximum timeInterval:self.imageTimeInterval color:kBorderColor hiddenTimeLabel:self.borderTimeLabelHidden];
    
    [self.trimmerRangeViews insertObject:trimmerRangeView atIndex:insertIndex];
    
    trimmerRangeView.delegate = self;
    trimmerRangeView.selected = YES;
    [self.contentView addSubview:trimmerRangeView];
    
    [trimmerRangeView showInsertAnimation];
    
    if (insertIndex - 1 >= 0) {
        MDVideoTrimmerRangeView *leftRangeView = self.trimmerRangeViews[insertIndex-1];
        leftRangeView.limitRange = MDLRRangeMake(leftRangeView.limitRange.left, trimmerRange.left);
        leftRangeView.rightOverLayView.hidden = YES;
    }
    
    if (insertIndex + 1 < self.trimmerRangeViews.count) {
        MDVideoTrimmerRangeView *rightRangeView = self.trimmerRangeViews[insertIndex+1];
        rightRangeView.limitRange = MDLRRangeMake(trimmerRange.right, rightRangeView.limitRange.right);
        rightRangeView.leftOverLayView.hidden = YES;
    }
    
    if (!self.defaultOverlayView.hidden) {
        self.defaultOverlayView.hidden = YES;
    }
    
    return YES;
}

- (MDLRRange)getLimitRangeWithTrimmerRangeAtIndex:(NSUInteger)index
{
    if (self.trimmerRanges.count > 0) {
        if (self.trimmerRanges.count == 1) {
            if (index == 0) {
                return MDLRRangeMake(0, self.frameWidth);
            } else {
                return MDLRRangeMake(0, 0);
            }
        } else {
            if (index == 0) {
                NSValue *rightRangeValue = self.trimmerRanges[index+1];
                MDLRRange rightTrimmerRange;
                [rightRangeValue getValue:&rightTrimmerRange];
                return MDLRRangeMake(0, rightTrimmerRange.left);
            } else if (index == self.trimmerRanges.count-1) {
                NSValue *leftRangeValue = self.trimmerRanges[index-1];
                MDLRRange leftTrimmerRange;
                [leftRangeValue getValue:&leftTrimmerRange];
                return MDLRRangeMake(leftTrimmerRange.right, self.frameWidth);
            } else {
                NSValue *leftRangeValue = self.trimmerRanges[index-1];
                MDLRRange leftTrimmerRange;
                [leftRangeValue getValue:&leftTrimmerRange];
                
                NSValue *rightRangeValue = self.trimmerRanges[index+1];
                MDLRRange rightTrimmerRange;
                [rightRangeValue getValue:&rightTrimmerRange];
                
                return MDLRRangeMake(leftTrimmerRange.right, rightTrimmerRange.left);
            }
        }
    }
    return MDLRRangeMake(0, 0);
}

- (NSInteger)canInsertTrimmerRange:(MDLRRange)trimmerRange
{
    CGFloat frameWidth = self.frameWidth;
    if (trimmerRange.left < 0 || trimmerRange.right > frameWidth) {
        return NSNotFound;
    }
    
    if (self.trimmerRanges.count == 0) {
        return 0;
    } else if (self.trimmerRanges.count == 1) {
        NSValue *firstTrimmerRangeValue = self.trimmerRanges.firstObject;
        MDLRRange firstTrimmerRange;
        [firstTrimmerRangeValue getValue:&firstTrimmerRange];
        if (trimmerRange.right <= firstTrimmerRange.left) {
            return 0;
        }
        if (trimmerRange.left >= firstTrimmerRange.right) {
            return 1;
        }
    } else {
        NSValue *firstTrimmerRangeValue = self.trimmerRanges.firstObject;
        MDLRRange firstTrimmerRange;
        [firstTrimmerRangeValue getValue:&firstTrimmerRange];
        if (trimmerRange.right <= firstTrimmerRange.left) {
            return 0;
        }
        NSValue *lastTrimmerRangeValue = self.trimmerRanges.lastObject;
        MDLRRange lastTrimmerRange;
        [lastTrimmerRangeValue getValue:&lastTrimmerRange];
        if (trimmerRange.left >= lastTrimmerRange.right) {
            return self.trimmerRanges.count;
        }
        
        for (int i = 0; i < self.trimmerRanges.count-1; i++) {
            NSValue *leftTrimmerRangeValue = self.trimmerRanges[i];
            MDLRRange leftTrimmerRange;
            [leftTrimmerRangeValue getValue:&leftTrimmerRange];
            
            NSValue *rightTrimmerRangeValue = self.trimmerRanges[i+1];
            MDLRRange rightTrimmerRange;
            [rightTrimmerRangeValue getValue:&rightTrimmerRange];
            
            if (leftTrimmerRange.right <= trimmerRange.left && rightTrimmerRange.left >= trimmerRange.right) {
                return i+1;
            }
        }
    }
    return NSNotFound;
}

- (void)deleteSelectedTimeRange
{
    if (self.selectedTrimmerRangeView) {
        
        if (self.trimmerRangeViews.count == 1) {
            self.defaultOverlayView.hidden = NO;
        }
        
        NSInteger index = [self.trimmerRangeViews indexOfObject:self.selectedTrimmerRangeView];
    
        NSInteger tag = 0;
        
        if (index - 1 >= 0) {
            tag++;
            
            MDVideoTrimmerRangeView *leftRangeView = self.trimmerRangeViews[index-1];
            MDLRRange newLeftRangeViewLimitRange = leftRangeView.limitRange;
            newLeftRangeViewLimitRange.right = self.selectedTrimmerRangeView.limitRange.right;
            leftRangeView.limitRange = newLeftRangeViewLimitRange;
            
            leftRangeView.rightOverLayView.hidden = NO;
        }
        
        if (index + 1 < self.trimmerRangeViews.count) {
            tag++;

            MDVideoTrimmerRangeView *rightRangeView = self.trimmerRangeViews[index+1];
            MDLRRange newRightRangeViewLimitRange = rightRangeView.limitRange;
            newRightRangeViewLimitRange.left = self.selectedTrimmerRangeView.limitRange.left;
            rightRangeView.limitRange = newRightRangeViewLimitRange;
            
            if (tag == 2) {
                rightRangeView.leftOverLayView.hidden = YES;
            } else {
                rightRangeView.leftOverLayView.hidden = NO;
            }
        }
        
        self.selectedTrimmerRangeView.delegate = nil;
        [self.selectedTrimmerRangeView removeFromSuperview];
        self.selectedTrimmerRangeView = nil;

        [self.trimmerRangeViews removeObjectAtIndex:index];
        [self.trimmerRanges removeObjectAtIndex:index];
    }
}

- (void)deleteTimeRangeAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.trimmerRangeViews.count) {
        
        if (index == self.selectedTrimmerRangeIndex) {
            [self deleteSelectedTimeRange];
        } else {
            
            if (self.trimmerRangeViews.count == 1) {
                self.defaultOverlayView.hidden = NO;
            }
            
            MDVideoTrimmerRangeView *willDeleteTrimmerRangeView = self.trimmerRangeViews[index];
            
            NSInteger tag = 0;
            
            if (index - 1 >= 0) {
                tag++;
                
                MDVideoTrimmerRangeView *leftRangeView = self.trimmerRangeViews[index-1];
                MDLRRange newLeftRangeViewLimitRange = leftRangeView.limitRange;
                newLeftRangeViewLimitRange.right = willDeleteTrimmerRangeView.limitRange.right;
                leftRangeView.limitRange = newLeftRangeViewLimitRange;
                
                leftRangeView.rightOverLayView.hidden = NO;
            }
            
            if (index + 1 < self.trimmerRangeViews.count) {
                tag++;
                
                MDVideoTrimmerRangeView *rightRangeView = self.trimmerRangeViews[index+1];
                MDLRRange newRightRangeViewLimitRange = rightRangeView.limitRange;
                newRightRangeViewLimitRange.left = willDeleteTrimmerRangeView.limitRange.left;
                rightRangeView.limitRange = newRightRangeViewLimitRange;
                
                if (tag == 2) {
                    rightRangeView.leftOverLayView.hidden = YES;
                } else {
                    rightRangeView.leftOverLayView.hidden = NO;
                }
            }
            
            willDeleteTrimmerRangeView.delegate = nil;
            [willDeleteTrimmerRangeView removeFromSuperview];
            
            [self.trimmerRangeViews removeObjectAtIndex:index];
            [self.trimmerRanges removeObjectAtIndex:index];
            
        }
    }
}

- (void)deleteAllTimeRange
{
    for (MDVideoTrimmerRangeView *rangeView in self.trimmerRangeViews) {
        rangeView.delegate = nil;
        [rangeView removeFromSuperview];
    }
    [self.trimmerRangeViews removeAllObjects];
    [self.trimmerRanges removeAllObjects];
    
    self.selectedTrimmerRangeView = nil;
    self.defaultOverlayView.hidden = NO;
}

- (NSArray<NSValue*> *)trimmerTimeRanges
{
    if (self.trimmerRanges.count) {
        NSMutableArray *timeRanges = [NSMutableArray arrayWithCapacity:self.trimmerRanges.count];
        for (NSValue *value in self.trimmerRanges) {
            MDLRRange trimmerRange;
            [value getValue:&trimmerRange];
            
            CMTimeRange timeRange = [self timeRangeByTrimmerRange:trimmerRange];
            [timeRanges addObject:[NSValue valueWithCMTimeRange:timeRange]];
        }
        return timeRanges;
    }
    return nil;
}

- (NSUInteger)selectedTrimmerRangeIndex
{
    if (self.selectedTrimmerRangeView) {
        return [self.trimmerRangeViews indexOfObject:self.selectedTrimmerRangeView];
    } else {
        return NSNotFound;
    }
}

- (CMTimeRange)selectedTrimmerTimeRange
{
    NSInteger index = self.selectedTrimmerRangeIndex;;
    
    if (index != NSNotFound) {
        NSValue *value = self.trimmerRanges[index];
        MDLRRange trimmerRange;
        [value getValue:&trimmerRange];
        return [self timeRangeByTrimmerRange:trimmerRange];
    } else {
        return kCMTimeRangeInvalid;
    }
}

- (CMTimeRange)timeRangeByTrimmerRange:(MDLRRange)trimmerRange
{
    CGFloat rangeWidth = trimmerRange.right - trimmerRange.left;
    if (rangeWidth > 0) {
        Float64 startSecond = trimmerRange.left / kPerFrameWidth * self.imageTimeInterval;
        CMTime start = CMTimeMakeWithSeconds(startSecond, self.asset.duration.timescale);
        
        Float64 durationSecond = rangeWidth / kPerFrameWidth * self.imageTimeInterval;
        CMTime duration = CMTimeMakeWithSeconds(durationSecond, self.asset.duration.timescale);
        
        return CMTimeRangeMake(start, duration);
    }
    return kCMTimeRangeInvalid;
}

- (CGFloat)handleTrimmerRangeView:(MDVideoTrimmerRangeView *)trimmerRangeView expandRequest:(CGFloat)offsetX
{
    if (offsetX > 0) {
        
        if (trimmerRangeView.trimmerRange.right >= self.scrollView.contentSize.width) {
            return 0;
        }
        
        CGFloat contentRightOffsetX = self.scrollView.contentOffset.x + self.scrollView.frame.size.width;
        CGFloat trimmerRangeRight = trimmerRangeView.trimmerRange.right;
        
        if (contentRightOffsetX - trimmerRangeRight <= kExpandScrollThreshold) {
            CGPoint targetContentOffset = CGPointMake(self.scrollView.contentOffset.x+offsetX, self.scrollView.contentOffset.y);
            [self.scrollView setContentOffset:targetContentOffset];
        }
        
        if (trimmerRangeView.trimmerRange.right + offsetX > self.scrollView.contentSize.width) {
            return self.scrollView.contentSize.width-trimmerRangeView.trimmerRange.right;
        }
    } else {
        
        if (trimmerRangeView.trimmerRange.left <= 0) {
            return 0;
        }
        
        CGFloat contentLeftOffsetX = self.scrollView.contentOffset.x;
        CGFloat trimmerRangeLeft = trimmerRangeView.trimmerRange.left;
        
        if (trimmerRangeLeft - contentLeftOffsetX <= kExpandScrollThreshold) {
            CGPoint targetContentOffset = CGPointMake(self.scrollView.contentOffset.x+offsetX, self.scrollView.contentOffset.y);
            [self.scrollView setContentOffset:targetContentOffset];
        }
        
        if (trimmerRangeView.trimmerRange.left + offsetX < 0) {
            return 0-trimmerRangeView.trimmerRange.left;
        }
    }
    
    return offsetX;
}

- (void)setSelectedTrimmerRangeView:(MDVideoTrimmerRangeView *)selectedTrimmerRangeView
{
    _selectedTrimmerRangeView = selectedTrimmerRangeView;
    if (_selectedTrimmerRangeView == nil) {
        self.timeLabel.hidden = NO;
    } else {
        self.timeLabel.hidden = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat actualOffsetX = scrollView.contentOffset.x + scrollView.contentInset.left;
    // temp fix
    if (actualOffsetX + 1 >= scrollView.contentSize.width) {
        actualOffsetX = scrollView.contentSize.width;
    }
    // temp fix
    
    int minute = 0;
    int second = 0;
    
    second = (int)(actualOffsetX / kPerFrameWidth * self.imageTimeInterval);
    
    Float64 duration = CMTimeGetSeconds(self.asset.duration);
    if (second > duration) {
        second = (int)duration;
    }
    if (second < 0) {
        second = 0;
    }
    
    if (second >= 60) {
        minute = second / 60;
        second = second % 60;
    }
    NSString *leftTimeStr = [NSString stringWithFormat:@"%02d:%02d", minute, second];
    self.timeLabel.text = leftTimeStr;
    [self.timeLabel sizeToFit];
    
    if (self.player.rate == 0) {
        CMTime currentTime = self.currentPointerTime;
        CMTime presentationTime = [self.delegate videoTrimmerView:self presentationTimeFromMediaSourceTime:currentTime];
        [self.player seekToTime:presentationTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        }];
    }
    
    if ([self.delegate respondsToSelector:@selector(videoTrimmerViewDidScroll:)]) {
        [self.delegate videoTrimmerViewDidScroll:self];
    }
}

#pragma mark -
- (CGFloat)trimmerRangeView:(MDVideoTrimmerRangeView *)rangeView shouldMoved:(CGFloat)offsetX
{
    if (offsetX > 0) {
        
        if (rangeView.trimmerRange.right >= rangeView.limitRange.right) {
            return 0;
        }
        
        CGFloat contentRightOffsetX = self.scrollView.contentOffset.x + self.scrollView.frame.size.width;
        CGFloat trimmerRangeRight = rangeView.trimmerRange.right;
        
        if (contentRightOffsetX - trimmerRangeRight <= kExpandScrollThreshold) {
            CGPoint targetContentOffset = CGPointMake(self.scrollView.contentOffset.x+offsetX, self.scrollView.contentOffset.y);
            [self.scrollView setContentOffset:targetContentOffset];
        }
        
        if (rangeView.trimmerRange.right + offsetX > rangeView.limitRange.right) {
            return rangeView.limitRange.right - rangeView.trimmerRange.right;
        }
        
    } else {
        
        if (rangeView.trimmerRange.left <= rangeView.limitRange.left) {
            return 0;
        }
        
        CGFloat contentLeftOffsetX = self.scrollView.contentOffset.x;
        CGFloat trimmerRangeLeft = rangeView.trimmerRange.left;
        
        if (trimmerRangeLeft - contentLeftOffsetX <= kExpandScrollThreshold) {
            CGPoint targetContentOffset = CGPointMake(self.scrollView.contentOffset.x+offsetX, self.scrollView.contentOffset.y);
            [self.scrollView setContentOffset:targetContentOffset];
        }
        
        if (rangeView.trimmerRange.left + offsetX < rangeView.limitRange.left) {
            return rangeView.limitRange.left-rangeView.trimmerRange.left;
        }
    }
    
    return offsetX;
}

- (void)trimmerRangeViewWillChangeRange:(MDVideoTrimmerRangeView *)rangeView
{
    if ([self.delegate respondsToSelector:@selector(videoTrimmerViewDidStartChange:)]) {
        [self.delegate videoTrimmerViewDidStartChange:self];
    }
}

- (void)trimmerRangeViewIsChangingRange:(MDVideoTrimmerRangeView *)rangeView
{
    if ([self.delegate respondsToSelector:@selector(videoTrimmerViewDidChanged:)]) {
        
        NSInteger index = [self.trimmerRangeViews indexOfObject:rangeView];
        MDLRRange trimmerRange = rangeView.trimmerRange;
        NSValue *trimmerRangeValue = [NSValue valueWithBytes:&trimmerRange objCType:@encode(MDLRRange)];
        [self.trimmerRanges replaceObjectAtIndex:index withObject:trimmerRangeValue];
        
        [self.delegate videoTrimmerViewDidChanged:self];
    }
}

- (void)trimmerRangeViewDidChangeRange:(MDVideoTrimmerRangeView *)rangeView
{
    NSInteger index = [self.trimmerRangeViews indexOfObject:rangeView];
    MDLRRange trimmerRange = rangeView.trimmerRange;
    NSValue *trimmerRangeValue = [NSValue valueWithBytes:&trimmerRange objCType:@encode(MDLRRange)];
    [self.trimmerRanges replaceObjectAtIndex:index withObject:trimmerRangeValue];
    
    if ([self.delegate respondsToSelector:@selector(videoTrimmerViewDidEndChange:)]) {
        [self.delegate videoTrimmerViewDidEndChange:self];
    }
}

- (void)trimmerRangeViewDidChangeSelected:(MDVideoTrimmerRangeView *)rangeView
{
    if (!self.selectedTrimmerRangeView) {
        self.timeLabel.hidden = YES;
        self.selectedTrimmerRangeView = rangeView;
        [self adjustSelectedTrimmerRangeView:rangeView];
        
        [self notifyDelegateDidChangeSelected];
    } else {
     
        if (rangeView == self.selectedTrimmerRangeView) {
            if (rangeView.selected) {
                //NSLog(@"can not");
            } else {
                self.timeLabel.hidden = NO;
                self.selectedTrimmerRangeView = nil;
                
                [self notifyDelegateDidChangeSelected];
            }
        } else {
            if (rangeView.selected) {
                [self adjustSelectedTrimmerRangeView:rangeView];
                MDVideoTrimmerRangeView *previousRangeView = self.selectedTrimmerRangeView;
                self.selectedTrimmerRangeView = rangeView;
                previousRangeView.selected = NO;
                
                [self notifyDelegateDidChangeSelected];
            } else {
                //NSLog(@"do nothing");
            }
        }
    }
}

- (void)notifyDelegateDidChangeSelected
{
    if ([self.delegate respondsToSelector:@selector(videoTrimmerViewDidChangeSelected:)]) {
        [self.delegate videoTrimmerViewDidChangeSelected:self];
    }
}

- (void)adjustSelectedTrimmerRangeView:(MDVideoTrimmerRangeView *)rangeView
{
    rangeView.leftOverLayView.hidden = NO;
    rangeView.rightOverLayView.hidden = NO;
    
    NSInteger index = [self.trimmerRangeViews indexOfObject:rangeView];
    
    MDLRRange newLimitRange = rangeView.limitRange;
    
    if (index - 1 >= 0) {
        MDVideoTrimmerRangeView *leftRangeView = self.trimmerRangeViews[index-1];
        leftRangeView.rightOverLayView.hidden = YES;
        newLimitRange.left = leftRangeView.trimmerRange.right;
    }
    if (index + 1 < self.trimmerRangeViews.count) {
        MDVideoTrimmerRangeView *rightRangeView = self.trimmerRangeViews[index+1];
        rightRangeView.leftOverLayView.hidden = YES;
        newLimitRange.right = rightRangeView.trimmerRange.left;
    }
    
    rangeView.limitRange = newLimitRange;
    
    [rangeView.superview bringSubviewToFront:rangeView];
}

@end

@implementation MDVideoTrimmerView (Synchronize)

- (void)synchronizeWithPlayer:(AVPlayer *)player
{
    self.player = player;
    [self addTimeObserver];
}

- (void)addTimeObserver
{
    [self removeTimeObserver];
    if (self.player) {
        __weak __typeof(self) weakSelf = self;
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            if (weakSelf.player.rate != 0) {
                CMTime sourceTime = [weakSelf.delegate videoTrimmerView:weakSelf mediaSouceTimeFromPresentationTime:time];
                [weakSelf scrollToTime:sourceTime animated:NO];
            }
        }];
    }
}

- (void)removeTimeObserver
{
    if (self.timeObserver && self.player) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

@end

#pragma mark - MDVideoTrimmerRangeView

@interface MDVideoTrimmerRangeView ()
@property (nonatomic, assign) MDLRRange trimmerRange;
@property (nonatomic, assign) CGFloat minimum;
@property (nonatomic, assign) CGFloat maximum;
@property (nonatomic, assign) NSTimeInterval timeInterval;

@property (nonatomic, strong) UIView *centerRangeView;
@property (nonatomic, strong) UIView *topBorderView;
@property (nonatomic, strong) UIView *bottomBorderView;
@property (nonatomic, strong) MDVideoTrimmerThumbView *leftThumbView;
@property (nonatomic, strong) MDVideoTrimmerThumbView *rightThumbView;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;

@property (nonatomic, strong) UIView *leftOverLayView;
@property (nonatomic, strong) UIView *rightOverLayView;

@property (nonatomic, strong) UIPanGestureRecognizer *leftPan;
@property (nonatomic, strong) UIPanGestureRecognizer *rightPan;
@property (nonatomic, strong) UIPanGestureRecognizer *centerPan;

@property (nonatomic, assign) MDVideoTrimmerRangePanState panState;
@property (nonatomic, assign) BOOL hideTimeLabel;
@end

@implementation MDVideoTrimmerRangeView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.userInteractionEnabled == NO) {
        return nil;
    }
    
    UIView *resultView = nil;
    
    CGPoint centerRangePoint = [self.centerRangeView convertPoint:point fromView:self];
    
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(-kPerFrameWidth/2.f, -kPerFrameWidth/2.f, -kPerFrameWidth/2.f, -kPerFrameWidth/2.f);
    
    CGPoint leftThumbPoint = [self.leftThumbView convertPoint:centerRangePoint fromView:self.centerRangeView];
    CGRect relativeFrame = self.leftThumbView.bounds;
    CGRect hitTestFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    if (CGRectContainsPoint(hitTestFrame, leftThumbPoint)) {
        resultView = self.leftThumbView;
    }
    
    CGPoint rightThumbPoint = [self.rightThumbView convertPoint:centerRangePoint fromView:self.centerRangeView];
    relativeFrame = self.rightThumbView.bounds;
    hitTestFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    if (CGRectContainsPoint(hitTestFrame, rightThumbPoint)) {
        resultView = self.rightThumbView;
    }
    
    if ([self.centerRangeView pointInside:centerRangePoint withEvent:event] || resultView != nil) {
        self.selected = YES;
    } else {
        self.selected = NO;
    }
    
    return resultView;
}

- (instancetype)initWithFrame:(CGRect)frame trimmerRange:(MDLRRange)trimmerRange limitRange:(MDLRRange)limitRange minimum:(CGFloat)minimum maximum:(CGFloat)maximum timeInterval:(NSTimeInterval)timeInterval color:(UIColor *)color hiddenTimeLabel:(BOOL)isHidden
{
    self = [super initWithFrame:frame];
    if (self) {
        self.trimmerRange = trimmerRange;
        self.limitRange = limitRange;
        self.minimum = minimum;
        self.maximum = maximum;
        self.timeInterval = timeInterval;
        
        self.leftOverLayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, trimmerRange.left-limitRange.left, CGRectGetHeight(frame))];
        self.leftOverLayView.backgroundColor = kOverlayBackgroudColor;
        [self addSubview:self.leftOverLayView];
        
        self.rightOverLayView = [[UIView alloc] initWithFrame:CGRectMake(trimmerRange.right-limitRange.left, 0, limitRange.right-trimmerRange.right, CGRectGetHeight(frame))];
        self.rightOverLayView.backgroundColor = kOverlayBackgroudColor;
        
        [self addSubview:self.rightOverLayView];
        
        self.centerRangeView = [[UIView alloc] initWithFrame:CGRectMake(trimmerRange.left-limitRange.left, 0, trimmerRange.right-trimmerRange.left, CGRectGetHeight(frame))];
        [self addSubview:self.centerRangeView];
        
        self.topBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, -4, CGRectGetWidth(self.centerRangeView.frame), 4)];
        self.topBorderView.backgroundColor = color;
        [self.centerRangeView addSubview:self.topBorderView];
        
        self.bottomBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.centerRangeView.frame), CGRectGetWidth(self.centerRangeView.frame), 4)];
        self.bottomBorderView.backgroundColor = color;
        [self.centerRangeView addSubview:self.bottomBorderView];
        
        self.leftThumbView = [[MDVideoTrimmerThumbView alloc] initWithFrame:CGRectMake(-kTrimmerThumbViewWidth, -4, kTrimmerThumbViewWidth, CGRectGetHeight(self.centerRangeView.frame)+8) color:color rightFlag:NO];
        self.leftThumbView.backgroundColor = [UIColor clearColor];
        self.leftThumbView.layer.masksToBounds = YES;
        [self.centerRangeView addSubview:self.leftThumbView];
        
        self.rightThumbView = [[MDVideoTrimmerThumbView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.centerRangeView.frame), -4, kTrimmerThumbViewWidth, CGRectGetHeight(self.centerRangeView.frame)+8) color:color rightFlag:YES];
        self.rightThumbView.backgroundColor = [UIColor clearColor];
        self.rightThumbView.layer.masksToBounds = YES;
        [self.centerRangeView addSubview:self.rightThumbView];
        
        self.leftTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(-22, -30, 0, 20)];
        self.leftTimeLabel.backgroundColor = [UIColor clearColor];
        self.leftTimeLabel.font = [UIFont systemFontOfSize:12];
        self.leftTimeLabel.textColor = [UIColor whiteColor];
        self.leftTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.leftTimeLabel.text = @"00:00";
        self.leftTimeLabel.hidden = isHidden;
        [self.leftTimeLabel sizeToFit];
        [self.centerRangeView addSubview:self.leftTimeLabel];
        
        self.rightTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.centerRangeView.frame)-12, -30, 0, 20)];
        self.rightTimeLabel.backgroundColor = [UIColor clearColor];
        self.rightTimeLabel.font = [UIFont systemFontOfSize:12];
        self.rightTimeLabel.textColor = [UIColor whiteColor];
        self.rightTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.rightTimeLabel.text = @"00:00";
        self.rightTimeLabel.hidden = isHidden;
        [self.rightTimeLabel sizeToFit];
        [self.centerRangeView addSubview:self.rightTimeLabel];
        self.hideTimeLabel = isHidden;
        
        UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPanMoved:)];
        [self.leftThumbView addGestureRecognizer:leftPan];
//        [self.leftOverLayView addGestureRecognizer:leftPan];
        self.leftPan = leftPan;
        
        UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightPanMoved:)];
        [self.rightThumbView addGestureRecognizer:rightPan];
//        [self.rightOverLayView addGestureRecognizer:rightPan];
        self.rightPan = rightPan;
        
        UIPanGestureRecognizer *centerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(centerPanMoved:)];
        [leftPan requireGestureRecognizerToFail:centerPan];
        [rightPan requireGestureRecognizerToFail:centerPan];
//        [self.centerRangeView addGestureRecognizer:centerPan];
        self.centerPan = centerPan;
        
        UITapGestureRecognizer *centerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(centerTapped:)];
        [centerTap requireGestureRecognizerToFail:centerPan];
//        [self.centerRangeView addGestureRecognizer:centerTap];
        
        [self bringSubviewToFront:self.centerRangeView];
        [self.centerRangeView bringSubviewToFront:self.leftThumbView];
        [self.centerRangeView bringSubviewToFront:self.rightThumbView];
        
        [self refreshTimeLabel];
        
//        _selected = YES;
    }
    return self;
}

- (void)leftPanMoved:(UIPanGestureRecognizer *)leftPan
{
    CGFloat translationX = [leftPan translationInView:self].x;
    [leftPan setTranslation:CGPointMake(0, 0) inView:self];
    
    [self tryLeftTranslationX:translationX];
    
    if (leftPan.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(trimmerRangeViewWillChangeRange:)]) {
            [self.delegate trimmerRangeViewWillChangeRange:self];
        }
    } else if (leftPan.state == UIGestureRecognizerStateChanged) {
        if ([self.delegate respondsToSelector:@selector(trimmerRangeViewIsChangingRange:)]) {
            [self.delegate trimmerRangeViewIsChangingRange:self];
        }
    } else if (leftPan.state == UIGestureRecognizerStateEnded) {
        self.panState = MDVideoTrimmerRangePanState_Idle;
        
        if ([self.delegate respondsToSelector:@selector(trimmerRangeViewDidChangeRange:)]) {
            [self.delegate trimmerRangeViewDidChangeRange:self];
        }
    }
}

- (void)rightPanMoved:(UIPanGestureRecognizer *)rightPan
{
    CGFloat translationX = [rightPan translationInView:self].x;
    [rightPan setTranslation:CGPointMake(0, 0) inView:self];
    
    [self tryRightTranslationX:translationX];
    
    if (rightPan.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(trimmerRangeViewWillChangeRange:)]) {
            [self.delegate trimmerRangeViewWillChangeRange:self];
        }
    } else if (rightPan.state == UIGestureRecognizerStateChanged) {
        if ([self.delegate respondsToSelector:@selector(trimmerRangeViewIsChangingRange:)]) {
            [self.delegate trimmerRangeViewIsChangingRange:self];
        }
    } else if (rightPan.state == UIGestureRecognizerStateEnded) {
        self.panState = MDVideoTrimmerRangePanState_Idle;
        
        if ([self.delegate respondsToSelector:@selector(trimmerRangeViewDidChangeRange:)]) {
            [self.delegate trimmerRangeViewDidChangeRange:self];
        }
    }
}

- (void)centerPanMoved:(UIPanGestureRecognizer *)centerPan
{
    CGFloat translationX = [centerPan translationInView:self].x;
    [centerPan setTranslation:CGPointMake(0, 0) inView:self];

    CGPoint point = [centerPan locationInView:self.centerRangeView];
    if ((point.x <= kPerFrameWidth || self.panState == MDVideoTrimmerRangePanState_Left) && self.panState != MDVideoTrimmerRangePanState_Center) {
        [self tryLeftTranslationX:translationX];
    } else if ((CGRectGetWidth(self.centerRangeView.frame)-point.x <= kPerFrameWidth || self.panState == MDVideoTrimmerRangePanState_Right) && self.panState != MDVideoTrimmerRangePanState_Center) {
        [self tryRightTranslationX:translationX];
    } else {
        [self tryCenterTranslationX:translationX];
    }
    
    if (centerPan.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(trimmerRangeViewWillChangeRange:)]) {
            [self.delegate trimmerRangeViewWillChangeRange:self];
        }
    } else if (centerPan.state == UIGestureRecognizerStateChanged) {
        if ([self.delegate respondsToSelector:@selector(trimmerRangeViewIsChangingRange:)]) {
            [self.delegate trimmerRangeViewIsChangingRange:self];
        }
    } else if (centerPan.state == UIGestureRecognizerStateEnded) {
        self.panState = MDVideoTrimmerRangePanState_Idle;
        
        if ([self.delegate respondsToSelector:@selector(trimmerRangeViewDidChangeRange:)]) {
            [self.delegate trimmerRangeViewDidChangeRange:self];
        }
    }
}

- (void)centerTapped:(UITapGestureRecognizer *)centerTap
{
//    self.selected = !self.selected;
}

- (void)tryLeftTranslationX:(CGFloat)translationX
{
    if (translationX > 0) {
        if (self.trimmerRange.right - self.trimmerRange.left <= self.minimum) {
            return;
        } else if (self.trimmerRange.right - self.trimmerRange.left - translationX < self.minimum) {
            translationX = self.trimmerRange.right - self.trimmerRange.left - self.minimum;
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(trimmerRangeView:shouldMoved:)]) {
            translationX = [self.delegate trimmerRangeView:self shouldMoved:translationX];
            if (!translationX) {
                return;
            }
        } else {
            return;
        }
        
        if (self.trimmerRange.right - self.trimmerRange.left >= self.maximum) {
            return;
        } else if (self.trimmerRange.right - self.trimmerRange.left - translationX > self.maximum) {
            translationX = -(self.maximum - (self.trimmerRange.right - self.trimmerRange.left));
        }
    }
    
    CGRect frame;
    
    frame = self.leftOverLayView.frame;
    frame.size.width += translationX;
    self.leftOverLayView.frame = frame;
    
    frame = self.centerRangeView.frame;
    frame.size.width -= translationX;
    frame.origin.x += translationX;
    self.centerRangeView.frame = frame;
    
    frame = self.topBorderView.frame;
    frame.size.width -= translationX;
    self.topBorderView.frame = frame;
    
    frame = self.bottomBorderView.frame;
    frame.size.width -= translationX;
    self.bottomBorderView.frame = frame;
    
    frame = self.rightThumbView.frame;
    frame.origin.x -= translationX;
    self.rightThumbView.frame = frame;
    
    frame = self.rightTimeLabel.frame;
    frame.origin.x -= translationX;
    self.rightTimeLabel.frame = frame;
    
    MDLRRange trimmerRange = self.trimmerRange;
    trimmerRange.left += translationX;
    self.trimmerRange = trimmerRange;
    
    [self refreshTimeLabel];
    
    self.panState = MDVideoTrimmerRangePanState_Left;
}

- (void)tryRightTranslationX:(CGFloat)translationX
{
    if (translationX < 0) {
        if (self.trimmerRange.right - self.trimmerRange.left <= self.minimum) {
            return;
        } else if (self.trimmerRange.right - self.trimmerRange.left + translationX < self.minimum) {
            translationX = -(self.trimmerRange.right - self.trimmerRange.left - self.minimum);
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(trimmerRangeView:shouldMoved:)]) {
            translationX = [self.delegate trimmerRangeView:self shouldMoved:translationX];
            if (!translationX) {
                return;
            }
        } else {
            return;
        }
        
        if (self.trimmerRange.right - self.trimmerRange.left >= self.maximum) {
            return;
        } else if (self.trimmerRange.right - self.trimmerRange.left + translationX > self.maximum) {
            translationX = self.maximum - (self.trimmerRange.right - self.trimmerRange.left);
        }
    }
    
    CGRect frame;
    
    frame = self.rightOverLayView.frame;
    frame.size.width -= translationX;
    frame.origin.x += translationX;
    self.rightOverLayView.frame = frame;
    
    frame = self.centerRangeView.frame;
    frame.size.width += translationX;
    self.centerRangeView.frame = frame;
    
    frame = self.topBorderView.frame;
    frame.size.width += translationX;
    self.topBorderView.frame = frame;
    
    frame = self.bottomBorderView.frame;
    frame.size.width += translationX;
    self.bottomBorderView.frame = frame;
    
    frame = self.rightThumbView.frame;
    frame.origin.x += translationX;
    self.rightThumbView.frame = frame;
    
    frame = self.rightTimeLabel.frame;
    frame.origin.x += translationX;
    self.rightTimeLabel.frame = frame;
    
    MDLRRange trimmerRange = self.trimmerRange;
    trimmerRange.right += translationX;
    self.trimmerRange = trimmerRange;
    
    [self refreshTimeLabel];
    
    self.panState = MDVideoTrimmerRangePanState_Right;
}

- (void)setLimitRange:(MDLRRange)limitRange
{
    if (_limitRange.left || _limitRange.right) {
    
        CGRect frame;
        
        frame = self.leftOverLayView.frame;
        frame.origin.x = 0;
        frame.size.width = self.trimmerRange.left - limitRange.left;
        self.leftOverLayView.frame = frame;
        
        frame = self.rightOverLayView.frame;
        frame.origin.x = self.trimmerRange.right - limitRange.left;
        frame.size.width = limitRange.right - self.trimmerRange.right;
        self.rightOverLayView.frame = frame;
        
        frame = self.centerRangeView.frame;
        frame.origin.x = self.trimmerRange.left - limitRange.left;
        self.centerRangeView.frame = frame;
        
        frame = self.frame;
        frame.origin.x = limitRange.left;
        frame.size.width = limitRange.right - limitRange.left;
        self.frame = frame;
    }
    
    _limitRange = limitRange;
}

- (void)tryCenterTranslationX:(CGFloat)translationX
{
    if ([self.delegate respondsToSelector:@selector(trimmerRangeView:shouldMoved:)]) {
        translationX = [self.delegate trimmerRangeView:self shouldMoved:translationX];
        if (!translationX) {
            return;
        }
    } else {
        return;
    }
    
    CGRect frame;
    
    frame = self.leftOverLayView.frame;
    frame.size.width += translationX;
    self.leftOverLayView.frame = frame;
    
    frame = self.rightOverLayView.frame;
    frame.size.width -= translationX;
    frame.origin.x += translationX;
    self.rightOverLayView.frame = frame;
    
    frame = self.centerRangeView.frame;
    frame.origin.x += translationX;
    self.centerRangeView.frame = frame;
    
    MDLRRange trimmerRange = self.trimmerRange;
    trimmerRange.left += translationX;
    trimmerRange.right += translationX;
    self.trimmerRange = trimmerRange;
    
    [self refreshTimeLabel];
    
    self.panState = MDVideoTrimmerRangePanState_Center;
}

- (void)refreshTimeLabel
{
    int minute = 0;
    int second = 0;
    
    second = (int)(self.trimmerRange.left / kPerFrameWidth * self.timeInterval);
    
    if (second >= 60) {
        minute = second / 60;
        second = second % 60;
    }
    NSString *leftTimeStr = [NSString stringWithFormat:@"%02d:%02d", minute, second];
    self.leftTimeLabel.text = leftTimeStr;
    [self.leftTimeLabel sizeToFit];
    
    minute = 0;
    second = (int)(self.trimmerRange.right / kPerFrameWidth * self.timeInterval);
    if (second >= 60) {
        minute = second / 60;
        second = second % 60;
    }
    NSString *rightTimeStr = [NSString stringWithFormat:@"%02d:%02d", minute, second];
    self.rightTimeLabel.text = rightTimeStr;
    [self.rightTimeLabel sizeToFit];
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        
        self.topBorderView.hidden = !selected;
        self.bottomBorderView.hidden = !selected;
        self.leftThumbView.hidden = !selected;
        self.rightThumbView.hidden = !selected;
        self.leftTimeLabel.hidden = !selected || self.hideTimeLabel;
        self.rightTimeLabel.hidden = !selected || self.hideTimeLabel;
        
        self.leftPan.enabled = selected;
        self.rightPan.enabled = selected;
        self.centerPan.enabled = selected;
        
        if ([self.delegate respondsToSelector:@selector(trimmerRangeViewDidChangeSelected:)]) {
            [self.delegate trimmerRangeViewDidChangeSelected:self];
        }
    }
}

- (void)showInsertAnimation
{
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    animation.fromValue = [NSValue valueWithCGRect:CGRectMake(self.centerRangeView.left, self.centerRangeView.top, 0, self.centerRangeView.height)];
    animation.toValue = [NSValue valueWithCGRect:self.centerRangeView.frame];
    animation.duration = 0.5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CGRect rightOverlayFrame = self.rightOverLayView.frame;
    
    __weak __typeof(self) weakSelf = self;
    [animation setAnimationDidApplyBlock:^(POPAnimation *ani) {
        CGRect toFrame = [[(POPBasicAnimation *)ani toValue] CGRectValue];
        weakSelf.rightTimeLabel.alpha = weakSelf.centerRangeView.width / CGRectGetWidth(toFrame);
        
        CGFloat remainDistance = CGRectGetWidth(toFrame) - weakSelf.centerRangeView.width;
        CGRect refreshRightOverlayFrame = rightOverlayFrame;
        refreshRightOverlayFrame.size.width += remainDistance;
        refreshRightOverlayFrame.origin.x -= remainDistance;
        weakSelf.rightOverLayView.frame = refreshRightOverlayFrame;
    }];
    
    [animation setAnimationDidStartBlock:^(POPAnimation *ani) {
        weakSelf.userInteractionEnabled = NO;
        weakSelf.rightTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        weakSelf.rightThumbView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        weakSelf.topBorderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        weakSelf.bottomBorderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }];
    
    [animation setCompletionBlock:^(POPAnimation *ani, BOOL finished) {
        weakSelf.userInteractionEnabled = YES;
        weakSelf.rightTimeLabel.autoresizingMask = UIViewAutoresizingNone;
        weakSelf.rightThumbView.autoresizingMask = UIViewAutoresizingNone;
        weakSelf.topBorderView.autoresizingMask = UIViewAutoresizingNone;
        weakSelf.bottomBorderView.autoresizingMask = UIViewAutoresizingNone;
        
        weakSelf.rightTimeLabel.alpha = 1.f;
        weakSelf.rightOverLayView.frame = rightOverlayFrame;
    }];
    
    [self.centerRangeView pop_addAnimation:animation forKey:nil];
}

@end

#pragma mark - MDVideoTrimmerThumbView

@interface MDVideoTrimmerThumbView ()
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL rightFlag;
@end

@implementation MDVideoTrimmerThumbView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color rightFlag:(BOOL)rightFlag
{
    self = [super initWithFrame:frame];
    if (self) {
        self.color = color;
        self.rightFlag = rightFlag;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = image;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.image) {
        [self.image drawInRect:rect];
    } else {
        CGRect bubbleFrame = self.bounds;
        CGRect roundedRect = CGRectMake(CGRectGetMinX(bubbleFrame), CGRectGetMinY(bubbleFrame), CGRectGetWidth(bubbleFrame), CGRectGetHeight(bubbleFrame));
        UIBezierPath *roundedRectanglePath;
        if (self.rightFlag) {
            roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:roundedRect byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(2.5f, 2.5f)];
        } else {
            roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:roundedRect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(2.5f, 2.5f)];
        }
        [roundedRectanglePath closePath];
        [self.color setFill];
        [roundedRectanglePath fill];
        
        CGRect decorationLineFrame = CGRectMake(CGRectGetMinX(bubbleFrame)+CGRectGetWidth(bubbleFrame)/2.f-1.f, CGRectGetMinY(bubbleFrame)+CGRectGetHeight(bubbleFrame)/3.f, 2.f, CGRectGetHeight(bubbleFrame)/3.f);
        UIBezierPath *decorationLinePath = [UIBezierPath bezierPathWithRoundedRect:decorationLineFrame byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(1.f, 1.f)];
        [decorationLinePath closePath];
        [[UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1.f] setFill];
        [decorationLinePath fill];
    }
}

@end
