//
//  MDUnifiedRecordViewController+Permission.m
//  MDChat
//
//  Created by 符吉胜 on 2017/6/3.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordViewController+Permission.h"
#import "UIAlertView+Blocks.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

static const NSInteger kNoRecordAudioPermissionAlertTag = 40000;
static const NSInteger kNoCameraPermissionAlertTag = 40001;
static const NSInteger kNoCameraAndRecordAudioPermissionAlertTag = 40002;

@implementation MDUnifiedRecordViewController (Permission)

//检查权限
+ (BOOL)checkDevicePermission
{
    // viewDidLoad里检查权限
    AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    ALAuthorizationStatus assetAuthorizationStatus = [ALAssetsLibrary authorizationStatus];
    
    if ((videoAuthorizationStatus == AVAuthorizationStatusAuthorized || videoAuthorizationStatus == AVAuthorizationStatusNotDetermined) &&
        (audioAuthorizationStatus == AVAuthorizationStatusAuthorized || audioAuthorizationStatus == AVAuthorizationStatusNotDetermined) &&
        (assetAuthorizationStatus == ALAuthorizationStatusAuthorized || assetAuthorizationStatus == ALAuthorizationStatusNotDetermined) ) {
        // 如果录音和摄像头权限都打开了,或者系统还没有向用户确认,则不用管.
        return YES;
    } else if ((videoAuthorizationStatus == AVAuthorizationStatusRestricted || videoAuthorizationStatus == AVAuthorizationStatusDenied) &&
               (audioAuthorizationStatus == AVAuthorizationStatusRestricted || audioAuthorizationStatus == AVAuthorizationStatusDenied)) {
        // 如果录音和摄像头权限都没打开
        [self haveNoCameraAndRecordAudioPermission];
    } else if ((videoAuthorizationStatus == AVAuthorizationStatusRestricted || videoAuthorizationStatus == AVAuthorizationStatusDenied)) {
        [self haveNoCameraPermission];
        
    } else if ((assetAuthorizationStatus == ALAuthorizationStatusRestricted || assetAuthorizationStatus == ALAuthorizationStatusDenied)) {
        [self haveNoAlbumPremission];
        
    }else {
        [self haveNoRecordAudioPermission];
    }

    
    return NO;
}

+ (void)haveNoRecordAudioPermission
{
    if ([UIUtility systemVersion] < 8.0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法使用麦克风"
                                                            message:@"可以到手机系统\"设置-隐私-麦克风\"中开启"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确认"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法使用麦克风"
                                                            message:@"可以到手机系统\"设置-隐私-麦克风\"中开启"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"开启麦克风", nil];
        alertView.tag = kNoRecordAudioPermissionAlertTag;
        [alertView show];
    }
}

+ (void)haveNoCameraPermission
{
    if ([UIUtility systemVersion] < 8.0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法访问相机"
                                                            message:@"可以到手机系统\"设置-隐私-相机\"中开启"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确认"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法访问相机"
                                                            message:@"可以到手机系统\"设置-隐私-相机\"中开启"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"开启相机", nil];
        alertView.tag = kNoCameraPermissionAlertTag;
        [alertView show];
    }
}

+ (void)haveNoCameraAndRecordAudioPermission
{
    if ([UIUtility systemVersion] < 8.0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法使用麦克风和相机"
                                                            message:@"可以到手机系统\"设置-隐私\"中开启"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确认"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法使用麦克风和相机"
                                                            message:@"可以到手机系统\"设置-隐私\"中开启"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"开启", nil];
        alertView.tag = kNoCameraAndRecordAudioPermissionAlertTag;
        [alertView show];
    }
}

+(void)haveNoAlbumPremission {

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法使用相册" message:@"可以到手机系统\"设置-隐私-照片\"中开启" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开启", nil];
    alertView.tag = kNoCameraPermissionAlertTag;
    [alertView show];
}

