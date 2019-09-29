//
//  MDModelAnimation.m
//  RecordSDK
//
//  Created by 杜林 on 16/9/26.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MDModelAnimation.h"
#import "MDNavigationHelper.h"
#import "UINavigationController_PrivateHelper.h"
#import "MDNavigationTransitionUtility.h"

static const NSInteger tagSnapShot = INT_MAX -102;

@implementation MDModelAnimation

#pragma mark - MDNavigationAnimatedTransitionDelegate

- (NSTimeInterval)transitionDuration
{
    return 0.5f;
}

- (void)pushAnimationWithFromVC:(UIViewController *)fromVC
                           toVC:(UIViewController *)toVC
                  containerView:(UIView *)containerView
              transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    BOOL fromCustomed = [MDNavigationTransitionUtility isBarCustomed:fromVC];
    BOOL toCustomed = [MDNavigationTransitionUtility isBarCustomed:toVC];
    
    CGRect toRect = toVC.view.frame;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if (!CGRectEqualToRect(toRect, screenBounds)) {
        toVC.view.frame = screenBounds;
    }

    [containerView insertSubview:toVC.view aboveSubview:fromVC.view];
    toVC.view.transform = CGAffineTransformMakeTranslation(0, toVC.view.frame.size.height);
    
    UINavigationBar *navigationBar = fromVC.navigationController.navigationBar;
    navigationBar.alpha = fromCustomed ? 0 : 1;
    [UIView animateWithDuration:[self transitionDuration]
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [CATransaction begin];
                         [CATransaction setAnimationDuration:[self transitionDuration]];
                         [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.08 :1.00 :0.08 :1.00]];
                         toVC.view.transform = CGAffineTransformIdentity;
                         navigationBar.alpha = toCustomed ? 0 : 1;
                         [CATransaction commit];
                     }
                     completion:^(BOOL finished) {
                         
                         toVC.view.transform = CGAffineTransformIdentity;
                         fromVC.view.transform = CGAffineTransformIdentity;
                         
                         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                         
                         [fromVC.navigationController setTransitioning:NO];
                         
                         //push动画完成回调
                         id<MDNavigationPushPopDelegate> willPush = [MDNavigationTransitionUtility realController:toVC];
                         if ([willPush respondsToSelector:@selector(mdNavigationDidFinishPush)]) {
                             [willPush mdNavigationDidFinishPush];
                         }
                         
                     }];
}

- (void)popAnimationWithFromVC:(UIViewController *)fromVC
                          toVC:(UIViewController *)toVC
                 containerView:(UIView *)containerView
             transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    //setup container subviews
    [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    [self setupBarSnapShotWithFromVC:fromVC toVC:toVC];//个别情况导航条截图
    
    //动画开始前的初始设置
    fromVC.view.transform = CGAffineTransformIdentity;
    toVC.view.transform = CGAffineTransformIdentity;
    fromVC.view.alpha = 1.f;
    //导航条初始设置
    [self beginPopAppearanceFromVC:fromVC toVC:toVC];
    // 用UIView动画是用来改变view的可动画属性，然后才能做view的显示动画。
    [UIView animateWithDuration:[self transitionDuration]
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [CATransaction begin];
                         [CATransaction setAnimationDuration:[self transitionDuration]];
                         [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.08 :1.00 :0.08 :1.00]];
                         fromVC.view.transform = CGAffineTransformMakeTranslation(0, fromVC.view.frame.size.height);
                         toVC.view.transform = CGAffineTransformIdentity;
                         fromVC.view.alpha = 1.0f;
                         [self endPopAppearanceFromVC:fromVC toVC:toVC];//导航条目标样式设置
                         [CATransaction commit];
                         
                     }
                     completion:^(BOOL finished) {
                         
                         toVC.view.transform = CGAffineTransformIdentity;
                         fromVC.view.transform = CGAffineTransformIdentity;
                         [self completionPopAppearanceFromVC:fromVC toVC:toVC cancelled:transitionContext.transitionWasCancelled];//导航条归位设置
                         
                         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                         
                         [self removeBarSnapShotWithFromVC:fromVC toVC:toVC];
                         
                         [toVC.navigationController setTransitioning:NO];
                         
                         //pop动画完成回调
                         id<MDNavigationPushPopDelegate> willPop = [MDNavigationTransitionUtility realController:fromVC];
                         if ([willPop respondsToSelector:@selector(mdNavigationDidFinishPop:)]) {
                             [willPop mdNavigationDidFinishPop:transitionContext.transitionWasCancelled];
                         }
                         
                     }];
}

