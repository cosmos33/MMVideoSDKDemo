//
//  MDSpecialEffectsLayer.m
//  BlockTest
//
//  Created by litianpeng on 2018/8/6.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import "MDSpecialEffectsLayer.h"
#import "MDSpecialEffectsProgressModel.h"

@interface MDSpecialEffectsLayer()

@end

@implementation MDSpecialEffectsLayer

// 下列属性改变，则刷新层
/**
 *  指定属性改变时，layer刷新
 *
 *  @param key 属性名
 *
 *  @return 刷新：YES；  不刷新：NO
 */
+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if  (
         [key isEqualToString:@"transparentArr"]
         )
    {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}
/**
 *  绘制矩形
 *
 *  @param ctx 设备上下文
 */
- (void)drawInContext:(CGContextRef)ctx
{
    [self drawRectWithContext:ctx];
}

-(void)drawRectWithContext:(CGContextRef)currentContext
{
    
    for (MDSpecialEffectsProgressModel *model in self.transparentArr) {
        CGRect rectangle = model.colorRect;
        //创建路径并获取句柄
        CGMutablePathRef path = CGPathCreateMutable();
        
        //指定矩形
        //将矩形添加到路径中
        CGPathAddRect(path,NULL, rectangle);
        
        //将路径添加到上下文
        CGContextAddPath(currentContext, path);
        
        //设置矩形填充色
        CGContextSetFillColorWithColor(currentContext, model.bgColor.CGColor);
        //矩形边框颜色
        CGContextSetStrokeColorWithColor(currentContext,  model.bgColor.CGColor);
        
        //边框宽度
        CGContextSetLineWidth(currentContext,0.0f);
        //绘制
        CGContextDrawPath(currentContext, kCGPathFillStroke);
        
        CGPathRelease(path);
    }
}
@end
