/*
 Copyright (c) 2011, Tony Million.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE. 
 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#define kMDR_ReachabilityChangedNotification @"kMDNetworkReachabilityChangedNotification"


/**
 * Does ARC support support GCD objects?
 * It does if the minimum deployment target is iOS 6+ or Mac OS X 8+
 **/
#if TARGET_OS_IPHONE

// Compiling for iOS

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 // iOS 6.0 or later
#define MDR_NEEDS_DISPATCH_RETAIN_RELEASE 0
#else                                         // iOS 5.X or earlier
#define MDR_NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif

#else

// Compiling for Mac OS X

#if MAC_OS_X_VERSION_MIN_REQUIRED >= 1080     // Mac OS X 10.8 or later
#define MDR_NEEDS_DISPATCH_RETAIN_RELEASE 0
#else
#define MDR_NEEDS_DISPATCH_RETAIN_RELEASE 1     // Mac OS X 10.7 or earlier
#endif

#endif

// 新增网络监测功能,能细分窝蜂网类型.
// 实现原理:利用Reachability实现网络状态变化的监听.网络状态变化时,用Reachability判断当前是否为WIFI,如果不为WIFI,则用CTTelephonyNetworkInfo来细分窝蜂网类型
// 注意事项:当网络从A网络切换为B网络时,可能会经历"A"->"Unkonwn"->"B"的过程.虽然Unkonwn的状态很短暂,但是存在读取网络状态时,可能刚好处于Unkonwn的过渡期,所以准确率和实时性达不到100%

// type枚举值和安卓/服务端保持一致,不能随意更改顺序.
typedef enum {
    MDR_NetworkStatusType_Unkonwn     = -1,
    MDR_NetworkStatusType_Unreachable = 0,
    MDR_NetworkStatusType_Wifi        = 1,
    MDR_NetworkStatusType_2G          = 2,
    MDR_NetworkStatusType_3G          = 3,
    MDR_NetworkStatusType_4G          = 4,
} MDR_NetworkStatusType;


//extern NSString *const kReachabilityChangedNotification;

typedef enum 
{
	// Apple NetworkStatus Compatible Names.
	MDR_NotReachable     = 0,
	MDR_ReachableViaWiFi = 2,
	MDR_ReachableViaWWAN = 1
} MDR_NetworkStatus;

@class MDRecordReachability;

typedef void (^MDR_NetworkReachable)(MDRecordReachability * reachability);
typedef void (^MDR_NetworkUnreachable)(MDRecordReachability * reachability);

@interface MDRecordReachability : NSObject

//当前为了处理类似imjreconnectionmanager中需要将对网络状态变化的处理隔离开来的情况（主要是工程中需要处理多个reachability示例的情况）
@property (nonatomic, copy) MDR_NetworkReachable    reachableBlock;
@property (nonatomic, copy) MDR_NetworkUnreachable  unreachableBlock;


@property (nonatomic, assign) BOOL reachableOnWWAN;

// 使用此方法获取单例,保证只有一个Reachability实例
+(MDRecordReachability*)sharedReachabilityForInternetConnection;

+(MDRecordReachability*)reachabilityWithHostName:(NSString*)hostname;
+(MDRecordReachability*)reachabilityForInternetConnection;
+(MDRecordReachability*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;
+(MDRecordReachability*)reachabilityForLocalWiFi;

-(MDRecordReachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

-(BOOL)startNotifier;
-(void)stopNotifier;

-(BOOL)isReachable;
-(BOOL)isReachableViaWWAN;
-(BOOL)isReachableViaWiFi;

// 【新增】获取当前的网络状态类型,获取前,务必先调用startNotifier方法.
- (MDR_NetworkStatusType)currentNetworkStatus;

- (NSString *)currentNetworkStatusString;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired; // Identical DDG variant.
-(BOOL)connectionRequired; // Apple's routine.
// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand;
// Is user intervention required?
-(BOOL)isInterventionRequired;

-(MDR_NetworkStatus)currentReachabilityStatus;
-(SCNetworkReachabilityFlags)reachabilityFlags;
-(NSString*)currentReachabilityString;
-(NSString*)currentReachabilityFlags;

+ (NSString *)stringForNetworkStatus:(MDR_NetworkStatusType)aType;
+ (id)fetchSSIDInfo;

@end
