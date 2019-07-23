//
//  MDUnifiedRecordButton.m
//  MDChat
//
//  Created by 符吉胜 on 2017/6/19.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordButton.h"
#import "MDRecordCircleStrokenView.h"
#import "MDRecordColorCircleView.h"
#import "MDRecordWhiteRingView.h"
#import "MDFaceDecorationImageView.h"
#import "MDRecordHeader.h"

const CGFloat kUnifiedRecordButtonInsetMargin = 20.0f;
const CGFloat kUnifiedRecordButtonActiveScale = 1.15f;


@interface MDUnifiedRecordButton ()
@property (nonatomic, assign) MDUnifiedRecordButtonType buttonType;

@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, strong) MDRecordWhiteRingView *whiteRingView;
@property (nonatomic, strong) MDRecordCircleStrokenView *strokenView;
@property (nonatomic, strong) MDRecordColorCircleView *colorCircleView;
@property (nonatomic, strong) MDFaceDecorationImageView *iconView;

@property (nonatomic, assign) BOOL longPressOutside;
@end

@implementation MDUnifiedRecordButton

- (instancetype)initWithFrame:(CGRect)frame andButtonType:(MDUnifiedRecordButtonType)buttonType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonType = buttonType;
        [self createSubViews];
        [self addGesture];
        
        self.layer.cornerRadius = self.bounds.size.width/2.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)addGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.5f;
    [self addGestureRecognizer:longPress];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [singleTap requireGestureRecognizerToFail:longPress];
    [self addGestureRecognizer:singleTap];
}

- (void)createSubViews {
    //毛玻璃
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView * blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.bounds;
    blurView.layer.cornerRadius = self.bounds.size.width/2.0;
    blurView.layer.masksToBounds = YES;
    [self addSubview:blurView];
    self.blurView = blurView;
    
    //白环
    self.whiteRingView = [[MDRecordWhiteRingView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    self.whiteRingView.center = CGPointMake(self.width/2, self.height/2);
    [self addSubview:self.whiteRingView];
    
    //进度条圈
    self.strokenView = [[MDRecordCircleStrokenView alloc] initWithFrame:self.whiteRingView.frame];
    self.strokenView.transform = CGAffineTransformMakeScale(kUnifiedRecordButtonActiveScale, kUnifiedRecordButtonActiveScale);
    [self addSubview:self.strokenView];
    
    //高级拍摄的彩圈
    self.colorCircleView = [[MDRecordColorCircleView alloc] initWithFrame:CGRectInset(self.bounds, kUnifiedRecordButtonInsetMargin, kUnifiedRecordButtonInsetMargin)];
    [self addSubview:self.colorCircleView];
    
    //中心变脸图标
    self.iconView = [[MDFaceDecorationImageView alloc] initWithFrame:CGRectMake(0, 0, 57, 57)];
    self.iconView.center = CGPointMake(self.width/2, self.height/2);
    self.iconView.hidden = YES;
    [self addSubview:self.iconView];

    
    if (self.buttonType == MDUnifiedRecordButtonTypeNormal) {
        self.whiteRingView.hidden = NO;
        self.strokenView.hidden = YES;

        self.blurView.hidden = YES;
        self.colorCircleView.hidden = YES;
    }else {
        self.whiteRingView.hidden = YES;
        self.strokenView.hidden = YES;

        self.blurView.hidden = NO;
        self.colorCircleView.hidden = NO;
    }
}

- (void)setActive:(BOOL)active {
    _active = active;
    [self updateUI];
}

- (void)setProgress:(CGFloat)progress {
    if (self.buttonType == MDUnifiedRecordButtonTypeNormal) {
        [self.strokenView setProgress:progress];
    }
}

- (void)resetNormalTypeActiveUI {
    self.whiteRingView.hidden = NO;
    self.whiteRingView.transform = CGAffineTransformIdentity;
    self.whiteRingView.alpha = 1;

    self.strokenView.hidden = NO;
    self.strokenView.alpha = 0;
    [self.strokenView setProgress:0];

    self.blurView.hidden = YES;
    self.colorCircleView.hidden = YES;
    
    self.iconView.hidden = YES;
    self.iconView.iconView.image = nil;
    self.iconView.transform = CGAffineTransformIdentity;
}
- (void)resetNormalTypeInActiveUI {
    self.whiteRingView.hidden = NO;
    
    self.strokenView.hidden = YES;
    
    self.blurView.hidden = YES;
    self.colorCircleView.hidden = YES;
    
    if (self.iconView.iconView.image) {
        self.iconView.hidden = NO;
        self.iconView.alpha = 1;
    }else {
        self.iconView.hidden = YES;
    }
}

- (void)updateUI {
    
    if (self.buttonType == MDUnifiedRecordButtonTypeNormal) {
        [self updateUIWithNormalType];
    }else {
        [self updateUIWithHighType];
    }
}

- (void)updateUIWithNormalType {

    if (self.active) {
        [self resetNormalTypeActiveUI];

        if ([self.delegate respondsToSelector:@selector(getCurrentIconUrl)]) {
            NSString *iconUrl = [self.delegate getCurrentIconUrl];
            if ([iconUrl isNotEmpty]) {
                self.iconView.hidden = NO;
                self.iconView.alpha = 1.0f;
#warning sunfei image
//                [self.iconView.iconView setImageWithURL:[NSURL URLWithString:iconUrl] effect:SDWebImageEffectCircle];
                [self.iconView.iconView sd_setImageWithURL:[NSURL URLWithString:iconUrl]];
            }
        }
        
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                self.whiteRingView.alpha = 0.2;
            }];

            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                self.whiteRingView.transform = CGAffineTransformMakeScale(0.65, 0.65);
                self.iconView.transform = CGAffineTransformMakeScale(0.7, 0.7);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.4 animations:^{
                self.whiteRingView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                self.iconView.transform = CGAffineTransformMakeScale(0.9, 0.9);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
                self.whiteRingView.transform = CGAffineTransformMakeScale(kUnifiedRecordButtonActiveScale, kUnifiedRecordButtonActiveScale);
            }];
        } completion:^(BOOL finished) {
            self.strokenView.alpha = 1.0;
        }];
    }else {
        [self resetNormalTypeInActiveUI];
        [UIView animateWithDuration:0.1 animations:^{
            self.iconView.alpha = 0;
            self.whiteRingView.transform = CGAffineTransformIdentity;
            self.whiteRingView.alpha = 1;

        } completion:^(BOOL finished) {
            self.iconView.hidden = YES;
        }];
    }
}

