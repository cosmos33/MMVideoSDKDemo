//
//  MDThreadSafeSet.h
//  MomoChat
//
//  Created by wang.xu_1106 on 16/8/5.
//  Copyright © 2016年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  线程安全NSMutableSet，使用自旋锁保证多线程操作安全
 */
@interface MDThreadSafeSet<ObjectType> : NSMutableSet<ObjectType>

@end
