//
//  MDSheetMusicLayer.h
//  animation
//
//  Created by RFeng on 2018/5/14.
//  Copyright © 2018年 RFeng. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#define kMarginLineWidth  1 // 边线的宽度

@interface MDSheetMusicProgressLayer : CALayer

@property (nonatomic, strong) UIColor *progressColor;  // 进度条填充色 开始颜色

@property (nonatomic, strong) UIColor *trackColor;  // 进度条痕迹填充色

@property (nonatomic, strong) UIColor *inactiveColor; // 不在 beginValue 和 endValue 之间显示的颜色

// 指的是 beginValue 和 endValue 之间的区域
@property (nonatomic, strong) UIColor *selectAreaBgColor; // 选中的区域背景色

@property (nonatomic, strong) UIColor *beginLineColor; // 开始线的颜色

@property (nonatomic, strong) UIColor *endLineCloror; // 结束线的颜色

@property (nonatomic, assign, readonly) CGRect beginLineRect;

@property (nonatomic, assign, readonly) CGRect endLineRect;

@property (nonatomic, assign) CGFloat leftMargin; //  条最开始距左边距

@property (nonatomic, assign) CGFloat rightMargin; //  条最开始距左边距 0.5倍~1.5倍之间 因为需要看所剩下控件能否插入竖线

@property (nonatomic, assign) CGFloat linePadding; // 条之间的间距

@property (nonatomic, assign) CGFloat lineWidth;   // 条的宽度

// 当前值和最大值之间的的均匀比例 超过会按临界值算
@property (nonatomic ,assign) CGFloat currentValue; // 当前值

// 进度的起始和终止位置
@property (nonatomic, assign) CGFloat beginValue;

@property (nonatomic, assign) CGFloat endValue;

@property (nonatomic, copy) CGFloat (^getLineHeightBlock)(NSUInteger number);

@property (nonatomic, assign) BOOL disable;

@end
