//
//  ALAssetsLibrary+CustomPhotoAlbum.h
//  MDChat
//
//  Created by Allen on 13/11/14.
//  Copyright (c) 2014 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

typedef void(^SaveImageCompletion)(NSError* error);
typedef void(^SaveVideoCompletion)(NSError* error);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
typedef void(^CheckAuthorizationStatusCompletion)(ALAuthorizationStatus status);
#pragma clang diagnostic pop
typedef void (^BatchSaveComoletion)(NSDictionary *result);

@interface ALAssetsLibrary(CustomPhotoAlbum)

- (void)saveImage:(UIImage *)image toAlbum:(NSString *)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;

- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;

//将图片存到名字为albumName的相册中
+ (BOOL)saveImag:(UIImage *)image toAlubm:(NSString *)ablumName withCompletionBlock:(SaveImageCompletion)completionBlock;

//将视频存到名字为albumName的相册中
+ (void)saveVideo:(NSURL *)videoURL toAlbum:(NSString *)albumName withCompletionBlock:(SaveVideoCompletion)completionBlock;

//将一批图片保存到lbumName的相册中
+ (BOOL)saveBatchImag:(NSArray *)images toAlubm:(NSString *)ablumName withCompletionBlock:(BatchSaveComoletion)resultBlock;

//检查照相的权限
+ (void)checkAVAuthorizationStatus;

//读取相册的权限检查
+ (void)checkAlbumAuthorizationStatus:(CheckAuthorizationStatusCompletion)completionBlock;

@end
