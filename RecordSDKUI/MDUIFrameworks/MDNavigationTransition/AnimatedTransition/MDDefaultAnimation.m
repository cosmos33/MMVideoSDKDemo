//
//  MDDefaultAnimation.m
//  RecordSDK
//
//  Created by 杜林 on 16/9/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MDDefaultAnimation.h"
#import "MDNavigationHelper.h"
#import "UINavigationController_PrivateHelper.h"
#import "MDNavigationTransitionUtility.h"
#import "MDNavigationTransitionDelegate.h"

static const NSInteger tagShadow = INT_MAX -100;
static const NSInteger tagMask = INT_MAX -101;
static const NSInteger tagSnapShot = INT_MAX -102;

@implementation MDDefaultAnimation

#pragma mark - MDNavigationAnimatedTransitionDelegate

- (NSTimeInterval)transitionDuration
{
    return 0.3f;
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
    toVC.view.transform = CGAffineTransformMakeTranslation(toVC.view.frame.size.width, 0);
    UIView *maskView = [self setupMaskView:containerView aboveVC:fromVC];
    maskView.alpha = 0;
    
    [self setupBarSnapShotWhenPushFromVC:fromVC toVC:toVC];//个别情况导航条截图
    
    UINavigationBar *navigationBar = fromVC.navigationController.navigationBar;
    navigationBar.alpha = fromCustomed ? 0 : 1;

    [UIView animateWithDuration:[self transitionDuration]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         fromVC.view.transform = CGAffineTransformMakeTranslation(-100.f, 0);
                         toVC.view.transform = CGAffineTransformIdentity;
                         navigationBar.alpha = toCustomed ? 0 : 1;
                         maskView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         
                         toVC.view.transform = CGAffineTransformIdentity;
                         fromVC.view.transform = CGAffineTransformIdentity;
                         
                         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                         
                         [self removeMaskView:containerView];
                         [self removeShadowViewWithVC:fromVC];
                         [self removeShadowViewWithVC:toVC];
                         [self removeBarSnapShotWithFromVC:fromVC toVC:toVC];

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
    UIView *maskView = [self setupMaskView:containerView aboveVC:toVC];//from和to之间的遮罩
    UIView *shadow = [self setupShadowViewWithFromVC:fromVC];//侧滑侧边阴影
    [self setupBarSnapShotWhenPopFromVC:fromVC toVC:toVC];//个别情况导航条截图
    
    
    //动画开始前的初始设置
    fromVC.view.transform = CGAffineTransformIdentity;
    toVC.view.transform = CGAffineTransformMakeTranslation(-100.f, 0);
    fromVC.view.alpha = 1.f;
    //导航条初始设置
    [self beginPopAppearanceFromVC:fromVC toVC:toVC];
    
    //侧滑使用线性动画，否则侧滑时不跟手
    UIViewAnimationOptions option = UIViewAnimationOptionCurveEaseInOut;
    if (transitionContext.isInteractive) {
        //侧滑返回时
        option = UIViewAnimationOptionCurveLinear;
    }
    
    [UIView animateWithDuration:[self transitionDuration]
                          delay:0
                        options:option
                     animations:^{
                         
                         shadow.alpha = 0;
                         maskView.alpha = 0;
                         
                         fromVC.view.transform = CGAffineTransformMakeTranslation(fromVC.view.frame.size.width, 0);
                         toVC.view.transform = CGAffineTransformIdentity;
                         fromVC.view.alpha = 1.0f;
                         [self endPopAppearanceFromVC:fromVC toVC:toVC];//导航条目标样式设置
                     }
                     completion:^(BOOL finished) {
                         
                         toVC.view.transform = CGAffineTransformIdentity;
                         fromVC.view.transform = CGAffineTransformIdentity;
                         
                         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                         
                         //导航条设置，一定要在completeTransition方法执行完后，否则设置不生效
                         [self completionPopAppearanceFromVC:fromVC toVC:toVC cancelled:transitionContext.transitionWasCancelled];//导航条归位设置
                         
                         [self removeMaskView:containerView];
                         [self removeShadowViewWithVC:fromVC];
                         [self removeShadowViewWithVC:toVC];
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

- (UIView *)setupShadowViewWithFromVC:(UIViewController *)fromVC
{
    UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, 10, fromVC.view.frame.size.height)];
    shadow.image = [UIImage imageNamed:@"UIBundle.bundle/nav_trasition_shadow.png"];
    shadow.tag = tagShadow;
    shadow.alpha = 0.6f;
    [fromVC.view addSubview:shadow];
    return shadow;
}

- (void)removeShadowViewWithVC:(UIViewController *)viewController
{
    UIView *shadow = [viewController.view viewWithTag:tagShadow];
    if (shadow) {
        [shadow removeFromSuperview];
    }
}

- (void)setupBarSnapShotWhenPushFromVC:(UIViewController *)fromVC
                                  toVC:(UIViewController *)toVC
{
    UIViewController *fromRealVC = [MDNavigationTransitionUtility realController:fromVC];
    
    BOOL fromCustomed = [MDNavigationTransitionUtility isBarCustomed:fromVC];
    BOOL toCustomed = [MDNavigationTransitionUtility isBarCustomed:toVC];
    
    MDNavigationHelper *helper = fromVC.navigationController.helper;
    
    if (!fromCustomed && toCustomed){
        //非自定义导航条界面 push至 自定义界面
        UIImage *image = [helper snapForViewController:fromRealVC];
        if (image) {
            UIImageView *view = [[UIImageView alloc] initWithImage:image];
            view.tag = tagSnapShot;
            [fromVC.view addSubview:view];
        }
    }
}


- (void)setupBarSnapShotWhenPopFromVC:(UIViewController *)fromVC
                                 toVC:(UIViewController *)toVC
{
    UIViewController *fromRealVC = [MDNavigationTransitionUtility realController:fromVC];
    UIViewController *toRealVC = [MDNavigationTransitionUtility realController:toVC];
    
    BOOL fromCustomed = [MDNavigationTransitionUtility isBarCustomed:fromVC];
    BOOL toCustomed = [MDNavigationTransitionUtility isBarCustomed:toVC];
    
    MDNavigationHelper *helper = toVC.navigationController.helper;
    if (fromCustomed && !toCustomed) {
        //自定义导航条界面 pop至 非自定义界面
        UIImage *image = [helper snapForViewController:toRealVC];
        if (image) {
            UIImageView *view = [[UIImageView alloc] initWithImage:image];
            view.tag = tagSnapShot;
            [toVC.view addSubview:view];
        }
    }
    else if (!fromCustomed && toCustomed){
        //非自定义导航条界面 pop至 自定义界面
        UIImage *image = [helper snapForViewController:fromRealVC];
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
        //自定义导航条界面 至 非自定义界面
        UIView *view = [toVC.view viewWithTag:tagSnapShot];
        [view removeFromSuperview];
    }else if (!fromCustomed && toCustomed){
        //非自定义导航条界面 至 自定义界面
        UIView *view = [fromVC.view viewWithTag:tagSnapShot];
        [view removeFromSuperview];
    }
}

- (UIView *)setupMaskView:(UIView *)containerView
                  aboveVC:(UIViewController *)vc
{
    UIView *maskView = [[UIView alloc] initWithFrame:containerView.bounds];
    maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15f];
    maskView.tag = tagMask;
    [containerView insertSubview:maskView aboveSubview:vc.view];
    return maskView;
}

- (void)removeMaskView:(UIView *)containerView
{
    UIView *maskView = [containerView viewWithTag:tagMask];
    if (maskView) {
        [maskView removeFromSuperview];
    }
}

@end