+ (BOOL)checkDevicePermissionWithCancelHandleBlock:(void(^)())block
{
    AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if ((videoAuthorizationStatus == AVAuthorizationStatusAuthorized || videoAuthorizationStatus == AVAuthorizationStatusNotDetermined) &&
        (audioAuthorizationStatus == AVAuthorizationStatusAuthorized || audioAuthorizationStatus == AVAuthorizationStatusNotDetermined)) {
        // 如果录音和摄像头权限都打开了,或者系统还没有向用户确认,则不用管.
        return YES;
    } else if ((videoAuthorizationStatus == AVAuthorizationStatusRestricted || videoAuthorizationStatus == AVAuthorizationStatusDenied) &&
               (audioAuthorizationStatus == AVAuthorizationStatusRestricted || audioAuthorizationStatus == AVAuthorizationStatusDenied)) {
        
        [UIAlertView showWithTitle:@"无法使用麦克风和相机"
                           message:@"可以到手机系统\"设置-隐私\"中开启"
                 cancelButtonTitle:@"取消"
                 otherButtonTitles:@[@"开启"]
                          tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                              if (buttonIndex != alertView.cancelButtonIndex) {
                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                              }
                              else {
                                  if (block) {
                                      block();
                                  }
                              }
                          }];
        
    } else if ((videoAuthorizationStatus == AVAuthorizationStatusRestricted || videoAuthorizationStatus == AVAuthorizationStatusDenied)) {
        [UIAlertView showWithTitle:@"无法访问相机"
                           message:@"可以到手机系统\"设置-隐私-相机\"中开启"
                 cancelButtonTitle:@"取消"
                 otherButtonTitles:@[@"开启相机"]
                          tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                              if (buttonIndex != alertView.cancelButtonIndex) {
                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                              }
                              else {
                                  if (block) {
                                      block();
                                  }
                              }
                          }];
        
    } else {
        [UIAlertView showWithTitle:@"无法使用麦克风"
                           message:@"可以到手机系统\"设置-隐私-麦克风\"中开启"
                 cancelButtonTitle:@"取消"
                 otherButtonTitles:@[@"开启麦克风"]
                          tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                              if (buttonIndex != alertView.cancelButtonIndex) {
                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                              }
                              else {
                                  if (block) {
                                     block();
                                  }
                              }
                          }];
        
    }
    
    return NO;
    
}


+ (BOOL)checkAudioDevicePermissionWithCancelHandleBlock:(void(^)())block
{
    AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    BOOL havePermission = audioAuthorizationStatus == AVAuthorizationStatusAuthorized || audioAuthorizationStatus == AVAuthorizationStatusNotDetermined;
    
    if (!havePermission) {
        [UIAlertView showWithTitle:@"无法使用麦克风"
                           message:@"可以到手机系统\"设置-隐私-麦克风\"中开启"
                 cancelButtonTitle:@"取消"
                 otherButtonTitles:@[@"开启麦克风"]
                          tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                              if (buttonIndex != alertView.cancelButtonIndex) {
                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                              }
                              else {
                                  if (block) {
                                      block();
                                  }
                              }
                          }];
    }
    
    return havePermission;
}

+ (BOOL)checkCameraDevicePermissionWithCancelHandleBlock:(void(^)())block
{
    AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    BOOL havePermission = videoAuthorizationStatus == AVAuthorizationStatusAuthorized || videoAuthorizationStatus == AVAuthorizationStatusNotDetermined;
    if (!havePermission) {
        [UIAlertView showWithTitle:@"无法访问相机"
                           message:@"可以到手机系统\"设置-隐私-相机\"中开启"
                 cancelButtonTitle:@"取消"
                 otherButtonTitles:@[@"开启相机"]
                          tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                              if (buttonIndex != alertView.cancelButtonIndex) {
                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                              }
                              else {
                                  if (block) {
                                      block();
                                  }
                              }
                          }];
    }
    return havePermission;
}

#pragma mark - UIAlertViewDelegate
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == kNoRecordAudioPermissionAlertTag || alertView.tag == kNoCameraPermissionAlertTag || alertView.tag == kNoCameraAndRecordAudioPermissionAlertTag) {
            if ([UIUtility systemVersion] >= 8.0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }
    }
}

@end
