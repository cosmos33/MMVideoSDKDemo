//
//  MDNavigationTransitionUtility.m
//  RecordSDK
//
//  Created by 杜林 on 16/9/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MDNavigationTransitionUtility.h"
#import "MDDefaultAnimation.h"
#import "MDModelAnimation.h"
#import <objc/message.h>

@implementation MDNavigationTransitionUtility

+ (NSDictionary *)animationCofigs
{
    NSMutableDictionary *configs = nil;
    id<MDNavigationTransitionUtilityExtension>delegate = [UIApplication sharedApplication].delegate;
    if (delegate && [delegate respondsToSelector:@selector(animationCofigs)]) {
        NSDictionary *dic = [delegate animationCofigs];
        configs = [NSMutableDictionary dictionaryWithDictionary:dic];
    }
    
    if (!configs) {
        configs = [NSMutableDictionary dictionary];
    }
    
    [configs setObject:NSStringFromClass([MDDefaultAnimation class]) forKey:@(MDNavigationTransitionTypeDefault)];
    [configs setObject:NSStringFromClass([MDModelAnimation class]) forKey:@(MDNavigationTransitionTypeModel)];
    
    return configs;
}

+ (id<MDNavigationAnimatedTransitionDelegate>)animationWithType:(MDNavigationTransitionType)type
{
    NSString *classString = [[self animationCofigs] objectForKey:@(type)];
    id<MDNavigationAnimatedTransitionDelegate> animation = [[NSClassFromString(classString) alloc] init];
    return animation;
}

+ (BOOL)conformsProtocol:(UIViewController *)viewController
{
    BOOL conform = [viewController conformsToProtocol:@protocol(MDNavigationBarAppearanceDelegate)];
    return conform;
}

+ (BOOL)isBarCustomed:(UIViewController *)viewController
{
    //如果在viewdidload之前调用，自定义的navigationBar还没有初始化，
    //所以不可以用navigationBar是否为nil来判断，应该用是否实现了该协议来判断
    UIViewController *realVC = [self realController:viewController];
    
    BOOL conform = [self conformsProtocol:realVC];
    id<MDNavigationBarAppearanceDelegate> vc = (id)realVC;
    
    if (!conform) return NO;
    
    if ([vc respondsToSelector:@selector(md_isCurrentCustomed)]) {
        return [vc md_isCurrentCustomed];
    } else if ([vc respondsToSelector:@selector(md_CustomNavigationBar)]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isBarNavShowCustomed:(UIViewController *)viewController
{
    //如果在viewdidload之前调用，自定义的navigationBar还没有初始化，
    //所以不可以用navigationBar是否为nil来判断，应该用是否实现了该协议来判断
    UIViewController *realVC = [self navShowRealController:viewController];
    
    if ([realVC isKindOfClass:[UINavigationController class]]) {
        return YES;
    }
    
    BOOL conform = [self conformsProtocol:realVC];
    id<MDNavigationBarAppearanceDelegate> vc = (id)realVC;
    
    if (!conform) return NO;
    
    if ([vc respondsToSelector:@selector(md_isCurrentCustomed)]) {
        return [vc md_isCurrentCustomed];
    } else if ([vc respondsToSelector:@selector(md_CustomNavigationBar)]) {
        return YES;
    }
    
    return NO;
}

+ (UINavigationBar *)navigationBarCustomed:(UIViewController *)viewController
{
    UIViewController *realVC = [self realController:viewController];
    
    BOOL conform = [self conformsProtocol:realVC];
    id<MDNavigationBarAppearanceDelegate> vc = (id)realVC;
    
    if (conform && [vc respondsToSelector:@selector(md_CustomNavigationBar)]) {
        return [vc md_CustomNavigationBar];
    }
    
    return nil;
}

+ (UIViewController *)realController:(UIViewController *)viewcontroller
{
    id<MDNavigationTransitionUtilityExtension>delegate = [UIApplication sharedApplication].delegate;
    if (delegate && [delegate respondsToSelector:@selector(realController:)]) {
        return [delegate realController:viewcontroller];
    }
    
    return viewcontroller;
}

+ (UIViewController *)navShowRealController:(UIViewController *)viewcontroller
{
    id<MDNavigationTransitionUtilityExtension>delegate = [UIApplication sharedApplication].delegate;
    if (delegate && [delegate respondsToSelector:@selector(navShowRealController:)]) {
        return [delegate navShowRealController:viewcontroller];
    }

    return viewcontroller;
}

@end
