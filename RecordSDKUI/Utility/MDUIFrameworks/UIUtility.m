//
//  UIUtility.m
//  Pods
//
//  Created by RecordSDK on 2016/10/9.
//
//

#import "UIUtility.h"
#import "UIPublic.h"
#import "UIDevice-Hardware.h"

static float _systemVersionFloat;

@implementation UIUtility

+ (float)systemVersion
{
    if (!_systemVersionFloat) {
        _systemVersionFloat = [[[UIDevice currentDevice] systemVersion] floatValue];
    }
    
    return _systemVersionFloat;
}

+ (BOOL)isLessThanSystemVersion7_0
{
    float version = [UIUtility systemVersion];
    if (version < 7.0) {
        return YES;
    } else {
        return NO;
    }
}

// > 某个版本，没有=
+ (BOOL)isMoreThanVersion:(float)aVersion
{
    float version = [UIUtility systemVersion];
    if (version > aVersion) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isLessThanVersion:(float)aVersion
{
    float version = [UIUtility systemVersion];
    if (version < aVersion) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isNotLessThanVersion:(float)aVersion
{
    float version = [UIUtility systemVersion];
    if (version >= aVersion) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark -
+ (UIViewController *)getUsablePresentedViewController:(UIViewController *)aVC
{
    UIViewController *viewController = aVC.presentedViewController;
    
    if (!viewController){
        viewController = aVC;
    }else {
        UIViewController *tempVC =  viewController.presentedViewController;
        
        if (!tempVC){
            return viewController;
        }else {
            viewController = [self getUsablePresentedViewController:viewController];
        }
    }
    
    return viewController;
}

+ (BOOL)isIPhoneX
{
    static BOOL x = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MDRecordUIDevicePlatform type = (MDRecordUIDevicePlatform)[[UIDevice currentDevice] platformType];
        if (type == MDRecordUIDeviceXiPhone || type == MDRecordUIDeviceXSiPhone || type == MDRecordUIDeviceXSMaxiPhone || type == MDRecordUIDeviceXRiPhone) {
            x = YES;
        } else if (type == MDRecordUIDeviceiPhoneSimulatoriPhone && (CGSizeEqualToSize([[UIScreen mainScreen] bounds].size, CGSizeMake(375.f, 812.f)) || CGSizeEqualToSize([[UIScreen mainScreen] bounds].size, CGSizeMake(414.f, 896.f)))) {
            x = YES;
        }
    });
    return x;
}

@end
