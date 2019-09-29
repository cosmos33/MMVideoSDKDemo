//
//  MDRecordCircleStrokenView.m
//  MDChat
//
//  Created by YZK on 2017/6/19.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDRecordCircleStrokenView.h"
#import "MDRecordHeader.h"

@interface MDRecordCircleStrokenView ()
@property (nonatomic,strong) CAShapeLayer *progressLayer;
@end

@implementation MDRecordCircleStrokenView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createGrandientCircle];
        [self setProgress:0.0];
    }
    return self;
}

- (void)createGrandientCircle {
    CGFloat lineWidth = 5;
    
    UIColor *color1 = RGBCOLOR(0, 175, 255);
    UIColor *color2 = RGBCOLOR(158, 30, 255);
    UIColor *color3 = RGBCOLOR(255, 185, 0);
    UIColor *color4 = RGBCOLOR(226, 48, 92);
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CALayer *gradientLayer = [CALayer layer];
    gradientLayer.frame = self.bounds;
    
    CAGradientLayer *gradientLayer1 = [CAGradientLayer layer];
    gradientLayer1.frame = CGRectMake(width/2.0, 0, width/2.0,  height);
    gradientLayer1.colors = @[(__bridge id)color1.CGColor, (__bridge id)color2.CGColor, (__bridge id)color3.CGColor];
    gradientLayer1.startPoint = CGPointMake(0.5, 0);
    gradientLayer1.endPoint = CGPointMake(0.5, 1);
    [gradientLayer addSublayer:gradientLayer1];
    
    CAGradientLayer *gradientLayer2 = [CAGradientLayer layer];
    gradientLayer2.frame = CGRectMake(0, 0, width/2.0, height);
    gradientLayer2.colors = @[(__bridge id)color3.CGColor, (__bridge id)color4.CGColor, (__bridge id)color1.CGColor];
    gradientLayer2.startPoint = CGPointMake(0.5, 1);
    gradientLayer2.endPoint = CGPointMake(0.5, 0);
    [gradientLayer addSublayer:gradientLayer2];
    
    [self.layer addSublayer:gradientLayer];
    
    
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.frame = self.bounds;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    progressLayer.strokeColor = [UIColor redColor].CGColor;
    progressLayer.lineWidth = lineWidth;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:self.frame.size.width/2.0 - lineWidth/2 startAngle:-M_PI_2 endAngle:-M_PI_2+M_PI*2 clockwise:YES];
    progressLayer.path = path.CGPath;
    gradientLayer.mask = progressLayer;
    self.progressLayer = progressLayer;
}

- (void)setProgress:(CGFloat)progress {
    progress = MIN(1, MAX(0, progress));
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.progressLayer.strokeEnd = progress;
    [CATransaction commit];
}

- (void)setProgress:(CGFloat)progress animatedWithDuration:(NSTimeInterval)duration {
    progress = MIN(1, MAX(0, progress));
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    self.progressLayer.strokeEnd = progress;
    [CATransaction commit];
}

@end
