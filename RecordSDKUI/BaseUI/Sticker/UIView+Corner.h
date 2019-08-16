//
//  UIView+Corner.h
//  MomoChat
//
//  Created by MOMO on 2018/8/13.
//  Copyright © 2018年 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Corner)

/**
 设置圆角位置以及圆角半径
 
 @param corners 圆角位置
 @param radius 圆角半径
 */
- (void)setCornerType:(UIRectCorner)corners cornerRadius:(CGFloat)radius;

@end
