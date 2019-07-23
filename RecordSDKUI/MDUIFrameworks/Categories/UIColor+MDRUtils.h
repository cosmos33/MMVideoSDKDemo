//
//  UIColor+Utils.h
//  Pods
//
//  Created by RecordSDK on 2016/9/27.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (MDRUtils)

+ (UIColor *)mdr_colorWithHexString: (NSString*)hex;//#aabbcc

//带alpha通道的十六进制串
+ (UIColor *)mdr_colorWithARGBHexString: (NSString*)hex;//#AARRGGBB

+ (UIColor *)mdr_colorWithRGBString: (NSString *)string;//@"255, 255, 255"
+ (UIColor *)mdr_colorWithRGBString:(NSString *)string defaultColor:(UIColor *)color;

@end
