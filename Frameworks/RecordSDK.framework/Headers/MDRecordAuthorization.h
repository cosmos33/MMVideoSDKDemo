//
//  MDRecordAuthorization.h
//  CXBeautyKit
//
//  Created by sunfei on 2018/8/3.
//

#import <Foundation/Foundation.h>

@interface MDRecordAuthorization : NSObject

// when authorization is authorized or not determined, will return YES, otherwise return NO.

// asset, video and audio capture device permission
+ (void)checkAllDevicePermissionWithBlock:(void(^)(BOOL videoAuthorization, BOOL audioAuthorization, BOOL assetAuthorization))block;

// video and audio capture permission
+ (void)checkVideoAndAudioCaptureDevicePermissionWithBlock:(void(^)(BOOL videoAuthorization, BOOL audioAuthorizatio))block;

// audio capture device permission
+ (void)checkAudioCaptureDevicePermissionWithBlock:(void(^)(BOOL audioAuthorization))block;

// video capture device permission
+ (void)checkVideoCaptureDevicePermissionWithBlock:(void(^)(BOOL videoAuthorization))block;

@end
