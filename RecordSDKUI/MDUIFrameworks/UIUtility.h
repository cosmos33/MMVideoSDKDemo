//
//  UIUtility.h
//  Pods
//
//  Created by RecordSDK on 2016/10/9.
//
//

#import <UIKit/UIKit.h>

#define kBadgeViewTag           77

@interface UIUtility : NSObject

+ (float)systemVersion;
//小于7.0
+ (BOOL)isLessThanSystemVersion7_0;

// > 某个版本，没有=
+ (BOOL)isMoreThanVersion:(float)aVersion;
+ (BOOL)isLessThanVersion:(float)aVersion;
+ (BOOL)isNotLessThanVersion:(float)aVersion;

+ (UIViewController *)getUsablePresentedViewController:(UIViewController *)aVC;

+ (BOOL)isIPhoneX;

@end
