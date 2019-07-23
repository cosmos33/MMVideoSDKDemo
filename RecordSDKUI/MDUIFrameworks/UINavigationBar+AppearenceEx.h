//
//  UINavigationBar+AppearenceEx.h
//  RecordSDK
//
//  Created by 杜林 on 15/8/10.
//  Copyright (c) 2015年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (AppearenceEx)

- (void)setBottomLineColor:(UIColor *)color;

- (void)setBarDefault;
//设置导航条透明
- (void)setBarClear;
//设置导航条颜色
- (void)setBarCustomColor:(UIColor *)color;

//导航条滚动视差效果，是否显示
//show,NO代表导航条滚动的视差当前显示为透明，YES代表显示滚动视差最终的颜色
- (void)showScrollTransition:(BOOL)show;
- (void)showScrollTransition:(BOOL)show withCustomTransitionView:(UIView *)view;

- (void)setScrollTransitionAlpha:(CGFloat)alpha;
- (void)setScrollTransitionColor:(UIColor *)color;

#pragma mark - 渐变遮罩
- (void)showGradientMask:(BOOL)show;

#pragma mark - 高斯模糊
- (void)setBlurImage:(UIImage *)image originImage:(UIImage *)originImage;
- (void)setBlurOffsetY:(CGFloat)dy alpha:(CGFloat)alpha show:(BOOL)show;


- (UIView *)scrollTransitionView;

@end
