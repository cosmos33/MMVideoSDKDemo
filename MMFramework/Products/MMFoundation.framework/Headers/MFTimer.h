//
//  MFTimer.h
//  MomoChat
//
//  Created by 晗晖 刘 on 12-9-24.
//  Copyright (c) 2012年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 创建一个计时器，计时器到时自动执行 aDelegate 的 didReceiveTimerMark 方法
 * aInterval -- 计时间隔
 * aDelegate --- 到时执行方法的对象
 * aRepeat   --- 计时器是否重复执行
 * - (void) delay; 推迟计时器
 * - (void) cancel; 取消计时器
 */

@interface MFTimer : NSObject
{
    dispatch_source_t innerTimer;
    
    float interval;
    id delegate;
    bool repeat;
    
    NSString *identifier;
    dispatch_queue_t targetQueue;
}

@property(nonatomic, retain) NSString *identifier;


#pragma mark - init
// 创建一个计时器，计时器到时自动执行 aDelegate 的 didReceiveTimerMark 方法
+ (id) timerWithInterval:(float)aInterval
                delegate:(id)aDelegate
                  repeat:(BOOL)aRepeat;

- (id) initWithInterval:(float)aInterval
               delegate:(id)aDelegate
                 repeat:(BOOL)aRepeat;

+ (id) timerWithInterval:(float)aInterval
                   delay:(float)delay
                delegate:(id)aDelegate
                  repeat:(BOOL)aRepeat
             targetQueue:(dispatch_queue_t)queue;

- (id) initWithInterval:(float)aInterval
                  delay:(float)delay
               delegate:(id)aDelegate
                 repeat:(BOOL)aRepeat
            targetQueue:(dispatch_queue_t)queue;

- (void) dealloc;

#pragma mark - set
- (void) cancel;
- (void) clearDelegateAndCancel;
- (void) delay;

- (void) handleInnerTimer;

@end

#pragma mark - MFTimerDelegate
@protocol MFTimerDelegate
- (void) didReceiveTimerMark:(MFTimer *)sender;
@end