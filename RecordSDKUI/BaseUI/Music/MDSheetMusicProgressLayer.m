//
//  MDSheetMusicLayer.m
//  animation
//
//  Created by RFeng on 2018/5/14.
//  Copyright © 2018年 RFeng. All rights reserved.
//



#import "MDSheetMusicProgressLayer.h"


typedef NS_ENUM(NSUInteger,MarginLineType){
    MarginLineBegin = 0,
    MarginLineEnd = 1,
};

#define KProgressWidth  3 //  每个小竖条的宽度

#define KProgressInterval 8.0 // 临近两个之间的间隔

#define KFaultToleranceValue 30  // 开始 和结束线响应事件的X 方向的扩大范围

@interface MDSheetMusicProgressLayer()
@property (nonatomic, assign) CGRect beginLineRect;

@property (nonatomic, assign) CGRect endLineRect;
@end

@implementation MDSheetMusicProgressLayer

+ (CGFloat)sigleLineAdjustOffset {
    static CGFloat adjustOffset = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adjustOffset = (1 / [UIScreen mainScreen].scale) / 2;
    });
    return adjustOffset;
}


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
    if  (  [key isEqualToString:@"progressColor"]
         || [key isEqualToString:@"trackColor"]
         || [key isEqualToString:@"inactiveColor"]
         || [key isEqualToString:@"currentValue"]
         || [key isEqualToString:@"beginValue"]
         || [key isEqualToString:@"endValue"]
         || [key isEqualToString:@"leftMargin"]
         || [key isEqualToString:@"rightMargin"]
         || [key isEqualToString:@"linePadding"]
         || [key isEqualToString:@"lineWidth"]
         || [key isEqualToString:@"beginLineColor"]
         || [key isEqualToString:@"endLineCloror"]
         || [key isEqualToString:@"selectAreaBgColor"]
         || [key isEqualToString:@"disable"]
         || [key isEqualToString:@"getLineHeightBlock"] )
    {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.linePadding = KProgressInterval;
        self.lineWidth = KProgressWidth;
    }
    return self;
}

/**
 *  绘制层
 *
 *  @param ctx 设备上下文
 */
- (void)drawInContext:(CGContextRef)ctx
{
    [self drawProgressionInContext:ctx];
}


/**
 绘制进度条

 @param ctx 上下文
 */
-(void)drawProgressionInContext:(CGContextRef)ctx
{
    //  开始的位置
    CGFloat x = kMarginLineWidth + self.leftMargin + self.lineWidth / 2.0;
    NSUInteger lineNumber = 0; // 第几条线
    if (!self.disable) {
        [self drawRectWithContext:ctx];
    }
    while (x+self.lineWidth/2.0 < self.frame.size.width - kMarginLineWidth - self.rightMargin) {
        CGFloat progress = x / self.frame.size.width;
        UIColor *drawColor = self.progressColor;
        if (self.disable) {
            drawColor = self.inactiveColor;
        }
        else if (progress > self.endValue) {
            drawColor = self.inactiveColor;
        }
        else if (progress < self.beginValue) {
            drawColor = self.inactiveColor;
        }
        else if (progress <= self.currentValue) {
            drawColor = self.trackColor;
        }
        lineNumber++;
        CGFloat lineHeight = self.getLineHeightBlock ? self.getLineHeightBlock(lineNumber) : [self getLineHeightWithNumber:lineNumber];
        [self drawLineWithContext:ctx Color:drawColor originX:x lineHeight:lineHeight];
        x = x + self.lineWidth + self.linePadding; // 加上宽度和间隔
    }

    CGFloat beginLineX = self.frame.size.width * self.beginValue;
    [self drawMarginLineContext:ctx Color:self.beginLineColor originX:beginLineX lineType:MarginLineBegin];
    CGFloat endLineX = self.frame.size.width * self.endValue;
    [self drawMarginLineContext:ctx Color:self.endLineCloror originX:endLineX lineType:MarginLineEnd];
    
}
#pragma mark - 返回每条线的高度
//高度 10/20/14/30/14/30  一组
-(CGFloat)getLineHeightWithNumber:(NSUInteger)number
{
    if(number % 6 == 0 ){ // 5的整数倍
        return 30;
    }
    if(number % 5 == 0){
        return 14;
    }
    if(number % 4 == 0){
        return 30;
    }
    if(number % 3 == 0){
        return 14;
    }
    if(number % 2 == 0){
        return 20;
    }
    return 10;
}

