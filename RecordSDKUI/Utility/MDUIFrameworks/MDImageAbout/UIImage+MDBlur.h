//
//  UIImage+MDBlur.h
//  RecordSDK
//
//  Created by 杜林 on 16/3/25.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MDBlur)

//直播动态样式，白色高斯模糊底部, 上部遮罩图片
- (UIImage *)blurLiveResourceImageWithFinalSize:(CGSize)fSize
                                       blurRect:(CGRect)blurRect
                                   cornerRadius:(CGFloat)cornerRadius
                                        topMask:(UIImage *)topMask;
//直播动态样式，白色高斯模糊底部，上部纯色遮罩
- (UIImage *)blurLiveResourceImageWithFinalSize:(CGSize)fSize
                                       blurRect:(CGRect)blurRect
                                   cornerRadius:(CGFloat)cornerRadius
                               topMaskTintColor:(UIColor *)topMaskTintColor;


//高斯模糊任意图片区域，并缩放至fsize
- (UIImage *)blurClipImageWithFinalSize:(CGSize)fSize
                               blurRect:(CGRect)blurRect
                           cornerRadius:(CGFloat)cornerRadius
                             blurRadius:(CGFloat)blurRadius
                              tintColor:(UIColor *)tintColor
                  saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                              maskImage:(UIImage *)maskImage;

@end
