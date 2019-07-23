//
//  UIView+RoundCorner.m
//  SDKLive
//
//  Created by wqw on 16/2/27.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "UIView+RoundCorner.h"

#if !__has_feature(objc_arc)
#error UIView (RoundCorner) must be built with ARC.
#endif

@implementation UIView (RoundCorner)

- (void)roundCorners:(UIRectCorner)corners radius:(CGFloat)radius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
}

@end
