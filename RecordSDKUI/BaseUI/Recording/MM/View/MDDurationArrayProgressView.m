//
//  MDDurationArrayProgressView.m
//  MDChat
//
//  Created by wangxuan on 16/12/28.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDDurationArrayProgressView.h"
#import "MDRecordProgressView.h"
#import "MDRecordHeader.h"

static const CGFloat kViewLeftRightMargin = 7.0f;
static const CGFloat kViewTopMargin = 5.0f;
static const CGFloat kBetweenSegmentMargin = 1.0f;
static const CGFloat kProgressViewHeight = 4.0f;
static const CGFloat kProgressViewMinWidth = .5f;

@interface MDDurationArrayProgressView ()

@property (nonatomic, strong) NSMutableArray<UIProgressView *> *progressViewArray;
@property (nonatomic, strong) MDRecordProgressView *currentProgressView;
@property (nonatomic, assign) double savedProgress;

@end

@implementation MDDurationArrayProgressView

- (instancetype)initWithProgressColor:(UIColor *)progressColor trackColor:(UIColor *)trackColor
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, 0, MDScreenWidth, kProgressViewHeight);
        self.progressColor = progressColor;
        self.trackColor = trackColor;
        [self addSubview:self.currentProgressView];
    }
    
    return self;
}

- (void)refreshSegmentsAppearrence:(NSArray *)durations
{
    for (UIView *view in self.progressViewArray) {
        [view removeFromSuperview];
    }
    [self.progressViewArray removeAllObjects];
    CGFloat viewWidth = MDScreenWidth - kViewLeftRightMargin *2;
    
    CGFloat originX = kViewLeftRightMargin;
    self.savedProgress = .0f;
    self.progress = .0f;
    
    for (NSUInteger i = 0; i < durations.count; ++i) {
        
        double duration = [durations doubleAtIndex:i defaultValue:0];
        
        CGFloat margin = i == durations.count -1 ? 0 : kBetweenSegmentMargin;
        CGFloat width = MAX(duration *viewWidth -margin, kProgressViewMinWidth);
        width = MIN(width, MDScreenWidth -kViewLeftRightMargin -originX);
    
        MDRecordProgressView *progressView = [self progressViewWithFrame:CGRectMake(originX, kViewTopMargin, width, kProgressViewHeight)];
        
        [self addSubview:progressView];
        [self.progressViewArray addObjectSafe:progressView];
        
        originX += width +kBetweenSegmentMargin;
        self.savedProgress +=duration;
    }
    
    BOOL canShowNextProgress = originX < MDScreenWidth - kViewLeftRightMargin;
    self.currentProgressView.hidden = !canShowNextProgress || durations.count <= 0;
    self.currentProgressView.frame = CGRectMake(originX, kViewTopMargin, MDScreenWidth -kViewLeftRightMargin - originX, kProgressViewHeight);
}

- (void)refreshHilightedState:(BOOL)hilighted
{
    UIProgressView *view = self.progressViewArray.lastObject;
    if (view) {
        UIColor *color = hilighted ? self.hilightedColor : self.progressColor;
        view.progressTintColor = color;
    }
}

- (MDRecordProgressView *)progressViewWithFrame:(CGRect)frame
{
    MDRecordProgressView *progressView = [[MDRecordProgressView alloc] initWithFrame:frame];
    progressView.progressTintColor = self.progressColor;
    progressView.trackTintColor = self.trackColor;
    progressView.progress = 1.0f;
    
    return progressView;
}

#pragma mark - properties
- (NSMutableArray *)progressViewArray
{
    if (!_progressViewArray) {
        _progressViewArray = [[NSMutableArray alloc] init];
    }
    return _progressViewArray;
}

- (void)setProgress:(double)progress
{
    _progress = progress;
    if (_savedProgress >= 1) {
        _currentProgressView.progress = .0f;
    } else {
        _currentProgressView.progress = (progress -_savedProgress) / (1 - _savedProgress);
    }
    _currentProgressView.hidden = progress <= 0;
//    NSLog(@"currentProgress:%f",self.currentProgressView.progress);
}

- (void)setHilighted:(BOOL)hilighted
{
    _hilighted = hilighted;
    [self refreshHilightedState:hilighted];
}

- (MDRecordProgressView *)currentProgressView
{
    if (!_currentProgressView) {
        _currentProgressView = [self progressViewWithFrame:CGRectMake(kViewLeftRightMargin, 5, MDScreenWidth - 2*kViewLeftRightMargin, kProgressViewHeight)];
        _currentProgressView.progress = .0f;
    }
    return _currentProgressView;
}
@end
