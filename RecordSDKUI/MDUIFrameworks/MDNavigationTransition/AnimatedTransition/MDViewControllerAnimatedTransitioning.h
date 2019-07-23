//
//  MDViewControllerAnimatedTransitioning.h
//  RecordSDK
//
//  Created by 杜林 on 16/9/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MDNavigationTransitionExtra.h"

@interface MDViewControllerAnimatedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

+ (instancetype)transitioningWithType:(MDNavigationTransitionType)type
                            operation:(UINavigationControllerOperation)operation;


@end
