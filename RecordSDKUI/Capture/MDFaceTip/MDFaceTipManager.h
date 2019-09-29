//
//  MDFaceTipManager.h
//  MDChat
//
//  Created by sdk on 2017/6/22.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MDFaceTipShowDelegate.h"

/**
 *  管理人脸素材附带提示，前置和后置区分开来，显示逻辑为：配置可以配置两级显示文案，
 *  如果需人脸检测提示则配两级文案，先提示一级文案，当人脸检测到了提示二级文案，二级文案默认显示2s,
 *  如果不需要人脸检测，则配置一级文案，文案显示默认提示2秒
 */

@class MDFaceTipItem;

@interface MDFaceTipManager : NSObject

@property (readonly) MDFaceTipItem *currentItem;
@property (readonly) BOOL  shouldContinue;

/**
 *  创建提示文案管理实例
 */
+ (instancetype)managerWithDictionary:(NSDictionary *)dic
                             position:(AVCaptureDevicePosition)position
                           showTarget:(id<MDFaceTipShowDelegate>)showTarget;


/**
 *  创建无变脸素材的露脸提示文案
 */
- (instancetype)initWithFaceTipItem:(MDFaceTipItem *)faceTipItem
                           position:(AVCaptureDevicePosition)position
                         showTarget:(id <MDFaceTipShowDelegate>)showTarget;

/**
 *  开始显示逻辑处理,开始提示一级文案
 */
- (void)start;

/**
 *  停止显示逻辑处理，tip隐藏提示
 */
- (void)stop;

/**
 *  输入状态变化，触发显示逻辑变更
 */
- (void)input:(MDFaceTipSignal)signal;

@end