- (void)updateUIWithHighType {
    self.whiteRingView.hidden = YES;
    self.strokenView.hidden = YES;
    self.colorCircleView.hidden = NO;
    
    if (self.active) {
        self.colorCircleView.transform = CGAffineTransformIdentity;
        [self.colorCircleView beginAniamtion];
        
        CGFloat endScale = self.width/self.colorCircleView.width;
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.35 animations:^{
                self.colorCircleView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.35 relativeDuration:0.55 animations:^{
                self.colorCircleView.transform = CGAffineTransformMakeScale(endScale+0.2, endScale+0.2);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
                self.colorCircleView.transform = CGAffineTransformMakeScale(endScale, endScale);
            }];
        } completion:^(BOOL finished) {
            [self.colorCircleView beginLineWidthAnimation];
        }];
    }else {
        [self.colorCircleView endLineWidthAnimation];
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                self.colorCircleView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.4 animations:^{
                self.colorCircleView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
                self.colorCircleView.transform = CGAffineTransformIdentity;
            }];
        } completion:^(BOOL finished) {
        }];
    }
    
}

- (void)setOffsetPercentage:(CGFloat)percentage withTargetButtonType:(MDUnifiedRecordButtonType)buttonType
{
    if (self.buttonType == buttonType) {
        return;
    }
    
    percentage = MIN(1.0, MAX(0.0, percentage));
        
    if (buttonType == MDUnifiedRecordButtonTypeHigh) {
        
        //白环缩小
        self.whiteRingView.hidden = NO;
        CGFloat whiteRingscale = self.colorCircleView.bounds.size.width/self.whiteRingView.bounds.size.width;
        if (percentage < 0.9) {
            whiteRingscale = 1 + (whiteRingscale - 1) * percentage / 0.9;
        }
        self.whiteRingView.transform = CGAffineTransformMakeScale(whiteRingscale, whiteRingscale);
        
        //白环渐隐
        CGFloat whiteRingAlpha = 1;
        if (percentage > 0.9) {
            whiteRingAlpha = 1 + (0 - 1) * (percentage-0.9)/0.1;
        }
        self.whiteRingView.alpha = whiteRingAlpha;
        
        //毛玻璃显示动画
        self.blurView.hidden = NO;
        CGFloat blurScale = self.colorCircleView.bounds.size.width/self.blurView.bounds.size.width;
        blurScale = blurScale + (1 - blurScale) * percentage;
        self.blurView.transform = CGAffineTransformMakeScale(blurScale, blurScale);
        CGFloat blurAlpha = 0 + (1 - 0) * percentage;
        self.blurView.alpha = blurAlpha;

        //彩环显示动画
        self.colorCircleView.hidden = NO;
        CGFloat colorCircleAlpha = 0;
        if (percentage > 0.9) {
            colorCircleAlpha = 0 + (1 - 0) * (percentage-0.9)/0.1;
        }
        self.colorCircleView.alpha = colorCircleAlpha;
    }else {
        //白环放大
        self.whiteRingView.hidden = NO;
        CGFloat whiteRingscale = self.colorCircleView.bounds.size.width/self.whiteRingView.bounds.size.width;
        if (percentage > 0.1) {
            whiteRingscale = whiteRingscale + (1 - whiteRingscale) * (percentage-0.1) / 0.9;
        }
        self.whiteRingView.transform = CGAffineTransformMakeScale(whiteRingscale, whiteRingscale);
        
        //白环渐现
        CGFloat whiteRingAlpha = 1;
        if (percentage < 0.1) {
            whiteRingAlpha = 0 + (1 - 0) * percentage/0.1;
        }
        self.whiteRingView.alpha = whiteRingAlpha;
        
        //毛玻璃消失动画
        self.blurView.hidden = NO;
        CGFloat blurScale = self.colorCircleView.bounds.size.width/self.blurView.bounds.size.width;
        blurScale = 1 + (blurScale - 1) * percentage;
        self.blurView.transform = CGAffineTransformMakeScale(blurScale, blurScale);
        CGFloat blurAlpha = 1 + (0 - 1) * percentage;
        self.blurView.alpha = blurAlpha;
        
        //彩环消失动画
        self.colorCircleView.hidden = NO;
        CGFloat alpha = 0;
        if (percentage < 0.1) {
            alpha = 1 + (0 - 1) * percentage/0.1;
        }
        self.colorCircleView.alpha = alpha;
    }
}

