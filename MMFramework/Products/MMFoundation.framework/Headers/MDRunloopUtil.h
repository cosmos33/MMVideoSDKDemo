//
//  MDRunloopUtil.h
//  MomoChat
//
//  Created by zhang.yupeng on 15/12/21.
//  Copyright © 2015年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RunLoopIdleBlock)(void);

@interface MDRunloopUtil : NSObject

/**
 把block添加到Runloop,等当前runloop空闲时执行.
 
 @param block 当前block会被持有直到runloop 即将空闲并执行完任务后释放.
 */
+ (void)addRunLoopIdleBlock:(RunLoopIdleBlock)block;

@end
