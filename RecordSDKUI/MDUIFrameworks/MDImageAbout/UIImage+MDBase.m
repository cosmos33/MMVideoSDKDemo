//
//  UIImage+MDBase.m
//  RecordSDK
//
//  Created by 杜林 on 16/2/1.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "UIImage+MDBase.h"
#import "UIConst.h"
#import "UIImage+LargeImage.h"

@implementation UIImage (MDBase)

static BOOL __clipOptimizeEnable = NO;
+ (void)md_setClipOptimizeEnable:(BOOL)en
{
    __clipOptimizeEnable = en;
}

#pragma mark - 对图片处理的基类方法，所有图片处理都基于该方法

- (UIImage *)convertImageInSize:(CGSize)size willDrawTask:(convertTaskBlock)willDraw didDrawTask:(convertTaskBlock)didDraw
{
    return [self convertImageInSize:size backgroundColor:nil alpha:1 willDrawTask:willDraw didDrawTask:didDraw];
}

- (UIImage *)convertImageInSize:(CGSize)size alpha:(CGFloat)alpha willDrawTask:(convertTaskBlock)willDraw didDrawTask:(convertTaskBlock)didDraw
{
    return [self convertImageInSize:size backgroundColor:nil alpha:alpha willDrawTask:willDraw didDrawTask:didDraw];
}

- (UIImage *)convertImageInSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor alpha:(CGFloat)alpha willDrawTask:(convertTaskBlock)willDraw didDrawTask:(convertTaskBlock)didDraw
{
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGRect rect = {.size = size};
    
    CGFloat scale = 2.f;
    if (__clipOptimizeEnable)
    {
        scale = 1.f;
    }
    
    if (isFloatEqual(width, 0.f) || isFloatEqual(height, 0.f)) {
        return nil;
    }
    
    UIImage *downSizeImage = [self downsize];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAlpha(context, alpha);
    
    if (willDraw) {
        willDraw(context, rect);
    }
    
    CGContextTranslateCTM(context, 0.0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if (backgroundColor && CGColorGetAlpha(backgroundColor.CGColor) > 0.0) {
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, rect);
    }
    
    CGContextDrawImage(context, rect, downSizeImage.CGImage);
    
    
    if (didDraw) {
        didDraw(context, rect);
    }
    
    
    UIImage *imageConverted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageConverted;
}


#pragma mark - 添加蒙层

- (void)addMaskWithTintColor:(UIColor *)tintColor inContext:(CGContextRef)context rect:(CGRect)rect
{
    if (tintColor && CGColorGetAlpha(tintColor.CGColor) > 0.0) {
        CGContextSetFillColorWithColor(context, tintColor.CGColor);
        CGContextFillRect(context, rect);
    }
}

#pragma mark - 绘制边框

- (void)addBorderWithPath:(UIBezierPath *)borderPath borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth
{
    if ( borderPath && borderColor && CGColorGetAlpha(borderColor.CGColor) > 0.f && borderWidth > 0.f) {
        [borderColor setStroke];
        [borderPath setLineWidth:borderWidth];
        [borderPath stroke];
    }
}

#pragma mark - 切割图片的基类方法，所有切割图片的处理，都基于该方法

//图像 不会 缩放至fSize，且不会产生形变，切割超出区域
- (UIImage *)clipImageWithFinalSize:(CGSize)fSize
{
    CGRect clipRect = CGRectZero;
    CGImageRef clipRef;
    
    CGFloat scale = self.scale;
    CGSize sSize = CGSizeMake(self.size.width *scale, self.size.height *scale);
    
    CGFloat deltaW = sSize.width/fSize.width;
    CGFloat deltaH = sSize.height/fSize.height;
    
    if (deltaW < deltaH) {
        CGSize clipSize = CGSizeZero;
        clipSize.width = sSize.width;
        clipSize.height = deltaW *fSize.height;
        
        float deltaY = (sSize.height -clipSize.height)*0.5f;
        clipRect.origin.y = deltaY;
        clipRect.size = clipSize;
    }else{
        CGSize clipSize = CGSizeZero;
        clipSize.height = sSize.height;
        clipSize.width = deltaH *fSize.width;
        
        float deltaX = (sSize.width -clipSize.width )*0.5f;
        clipRect.origin.x = deltaX;
        clipRect.size = clipSize;
    }
    clipRef = CGImageCreateWithImageInRect(self.CGImage, clipRect);
    UIImage* smallImage = [UIImage imageWithCGImage:clipRef];
    if (clipRef) {
        CFRelease(clipRef);
    }
    
    return smallImage;
}

//图像 不会 缩放至rect.size，且不会产生形变，切割超出区域
- (UIImage *)clipImageInRect:(CGRect)rect
{
    CGFloat scale = self.scale;
    CGRect clipRect = rect;
    clipRect.size.width = rect.size.width *scale;
    clipRect.size.height = rect.size.height *scale;
    clipRect.origin.x = rect.origin.x *scale;
    clipRect.origin.y = rect.origin.y *scale;
    
    CGImageRef cgRef = self.CGImage;
    CGImageRef imageRef = CGImageCreateWithImageInRect(cgRef, clipRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}

@end
