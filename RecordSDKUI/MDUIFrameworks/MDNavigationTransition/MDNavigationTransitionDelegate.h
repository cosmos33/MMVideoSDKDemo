//
//  MDNavigationTransitionDelegate.h
//  RecordSDK
//
//  Created by 杜林 on 16/9/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, MDPopGestureOrientation)
{
    MDPopGestureOrientationLeftToRight  = 1 << 0,
    MDPopGestureOrientationTopToBottom  = 1 << 1,
    MDPopGestureOrientationDefault  = MDPopGestureOrientationLeftToRight,
};

@protocol MDNavigationAnimatedTransitionDelegate <NSObject>

- (NSTimeInterval)transitionDuration;
- (void)pushAnimationWithFromVC:(UIViewController *)fromVC
                           toVC:(UIViewController *)toVC
                  containerView:(UIView *)containerView
              transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;

- (void)popAnimationWithFromVC:(UIViewController *)fromVC
                          toVC:(UIViewController *)toVC
                 containerView:(UIView *)containerView
             transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;

@end


@protocol MDNavigationBarAppearanceDelegate <NSObject>

@optional
- (UINavigationBar *)md_CustomNavigationBar;
//实时获取是否自定义导航条
- (BOOL)md_isCurrentCustomed;

@end

//push 和 pop 动画完成回调
@protocol MDNavigationPushPopDelegate <NSObject>

@optional

- (void)mdNavigationDidFinishPush;
//cancelled YES侧滑失败，NO侧滑成功
- (void)mdNavigationDidFinishPop:(BOOL)cancelled;

@end

@protocol MDPopGestureRecognizerDelegate <NSObject>

@optional
- (BOOL)md_popGestureRecognizerEnabled;
- (MDPopGestureOrientation)md_popGestureOrientation;
- (NSDictionary *)md_popNavigationTransitionType;

@end

//业务扩展所需
@protocol MDNavigationTransitionUtilityExtension <NSObject>

- (NSDictionary *)animationCofigs;
- (UIViewController *)realController:(UIViewController *)viewcontroller;
- (UIViewController *)navShowRealController:(UIViewController *)viewcontroller;

@end

