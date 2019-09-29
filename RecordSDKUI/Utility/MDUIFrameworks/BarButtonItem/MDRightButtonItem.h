//
//  MDRightButtonItem.h
//  CocoaLumberjack
//
//  Created by tamer on 02/04/2018.
//

#import "MFBarButtonItem.h"

@interface MDRightButtonItem : MFBarButtonItem

+ (instancetype)blueCornerRadiusItemWithTitle:(NSString *)title activity:(BOOL)activity;

/**
 @activity :蓝色圆角+白色（14号）title
 @inactivity :浅灰色圆角+深灰色（14号）title

 @param bounds defaults is（0，0，60.f，30.f）
 @param title defaults is @"发布"
 @param titleColor  default activity is:白色（14号),default inactivity is:深灰色（14号）
 @param bgColor default activity is:蓝色,default inactivity is:浅灰色
 */
+ (instancetype)blueCornerRadiusItemWithBounds:(CGRect)bounds title:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)bgColor activity:(BOOL)activity;
- (void)updateState:(BOOL)activity;
- (void)updateFontSize:(CGFloat)size;

@end
