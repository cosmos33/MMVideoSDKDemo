//
//  UIViewController+MDTransitionType.m
//  RecordSDK
//
//  Created by 杜林 on 16/9/26.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "UIViewController+MDTransitionType.h"
#import <objc/runtime.h>

static char KEYTRANSITIONTYPE;
static char KEYINFO;

@implementation UIViewController (MDTransitionType)

- (void)setTransitionType:(MDNavigationTransitionType)type
{
    objc_setAssociatedObject(self, &KEYTRANSITIONTYPE, @(type), OBJC_ASSOCIATION_RETAIN);
}

- (MDNavigationTransitionType)transitionType
{
    return [objc_getAssociatedObject(self, &KEYTRANSITIONTYPE) integerValue];
}

- (void)setMdTransitionInfo:(NSDictionary *)info
{
    objc_setAssociatedObject(self, &KEYINFO, info, OBJC_ASSOCIATION_RETAIN);
}

- (NSDictionary *)mdTransitionInfo
{
    return objc_getAssociatedObject(self, &KEYINFO);
}


@end