-(void)drawMarginLineContext:(CGContextRef)context Color:(UIColor *)color  originX:(CGFloat)originX lineType:(MarginLineType)type
{
    CGFloat height = self.frame.size.height;
    // 线的颜色
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    // 线的宽度
    //CGContextSetLineCap(context,kCGLineCapRound);
    CGContextSetLineWidth(context, kMarginLineWidth);

    if(type == MarginLineBegin &&originX <=  kMarginLineWidth / 2){
        originX =  kMarginLineWidth / 2;
    }
    if(type == MarginLineEnd && originX >= self.frame.size.width - kMarginLineWidth / 2){
        originX = self.frame.size.width - kMarginLineWidth / 2;
    }
    
    CGFloat pixelAdjustOffset = 0;
    if (((int)(kMarginLineWidth * [UIScreen mainScreen].scale)) % 2 == 1) {
        pixelAdjustOffset = [[self class] sigleLineAdjustOffset];
    }
    originX = round(originX)+pixelAdjustOffset;

    
    CGContextMoveToPoint(context, originX, 0);
    // 终点
    CGContextAddLineToPoint(context, originX, height); //draw to this point
    //  连接路径
    CGContextStrokePath(context);
    CGRect rect =  CGRectMake(originX - KFaultToleranceValue,0,  kMarginLineWidth + 2 * KFaultToleranceValue, height);
    if(type == MarginLineBegin){
        self.beginLineRect = rect;
    }else{ 
        self.endLineRect = rect;
    }
    // 下面是区域重叠后平分重叠部分
    if(CGRectIntersectsRect(self.beginLineRect,self.endLineRect)){
        CGRect IntersectionRect =   CGRectIntersection(self.beginLineRect,self.endLineRect);
        CGSize size = IntersectionRect.size;
        CGSize beginSize = self.beginLineRect.size;
        beginSize.width = beginSize.width - size.width/ 2.0; // 左边减去重合部分一半
        self.beginLineRect = (CGRect){.origin = self.beginLineRect.origin, .size = beginSize};\
        CGPoint endOrigin = self.endLineRect.origin;
        CGSize endSize = self.endLineRect.size;
        endSize.width = endSize.width - size.width / 2.0;
        endOrigin.x = endOrigin.x + size.width / 2.0;
        self.endLineRect = (CGRect){.origin = endOrigin, .size =  endSize};

    }
    
   
}



#pragma mark - 绘制中间五线谱
-(void)drawLineWithContext:(CGContextRef)context Color:(UIColor *)color  originX:(CGFloat)originX lineHeight:(CGFloat)height
{
    // 线的颜色
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    // 线的宽度
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetLineCap(context,kCGLineCapRound);
    // 线的起始点
    CGFloat centerY = self.frame.size.height / 2.0; // 垂直方向中间的Y值
    
    CGFloat pixelAdjustOffset = 0;
    if (((int)(self.lineWidth * [UIScreen mainScreen].scale)) % 2 == 1) {
        pixelAdjustOffset = [[self class] sigleLineAdjustOffset];
    }
    originX = round(originX)+pixelAdjustOffset;
    
    CGContextMoveToPoint(context, originX , centerY + height / 2.0);
    // 终点
    CGContextAddLineToPoint(context, originX, centerY - height / 2.0); //draw to this point
    //  连接路径
    CGContextStrokePath(context);
}

-(void)drawRectWithContext:(CGContextRef)currentContext
{
    //创建路径并获取句柄
    CGMutablePathRef path = CGPathCreateMutable();
    
    //指定矩形
    CGRect rectangle = CGRectMake(self.frame.size.width  * self.beginValue, 0,self.frame.size.width * (self.endValue - self.beginValue), self.frame.size.height);
    //将矩形添加到路径中
    CGPathAddRect(path,NULL, rectangle);
    
    
    //将路径添加到上下文
    CGContextAddPath(currentContext, path);
    
    //设置矩形填充色
    CGContextSetFillColorWithColor(currentContext, self.selectAreaBgColor.CGColor);
    
    //矩形边框颜色
    CGContextSetStrokeColorWithColor(currentContext, self.selectAreaBgColor.CGColor);
    
    //边框宽度
    CGContextSetLineWidth(currentContext,0.0f);
    
    //绘制
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    
    CGPathRelease(path);
    
}


@end
