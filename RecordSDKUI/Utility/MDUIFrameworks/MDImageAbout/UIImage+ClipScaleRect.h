//
//  UIImage+ClipScaleRect.h
//  RecordSDK
//
//  Created by 杜林 on 16/3/29.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

/*
 * 获取矩形图片
 */


#import <UIKit/UIKit.h>

@interface UIImage (ClipScaleRect)

- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius;

#pragma mark - clip

//截取指定矩形的图像
//截取后的图像会缩放至rect.size，且不会产生形变，但是超出部分不会显示，按最小比例缩放，切割超出区域
//切割并缩放一个矩形，并切圆角
- (UIImage *)clipImageInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

//图像会缩放至rect.size，且不会产生形变，但是超出部分不会显示，按最小比例缩放，切割超出区域
//切割并缩放一个矩形，并切圆角
- (UIImage *)clipImageWithFinalSize:(CGSize)fSize
                       cornerRadius:(CGFloat)cornerRadius;
////图像会缩放至rect.size，且不会产生形变，但是超出部分不会显示，按最小比例缩放，切割超出区域
// 切一个图片，特定角带圆角
- (UIImage *)clipImageWithFinalSize:(CGSize)fSize
                       cornerRadius:(CGFloat)cornerRadius
                    RoundingCorners:(UIRectCorner)cornerEnable;

//切割并缩放一个矩形，可以带圆角，边框，纯色遮罩或者图片遮罩
//图像会缩放至rect.size，且不会产生形变，但是超出部分不会显示，按最小比例缩放，切割超出区域
- (UIImage *)clipImageWithFinalSize:(CGSize)fSize
                    backgroundColor:(UIColor *)backgroundColor
                              alpha:(CGFloat)alpha
                        borderColor:(UIColor *)borderColor
                        borderWidth:(CGFloat)borderWidth
                       cornerRadius:(CGFloat)cornerRadius
                          tintColor:(UIColor *)tintColor
                          maskImage:(UIImage *)maskImage;

#pragma mark - scale

//图像会产生形变
//缩放一个矩形，至指定大小，并切圆角
- (UIImage *)scaleImageWithFinalSize:(CGSize)fSize
                        cornerRadius:(CGFloat)cornerRadius;

//图像会产生形变
//缩放一个矩形，可以带圆角，边框，纯色遮罩或者图片遮罩
- (UIImage *)scaleImageWithFinalSize:(CGSize)fSize
                     backgroundColor:(UIColor *)backgroundColor
                               alpha:(CGFloat)alpha
                         borderColor:(UIColor *)borderColor
                         borderWidth:(CGFloat)borderWidth
                        cornerRadius:(CGFloat)cornerRadius
                           tintColor:(UIColor *)tintColor
                           maskImage:(UIImage *)maskImage;

@end