- (void)setCurrentButtonType:(MDUnifiedRecordButtonType)buttonType
{
    self.buttonType = buttonType;
    
    if (self.buttonType == MDUnifiedRecordButtonTypeNormal) {

        self.whiteRingView.hidden = NO;
        CGFloat blurScale = self.colorCircleView.bounds.size.width/self.blurView.bounds.size.width;
        
        [UIView animateWithDuration:0.1 animations:^{
            //白环放大
            self.whiteRingView.transform = CGAffineTransformIdentity;
            //白环渐现
            self.whiteRingView.alpha = 1;
            //毛玻璃消失动画
            self.blurView.transform = CGAffineTransformMakeScale(blurScale, blurScale);
            self.blurView.alpha = 0;
            //彩环消失动画
            self.colorCircleView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.colorCircleView endAnimation];
            self.colorCircleView.hidden = YES;
            self.blurView.hidden = YES;
        }];
        
    } else {
        
        self.colorCircleView.hidden = NO;
        self.blurView.hidden = NO;
        CGFloat whiteRingscale = self.colorCircleView.bounds.size.width/self.whiteRingView.bounds.size.width;
        
        [UIView animateWithDuration:0.1 animations:^{
            //白环缩小
            self.whiteRingView.transform = CGAffineTransformMakeScale(whiteRingscale, whiteRingscale);;
            //白环渐隐
            self.whiteRingView.alpha = 0;
            //毛玻璃显示动画
            self.blurView.transform = CGAffineTransformIdentity;
            self.blurView.alpha = 1;
            //彩环显示动画
            self.colorCircleView.alpha = 1;
        } completion:^(BOOL finished) {
            self.whiteRingView.hidden = YES;
            [self.colorCircleView beginAniamtion];
        }];
    }
}

#pragma mark - event response

- (void)tap {
    if ([self.delegate respondsToSelector:@selector(didTapRecordButton)]) {
        [self.delegate didTapRecordButton];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.longPressOutside = NO;
            if ([self.delegate respondsToSelector:@selector(didLongPressBegan)]) {
                [self.delegate didLongPressBegan];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            BOOL pointInside = CGRectContainsPoint(sender.view.bounds, point);
            if (!self.longPressOutside && !pointInside) {
                if ([self.delegate respondsToSelector:@selector(didLongPressDragExit)]) {
                    [self.delegate didLongPressDragExit];
                }
            }
            
            self.longPressOutside = !pointInside;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        {
            BOOL pointInside = CGRectContainsPoint(sender.view.bounds, point);
            
            if ([self.delegate respondsToSelector:@selector(didLongPressEnded:)]) {
                [self.delegate didLongPressEnded:pointInside];
            }
            self.longPressOutside = pointInside;
            break;
        }
        default:
            break;
    }
}

@end
