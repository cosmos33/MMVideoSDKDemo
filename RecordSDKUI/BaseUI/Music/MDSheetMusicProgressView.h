//
//  MProgressView.h
//  animation
//
//  Created by RFeng on 2018/5/14.
//  Copyright © 2018年 RFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDSheetMusicProgressView : UIView


@property (nonatomic, strong) UIColor *progressColor;  // 进度条填充色 开始颜色

@property (nonatomic, strong) UIColor *trackColor;  // 进度条痕迹填充色

@property (nonatomic, strong) UIColor  *inactiveColor; // 不在 beginValue 和 endValue 之间显示的颜色

// 默认没有颜色 显示该View 背景色
@property (nonatomic, strong) UIColor *selectAreaBgColor; // 选中的区域背景色
// 选中区域开始线 和结束线
@property (nonatomic, strong) UIColor *beginLineColor; // 开始线的颜色
@property (nonatomic, strong) UIColor *endLineCloror; // 结束线的颜色
// 开始线的响应事件区域
@property (nonatomic, assign, readonly) CGRect beginLineRect;
// 结束线响应事件区域
@property (nonatomic, assign, readonly) CGRect endLineRect;
// 下面这个间距都会不算间距 间距只在相邻两个条之间起作用
@property (nonatomic, assign) CGFloat leftMargin; //  条最开始距左边距

@property (nonatomic, assign) CGFloat rightMargin; //  条最开始距左边距

@property (nonatomic, assign) CGFloat linePadding; // 条之间的间距

@property (nonatomic, assign) CGFloat lineWidth;   // 条的宽度

// 以下值均为 0~1 之间为百分比
@property (nonatomic ,assign) CGFloat currentValue; // 当前值

// 进度的起始和终止位置
@property (nonatomic, assign) CGFloat beginValue;

@property (nonatomic, assign) CGFloat endValue;

// 线的高度
@property (nonatomic, copy) CGFloat (^getLineHeightBlock)(NSUInteger number);

@property (nonatomic, assign) BOOL disable;

@end
