//
//  UIImage+MDUtility.m
//  RecordSDK
//
//  Created by 杜林 on 16/1/22.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "UIImage+MDUtility.h"

@implementation UIImage (MDUtility)

//纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color finalSize:(CGSize)size
{
    return [UIImage imageWithColor:color finalSize:size cornerRadius:0];
}

+ (UIImage *)imageWithColor:(UIColor *)color finalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius
{
    if (!color) {
        color = [UIColor clearColor];
    }
    
    UIImage *img = nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)imageWithColor:(UIColor *)color finalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius byRoundingCorners:(UIRectCorner)corners
{
    if (!color) {
        color = [UIColor clearColor];
    }
    
    UIImage *img = nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)] addClip];
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)imageWithColor:(UIColor *)color finalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor
{
    if (!color) {
        color = [UIColor clearColor];
    }
    
    UIImage *img = nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGRect rect_inner = CGRectMake(lineWidth, lineWidth, size.width-2*lineWidth, size.height-2*lineWidth);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    CGContextSetFillColorWithColor(context,lineColor.CGColor);
    CGContextFillRect(context, rect);
    [[UIBezierPath bezierPathWithRoundedRect:rect_inner cornerRadius:cornerRadius-lineWidth] addClip];
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect_inner);
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}

//带圆角纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color physicalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius
{
    if (!color) {
        color = [UIColor clearColor];
    }
    
    UIImage *img = nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)imageWithAlpha:(CGFloat)alpha finalSize:(CGSize)size
{
    return [self convertImageInSize:size alpha:alpha willDrawTask:nil didDrawTask:nil];
}

- (UIImage *)imageScaled:(CGFloat)scaled
{
    CGSize scaledSize = CGSizeMake(self.size.width *scaled, self.size.height *scaled);
    UIGraphicsBeginImageContextWithOptions(scaledSize, NO, [UIScreen mainScreen].scale);
    
    CGRect rect = CGRectMake(0, 0, scaledSize.width, scaledSize.height);
    [self drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

- (UIImage *)scaleImageToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [self drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

- (UIImage *)resizableImageWithTileModel
{
    CGFloat halfWidth = self.size.width *0.5f;
    CGFloat halfHeight = self.size.height *0.5f;
    //不留中间1单位的空间，图片中间会开裂
    UIEdgeInsets capInsets = UIEdgeInsetsMake(halfHeight -1, halfWidth -1, halfHeight, halfWidth);
    
    return [self resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeTile];
}

@end
