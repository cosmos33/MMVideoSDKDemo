//
//  MDViewControllerAnimatedTransitioning.m
//  RecordSDK
//
//  Created by 杜林 on 16/9/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MDViewControllerAnimatedTransitioning.h"
#import "MDNavigationTransitionUtility.h"
#import "MDDefaultAnimation.h"

@interface MDViewControllerAnimatedTransitioning ()
@property (nonatomic, assign) UINavigationControllerOperation       operation;
@property (nonatomic, strong) MDDefaultAnimation                    *animation;
@end

@implementation MDViewControllerAnimatedTransitioning

//预留接口type，可根据type扩展动画，利用type来索引animation
+ (instancetype)transitioningWithType:(MDNavigationTransitionType)type
                            operation:(UINavigationControllerOperation)operation
{
    //返回nil为系统默认动画
    //更换animation组件，即可更换动画，
    id<MDNavigationAnimatedTransitionDelegate> animation = [MDNavigationTransitionUtility animationWithType:type];
    MDViewControllerAnimatedTransitioning *trans = [[self alloc] init];
    trans.animation = animation;
    trans.operation = operation;
    
    return trans;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return [self.animation transitionDuration];
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    if (self.operation == UINavigationControllerOperationPush)
    {
        [self.animation pushAnimationWithFromVC:fromViewController
                                           toVC:toViewController
                                  containerView:container
                              transitionContext:transitionContext];
    }
    else if (self.operation == UINavigationControllerOperationPop)
    {
        
        
        [self.animation popAnimationWithFromVC:fromViewController
                                          toVC:toViewController
                                 containerView:container
                             transitionContext:transitionContext];
    }
}

@end
