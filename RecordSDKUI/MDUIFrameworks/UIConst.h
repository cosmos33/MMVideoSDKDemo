//
//  UIConst.h
//  Pods
//
//  Created by RecordSDK on 2016/9/26.
//
//
#import <UIKit/UIKit.h>
#import "UIUtility.h"

#ifndef UIConst_h
#define UIConst_h

NS_INLINE  BOOL isFloatEqual(float value1, float value2)
{
    return fabsf(value1 - value2) <= 0.00001f;
}

#define MDScreenWidth     CGRectGetWidth([[UIScreen mainScreen] bounds])
#define MDScreenHeight    CGRectGetHeight([[[UIApplication sharedApplication].delegate window] bounds])
#define MDAdapterScale    (MDScreenWidth/375.0)//以6的尺寸为基础

#define MDStatusBarHeight ([UIUtility isIPhoneX] ? 44.f : 20.f)
#define MDNavigationBarHeight 44.f
#define MDStatusBarAndNavigationBarHeight (MDStatusBarHeight + MDNavigationBarHeight)
#define MDHomeIndicatorHeight ([UIUtility isIPhoneX] ? 34.f : 0.f)

//视频使用
#define MLScreenWidth     CGRectGetWidth([[UIScreen mainScreen] bounds])
#define MLScreenHeight    CGRectGetHeight([[[UIApplication sharedApplication].delegate window] bounds])

#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

//6.1版本之后的背景色和字体颜色
#define ALL_VIEW_BACKGROUND_COLOR                       RGBCOLOR(244,243,242)

#define TEXT_COLOR                                      RGBCOLOR(30,30,30)
#define DETAIL_COLOR                                    RGBCOLOR(170, 170, 170)
#define BLUE_COLOR                                      RGBCOLOR(59, 179, 250)

#define ALL_TABLE_BACKGROUND_COLOR                      RGBCOLOR(255,255,255)
#define CELL_BACKGROUND_COLOR                           RGBCOLOR(255,255,255)
#define SEPARATOR_COLOR                                 RGBCOLOR(236,236,235)
#define HEADER_TEXT_COLOR                               RGBCOLOR(160,160,160)
#define SELECT_BACKGROUND_COLOR                         RGBCOLOR(247,246,245)

#define PERSONAL_TEXT_COLOR                             RGBCOLOR(160,160,160)
#define PERSONAL_NUM_COLOR                              RGBCOLOR(230,230,230)

#define NO_DATA_TEXT_COLOR                              RGBCOLOR(90,90,90)
#define NO_DATA_DETAIL_COLOR                            RGBCOLOR(170,170,170)

#define COLOR_TOPBAR_TEXT_NOMAL                         RGBCOLOR(255,255,255)
#define COLOR_TOPBAR_TEXT_HIGHLIGHT                     RGBCOLOR(0, 122, 255)
#define COLOR_TOPBAR_TEXT_DISABLE                       RGBCOLOR(146,146,146)
#define COLOR_VIEW_BACKGROUND_NOMAL                     RGBCOLOR(236,234,222)

#endif /* UIConst_h */
