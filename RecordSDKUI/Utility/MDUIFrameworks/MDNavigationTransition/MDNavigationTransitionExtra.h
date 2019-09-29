//
//  MDNavigationTransitionExtra.h
//  RecordSDK
//
//  Created by 杜林 on 16/9/26.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#ifndef MDNavigationTransitionExtra_h
#define MDNavigationTransitionExtra_h

typedef NS_ENUM(NSUInteger, MDNavigationTransitionType) {
    MDNavigationTransitionTypeDefault,
    MDNavigationTransitionTypeModel,
    MDNavigationTransitionTypeDown,
    MDNavigationTransitionTypePullDown,
    MDNavigationTransitionTypeScale,
    MDNavigationTransitionTypeHorizonPan
};

#import "UINavigationController+AnimatedTransition.h"
#import "UIViewController+MDTransitionType.h"
#import "MDNavigationTransitionDelegate.h"
#import "MDNavigationTransitionUtility.h"

#endif /* MDNavigationTransitionExtra_h */
