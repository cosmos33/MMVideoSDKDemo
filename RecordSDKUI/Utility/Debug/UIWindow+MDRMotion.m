//
//  UIWindow+MDRMotion.m
//  BroadcastChannel
//
//  Created by 符吉胜 on 2019/11/6.
//

#import "UIWindow+MDRMotion.h"
#import "MDRDebugViewWindow.h"

@implementation UIWindow (MDRMotion)

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [MDRDebugViewWindow showDebugViewController];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
}

@end
