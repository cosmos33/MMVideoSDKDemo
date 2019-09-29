//
//  UIImage+Bubble.m
//  RecordSDK
//
//  Created by 杜林 on 16/1/22.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "UIImage+Bubble.h"

@implementation UIImage (Bubble)

#pragma mark - left bubble image

- (UIImage *)convertLeftBubbleImageWithSize:(CGSize)size triangle:(CGSize)tSize offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY cornerRadius:(CGFloat)radius tintColor:(UIColor *)tintColor lineColor:(UIColor *)lineColor
{
    //生成描边的图片
    UIImage *lineImage = [[UIImage new] convertImageInSize:size willDrawTask:^(CGContextRef context, CGRect rect) {
        [self setupPathLeftBubbleSize:size triangle:tSize offsetX:offsetX offsetY:offsetY cornerRadius:radius context:context];
        
        if (lineColor && CGColorGetAlpha(lineColor.CGColor) > 0.0) {
            CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
            CGContextSetLineWidth(context, 1);
            CGContextStrokePath(context);
        }
    } didDrawTask:nil];
    
    UIImage *newImage = [self convertImageInSize:size willDrawTask:^(CGContextRef context, CGRect rect) {
        //切割图片
        [self setupPathLeftBubbleSize:size triangle:tSize offsetX:offsetX offsetY:offsetY cornerRadius:radius context:context];
        CGContextClip(context);
        
    } didDrawTask:^(CGContextRef context, CGRect rect) {
        //添加蒙层
        [self addMaskWithTintColor:tintColor inContext:context rect:rect];
        
        //把描边图片绘制在要显示的图片之上，形成图片描边
        CGContextDrawImage(context, rect, lineImage.CGImage);
    }];
    
    return newImage;
}


#pragma mark - right bubble image

- (UIImage *)convertRightBubbleImageWithSize:(CGSize)size triangle:(CGSize)tSize offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY cornerRadius:(CGFloat)radius tintColor:(UIColor *)tintColor lineColor:(UIColor *)lineColor
{
    //生成描边的图片
    UIImage *lineImage = [[UIImage new] convertImageInSize:size willDrawTask:^(CGContextRef context, CGRect rect) {
        [self setupPathRightBubbleSize:size triangle:tSize offsetX:offsetX offsetY:offsetY cornerRadius:radius context:context];
        
        if (lineColor && CGColorGetAlpha(lineColor.CGColor) > 0.0) {
            CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
            CGContextSetLineWidth(context, 1);
            CGContextStrokePath(context);
        }
    } didDrawTask:nil];
    
    
    UIImage *newImage = [self convertImageInSize:size willDrawTask:^(CGContextRef context, CGRect rect) {
        //切割图片
        [self setupPathRightBubbleSize:size triangle:tSize offsetX:offsetX offsetY:offsetY cornerRadius:radius context:context];
        CGContextClip(context);
        
    } didDrawTask:^(CGContextRef context, CGRect rect) {
        //添加蒙层
        [self addMaskWithTintColor:tintColor inContext:context rect:rect];
        
        //把描边图片绘制在要显示的图片之上，形成图片描边
        CGContextDrawImage(context, rect, lineImage.CGImage);
    }];
    
    return newImage;
}

#pragma mark - left path

- (void)setupPathLeftBubbleSize:(CGSize)size triangle:(CGSize)tSize offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY cornerRadius:(CGFloat)radius context:(CGContextRef)context{
    
    //bubble rect
    CGRect rect = CGRectMake(offsetX +tSize.width, 0, size.width -tSize.width -offsetX, size.height);
    //矩形顶点：从右至左，顺时针画
    CGPoint vertex[4];
    vertex[0] = CGPointMake(CGRectGetMaxX(rect) -radius, 0);//右上
    vertex[1] = CGPointMake(CGRectGetMaxX(rect), rect.size.height -radius);//右下
    vertex[2] = CGPointMake(rect.origin.x +radius, rect.size.height);//左下
    vertex[3] = CGPointMake(rect.origin.x, radius);//左上
    
    //圆角的圆心：从右至左，顺时针画
    CGPoint centers[4];
    centers[0] = CGPointMake(CGRectGetMaxX(rect) -radius, radius);//右上
    centers[1] = CGPointMake(CGRectGetMaxX(rect) -radius, rect.size.height -radius);//右下
    centers[2] = CGPointMake(rect.origin.x +radius, rect.size.height -radius);//左下
    centers[3] = CGPointMake(rect.origin.x +radius, radius);//左上
    
//    //三角形：从下向上画，顺时针
//    CGPoint points[7];
//    points[0] = CGPointMake(rect.origin.x, radius +offsetY +tSize.height +3);
//    points[1] = CGPointMake(rect.origin.x, radius +offsetY +tSize.height);
//    points[2] = CGPointMake(rect.origin.x -2, radius +offsetY +tSize.height -3);
//    points[3] = CGPointMake(offsetX +1, radius +offsetY +2);
//    points[4] = CGPointMake(offsetX, radius +offsetY +1);
//    points[5] = CGPointMake(offsetX +1, radius +offsetY);
//    points[6] = CGPointMake(rect.origin.x, radius +offsetY);
    
    
    CGContextBeginPath(context);
    CGContextMoveToPoint  (context, vertex[0].x, vertex[0].y);
    
    CGContextAddArc(context, centers[0].x, centers[0].y, radius, -M_PI_2, 0, 0);
    
    CGContextAddLineToPoint(context, vertex[1].x, vertex[1].y);
    CGContextAddArc(context, centers[1].x, centers[1].y, radius, 0, M_PI_2, 0);
    
    CGContextAddLineToPoint(context, vertex[2].x, vertex[2].y);
    CGContextAddArc(context, centers[2].x, centers[2].y, radius, M_PI_2, -M_PI, 0);
    
//    {
//        //画三角形
//        CGContextAddLineToPoint(context, points[0].x, points[0].y);
//        CGContextAddQuadCurveToPoint(context, points[1].x, points[1].y, points[2].x, points[2].y);
//        CGContextAddLineToPoint(context, points[3].x, points[3].y);
//        CGContextAddQuadCurveToPoint(context, points[4].x, points[4].y, points[5].x, points[5].y);
//        CGContextAddLineToPoint(context, points[6].x, points[6].y);
//    }
    
    CGContextAddLineToPoint(context, vertex[3].x, vertex[3].y);
    CGContextAddArc(context, centers[3].x, centers[3].y, radius, -M_PI, -M_PI_2, 0);
    
    CGContextAddLineToPoint(context, vertex[0].x, vertex[0].y);
    
    CGContextClosePath(context);
}

