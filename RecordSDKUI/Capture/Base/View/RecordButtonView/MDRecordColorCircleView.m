//
//  MDRecordColorCircleView.m
//  MDChat
//
//  Created by YZK on 2017/6/19.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDRecordColorCircleView.h"
#import <POP/POP.h>
#import "MDRecordHeader.h"

const CGFloat kRecordColorCircleViewLineWidth = 3.0f;

@interface MDRecordColorCircleView ()
@property (nonatomic,strong) CAGradientLayer *colorLayer;
@property (nonatomic,strong) CAShapeLayer *maskLayer;
@property (nonatomic,assign) CGRect originFrame;
@end

@implementation MDRecordColorCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = self.width/2;
        self.layer.masksToBounds = YES;
        
        UIColor *color1 = RGBCOLOR(0, 175, 255);
        UIColor *color2 = RGBCOLOR(158, 30, 255);
        
        CAGradientLayer *colorLayer = [CAGradientLayer layer];
        colorLayer.frame = self.bounds;
        colorLayer.startPoint = CGPointMake(1, 1);
        colorLayer.endPoint = CGPointMake(0, 0);
        colorLayer.colors = @[(__bridge id)color1.CGColor, (__bridge id)color2.CGColor];
        [self.layer addSublayer:colorLayer];
        self.colorLayer = colorLayer;
        
        
        CGFloat lineWidth = kRecordColorCircleViewLineWidth;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2.0, self.width/2.0) radius:self.width/2.0 startAngle:-M_PI_2 endAngle:-M_PI_2+M_PI*2 clockwise:YES];

        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.bounds;
        maskLayer.fillColor = [UIColor clearColor].CGColor;
        maskLayer.strokeColor = [UIColor redColor].CGColor;
        maskLayer.lineWidth = lineWidth*2;
        maskLayer.path = path.CGPath;
        self.maskLayer = maskLayer;
        self.colorLayer.mask = maskLayer;
    }
    return self;
}

- (void)beginAniamtion {
    if ([self.colorLayer animationForKey:@"color"]) {
        return;
    }
    
    UIColor *color1 = RGBCOLOR(0, 175, 255);
    UIColor *color2 = RGBCOLOR(158, 30, 255);
    UIColor *color3 = RGBCOLOR(255, 185, 0);
    UIColor *color4 = RGBCOLOR(226, 48, 92);
    
    CAKeyframeAnimation *keyAni = [CAKeyframeAnimation animation];
    keyAni.keyPath = @"colors";
    keyAni.duration = 5;
    keyAni.values = @[
                      @[(__bridge id)color1.CGColor, (__bridge id)color2.CGColor],
                      @[(__bridge id)color2.CGColor, (__bridge id)color3.CGColor],
                      @[(__bridge id)color3.CGColor, (__bridge id)color4.CGColor],
                      @[(__bridge id)color4.CGColor, (__bridge id)color1.CGColor],
                      @[(__bridge id)color1.CGColor, (__bridge id)color2.CGColor],
                      ];
    keyAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    keyAni.repeatCount = HUGE_VALF;
    [self.colorLayer addAnimation:keyAni forKey:@"color"];
}
- (void)endAnimation {
    [self.colorLayer removeAllAnimations];
}


- (void)beginLineWidthAnimation {
    if ([self.maskLayer animationForKey:@"lineWidth"]) {
        return;
    }
    
    CGAffineTransform transform = self.transform;
    CGFloat scale = transform.a;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"lineWidth";
    animation.fromValue = @(kRecordColorCircleViewLineWidth*2/scale);
    animation.toValue = @(5*2);
    animation.duration = 1;
    animation.repeatCount = HUGE_VALF;
    animation.autoreverses = YES;
    [self.maskLayer addAnimation:animation forKey:@"lineWidth"];
}
- (void)endLineWidthAnimation {
    [self.maskLayer removeAllAnimations];
}

@end
