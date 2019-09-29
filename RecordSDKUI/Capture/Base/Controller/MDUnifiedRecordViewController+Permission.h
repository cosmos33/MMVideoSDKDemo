//
//  MDUnifiedRecordViewController+Permission.h
//  MDChat
//
//  Created by 符吉胜 on 2017/6/3.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordViewController.h"

@interface MDUnifiedRecordViewController (Permission)

+ (BOOL)checkDevicePermission;
+ (void)haveNoRecordAudioPermission;
+ (void)haveNoCameraPermission;
+ (void)haveNoCameraAndRecordAudioPermission;

+ (BOOL)checkDevicePermissionWithCancelHandleBlock:(void(^)())block;

+ (BOOL)checkAudioDevicePermissionWithCancelHandleBlock:(void(^)())block;
+ (BOOL)checkCameraDevicePermissionWithCancelHandleBlock:(void(^)())block;

@end
