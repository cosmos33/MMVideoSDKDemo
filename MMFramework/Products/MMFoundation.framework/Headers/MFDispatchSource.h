//
//  MFDispatchSource.h
//  MomoChat
//
//  Created by xu bing on 13-6-7.
//  Copyright (c) 2013年 wemomo.com. All rights reserved.
//  此类用于数据频繁更新从而对UI频繁更新调用信号量空置  使得主线程更新UI通过信号量赖进行效率最优控制
//  主线程会在不繁忙的时候相应 如果短时间内过于频繁的信号量增加主线程会进行统一处理

#import <Foundation/Foundation.h>

typedef enum {
    
    refreshType_None            = 0,  // 未设置状态
	refreshType_UI              = 1,  //页面刷新UI
    refreshType_Data            = 2,  //数据刷新
    
} refreshType;


@protocol MFDispatchSourceDelegate <NSObject>

@optional
- (void)refreshUI;
- (void)refreshData;
@end


@interface MFDispatchSource : NSObject
{
    id <MFDispatchSourceDelegate> delegate;
}
@property(nonatomic, assign)id<MFDispatchSourceDelegate>delegate;
+ (id) sourceWithDelegate:(id)aDelegate type:(refreshType)refreshType dataQueue:(dispatch_queue_t)queue;
- (void)addSemaphore;
- (void)clearDelegateAndCancel;
- (id)initWithDelegate:(id)aDelegate type:(refreshType)refreshType dataQueue:(dispatch_queue_t)queue;

@end
