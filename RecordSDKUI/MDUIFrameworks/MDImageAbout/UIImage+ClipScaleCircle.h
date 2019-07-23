//
//  UIImage+ClipScaleCircle.h
//  RecordSDK
//
//  Created by 杜林 on 16/3/29.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

/*
 * 获取圆形图片
 */

#import <UIKit/UIKit.h>

@interface UIImage (ClipScaleCircle)

//图像会产生形变
//缩放一个圆，至指定半径
- (UIImage *)scaleCircleWithRadius:(CGFloat)radius;
//图像会产生形变
//缩放一个圆，可以带边框，纯色遮罩或者图片遮罩
- (UIImage *)scaleCircleWithRadius:(CGFloat)radius
                   backgroundColor:(UIColor *)backgroundColor
                             alpha:(CGFloat)alpha
                       borderColor:(UIColor *)borderColor
                       borderWidth:(CGFloat)borderWidth
                         tintColor:(UIColor *)tintColor
                         maskImage:(UIImage *)maskImage;

//图像不会产生形变，但是超出部分不会显示，按长宽最小值缩放，切割超出区域
//切割一个圆
- (UIImage *)clipCircle;

//图像不会产生形变，但是超出部分不会显示，按长宽最小值缩放，切割超出区域
//切割一个圆，可以带边框，纯色遮罩或者图片遮罩
- (UIImage *)clipCircleBorderColor:(UIColor *)borderColor
                   backgroundColor:(UIColor *)backgroundColor
                             alpha:(CGFloat)alpha
                       borderWidth:(CGFloat)borderWidth
                         tintColor:(UIColor *)tintColor
                         maskImage:(UIImage *)maskImage;

@end
