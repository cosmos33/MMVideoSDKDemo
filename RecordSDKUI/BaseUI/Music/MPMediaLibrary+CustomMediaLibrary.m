//
//  MPMediaLibrary+CustomMediaLibrary.m
//  MDChat
//
//  Created by 王璇 on 2017/4/19.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MPMediaLibrary+CustomMediaLibrary.h"
#import "MDRecordHeader.h"

@implementation MPMediaLibrary (CustomMediaLibrary)

+ (BOOL)checkMediaPickerAuthorizationStatus
{
    if ([MDRecordContext systemVersion] <= 9.3) {
        return YES;
    }
    
    MPMediaLibraryAuthorizationStatus status = [MPMediaLibrary authorizationStatus];
    if (status == MPMediaLibraryAuthorizationStatusAuthorized || status == MPMediaLibraryAuthorizationStatusNotDetermined) {
        return YES;
    } else  {
        if (status == MPMediaLibraryAuthorizationStatusDenied) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"开启媒体资料库权限" message:@"请在系统设置中开启媒体资料库权限" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开启", nil];
                [alertView show];
            });
        }
    }
    
    return NO;
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex){
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)checkMediaPickerWithAuthorizedHandler:(void(^)())authorizedHandler
                          unAuthorizedHandler:(void(^)())unAuthorizedHandler {
    if ([UIUtility systemVersion] <= 9.3) {
        authorizedHandler ? authorizedHandler() : nil;
        return;
    }
    
    MPMediaLibraryAuthorizationStatus authStatus = [MPMediaLibrary authorizationStatus];
    if (authStatus == MPMediaLibraryAuthorizationStatusNotDetermined) {
        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
            if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    authorizedHandler ? authorizedHandler() : nil;
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    unAuthorizedHandler ? unAuthorizedHandler() : nil;
                });
            }
        }];
    }else if (authStatus == MPMediaLibraryAuthorizationStatusAuthorized){
        authorizedHandler ? authorizedHandler() : nil;
    }else{
        unAuthorizedHandler ? unAuthorizedHandler() : nil;
    }
}


@end
