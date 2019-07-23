//
//  UIImage+Utility.h
//  RecordSDK
//
//  Created by Allen on 10/12/13.
//  Copyright (c) 2013 RecordSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (Utility)
- (UIImage *)autoVersionedStretchableImageWithLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight;
- (UIImage *)scaleImageWithWidth:(float)sWidth height:(float)sHeight;
- (UIImage *)scaleAspectFitImageWithWidth:(float)width height:(float)height;

/**
 *@根据fillColor、strokeColor、width、gridSize等生成一有格子的图片
 *@fillColor:生成图片的背景色
 *@strokeColor：格子线的颜色
 *@width：格子线的宽度
 *@gridCount：格子的行列数
 *@borderLineControl：控制整个格子最外面一圈要不要stroke，UIEdgeInset的top、left、bottom、right分别控制这四个方向有没有线
 */
+ (UIImage *)imageWithSize:(CGSize)size fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor strokeWidth:(CGFloat)width gridCount:(CGSize)gridCount borderLineControl:(UIEdgeInsets)borderControl;

- (UIImage *) imageWithTintColor:(UIColor *)tintColor;
//合成两张图片
+ (UIImage *)addTwoImageToOne:(UIImage *)oneImg twoImage:(UIImage *)twoImg topleft:(CGPoint)tlPos;

//缩放一张图片的两侧，避开中间区域, from1,to1, from2, to2都是比例不是具体的数字
- (UIImage *)resizedImageToWidth:(CGFloat)width tiledAreaFrom:(CGFloat)from1 to:(CGFloat)to1 andFrom:(CGFloat)from2 to:(CGFloat)to2;
//从gif图片获取一张静态图片
+ (UIImage *)getGIFStaticPhoto:(NSData *)data;
//生成一张虚线图片
+ (UIImage *)dashlineImageWithStrokeColor:(UIColor *)color imageWidth:(CGFloat)imgWidth lineWidth:(CGFloat)width dashedLength:(CGFloat)length dashedGap:(CGFloat)gap;

//截取正方形的图片 centerBool为YES  表示从中心开始截取
+ (UIImage*)getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect centerBool:(BOOL)centerBool;

+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect;

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;

@end
