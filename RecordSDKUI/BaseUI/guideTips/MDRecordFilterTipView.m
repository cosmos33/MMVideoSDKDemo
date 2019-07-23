//
//  MDRecordFilterTipView.m
//  MDChat
//
//  Created by YZK on 2018/5/11.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDRecordFilterTipView.h"
#import "MDRecordHeader.h"

@interface MDRecordFilterTipView ()

@property (nonatomic, strong) UIImageView *upArrowView;
@property (nonatomic, strong) UIImageView *bottomArrowView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, copy) void (^completion)(void);

@end

@implementation MDRecordFilterTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.upArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moment_record_filter_tip_1"]];
        self.upArrowView.top = 200;
        self.upArrowView.centerX = self.width/2.0;
        [self addSubview:self.upArrowView];
        
        self.bottomArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moment_record_filter_tip_2"]];
        self.bottomArrowView.top = 200;
        self.bottomArrowView.centerX = self.width/2.0;
        [self addSubview:self.bottomArrowView];
        
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.upArrowView.bottom, self.width, 25)];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.textColor = [UIColor whiteColor];
        self.tipLabel.font = [UIFont systemFontOfSize:18];
        self.tipLabel.shadowColor = RGBACOLOR(0, 0, 0, 0.6f);
        self.tipLabel.shadowOffset = CGSizeMake(0, 0.5f);
        self.tipLabel.text = @"上滑切换滤镜";
        [self addSubview:self.tipLabel];
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:tgr];
    }
    return self;
}

- (void)showWithContainView:(UIView *)containView comletion:(void (^)(void))completion {
    [containView addSubview:self];
    
    self.completion = completion;
    
    [CATransaction begin];
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        animation.duration = 0.8;
        animation.values = @[@(1.0),@(0.4),@(1.0)];
        animation.keyTimes = @[@(0),@(0.6),@(1.0)];
        animation.repeatCount = HUGE_VAL;
        [self.upArrowView.layer addAnimation:animation forKey:@"opacityAnimation"];
    }
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        animation.duration = 0.8;
        animation.values = @[@(1.0),@(0.4),@(1.0)];
        animation.keyTimes = @[@(0),@(0.6),@(1.0)];
        animation.timeOffset = 0.3;
        animation.repeatCount = HUGE_VAL;
        [self.bottomArrowView.layer addAnimation:animation forKey:@"opacityAnimation"];
    }
    [CATransaction commit];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.superview) {
            [self dismiss];
        }
    });
}

- (void)dismiss {
    if (self.completion) {
        self.completion();
    }
    self.completion = nil;
    
    [self.upArrowView.layer removeAllAnimations];
    [self.bottomArrowView.layer removeAllAnimations];
    [self removeFromSuperview];
}


@end
