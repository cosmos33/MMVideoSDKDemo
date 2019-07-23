//
//  UINavigationController+AnimatedTransition.h
//  RecordSDK
//
//  Created by 杜林 on 16/9/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDNavigationTransitionExtra.h"

@class MDNavigationHelper;

@interface UINavigationController (AnimatedTransition)

+ (instancetype)md_NavigationControllerWithRootViewController:(UIViewController *)rootViewController;

- (void)clearViewController:(UIViewController *)viewController;

- (void)pushViewController:(UIViewController *)viewController type:(MDNavigationTransitionType)type;
- (void)pushViewController:(UIViewController *)viewController type:(MDNavigationTransitionType)type info:(NSDictionary *)info;

- (void)setTransitioning:(BOOL)trans;
- (BOOL)isTransitioning;

- (UIPanGestureRecognizer *)popGestureRecognizer;

@end
