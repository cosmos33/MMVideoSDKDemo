//
//  UIImage+ClipScaleCircle.m
//  RecordSDK
//
//  Created by 杜林 on 16/3/29.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "UIImage+ClipScaleCircle.h"
#import "UIImage+MDBase.h"
#import "UIImage+ClipScaleRect.h"

@implementation UIImage (ClipScaleCircle)

#pragma mark - 获取圆形图片

//图像会产生形变
//缩放一个圆，至指定半径
- (UIImage *)scaleCircleWithRadius:(CGFloat)radius
{
    return [self scaleCircleWithRadius:radius
                       backgroundColor:nil
                                 alpha:1
                           borderColor:nil
                           borderWidth:0
                             tintColor:nil
                             maskImage:nil];
}

//缩放一个圆，可以带边框，纯色遮罩或者图片遮罩
//图像会产生形变
- (UIImage *)scaleCircleWithRadius:(CGFloat)radius
                   backgroundColor:(UIColor *)backgroundColor
                             alpha:(CGFloat)alpha
                       borderColor:(UIColor *)borderColor
                       borderWidth:(CGFloat)borderWidth
                         tintColor:(UIColor *)tintColor
                         maskImage:(UIImage *)maskImage
{
    CGSize size = CGSizeMake(radius *2, radius *2);
    
    return [self convertImageInSize:size backgroundColor:backgroundColor alpha:alpha willDrawTask:^(CGContextRef context, CGRect rect) {
        CGContextAddEllipseInRect(context, rect);
        CGContextClip(context);
    } didDrawTask:^(CGContextRef context, CGRect rect) {
        
        if (maskImage) {
            CGContextDrawImage(context, rect, maskImage.CGImage);
        }
        
        //添加蒙层
        [self addMaskWithTintColor:tintColor inContext:context rect:rect];
        
        //绘制边框
        if (borderColor && CGColorGetAlpha(borderColor.CGColor) > 0.f && borderWidth > 0.f) {
            UIBezierPath *bordPath = [self pathCircle:context rect:rect];
            [self addBorderWithPath:bordPath borderColor:borderColor borderWidth:borderWidth];
        }
        
    }];
}

//图像不会产生形变，但是超出部分不会显示，按长宽最小值缩放，切割超出区域
//切割一个圆
- (UIImage *)clipCircle
{
    return [self clipCircleBorderColor:nil
                       backgroundColor:nil
                                 alpha:1
                           borderWidth:0
                             tintColor:nil
                             maskImage:nil];
}

//缩放一个圆，可以带边框，纯色遮罩或者图片遮罩
//图像不会产生形变，但是超出部分不会显示，按长宽最小值缩放，切割超出区域
- (UIImage *)clipCircleBorderColor:(UIColor *)borderColor
                   backgroundColor:(UIColor *)backgroundColor
                             alpha:(CGFloat)alpha
                       borderWidth:(CGFloat)borderWidth
                         tintColor:(UIColor *)tintColor
                         maskImage:(UIImage *)maskImage
{
    CGFloat scale = self.scale;
    CGSize sSize = CGSizeMake(self.size.width *scale, self.size.height *scale);
    CGFloat radius = MIN(sSize.width *0.5f, sSize.height *0.5f);
    CGSize size = CGSizeMake(radius *2, radius *2);
    
    UIImage *clipedImage = [self clipImageWithFinalSize:size backgroundColor:nil alpha:1 borderColor:nil borderWidth:0 cornerRadius:0 tintColor:tintColor maskImage:maskImage];
    
    return [clipedImage convertImageInSize:clipedImage.size backgroundColor:backgroundColor alpha:alpha willDrawTask:^(CGContextRef context, CGRect rect) {
        CGContextAddEllipseInRect(context, rect);
        CGContextClip(context);
    } didDrawTask:^(CGContextRef context, CGRect rect) {
        //绘制边框
        if (borderColor && CGColorGetAlpha(borderColor.CGColor) > 0.f && borderWidth > 0.f) {
            UIBezierPath *bordPath = [self pathCircle:context rect:rect];
            [self addBorderWithPath:bordPath borderColor:borderColor borderWidth:borderWidth*5];
        }
    }];
}

#pragma mark - path

- (UIBezierPath *)pathCircle:(CGContextRef)context rect:(CGRect)rect
{
    CGContextBeginPath(context);
    CGContextAddEllipseInRect(context, rect);
    CGContextClosePath(context);
    CGPathRef pathRef = CGContextCopyPath(context);
    UIBezierPath *bordPath = [UIBezierPath bezierPathWithCGPath:pathRef];
    CFRelease(pathRef);
    return bordPath;
}

@end
