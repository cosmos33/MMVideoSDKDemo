//
//  MProgressView.m
//  animation
//
//  Created by RFeng on 2018/5/14.
//  Copyright © 2018年 RFeng. All rights reserved.
//

#import "MDSheetMusicProgressView.h"
#import "MDSheetMusicProgressLayer.h"
#import "UIView+Utils.h"

#define kMinValueDistance 40

@implementation MDSheetMusicProgressView

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self defaultInit];
        self.contentScaleFactor = [UIScreen mainScreen].scale;
    }
    return self;
}

-(void)defaultInit
{
    self.progressColor =  [UIColor yellowColor];
    self.trackColor =  [UIColor redColor];
    self.inactiveColor = [UIColor orangeColor];
    self.selectAreaBgColor = [UIColor purpleColor];
    self.leftMargin = 8;
    self.rightMargin = 8;
    self.beginValue = 0.0;
    self.endValue = 1;
    self.currentValue = 0.5;
    self.beginLineColor = [UIColor lightGrayColor];
    self.endLineCloror  = [UIColor lightGrayColor];
}


// 重设默认层
+ (Class)layerClass
{
    return [MDSheetMusicProgressLayer class];
}

// 重新布局视图
- (void)layoutSubviews
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    [layer setNeedsDisplay];
}

#pragma mark - setterAndgetter
-(UIColor *)progressColor
{
     MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.progressColor;
}

-(void)setProgressColor:(UIColor *)progressColor
{
    if(self.progressColor != progressColor){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.progressColor = progressColor;
        [layer setNeedsDisplay];
    }
}

-(UIColor *)trackColor
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.trackColor;
}

-(void)setTrackColor:(UIColor *)trackColor
{
    if(self.trackColor != trackColor){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.trackColor = trackColor;
        [layer setNeedsDisplay];
    }
}


-(UIColor *)inactiveColor
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.inactiveColor;
}
-(void)setInactiveColor:(UIColor *)inactiveColor
{
    if(self.inactiveColor != inactiveColor){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.inactiveColor = inactiveColor;
        [layer setNeedsDisplay];
    }
}

-(UIColor *)selectAreaBgColor
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.selectAreaBgColor;
}

-(void)setSelectAreaBgColor:(UIColor *)selectAreaBgColor
{
    if(self.selectAreaBgColor != selectAreaBgColor){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.selectAreaBgColor = selectAreaBgColor;
        [layer setNeedsDisplay];
    }
}

-(UIColor *)beginLineColor
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.beginLineColor;
}

-(void)setBeginLineColor:(UIColor *)beginLineColor
{
    if(self.beginLineColor != beginLineColor){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.beginLineColor = beginLineColor;
        [layer setNeedsDisplay];
    }
}

-(UIColor *)endLineCloror
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.endLineCloror;
}

-(void)setEndLineCloror:(UIColor *)endLineCloror
{
    if(self.endLineCloror != endLineCloror){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.endLineCloror = endLineCloror;
        [layer setNeedsDisplay];
    }
}

-(CGFloat)currentValue
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.currentValue;
}

-(void)setCurrentValue:(CGFloat)currentValue
{
    if(currentValue > self.endValue){
        currentValue = self.endValue;
    }else if (currentValue < self.beginValue){
        currentValue = self.beginValue;
    }
    if(self.currentValue != currentValue){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.currentValue = currentValue;
        [layer setNeedsDisplay];
    }
}

-(CGFloat)beginValue
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.beginValue;
}


-(void)setBeginValue:(CGFloat)beginValue
{
    if(beginValue >= self.endValue - (kMarginLineWidth+kMinValueDistance)/ self.size.width && self.endValue != 0){
        beginValue = self.endValue - (kMarginLineWidth+kMinValueDistance)/ self.size.width;
    }else if (beginValue <= 0){
        beginValue = 0;
    }else if(beginValue >=1){
        beginValue = 1;
    }
    if(self.beginValue != beginValue){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.beginValue = beginValue;
        [layer setNeedsDisplay];
    }
}
-(CGFloat)endValue
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.endValue;
}

-(void)setEndValue:(CGFloat)endValue
{
    if(self.endValue != endValue){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        if(endValue > 1){
            endValue = 1;
        }else if (endValue <= self.beginValue + (kMarginLineWidth+kMinValueDistance)/ self.size.width){
            endValue = self.beginValue + (kMarginLineWidth+kMinValueDistance)/ self.size.width;
        }
        layer.endValue = endValue;
        [layer setNeedsDisplay];
    }
    
}

-(CGFloat)leftMargin
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.leftMargin;
}

-(void)setLeftMargin:(CGFloat)leftMargin
{
    if(self.leftMargin != leftMargin){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.leftMargin = leftMargin;
        [layer setNeedsDisplay];
    }
}

-(CGFloat)rightMargin
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.rightMargin;
}
-(void)setRightMargin:(CGFloat)rightMargin
{
    if(self.rightMargin != rightMargin){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.rightMargin = rightMargin;
        [layer setNeedsDisplay];
    }
}

-(CGFloat)linePadding
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.linePadding;
}

-(void)setLinePadding:(CGFloat)linePadding
{
    if(self.linePadding != linePadding){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.linePadding = linePadding;
        [layer setNeedsDisplay];
    }
}

-(CGFloat)lineWidth
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.lineWidth;
}

-(void)setLineWidth:(CGFloat)lineWidth
{
    if(self.lineWidth != lineWidth){
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.lineWidth = lineWidth;
        [layer setNeedsDisplay];
    }
}

-(CGRect)beginLineRect{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.beginLineRect;
}

-(CGRect)endLineRect
{
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.endLineRect;
}

- (void)setGetLineHeightBlock:(CGFloat (^)(NSUInteger))getLineHeightBlock {
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    layer.getLineHeightBlock = getLineHeightBlock;
}

- (CGFloat (^)(NSUInteger))getLineHeightBlock {
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.getLineHeightBlock;
}

- (void)setDisable:(BOOL)disable {
    if(self.disable != disable){
        self.userInteractionEnabled = !disable;
        MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
        layer.disable = disable;
        [layer setNeedsDisplay];
    }
}

- (BOOL)disable {
    MDSheetMusicProgressLayer *layer = (MDSheetMusicProgressLayer *)self.layer;
    return layer.disable;
}

@end
