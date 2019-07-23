//
//  MDAssetUtility.h
//  MDChat
//
//  Created by YZK on 2018/12/10.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MDUnifiedRecordSettingItem.h"
#import "MDPhotoLibraryProvider.h"

@interface MDAssetUtility : NSObject

+ (instancetype)sharedInstance;

#pragma mark - 获取资源

/**
 获取所有的相册
 @param mediaType 包含的资源的分类(例如只要视频或只要照片)
 @return 相册数组
 */
- (NSArray<PHAssetCollection*> *)fetchAlbumsWithMediaType:(MDAssetMediaType)mediaType;

/**
 获取指定相册的所有资源
 @param assetCollection 指定相册
 @param options 获取选项
 @param mediaType 指定资源类型
 @param block 完成回调
 */
- (void)fetchAssetsWithAssetCollection:(PHAssetCollection *)assetCollection options:(PHFetchOptions *)options mediaType:(MDAssetMediaType)mediaType completeBlock:(void(^)(NSArray<MDPhotoItem*> *itemArray))block;

/**
 获取全部相册中，指定资源类型的所有资源
 @param mediaType 指定资源类型
 @param maxCount 指定获取的最大数量，为0不限制。如果大于0，则按创建时间排序获取最新的指定数量
 @param block 完成回调
 */
- (void)fetchAllAssetsWithMediaType:(MDAssetMediaType)mediaType completeBlock:(void(^)(NSArray<MDPhotoItem*> *itemArray))block;
- (void)fetchAllAssetsWithMediaType:(MDAssetMediaType)mediaType maxCount:(NSUInteger)maxCount completeBlock:(void(^)(NSArray<MDPhotoItem*> *itemArray))block;

// 获取相册中的前置摄像头的照片
-(void)fetchSelfieAssetsWithMediaType:(MDAssetMediaType)mediaType completeBlock:(void(^)(NSArray<MDPhotoItem*> *itemArray))block;
// 获取最近一个月的照片
-(void)fetchRecentAssetsWithMediaType:(MDAssetMediaType)mediaType completeBlock:(void(^)(NSArray<MDPhotoItem*> *itemArray))block;

#pragma mark - 获取图片(不包含iCloud图片)

// 获取像素大小为120*120低质量的缩略图，适用于快速滑动列表时展示
- (void)fetchLowQualityImageWithPhotoItem:(MDPhotoItem *)item complete:(void(^)(UIImage *image, NSString *identifer))complete;
// 获取列表静止时显示的缩略图（cellSize的大小）
- (void)fetchThumbImageFromPhotoItem:(MDPhotoItem *)item completeBlock:(void(^)(UIImage *image, NSString *identifer))block;
// 获取全屏显示的大图
- (void)fetchBigImageFromPhotoItem:(MDPhotoItem *)item completeBlock:(void(^)(UIImage *image, NSString *identifer))block;
// 获取指定尺寸的小图
- (void)fetchSmallImageWithAsset:(PHAsset *)asset targetSize:(CGSize)size complete:(void(^)(UIImage *image, NSString *identifer))complete;
- (void)synFetchSmallImageWithAsset:(PHAsset *)asset targetSize:(CGSize)size complete:(void(^)(UIImage *image, NSString *identifer))complete;

#pragma mark - 视频相关
// 获取指定视频
-(void)fetchAVAssetFromPHAsset:(PHAsset *)phAsset completeBlock:(void(^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info))completeBlock;
// 从iCloud下载相应的视频
- (PHImageRequestID)fetchAvassetFromICloudWithPHAsset:(PHAsset *)phAsset progressBlock:(void(^)(double progress))progressBlock completeBlock:(void(^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info))completeBlock;
// 取消iCloud下载
- (void)cancelVideoRequest:(PHImageRequestID)requestID;

@end
