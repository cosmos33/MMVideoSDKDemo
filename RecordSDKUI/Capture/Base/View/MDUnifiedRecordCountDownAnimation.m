//
//  MDUnifiedRecordCountDownAnimation.m
//  MDChat
//
//  Created by 符吉胜 on 2017/6/20.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordCountDownAnimation.h"
#import <POP/POP.h>
#import "MDRecordHeader.h"

const CGFloat kStartPrepareAnimationDuration = 0.3f;
const CGFloat kDismissPrepareAnimationDuration = 0.15f;

@interface MDUnifiedRecordCountDownAnimation ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) NSInteger countDownNumber;

@property (nonatomic, strong) CADisplayLink *timer;
@property (nonatomic, copy) void (^completionHandler)(BOOL);

@property (nonatomic, weak) NSTimer *prepareTimer;
@property (nonatomic, assign) BOOL prepareShow;
@end

@implementation MDUnifiedRecordCountDownAnimation

-(void)dealloc
{
    NSLog(@"MDUnifiedRecordCountDownAnimation");
}

- (instancetype)initWithContainer:(UIView *)container
{
    self = [super init];
    if(self){
        self.contentView = container;
        [self setupSubView];
    }
    return self;
}

- (void)setCount:(NSInteger)count {
    _count = count;
    self.countDownNumber = count;
}
- (void)setCountDownNumber:(NSInteger)countDownNumber {
    _countDownNumber = countDownNumber;
    self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)countDownNumber];
}

- (void)setupSubView
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)];
    label.font = [UIFont systemFontOfSize:150];
    label.textAlignment = NSTextAlignmentCenter;
    label.center = CGPointMake(self.contentView.width *0.5f, self.contentView.height *0.5f);
    label.text = [NSString stringWithFormat:@"%ld",(long)self.countDownNumber];
    label.textColor = [UIColor whiteColor];
    label.alpha = .0f;
    self.countLabel = label;
}


#pragma mark - prepare animation

- (void)showPrepareAnimationWithString:(NSString *)string {
    
    [self.contentView addSubview:self.countLabel];
    self.countLabel.alpha = 1;
    self.countLabel.text = string;
    
    self.prepareShow = YES;
    CGFloat timeInterval = 2+kStartPrepareAnimationDuration;
    if (self.prepareTimer) {
        [self.prepareTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
        return;
    }
    
    self.prepareTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                         target:self
                                                       selector:@selector(dismissPrepareAnimation)
                                                       userInfo:nil
                                                        repeats:NO];
    [self startPrepareAnimation];
}

- (void)startPrepareAnimation {
    // Scale animation
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(0);
    scaleAnimation.toValue = @(1);
    scaleAnimation.duration = 0.2;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    // Opacity animation
    CABasicAnimation *opacityAnimaton = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimaton.fromValue = @(0);
    opacityAnimaton.toValue = @(1);
    opacityAnimaton.duration = 0.3;
    opacityAnimaton.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    // Animation
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, opacityAnimaton];
    animation.duration = kStartPrepareAnimationDuration;
    [self.countLabel.layer addAnimation:animation forKey:@"prepareAnimation"];
}
- (void)dismissPrepareAnimation {
    // Opacity animation
    self.countLabel.alpha = 0;
    CABasicAnimation *opacityAnimaton = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimaton.fromValue = @(1);
    opacityAnimaton.toValue = @(0);
    opacityAnimaton.duration = kDismissPrepareAnimationDuration;
    opacityAnimaton.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.countLabel.layer addAnimation:opacityAnimaton forKey:@"opacityAnimaton"];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDismissPrepareAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.countLabel removeFromSuperview];
        weakSelf.prepareShow = NO;
    });
}

- (void)dismissPrepareAndShow {
    CFTimeInterval duration = 1.0f;
    // Opacity animation
    self.countLabel.alpha = 0;
    CAKeyframeAnimation *opacityAnimaton = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimaton.keyTimes = @[@(0), @(0.35), @(0.5)];
    opacityAnimaton.values = @[@(1), @(1), @(0)];
    opacityAnimaton.duration = duration;
    opacityAnimaton.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [self.countLabel.layer addAnimation:opacityAnimaton forKey:@"PrepareDismissAnimation"];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.prepareShow = NO;
        weakSelf.countDownNumber -= 1;
        [weakSelf beginAnimation];
    });
}

#pragma mark - countDonw animation

- (void)startAnimationWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    self.completionHandler = completionHandler;
    self.isAnimating = YES;
    self.countDownNumber = self.count;
    
    if (self.prepareShow) {
        [self.prepareTimer invalidate];
        self.prepareTimer = nil;
        [self dismissPrepareAndShow];
        return;
    }
    [self beginAnimation];
}

- (void)beginAnimation {
    [self.contentView addSubview:self.countLabel];
    [self countDownAnimation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(countDownTimerFired)];
        if ([self.timer respondsToSelector:@selector(setPreferredFramesPerSecond:)]) {
            [self.timer setPreferredFramesPerSecond:1];
        }else {
            self.timer.frameInterval = 60;
        }
        [self.timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    });
}


- (void)countDownTimerFired
{
    self.countDownNumber -= 1;
    self.countLabel.text = self.countDownNumber < 1 ? @"":[NSString stringWithFormat:@"%ld",(long)self.countDownNumber];
    
    //倒计时完成后停止定时器，移除动画
    if (self.countDownNumber < 1) {
        [self.countLabel removeFromSuperview];
        [self.countLabel.layer removeAllAnimations];
        
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
            self.isAnimating = NO;
            if (self.completionHandler) {
                self.completionHandler(YES);
            }
        }
    }
}

- (void)countDownAnimation
{
    CFTimeInterval duration = 1.0f;
    CFTimeInterval beginTime = CACurrentMediaTime();
    
    // Scale animation
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.keyTimes =@[@(0), @(0.1), @(0.2)];
    scaleAnimation.values = @[@(0), @(0.5), @(1)];
    scaleAnimation.duration = duration;
    
    // Opacity animation
    CAKeyframeAnimation *opacityAnimaton = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimaton.keyTimes = @[@(0), @(0.3), @(0.35), @(0.5)];
    opacityAnimaton.values = @[@(0),@(1), @(1), @(0)];
    opacityAnimaton.duration = duration;
    
    // Animation
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, opacityAnimaton];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = duration;
    animation.repeatCount = HUGE;
    animation.beginTime = beginTime;
    
    [self.countLabel.layer addAnimation:animation forKey:@"animation"];
    [self.contentView.layer addSublayer:self.countLabel.layer];
}


- (void)cancelAnimation
{
    if (self.timer) {
        [self.countLabel removeFromSuperview];
        [self.countLabel.layer removeAllAnimations];
        [self.timer invalidate];
        self.timer = nil;
        self.isAnimating = NO;
        if (self.completionHandler) {
            self.completionHandler(NO);
        }
    }
}

@end
