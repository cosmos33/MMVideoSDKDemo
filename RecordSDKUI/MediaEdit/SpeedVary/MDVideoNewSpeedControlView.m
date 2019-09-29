//
//  MDVideoSpeedControlView.m
//  MDChat
//
//  Created by wangxuan on 17/2/21.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDVideoNewSpeedControlView.h"
#import "UIImage+MDUtility.h"
#import "MDRecordHeader.h"

static const CGFloat kSegmentViewWidth = 32.0f;

@interface MDVideoNewSpeedControlView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView   *backView;
@property (nonatomic, strong) UIView   *segmentIndicator;
@property (nonatomic, strong) NSArray<MDVideoNewSpeedControlItem *> *segmentTitleArray;
@property (nonatomic, strong) NSArray<UILabel  *> *segmentLabelArray;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL animating;

@end

@implementation MDVideoNewSpeedControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        [self setupSubView];
        [self addGesture];
    }
    
    return self;
}

- (void)setupSubView
{
    UIView *backView = [[UIView alloc] initWithFrame:self.bounds];
    backView.backgroundColor = [UIColor clearColor];
    backView.layer.cornerRadius = self.height/2.0;
    backView.layer.masksToBounds = YES;
    self.backView = backView;
    [self addSubview:self.backView];
    

    UIView *maskView = [[UIView alloc] initWithFrame:self.backView.bounds];
    maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    maskView.alpha = 0.49;
    maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.backView addSubview:maskView];
    
    UIView *segmentIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5, kSegmentViewWidth, kSegmentViewWidth)];
    segmentIndicator.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0f];
    segmentIndicator.layer.cornerRadius = kSegmentViewWidth *0.5f;
    segmentIndicator.clipsToBounds = YES;
    [self addSubview:segmentIndicator];
    self.segmentIndicator = segmentIndicator;
}

- (void)addGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.segmentIndicator addGestureRecognizer:pan];
}

#pragma mark - public

- (CGFloat)selectedFactor {
    if (self.selectedIndex>=0 && self.selectedIndex<self.segmentTitleArray.count) {
        return [[self.segmentTitleArray objectAtIndex:self.selectedIndex defaultValue:nil] factor];
    }
    return 0.0f;
}

- (void)layoutWithSegmentTitleArray:(NSArray <MDVideoNewSpeedControlItem *> *)segmentTitleArray {
    self.segmentTitleArray = segmentTitleArray;
    [self addSegmentViewWithTitles:segmentTitleArray];
    
    self.selectedIndex = -1;
    [self setCurrentSegmentIndex:0 animated:NO];
}

- (void)setCurrentSegmentIndex:(NSInteger)index animated:(BOOL)animated {
    [self setCurrentSegmentIndex:index animated:animated withEvent:NO];
}

- (void)setCurrentSegmentIndex:(NSInteger)index animated:(BOOL)animated withEvent:(BOOL)withEvent {
    if (self.segmentTitleArray.count <= index) {
        return;
    }
    if (self.selectedIndex == index) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self seekToIndex:index animate:animated completionHandler:^(BOOL finished) {
        weakSelf.selectedIndex = index;
        if (withEvent) {
            [weakSelf sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }];
}


#pragma mark - gesture

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return !self.animating;
}

- (void)handlePan:(UIPanGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:{
            UIView *view = sender.view;
            CGPoint point = [sender locationInView:view];

            CGFloat centerX = view.center.x + point.x;
            centerX = MAX(centerX, 0);
            centerX = MIN(centerX, self.width);
            view.centerX = centerX;

            [sender setTranslation:CGPointZero inView:view];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:{
            UIView *view = sender.view;
            [self adjustSliderItemWithTargetPoint:view.center];
        }
            break;
        default:
            break;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.backView];
    [self adjustSliderItemWithTargetPoint:point];
}

- (void)adjustSliderItemWithTargetPoint:(CGPoint)point {
    CGFloat segmentWidth = self.backView.width / self.segmentTitleArray.count;
    NSInteger targetIndex = floor(point.x / segmentWidth);
    targetIndex = MAX(0, MIN(self.segmentTitleArray.count-1, targetIndex));
    
    __weak typeof(self) weakSelf = self;
    [self seekToIndex:targetIndex animate:YES completionHandler:^(BOOL finished) {
        if (targetIndex == weakSelf.selectedIndex) {
            return;
        }
        weakSelf.selectedIndex = targetIndex;
        [weakSelf sendActionsForControlEvents:UIControlEventValueChanged];
    }];
}

#pragma mark -

- (void)addSegmentViewWithTitles:(NSArray<MDVideoNewSpeedControlItem *> *)titles {
    NSMutableArray *marr = [NSMutableArray arrayWithArray:self.segmentLabelArray];
    while (marr.count) {
        UILabel *segmentTitleLabel = [marr lastObject];
        [segmentTitleLabel removeFromSuperview];
        [marr removeLastObject];
    }
    
    CGFloat width = self.backView.width / titles.count;
    for (int i=0; i<titles.count; i++) {
        UILabel *segmentTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*width, self.backView.top, width, self.backView.height)];
        segmentTitleLabel.backgroundColor = [UIColor clearColor];
        segmentTitleLabel.textColor = [UIColor whiteColor];
        segmentTitleLabel.font = [UIFont systemFontOfSize:11];
        segmentTitleLabel.text = [[titles objectAtIndex:i defaultValue:nil] title];
        segmentTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:segmentTitleLabel];
        [marr addObjectSafe:segmentTitleLabel];
    }
    self.segmentLabelArray = marr;
}

- (void)seekToIndex:(NSInteger)index animate:(BOOL)animated completionHandler:(void (^ __nullable)(BOOL finished))completionHandler
{
    UILabel *oldSegmentLabel = [self.segmentLabelArray objectAtIndex:self.selectedIndex defaultValue:nil];
    UILabel *newSegmentLabel = [self.segmentLabelArray objectAtIndex:index defaultValue:nil];
    CGFloat segmentWidth = self.backView.width / self.segmentTitleArray.count;
    CGFloat centerX = (index+0.5)*segmentWidth;

    if (self.animating) {
        return;
    }
    
    if (animated) {
        
        self.animating = YES;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.segmentIndicator.centerX = centerX;
        } completion:^(BOOL finished) {
            self.animating = NO;
            if (completionHandler) {
                completionHandler(finished);
            }
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            oldSegmentLabel.textColor = [UIColor whiteColor];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            newSegmentLabel.textColor = RGBCOLOR(50, 51, 51);
        });
        
    } else {
        self.segmentIndicator.centerX = centerX;

        oldSegmentLabel.textColor = [UIColor whiteColor];
        newSegmentLabel.textColor = RGBCOLOR(50, 51, 51);
        if (completionHandler) {
            completionHandler(YES);
        }
    }
}

@end


@implementation MDVideoNewSpeedControlItem

+ (instancetype)itemWithTitle:(NSString *)title factor:(CGFloat)factor {
    MDVideoNewSpeedControlItem *item = [[self alloc] init];
    item.title = title;
    item.factor = factor;
    return item;
}

@end