#pragma mark - appearance

- (void)beginPopAppearanceFromVC:(UIViewController *)fromVC
                            toVC:(UIViewController *)toVC
{
    UINavigationBar *navigationBar = toVC.navigationController.navigationBar;
    
    BOOL fromCustomed = [MDNavigationTransitionUtility isBarCustomed:fromVC];
    BOOL toCustomed = [MDNavigationTransitionUtility isBarCustomed:toVC];
    
    //reset alpha
    if (!fromCustomed && toCustomed) {
        navigationBar.alpha = 0;
    } else{
        navigationBar.alpha = fromCustomed ? 0 : 1;
    }
}

- (void)endPopAppearanceFromVC:(UIViewController *)fromVC
                          toVC:(UIViewController *)toVC
{
    UINavigationBar *navigationBar = toVC.navigationController.navigationBar;
    
    BOOL fromCustomed = [MDNavigationTransitionUtility isBarCustomed:fromVC];
    BOOL toCustomed = [MDNavigationTransitionUtility isBarCustomed:toVC];
    
    //reset alpha
    if (fromCustomed) {
        navigationBar.alpha = 0;
    }else{
        navigationBar.alpha = toCustomed ? 0 : 1;
    }
}

- (void)completionPopAppearanceFromVC:(UIViewController *)fromVC
                                 toVC:(UIViewController *)toVC
                            cancelled:(BOOL)cancelled
{
    //  动画完成时（completion回调里），如果成功pop（cancelled为NO），fromVC.navigationController 已经出栈，为空
    UINavigationBar *navigationBar = toVC.navigationController.navigationBar;
    
    BOOL fromCustomed = [MDNavigationTransitionUtility isBarCustomed:fromVC];
    BOOL toCustomed = [MDNavigationTransitionUtility isBarCustomed:toVC];
    
    if (cancelled) {
        navigationBar.alpha = fromCustomed ? 0 : 1;
    }else{
        navigationBar.alpha = toCustomed ? 0 : 1;
    }
}

#pragma mark - container subviews

- (void)setupBarSnapShotWithFromVC:(UIViewController *)fromVC
                              toVC:(UIViewController *)toVC
{
    UIViewController *fromRealVC = [MDNavigationTransitionUtility realController:fromVC];
    UIViewController *toRealVC = [MDNavigationTransitionUtility realController:toVC];
    
    BOOL fromCustomed = [MDNavigationTransitionUtility isBarCustomed:fromVC];
    BOOL toCustomed = [MDNavigationTransitionUtility isBarCustomed:toVC];
    
    
    if (fromCustomed && !toCustomed) {
        //自定义导航条界面 pop至 非自定义界面
        UIImage *image = [toVC.navigationController.helper snapForViewController:toRealVC];
        if (image) {
            UIImageView *view = [[UIImageView alloc] initWithImage:image];
            view.tag = tagSnapShot;
            [toVC.view addSubview:view];
        }
    }
    else if (!fromCustomed && toCustomed){
        //非自定义导航条界面 pop至 自定义界面
        UIImage *image = [toVC.navigationController.helper snapForViewController:fromRealVC];
        if (image) {
            UIImageView *view = [[UIImageView alloc] initWithImage:image];
            view.tag = tagSnapShot;
            [fromVC.view addSubview:view];
        }
    }
}

- (void)removeBarSnapShotWithFromVC:(UIViewController *)fromVC
                               toVC:(UIViewController *)toVC
{
    BOOL fromCustomed = [MDNavigationTransitionUtility isBarCustomed:fromVC];
    BOOL toCustomed = [MDNavigationTransitionUtility isBarCustomed:toVC];
    if (fromCustomed && !toCustomed) {
        //自定义导航条界面 pop至 非自定义界面
        UIView *view = [toVC.view viewWithTag:tagSnapShot];
        [view removeFromSuperview];
    }else if (!fromCustomed && toCustomed){
        //非自定义导航条界面 pop至 自定义界面
        UIView *view = [toVC.view viewWithTag:tagSnapShot];
        [view removeFromSuperview];
    }
}

@end
