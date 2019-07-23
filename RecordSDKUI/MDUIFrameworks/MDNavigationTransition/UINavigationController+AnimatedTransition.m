//
//  UINavigationController+AnimatedTransition.m
//  RecordSDK
//
//  Created by 杜林 on 16/9/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "UINavigationController+AnimatedTransition.h"
#import <objc/runtime.h>
#import "MDNavigationHelper.h"
#import "UIViewController+MDTransitionType.h"

static char KEYHELPER;
static char KEYTRANSITIONING;

@implementation UINavigationController (AnimatedTransition)

+ (instancetype)md_NavigationControllerWithRootViewController:(UIViewController *)rootViewController
{
    UINavigationController *navc = [[self alloc] initWithRootViewController:rootViewController];
    MDNavigationHelper *helper = [[MDNavigationHelper alloc] initWithViewController:navc];
    [navc setHelper:helper];
    return navc;
}

- (void)clearViewController:(UIViewController *)viewController
{
    [self.helper removeSnapForViewController:viewController];
}

- (void)setHelper:(MDNavigationHelper *)helper
{
    objc_setAssociatedObject(self, &KEYHELPER, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MDNavigationHelper *)helper
{
    return objc_getAssociatedObject(self, &KEYHELPER);
}

- (void)pushViewController:(UIViewController *)viewController type:(MDNavigationTransitionType)type
{
    viewController.transitionType = type;
    [self pushViewController:viewController animated:YES];
}

- (void)pushViewController:(UIViewController *)viewController type:(MDNavigationTransitionType)type info:(NSDictionary *)info
{
    viewController.transitionType = type;
    viewController.mdTransitionInfo = info;
    [self pushViewController:viewController animated:YES];
}

- (void)setTransitioning:(BOOL)trans
{
    objc_setAssociatedObject(self, &KEYTRANSITIONING, @(trans), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isTransitioning
{
    return [objc_getAssociatedObject(self, &KEYTRANSITIONING) boolValue];
}

- (UIPanGestureRecognizer *)popGestureRecognizer
{
    return [self.helper popGestureRecognizer];
}

@end
