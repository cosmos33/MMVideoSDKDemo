//
//  MPMediaLibrary+CustomMediaLibrary.h
//  MDChat
//
//  Created by 王璇 on 2017/4/19.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface MPMediaLibrary (CustomMediaLibrary)

//媒体资料库权限
+ (BOOL)checkMediaPickerAuthorizationStatus;

+ (void)checkMediaPickerWithAuthorizedHandler:(void(^)())authorizedHandler
                          unAuthorizedHandler:(void(^)())unAuthorizedHandler;
@end
