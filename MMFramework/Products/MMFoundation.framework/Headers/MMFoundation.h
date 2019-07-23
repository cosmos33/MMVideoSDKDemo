//
//  MMFoundation.h
//  MMFoundation
//
//  Created by momo783 on 16/5/6.
//  Copyright © 2016年 momo783. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for MMFoundation.
FOUNDATION_EXPORT double MMFoundationVersionNumber;

//! Project version string for MMFoundation.
FOUNDATION_EXPORT const unsigned char MMFoundationVersionString[];


#pragma mark - Json
#import <MMFoundation/MDJSONHelper.h>               // 系统json序列化简单封装


#pragma mark - Util
#import <MMFoundation/MDWeakProxy.h>                // 对对象的弱引用包装
#import <MMFoundation/MDDelayExecutionBridge.h>     // performSelector:afterDelay的中转
#import <MMFoundation/MDRunloopUtil.h>              // 把block添加到Runloop,等当前runloop空闲时执行.
#import <MMFoundation/MFInetAddress.h>              // 把Host和Port包装起来，便于传递和存储
#import <MMFoundation/MFLocation.h>                 // Location
#import <MMFoundation/MFStopWatch.h>                // 提供一个简单的运行时间计时


#pragma mark - NSObject+
#import <MMFoundation/MFDictionaryAccessor.h>       // objectForKey: setObject:forKey: 协议
#import <MMFoundation/NSObject+MFDictionaryAdapter.h>   // stringForKey \arrayForKey \dataForKey ...


#pragma mark - NSString+
#import <MMFoundation/NSString+MFCateory.h>         // isNotEmpty
#import <MMFoundation/NSString+URLEncoding.h>       // URLEncodedString \URLDecodedString


#pragma mark - NSArray+
#import <MMFoundation/NSArray+Safe.h>               // 数组操作保护
#import <MMFoundation/MFSortedArray.h>              // SortedArray

#pragma mark - NSMutableSet+
#import <MMFoundation/NSMutableSet+Safe.h>          // 数组操作保护

#pragma mark - FileUserConfig   文件读写操作简化              
#import <MMFoundation/MFUserConfig.h>
#import <MMFoundation/FileBaseUserConfig.h>

#pragma mark - MultipleThread
#import <MMFoundation/MDThreadSafeDictionary.h>     // 线程安全 Dictionary
#import <MMFoundation/QMSafeMutableArray.h>         // 线程安全 Array
#import <MMFoundation/QMSafeMutableDictionary.h>    // 线程安全 Dictionary
#import <MMFoundation/MFDispatchSource.h>           // UI刷新优化
#import <MMFoundation/MDSynchronizedSet.h>          // 线程安全 Set（使用递归锁且实现NSLocking协议，可在业务层控制同步操作粒度）
#import <MMFoundation/MDThreadSafeSet.h>            // 线程安全 Set


#pragma mark - Timer
#import <MMFoundation/MFTimer.h>                    //
#import <MMFoundation/MDSourceTimer.h>              // 使用dispatch_source_t实现的timer
#import <MMFoundation/NSTimer+MDBlockSupport.h>     //
