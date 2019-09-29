//
//  UIImage+MDBlur.m
//  RecordSDK
//
//  Created by 杜林 on 16/3/25.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "UIImage+MDBlur.h"
#import "UIImage+MDUtility.h"
#import "UIImageEffects.h"
#import "UIConst.h"

@implementation UIImage (MDBlur)

//直播动态样式，白色高斯模糊底部, 上部遮罩图片
- (UIImage *)blurLiveResourceImageWithFinalSize:(CGSize)fSize
                                       blurRect:(CGRect)blurRect
                                   cornerRadius:(CGFloat)cornerRadius
                                        topMask:(UIImage *)topMask
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.92];
    UIImage *clipedImage = [self clipImageWithFinalSize:fSize cornerRadius:0];
    UIImage *blured = [clipedImage blurImageWithBlurRect:blurRect Radius:30 tintColor:tintColor saturationDeltaFactor:1.8f maskImage:nil topMask:topMask topMaskTintColor:nil];
    return [blured scaleImageWithFinalSize:blured.size backgroundColor:nil alpha:1 borderColor:RGBCOLOR(232, 232, 232) borderWidth:1.0 cornerRadius:cornerRadius tintColor:nil maskImage:nil];
}

//直播动态样式，白色高斯模糊底部，上部纯色遮罩
- (UIImage *)blurLiveResourceImageWithFinalSize:(CGSize)fSize
                                       blurRect:(CGRect)blurRect
                                   cornerRadius:(CGFloat)cornerRadius
                               topMaskTintColor:(UIColor *)topMaskTintColor
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.92];
    UIImage *clipedImage = [self clipImageWithFinalSize:fSize cornerRadius:0];
    UIImage *blured = [clipedImage blurImageWithBlurRect:blurRect Radius:30 tintColor:tintColor saturationDeltaFactor:1.8f maskImage:nil topMask:nil topMaskTintColor:topMaskTintColor];
    return [blured imageWithCornerRadius:cornerRadius];
}

//高斯模糊图片任意区域，并在顶部加topmask遮罩
- (UIImage *)blurImageWithBlurRect:(CGRect)blurRect
                            Radius:(CGFloat)blurRadius
                         tintColor:(UIColor *)tintColor
             saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                         maskImage:(UIImage *)maskImage
                           topMask:(UIImage *)topMask
                  topMaskTintColor:(UIColor *)topMaskTintColor
{
    UIImage *thumbImage = [self clipImageInRect:blurRect];
    UIImage *blurImage = [UIImageEffects imageByApplyingBlurToImage:thumbImage withRadius:blurRadius tintColor:tintColor saturationDeltaFactor:saturationDeltaFactor maskImage:maskImage];
    
    UIImage *resizeTopImage = nil;
    CGRect drawTopRect = {.size = self.size};
    if (topMask) {
        //绘图的时候坐标y是翻转的
        drawTopRect.origin.y = self.size.height -blurRect.origin.y;
        drawTopRect.size.height = self.size.height -blurRect.size.height;
        resizeTopImage = [topMask scaleImageWithFinalSize:drawTopRect.size cornerRadius:0];
    }
    else if (!topMask && topMaskTintColor
             && CGColorGetAlpha(topMaskTintColor.CGColor) > 0.0) {
        resizeTopImage = [UIImage imageWithColor:topMaskTintColor finalSize:drawTopRect.size];
    }
    
    return [self convertImageInSize:self.size willDrawTask:nil didDrawTask:^(CGContextRef context, CGRect rect) {
        
        if (resizeTopImage) {
            CGContextDrawImage(context, drawTopRect, resizeTopImage.CGImage);
        }
        
        if (blurImage) {
            CGRect drawBlurRect = blurRect;
            //绘图的时候坐标y是翻转的
            drawBlurRect.origin.y = self.size.height -blurRect.size.height -blurRect.origin.y;
            
            CGContextDrawImage(context, drawBlurRect, blurImage.CGImage);
        }
        
    }];
}

#pragma mark - 高斯模糊图片任意区域，并缩放至fsize
- (UIImage *)blurClipImageWithFinalSize:(CGSize)fSize
                               blurRect:(CGRect)blurRect
                           cornerRadius:(CGFloat)cornerRadius
                             blurRadius:(CGFloat)blurRadius
                              tintColor:(UIColor *)tintColor
                  saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                              maskImage:(UIImage *)maskImage
{
    UIImage *clipedImage = [self clipImageWithFinalSize:fSize cornerRadius:0];
    UIImage *bluredImage = [clipedImage blurImageWithBlurRect:blurRect Radius:blurRadius tintColor:tintColor saturationDeltaFactor:saturationDeltaFactor maskImage:maskImage];
    return [bluredImage imageWithCornerRadius:cornerRadius];
    
}

- (UIImage *)blurImageWithBlurRect:(CGRect)blurRect
                            Radius:(CGFloat)blurRadius
                         tintColor:(UIColor *)tintColor
             saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                         maskImage:(UIImage *)maskImage
{
    UIImage *thumbImage = [self clipImageInRect:blurRect];
    UIImage *blurImage = [UIImageEffects imageByApplyingBlurToImage:thumbImage withRadius:blurRadius tintColor:tintColor saturationDeltaFactor:saturationDeltaFactor maskImage:maskImage];
    
    return [self convertImageInSize:self.size willDrawTask:nil didDrawTask:^(CGContextRef context, CGRect rect) {
        
        if (blurImage) {
            CGRect drawBlurRect = blurRect;
            //绘图的时候坐标y是翻转的
            drawBlurRect.origin.y = self.size.height -blurRect.size.height -blurRect.origin.y;
            
            CGContextDrawImage(context, drawBlurRect, blurImage.CGImage);
        }
        
    }];
}

@end
