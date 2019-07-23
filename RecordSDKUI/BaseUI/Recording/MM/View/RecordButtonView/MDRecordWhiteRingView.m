//
//  MDRecordWhiteRingView.m
//  MDChat
//
//  Created by YZK on 2017/7/25.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDRecordWhiteRingView.h"
#import "MDRecordHeader.h"

const CGFloat kMDRecordWhiteRingViewLineWidth = 5.0f;

@interface MDRecordWhiteRingView ()
@property (nonatomic, strong) CAShapeLayer *ringLayer;

@end

@implementation MDRecordWhiteRingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat lineWidth = kMDRecordWhiteRingViewLineWidth;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2.0, self.height/2.0) radius:(self.width-lineWidth)/2.0 startAngle:0 endAngle:M_PI*2 clockwise:YES];
        
        CAShapeLayer *ringLayer = [CAShapeLayer layer];
        ringLayer.frame = self.bounds;
        ringLayer.fillColor = [UIColor clearColor].CGColor;
        ringLayer.strokeColor = [UIColor whiteColor].CGColor;
        ringLayer.lineWidth = lineWidth;
        ringLayer.path = path.CGPath;
        [self.layer addSublayer:ringLayer];
        self.ringLayer = ringLayer;
    }
    return self;
}

@end
