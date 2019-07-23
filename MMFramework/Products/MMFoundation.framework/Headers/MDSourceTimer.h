//
//  MDSourceTimer.h
//  MomoChat
//
//  Created by Allen on 3/25/16.
//  Copyright © 2016 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 使用dispatch_source_t实现的timer，不会显式的retain timer的target，可以指定dispatch_source_t的queue，如果不指定会使用系统的dispatch_global_queue  
 */

typedef NS_ENUM(NSUInteger, MDSourceTimerMode)
{
    MDSourceTimerModeRunWhileApplicationActive  = 0,
    MDSourceTimerModeAlwaysRun                  = 1
};

@interface MDSourceTimer : NSObject

+ (MDSourceTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval targetQueue:(nullable dispatch_queue_t)targetQueue target:(id)target selector:(SEL)selector userInfo:(nullable id)userInfo repeat:(BOOL)yesOrNo;

+ (MDSourceTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval targetQueue:(nullable dispatch_queue_t)targetQueue target:(id)target selector:(SEL)selector userInfo:(nullable id)userInfo repeat:(BOOL)yesOrNo;


@property (nullable, readonly, strong) id            userInfo;

@property (nonatomic, assign) NSInteger              nanoSecondsOfLeeway;

@property (readonly) NSTimeInterval                  timeInterval;

//default mode is MDSourceTimerModeRunWhenApplicationActive
@property (nonatomic, assign) MDSourceTimerMode      timerMode;

@property (readonly, getter=isValid)BOOL             valid;

- (void)invalidate;

- (void)fire;

@end

NS_ASSUME_NONNULL_END
