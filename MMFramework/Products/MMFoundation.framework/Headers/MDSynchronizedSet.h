//
//  MDSynchronizedSet.h
//  MomoChat
//
//  Created by wang.xu_1106 on 16/8/4.
//  Copyright © 2016年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  线程安全NSMutableSet，大部分操作(NSSet.h中定义的全部)使用递归锁保证同步。同时使用同一把锁实现NSLocking协议，可通过lock自身实现自定义业务与其它操作线程安全。
 */
@interface MDSynchronizedSet<ObjectType> : NSMutableSet<ObjectType> <NSLocking>

@end
