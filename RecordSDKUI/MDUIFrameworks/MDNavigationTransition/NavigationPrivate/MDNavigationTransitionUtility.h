//
//  MDNavigationTransitionUtility.h
//  RecordSDK
//
//  Created by 杜林 on 16/9/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MDNavigationTransitionDelegate.h"
#import "MDNavigationTransitionExtra.h"

@interface MDNavigationTransitionUtility : NSObject

+ (id<MDNavigationAnimatedTransitionDelegate>)animationWithType:(MDNavigationTransitionType)type;

+ (UINavigationBar *)navigationBarCustomed:(UIViewController *)viewController;

+ (BOOL)isBarCustomed:(UIViewController *)viewController;
+ (BOOL)isBarNavShowCustomed:(UIViewController *)viewController;

+ (UIViewController *)realController:(UIViewController *)viewcontroller;
+ (UIViewController *)navShowRealController:(UIViewController *)viewcontroller;

@end