#pragma mark - right path

- (void)setupPathRightBubbleSize:(CGSize)size triangle:(CGSize)tSize offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY cornerRadius:(CGFloat)radius context:(CGContextRef)context{
    //bubble rect
    CGRect rect = CGRectMake(offsetX, 0, size.width -offsetX, size.height);
    //矩形顶点：从右至左，顺时针画
    CGPoint vertex[4];
    vertex[0] = CGPointMake(CGRectGetMaxX(rect) -tSize.width -radius, 0);//右上
    vertex[1] = CGPointMake(CGRectGetMaxX(rect) -tSize.width, rect.size.height -radius);//右下
    vertex[2] = CGPointMake(rect.origin.x +radius, rect.size.height);//左下
    vertex[3] = CGPointMake(rect.origin.x, radius);//左上
    
    //圆角的圆心：从右至左，顺时针画
    CGPoint centers[4];
    centers[0] = CGPointMake(CGRectGetMaxX(rect) -tSize.width -radius, radius);//右上
    centers[1] = CGPointMake(CGRectGetMaxX(rect) -tSize.width -radius, rect.size.height -radius);//右下
    centers[2] = CGPointMake(rect.origin.x +radius, rect.size.height -radius);//左下
    centers[3] = CGPointMake(rect.origin.x +radius, radius);//左上
    
    //三角形：从上向下画，顺时针
//    CGPoint points[7];
//    points[0] = CGPointMake(CGRectGetMaxX(rect) -tSize.width, radius +offsetY);
//    points[1] = CGPointMake(CGRectGetMaxX(rect) -1, radius +offsetY);
//    points[2] = CGPointMake(CGRectGetMaxX(rect), radius +offsetY +1);
//    points[3] = CGPointMake(CGRectGetMaxX(rect) -1, radius +offsetY +2);
//    points[4] = CGPointMake(CGRectGetMaxX(rect) -tSize.width +2, radius +offsetY +tSize.height -3);
//    points[5] = CGPointMake(CGRectGetMaxX(rect) -tSize.width, radius +offsetY +tSize.height);
//    points[6] = CGPointMake(CGRectGetMaxX(rect) -tSize.width, radius +offsetY +tSize.height +3);
    
    
    CGContextBeginPath(context);
    CGContextMoveToPoint  (context, vertex[0].x, vertex[0].y);
    CGContextAddArc(context, centers[0].x, centers[0].y, radius, -M_PI_2, 0, 0);
    
//    {
//        //画三角形
//        CGContextAddLineToPoint(context, points[0].x, points[0].y);
//        CGContextAddLineToPoint(context, points[1].x, points[1].y);
//        CGContextAddQuadCurveToPoint(context, points[2].x, points[2].y, points[3].x, points[3].y);
//        CGContextAddLineToPoint(context, points[4].x, points[4].y);
//        CGContextAddQuadCurveToPoint(context, points[5].x, points[5].y, points[6].x, points[6].y);
//    }
    
    CGContextAddLineToPoint(context, vertex[1].x, vertex[1].y);
    CGContextAddArc(context, centers[1].x, centers[1].y, radius, 0, M_PI_2, 0);
    
    CGContextAddLineToPoint(context, vertex[2].x, vertex[2].y);
    CGContextAddArc(context, centers[2].x, centers[2].y, radius, M_PI_2, -M_PI, 0);
    
    
    
    CGContextAddLineToPoint(context, vertex[3].x, vertex[3].y);
    CGContextAddArc(context, centers[3].x, centers[3].y, radius, -M_PI, -M_PI_2, 0);
    
    CGContextAddLineToPoint(context, vertex[0].x, vertex[0].y);
    
    CGContextClosePath(context);
}
@end
