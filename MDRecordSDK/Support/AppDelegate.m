//
//  AppDelegate.m
//  MDRecordSDK
//
//  Created by sunfei on 2018/11/29.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "AppDelegate.h"
#import "MDRecordContext.h"
#import "MDFaceDecorationManager.h"
#import <objc/runtime.h>
#include <GT/GT.h>

@interface AppDelegate () <GTParaDelegate>

@property (nonatomic, strong) NSTimer *batteryTimer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self initGT];
    
    GT_TIME_SWITCH_SET(YES);
    dispatch_async(dispatch_get_main_queue(), ^{
        GT_TIME_END("app启动时间", "冷启动时间");
    });
    
//    [MDRecordContext netConfiguration];
    [[MDRecordContext faceDecorationManager] requestFaceDecorationIfNeeded];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    GT_TIME_START("app启动时间", "热启动时间");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        GT_TIME_END("app启动时间", "热启动时间");
    });
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)initGT {
#ifndef GT_DEBUG_DISABLE
    NSLog(@"Start GT");
    
    GT_LOG_START("icaftest");
    GT_LOG_D("tagFun","%.2lldMB",GT_UTIL_GET_APP_MEM/(1024*1024));
    GT_LOG_END("icaftest");
    
    // GT Usage(合入) 初始化
    GT_DEBUG_INIT;
    
    // GT Usage(合入) 设置GT logo不旋转及支持方向
    GT_DEBUG_SET_AUTOROTATE(false);
    GT_DEBUG_SET_SUPPORT_ORIENTATIONS(UIInterfaceOrientationMaskPortrait);
    
    // GT Usage(profiler) 打开profiler功能
    GT_TIME_SWITCH_SET(YES);
    
    // GT Usage(输入参数) 注册输入参数
    NSArray *array = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
    GT_OC_IN_REGISTER(@"并发线程数", @"TN", array);
    
    array = [NSArray arrayWithObjects:@"true", @"false", nil];
    GT_OC_IN_REGISTER(@"KeepAlive", @"KA", array);
    
    array = [NSArray arrayWithObjects:@"15", @"10", @"20", nil];
    GT_OC_IN_REGISTER(@"读超时", @"超时", array);
    
    array = [NSArray arrayWithObjects:@"false", @"true", nil];
    GT_OC_IN_REGISTER(@"Cache缓存", @"缓存", array);
    
    array = [NSArray arrayWithObjects:@"150", @"200", nil];
    GT_OC_IN_REGISTER(@"AddedMem", @"ADDM", array);
    
    array = [NSArray arrayWithObjects:@"5", @"4", @"3",@"2",@"1",nil];
    GT_OC_IN_REGISTER(@"Interval", @"INTE", array);
    
    // GT Usage(输入参数) 设置在悬浮框上展示的输入参数
    GT_OC_IN_DEFAULT_ON_AC(@"并发线程数", @"KeepAlive", nil);
    
    // GT Usage(输出参数) 注册输出参数
    GT_OC_OUT_REGISTER(@"下载耗时", @"耗时");
    GT_OC_OUT_REGISTER(@"实际带宽", @"带宽");
    GT_OC_OUT_REGISTER(@"singlePicSpeed", @"SSPD");
    
    GT_OC_OUT_HISTORY_CHECKED_SET(@"下载耗时", YES);
    
    GT_OC_OUT_REGISTER(@"numberOfDownloadedPics", @"NDP");
    GT_OC_OUT_REGISTER(@"本次消耗流量", @"流量");
    
    //    GT_OC_OUT_WARNING_OUT_OF_RANGE_SET(@"App Smoothness", 2, 60, M_GT_UPPER_WARNING_INVALID);
    // debug
    GT_OC_OUT_REGISTER(@"Battery Level",  @"BL");
    GT_OC_OUT_WARNING_OUT_OF_RANGE_SET(@"Battery Level", 1, 0, 75);
    GT_OC_OUT_HISTORY_CHECKED_SET(@"Battery Level", YES);
    GT_OC_OUT_DELEGATE_SET(@"Battery Level", self);
    
    // GT Usage(输出参数) 设置在悬浮框上展示的输出参数
    GT_OC_OUT_DEFAULT_ON_AC(@"App CPU", @"App Memory", @"App Smoothness");
    GT_OC_OUT_DEFAULT_ON_DISABLED(@"singlePicSpeed", @"numberOfDownloadedPics", @"本次消耗流量", nil);
    
    //    GT_OUT_MONITOR_INTERVAL_SET(0.1);
    //    GT_OUT_GATHER_SWITCH_SET(YES);
    
    GT_OC_LOG_D(@"DEMO", @"DEMO GT INIT FINISH.");
    NSLog(@"End GT");
#endif
}

- (void)switchEnable
{
    //    NSLog(@"%s in", __FUNCTION__);
    self.batteryTimer = [NSTimer scheduledTimerWithTimeInterval:10  target:self selector:@selector(batteryTimerNotify:) userInfo:nil repeats:YES];
    
}

- (void)switchDisable
{
    //    NSLog(@"%s in", __FUNCTION__);
    if (self.batteryTimer) {
        [self.batteryTimer invalidate];
        self.batteryTimer = nil;
    }
}

- (void)batteryTimerNotify:(id)sender
{
    //    NSLog(@"%s in", __FUNCTION__);
    // debug
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    //    GT_OC_OUT_SET(@"Battery Level", NO, @"%.0f", [[UIDevice currentDevice] batteryLevel] * 100);
    GT_OC_OUT_SET(@"Battery Level", NO, @"%d", [self batteryLevel]);
}


- (int)batteryLevel
{
    return 0;
//    @try {
//        UIApplication *app = [UIApplication sharedApplication];
//        if (app.applicationState == UIApplicationStateActive) {
//            void *result = nil;
////            object_getInstanceVariable(app, "_statusBar", &result);
//            NSValue *value = [app valueForKey:@"_statusBar"];
//            [value getValue:&result];
//            id status  = (__bridge id)result;
//            for (id a in [status subviews]) {
//                for (id b in [a subviews]) {
//                    if ([NSStringFromClass([b class]) caseInsensitiveCompare:@"UIStatusBarBatteryPercentItemView"] == NSOrderedSame) {
//                        int ret = 0;
//                        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
////                            object_getInstanceVariable(b, "_percentString", &result);
//                            NSValue *value = [b valueForKey:@"_percentString"];
//                            [value getValue:&result];
//                            ret = (int)[(__bridge NSString *)result integerValue];
//                        } else {
////                            object_getInstanceVariable(b, "_capacity", &result);
//                            NSValue *value = [b valueForKey:@"_capacity"];
//                            [value getValue:&result];
//                            ret = (int)result;
//                        }
//                        if (ret > 0 && ret <= 100) {
//                            return ret;
//                        } else {
//                            return 0;
//                        }
//                    }
//                }
//            }
//        }
//
//        return 0;
//    }
//    @catch (...) {
//        return 0;
//    }
}



@end
