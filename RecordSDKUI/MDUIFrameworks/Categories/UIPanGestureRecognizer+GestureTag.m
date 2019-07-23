//
//  UIPanGestureRecognizer+GestureTag.m
//  Pods
//
//  Created by RecordSDK on 2016/12/8.
//
//

#import "UIPanGestureRecognizer+GestureTag.h"
#import <objc/runtime.h>

static char gestureTag;

@implementation UIPanGestureRecognizer (GestureTag)

- (void)setGestureTag:(NSInteger)tag
{
    objc_setAssociatedObject(self, &gestureTag, @(tag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)tag
{
    return [objc_getAssociatedObject(self, &gestureTag) integerValue];
}

@end
