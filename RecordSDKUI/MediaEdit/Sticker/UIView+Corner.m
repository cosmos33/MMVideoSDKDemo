//
//  UIView+Corner.m
//  MomoChat
//
//  Created by MOMO on 2018/8/13.
//  Copyright © 2018年 wemomo.com. All rights reserved.
//

#import "UIView+Corner.h"

@implementation UIView (Corner)

- (void)setCornerType:(UIRectCorner)corners cornerRadius:(CGFloat)radius
{
    UIBezierPath    * bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                         byRoundingCorners:corners
                                                               cornerRadii:CGSizeMake(radius*2, radius*2)];
    CAShapeLayer    * shapedLayer = [CAShapeLayer layer];
    shapedLayer.path = bezierPath.CGPath;
    shapedLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.layer.mask = shapedLayer;
}

@end
