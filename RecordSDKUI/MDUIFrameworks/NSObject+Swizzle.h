//
//  NSObject+Swizzle.h
//  RecordSDK
//
//  Created by Allen on 18/11/13.
//  Copyright (c) 2013 RecordSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzle)

+ (void)swizzleInstanceSelector:(SEL)originalSelector
                withNewSelector:(SEL)newSelector;

+ (void)swizzleClassSelector:(SEL)originalSelector
             withNewSelector:(SEL)newSelector;

+ (void)swizzleInstanceSelector:(SEL)originalSelector
                withNewSelector:(SEL)newSelector
                    newImpBlock:(id)block;

+ (void)swizzleClassSelector:(SEL)originalSelector
             withNewSelector:(SEL)newSelector
                 newImpBlock:(id)block;

@end
