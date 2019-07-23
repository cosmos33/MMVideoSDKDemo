//
//  NSTimer+MDBlockSupport.h
//  MomoChat
//
//  Created by Allen on 20/8/14.
//  Copyright (c) 2014 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (MDBlockSupport)

+ (NSTimer *)md_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)(void))block repeats:(BOOL)repeats;

+ (NSTimer *)md_scheduledTimerWithTimeInterval:(NSTimeInterval)interval scheduledTarget:(id)target scheduldSelector:(SEL)selector repeats:(BOOL)repeats;

@end
