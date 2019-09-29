//
//  UIImage+MDBase.h
//  RecordSDK
//
//  Created by 杜林 on 16/2/1.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^convertTaskBlock)(CGContextRef context, CGRect rect);

@interface UIImage (MDBase)

+ (void)md_setClipOptimizeEnable:(BOOL)en;

/*
 * 对图片处理的基类方法，所有图片处理都基于该方法
 */
- (UIImage *)convertImageInSize:(CGSize)size willDrawTask:(convertTaskBlock)willDraw didDrawTask:(convertTaskBlock)didDraw;
- (UIImage *)convertImageInSize:(CGSize)size alpha:(CGFloat)alpha willDrawTask:(convertTaskBlock)willDraw didDrawTask:(convertTaskBlock)didDraw;
- (UIImage *)convertImageInSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor alpha:(CGFloat)alpha willDrawTask:(convertTaskBlock)willDraw didDrawTask:(convertTaskBlock)didDraw;

/*
 * 给图片添加蒙层
 */
- (void)addMaskWithTintColor:(UIColor *)tintColor inContext:(CGContextRef)context rect:(CGRect)rect;

/*
 * 给图片绘制边框
 */
- (void)addBorderWithPath:(UIBezierPath *)bordPath borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

/*
 * 切割图片的基类方法，所有切割图片的处理，都基于该方法
 * 图像 不会 缩放至fSize，且不会产生形变，切割超出区域
 */
- (UIImage *)clipImageWithFinalSize:(CGSize)fSize;

/*
 * 截取指定矩形的图像
 * 切割图片的基类方法，所有切割图片的处理，都基于该方法
 * 图像 不会 缩放至rect.size，且不会产生形变，切割超出区域
 */
- (UIImage *)clipImageInRect:(CGRect)rect;

@end

