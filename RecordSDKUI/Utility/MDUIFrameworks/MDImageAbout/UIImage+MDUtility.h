//
//  UIImage+MDUtility.h
//  RecordSDK
//
//  Created by 杜林 on 16/1/22.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+MDBase.h"
#import "UIImage+ClipScaleRect.h"
#import "UIImage+ClipScaleCircle.h"
#import "UIImage+Bubble.h"
#import "UIImage+MDBlur.h"

@interface UIImage (MDUtility)

//纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color finalSize:(CGSize)size;
//带圆角纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color finalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius;
+ (UIImage *)imageWithColor:(UIColor *)color finalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius byRoundingCorners:(UIRectCorner)corners;
+ (UIImage *)imageWithColor:(UIColor *)color finalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor;
/**
 *  这个传入的是图片的点值，不是像素值，scale 自动适配
 *
 *  @param color        颜色
 *  @param size         size 的点值
 *  @param cornerRadius 半径 的点值
 *
 *  @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color physicalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

//把图片半透明
- (UIImage *)imageWithAlpha:(CGFloat)alpha finalSize:(CGSize)size;

//按照原比例缩放图片
- (UIImage *)imageScaled:(CGFloat)scaled;

- (UIImage *)scaleImageToSize:(CGSize)size;

//使用新接口拉伸9宫格图片，防止iphone设置粗体显示的时候，会导致图片中间裂开
- (UIImage *)resizableImageWithTileModel;

@end
