//
//  PHPhotoLibrary+MDSaveAsset.h
//  CXBeautyKit
//
//  Created by sunfei on 2018/11/27.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHPhotoLibrary (MDSaveAsset)

+ (void)savePhoto:(UIImage *)image toAlbumWithName:(NSString *)albumName completion:(void(^ _Nullable)(PHFetchResult<PHAsset *> * _Nullable, NSError * _Nullable))completion;

+ (void)savePhotos:(NSArray<UIImage *> *)images toAlbumWithName:(NSString *)albumName completion:(void(^ _Nullable)(PHFetchResult<PHAsset *> * _Nullable, NSError * _Nullable))completion;

+ (void)saveVideoAtPath:(NSURL *)url toAlbumWithName:(NSString *)albumName completion:(void(^ _Nullable)(PHFetchResult<PHAsset *> * _Nullable, NSError * _Nullable))completion;

@end

@interface PHPhotoLibrary (MDCheckAuthorizationStatus)

+ (void)checkAlbumAuthorizationStatus:(void(^)(PHAuthorizationStatus))completionBlock;

@end

NS_ASSUME_NONNULL_END
