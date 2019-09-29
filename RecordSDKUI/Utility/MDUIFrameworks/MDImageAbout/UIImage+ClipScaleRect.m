//
//  UIImage+ClipScaleRect.m
//  RecordSDK
//
//  Created by 杜林 on 16/3/29.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "UIImage+ClipScaleRect.h"
#import "UIImage+MDBase.h"

@implementation UIImage (ClipScaleRect)

- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius
{
    return [self scaleImageWithFinalSize:self.size cornerRadius:cornerRadius];
}

#pragma mark - clip

//图像会缩放至rect.size，且不会产生形变，但是超出部分不会显示，按最小比例缩放，切割超出区域
//切割并缩放一个矩形，并切圆角
- (UIImage *)clipImageInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
    UIImage *clipedImage = [self clipImageInRect:rect];
    return [clipedImage scaleImageWithFinalSize:rect.size backgroundColor:nil alpha:1 borderColor:nil borderWidth:0 cornerRadius:cornerRadius tintColor:nil maskImage:nil];
}

//图像会缩放至rect.size，且不会产生形变，但是超出部分不会显示，按最小比例缩放，切割超出区域
//切割并缩放一个矩形，并切圆角
- (UIImage *)clipImageWithFinalSize:(CGSize)fSize
                       cornerRadius:(CGFloat)cornerRadius
{
    return [self clipImageWithFinalSize:fSize
                        backgroundColor:nil
                                  alpha:1
                            borderColor:nil
                            borderWidth:0
                           cornerRadius:cornerRadius
                              tintColor:nil
                              maskImage:nil];
}
//
- (UIImage *)clipImageWithFinalSize:(CGSize)fSize
                       cornerRadius:(CGFloat)cornerRadius
                    RoundingCorners:(UIRectCorner)roundingCorner {
    return [self clipImageWithFinalSize:fSize backgroundColor:nil alpha:1 borderColor:nil borderWidth:0 cornerRadius:cornerRadius tintColor:nil maskImage:nil roundingCorner:roundingCorner];
}

//切割并缩放一个矩形，可以带圆角，边框，纯色遮罩或者图片遮罩
//图像会缩放至rect.size，且不会产生形变，但是超出部分不会显示，按最小比例缩放，切割超出区域
- (UIImage *)clipImageWithFinalSize:(CGSize)fSize
                    backgroundColor:(UIColor *)backgroundColor
                              alpha:(CGFloat)alpha
                        borderColor:(UIColor *)borderColor
                        borderWidth:(CGFloat)borderWidth
                       cornerRadius:(CGFloat)cornerRadius
                          tintColor:(UIColor *)tintColor
                          maskImage:(UIImage *)maskImage
{
    UIImage* imageCliped = [self clipImageWithFinalSize:fSize];
    UIImage* maskCliped = [maskImage clipImageWithFinalSize:fSize];
    return [imageCliped scaleImageWithFinalSize:fSize backgroundColor:backgroundColor alpha:alpha borderColor:borderColor borderWidth:borderWidth cornerRadius:cornerRadius tintColor:tintColor maskImage:maskCliped];
}

- (UIImage *)clipImageWithFinalSize:(CGSize)fSize
                    backgroundColor:(UIColor *)backgroundColor
                              alpha:(CGFloat)alpha
                        borderColor:(UIColor *)borderColor
                        borderWidth:(CGFloat)borderWidth
                       cornerRadius:(CGFloat)cornerRadius
                          tintColor:(UIColor *)tintColor
                          maskImage:(UIImage *)maskImage
                       roundingCorner:(UIRectCorner)roundingCorner
{
    UIImage* imageCliped = [self clipImageWithFinalSize:fSize];
    UIImage* maskCliped = [maskImage clipImageWithFinalSize:fSize];
    return [imageCliped scaleImageWithFinalSize:fSize backgroundColor:backgroundColor alpha:alpha borderColor:borderColor borderWidth:borderWidth cornerRadius:cornerRadius tintColor:tintColor maskImage:maskCliped roundingCorners:roundingCorner];
}



#pragma mark - scale

//图像会产生形变
//缩放一个矩形，至指定大小，并切圆角
- (UIImage *)scaleImageWithFinalSize:(CGSize)fSize
                        cornerRadius:(CGFloat)cornerRadius
{
    return [self scaleImageWithFinalSize:fSize
                         backgroundColor:nil
                                   alpha:1
                             borderColor:nil
                             borderWidth:0
                            cornerRadius:cornerRadius
                               tintColor:nil
                               maskImage:nil];
}

//缩放一个矩形，可以带圆角，边框，纯色遮罩或者图片遮罩
//图像会产生形变
- (UIImage *)scaleImageWithFinalSize:(CGSize)fSize
                     backgroundColor:(UIColor *)backgroundColor
                               alpha:(CGFloat)alpha
                         borderColor:(UIColor *)borderColor
                         borderWidth:(CGFloat)borderWidth
                        cornerRadius:(CGFloat)cornerRadius
                           tintColor:(UIColor *)tintColor
                           maskImage:(UIImage *)maskImage
{
    return [self convertImageInSize:fSize backgroundColor:backgroundColor alpha:alpha willDrawTask:^(CGContextRef context, CGRect rect) {
        if (cornerRadius)
        {
            [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
        }
    } didDrawTask:^(CGContextRef context, CGRect rect) {
        
        if (maskImage) {
            CGContextDrawImage(context, rect, maskImage.CGImage);
        }
        
        //添加蒙层
        [self addMaskWithTintColor:tintColor inContext:context rect:rect];
        //绘制边框
        if (borderColor && CGColorGetAlpha(borderColor.CGColor) > 0.f && borderWidth > 0.f) {
            UIBezierPath *bordPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
            [self addBorderWithPath:bordPath borderColor:borderColor borderWidth:borderWidth];
        }
    }];
}

- (UIImage *)scaleImageWithFinalSize:(CGSize)fSize
                     backgroundColor:(UIColor *)backgroundColor
                               alpha:(CGFloat)alpha
                         borderColor:(UIColor *)borderColor
                         borderWidth:(CGFloat)borderWidth
                        cornerRadius:(CGFloat)cornerRadius
                           tintColor:(UIColor *)tintColor
                           maskImage:(UIImage *)maskImage
                        roundingCorners:(UIRectCorner)roundingCorner
{
    return [self convertImageInSize:fSize backgroundColor:backgroundColor alpha:alpha willDrawTask:^(CGContextRef context, CGRect rect) {
        if (roundingCorner)
        {
            [[UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:roundingCorner cornerRadii:CGSizeMake(cornerRadius, cornerRadius)] addClip];
        }
    } didDrawTask:^(CGContextRef context, CGRect rect) {
        
        if (maskImage) {
            CGContextDrawImage(context, rect, maskImage.CGImage);
        }
        
        //添加蒙层
        [self addMaskWithTintColor:tintColor inContext:context rect:rect];
        //绘制边框
        if (borderColor && CGColorGetAlpha(borderColor.CGColor) > 0.f && borderWidth > 0.f) {
            UIBezierPath *bordPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:roundingCorner cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
            [self addBorderWithPath:bordPath borderColor:borderColor borderWidth:borderWidth];
        }
    }];
}


@end
