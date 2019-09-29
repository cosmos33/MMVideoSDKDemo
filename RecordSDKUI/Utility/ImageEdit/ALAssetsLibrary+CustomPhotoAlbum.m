//
//  ALAssetsLibrary+CustomPhotoAlbum.m
//  MDChat
//
//  Created by Allen on 13/11/14.
//  Copyright (c) 2014 sdk.com. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MDRecordHeader.h"
#import "Toast/Toast.h"

@implementation ALAssetsLibrary(CustomPhotoAlbum)

- (void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation
                           completionBlock:^(NSURL* assetURL, NSError* error) {
                               if (error != nil) {
                                   if (completionBlock){
                                       completionBlock(error);
                                   }
                                   
                                   return;
                               }
                               
                               [self addAssetURL:assetURL
                                         toAlbum:albumName
                             withCompletionBlock:completionBlock];
                           }];

    });
}

- (void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    __block BOOL albumWasFound = NO;
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
                            if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame){
                                albumWasFound = YES;
                                
                                [self assetForURL:assetURL
                                      resultBlock:^(ALAsset *asset) {
                                          [group addAsset:asset];
                                          if (completionBlock){
                                              completionBlock(nil);
                                          }
                                      } failureBlock:completionBlock];
                                
                                return;
                            }
        
                            if (group == nil && albumWasFound == NO) {
                                __weak ALAssetsLibrary* weakSelf = self;
                                
                                [self addAssetsGroupAlbumWithName:albumName
                                                      resultBlock:^(ALAssetsGroup *group) {
                                                          [weakSelf assetForURL: assetURL
                                                                    resultBlock:^(ALAsset *asset) {
                                                                        [group addAsset:asset];
                                                                        if (completionBlock){
                                                                            completionBlock(nil);
                                                                        }
                                                                    } failureBlock: completionBlock];
                                                      } failureBlock:completionBlock];
                                
                                return;
                            }
                        } failureBlock:completionBlock];
}

+ (BOOL)saveImag:(UIImage *)image toAlubm:(NSString *)ablumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    //if ([ALAssetsLibrary respondsToSelector:@selector(authorizationStatus)]){
        ALAuthorizationStatus status = [[self class] authorizationStatus];
        
        if (status != ALAuthorizationStatusAuthorized) {
            if (status == ALAuthorizationStatusDenied){
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存失败" message:@"图片保存失败，请开启系统照片选项" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开启", nil];
                        [alertView show];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存失败" message:@"图片保存失败，请开启系统照片选项" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                        [alertView show];
                    });
                }
                
                
                return NO;
            }
            else if (status != ALAuthorizationStatusNotDetermined){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[MDRecordContext appWindow] makeToast:@"图片保存失败" duration:1.5f position:CSToastPositionCenter];
                });
                
                return NO;
            }
            
        }

    //}
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library saveImage:image toAlbum:ablumName withCompletionBlock:completionBlock];
    
    return YES;
}

+ (void)saveVideo:(NSURL *)videoURL toAlbum:(NSString *)albumName withCompletionBlock:(SaveVideoCompletion)completionBlock
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error != nil) {
                    if (completionBlock) {
                        completionBlock(error);
                    }
                    return;
                }
                
                [library addAssetURL:assetURL toAlbum:albumName withCompletionBlock:completionBlock];
            }];
        });
    }
}

//将一批图片保存到lbumName的相册中
+ (BOOL)saveBatchImag:(NSArray *)images toAlubm:(NSString *)ablumName withCompletionBlock:(BatchSaveComoletion)resultBlock {
    
    ALAuthorizationStatus status = [[self class] authorizationStatus];
    
    if (status != ALAuthorizationStatusAuthorized) {
        if (status == ALAuthorizationStatusDenied){
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存失败" message:@"图片保存失败，请开启系统照片选项" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开启", nil];
                    [alertView show];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存失败" message:@"图片保存失败，请开启系统照片选项" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alertView show];
                });
            }
            
            return NO;
        }
        else if (status != ALAuthorizationStatusNotDetermined){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[MDRecordContext appWindow] makeToast:@"图片保存失败" duration:1.5f position:CSToastPositionCenter];
            });
            
            return NO;
        }
    }
    
    __block NSInteger finishImageCount = 0;
    __block NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    for (UIImage *imageItem in images) {
        
        [library saveImage:imageItem toAlbum:ablumName withCompletionBlock:^(NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (error) {
                    [resultDict setObjectSafe:@(0) forKey:imageItem];
                } else {
                    [resultDict setObjectSafe:@(1) forKey:imageItem];
                }
                
                finishImageCount++;
                if (finishImageCount == images.count) {
                    resultBlock(resultDict);
                }
            });
        }];
    }
    
    return YES;
}


+ (void)checkAVAuthorizationStatus
{
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

        if (AVAuthorizationStatusDenied == authStatus){
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"开启相机权限" message:@"请在系统设置中开启相机权限" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"开启相机权限" message:@"请在系统设置中开启相机权限或在底部选择相册和表情" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];
            }
            
        }
    }
    
}

+ (void)checkAlbumAuthorizationStatus:(CheckAuthorizationStatusCompletion)completionBlock
{
    ALAuthorizationStatus status = [[self class] authorizationStatus];
    if (status == ALAuthorizationStatusNotDetermined) {
        //由于ios 10上系统相册权限alert需要访问到相册的时候才会有，所以在此访问一下相册
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        
        // When the enumeration is done, 'enumerationBlock' will be called with group set to nil.
        [lib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            if (!group) {
                //回调通知,主要解决系统弹窗没有回调的问题
                ALAuthorizationStatus newStatus = [[self class] authorizationStatus];
                completionBlock(newStatus);
            }
            *stop = YES;
        } failureBlock:^(NSError *error) {
            //回调通知,主要解决系统弹窗没有回调的问题
            ALAuthorizationStatus newStatus = [[self class] authorizationStatus];
            completionBlock(newStatus);
        }];
    } else  {
        
        if (status == ALAuthorizationStatusDenied) {
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"开启相册权限" message:@"请在系统设置中开启相册权限" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开启", nil];
                    [alertView show];
                });
                
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"开启相册权限" message:@"请在系统设置中开启相册权限" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alertView show];
                });
            }
        }
        //回调通知,这里意义不大
        completionBlock(status);
    }
}
#pragma mark-
#pragma mark- UIAlertView delgate method
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex){
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
