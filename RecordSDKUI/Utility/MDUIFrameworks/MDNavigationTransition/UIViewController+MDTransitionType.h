//
//  UIViewController+MDTransitionType.h
//  RecordSDK
//
//  Created by 杜林 on 16/9/26.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDNavigationTransitionExtra.h"

@interface UIViewController (MDTransitionType)

- (void)setTransitionType:(MDNavigationTransitionType)type;
- (MDNavigationTransitionType)transitionType;

- (void)setMdTransitionInfo:(NSDictionary *)info;
- (NSDictionary *)mdTransitionInfo;

@end
