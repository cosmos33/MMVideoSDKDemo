//
//  NSObject+Swizzle.m
//  RecordSDK
//
//  Created by Allen on 18/11/13.
//  Copyright (c) 2013 RecordSDK. All rights reserved.
//

#import "NSObject+Swizzle.h"
#import <objc/runtime.h>

@implementation NSObject (Swizzle)

+ (void)swizzleInstanceSelector:(SEL)originalSelector
                withNewSelector:(SEL)newSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    
    BOOL methodAdded = class_addMethod([self class],
                                       originalSelector,
                                       method_getImplementation(newMethod),
                                       method_getTypeEncoding(newMethod));
    
    if (methodAdded) {
        class_replaceMethod([self class],
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

void SwizzleClassMethod(Class c, SEL orig, SEL new) {
    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(c, new);
    
    c = object_getClass((id)c);
    
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

+ (void)swizzleClassSelector:(SEL)originalSelector
             withNewSelector:(SEL)newSelector
{
    SwizzleClassMethod(self, originalSelector, newSelector);
}

+ (void)swizzleInstanceSelector:(SEL)originalSelector
                withNewSelector:(SEL)newSelector
                    newImpBlock:(id)block
{
    IMP newImp = imp_implementationWithBlock(block);
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    if (originalMethod && class_addMethod(self, newSelector, newImp, method_getTypeEncoding(originalMethod))) {
        Method newMethod = class_getInstanceMethod(self, newSelector);
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void)swizzleClassSelector:(SEL)originalSelector
             withNewSelector:(SEL)newSelector
                 newImpBlock:(id)block
{
    IMP newImp = imp_implementationWithBlock(block);
    Method originalMethod = class_getClassMethod(self, originalSelector);
    if (originalMethod && class_addMethod(object_getClass(self), newSelector, newImp, method_getTypeEncoding(originalMethod))) {
        Method newMethod = class_getClassMethod(self, newSelector);
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end
