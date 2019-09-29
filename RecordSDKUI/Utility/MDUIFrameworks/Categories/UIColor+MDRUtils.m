//
//  UIColor+Utils.m
//  Pods
//
//  Created by RecordSDK on 2016/9/27.
//
//

#import "UIColor+MDRUtils.h"

@implementation UIColor (MDRUtils)

+ (UIColor *)mdr_colorWithHexString:(NSString *)hex {
    return [self mdr_colorWithARGBHexString:hex];
}

+ (UIColor *)mdr_colorWithARGBHexString:(NSString *)hex {
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return nil;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6 && [cString length] != 8)
        return nil;
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    NSString *aString = @"FF";
    if (cString.length == 8) { //
        aString = [cString substringWithRange:range];
        range.location += 2;
    }
    
    NSString *rString = [cString substringWithRange:range];
    
    range.location += 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location += 2;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int a, r, g, b;
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:((float) a / 255.0f)];
}


+ (UIColor *)mdr_colorWithRGBString: (NSString *)string
{
    return [self mdr_colorWithRGBString:string defaultColor:nil];
}

+ (UIColor *)mdr_colorWithRGBString:(NSString *)string defaultColor:(UIColor *)color
{
    UIColor *newColor = color;
    
    NSArray *array = [string componentsSeparatedByString:@","];
    if (array.count >= 3) {
        float r = 0.0;
        float g = 0.0;
        float b = 0.0;
        r = [array[0] floatValue];
        g = [array[1] floatValue];
        b = [array[2] floatValue];
        
        float a = 1.0;
        if (array.count == 4) {
            a = [[array lastObject] floatValue];
        }
        newColor = [UIColor colorWithRed:( r / 255.0f)
                                   green:( g / 255.0f)
                                    blue:( b / 255.0f)
                                   alpha:a];
    }
    
    return newColor;
}


@end
