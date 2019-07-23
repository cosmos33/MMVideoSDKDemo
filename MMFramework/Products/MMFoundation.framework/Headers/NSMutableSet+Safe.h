//
//  NSMutableSet+Safe.h
//  MMFoundation
//
//  Created by wang.xu_1106 on 16/12/5.
//  Copyright © 2016年 momo783. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableSet<ObjectType> (Safe)

// 排除nil
- (void)addObjectSafe:(ObjectType)object;

- (void)removeObjectSafe:(ObjectType)object;

@end
