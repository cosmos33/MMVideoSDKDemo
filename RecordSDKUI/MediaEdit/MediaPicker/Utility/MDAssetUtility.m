//
//  MDAssetUtility.m
//  MDChat
//
//  Created by YZK on 2018/12/10.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDAssetUtility.h"
#import "MDAlbumAssetLibrary.h"

@interface MDAssetUtility ()
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@end

@implementation MDAssetUtility

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageManager = [[PHCachingImageManager alloc] init];
    }
    return self;
}

/**
 获取所有的相册
 
 @param mediaType 包含的资源的分类(例如只要视频或只要照片)
 */
- (NSArray *)fetchAlbumsWithMediaType:(MDAssetMediaType)mediaType {
    NSMutableArray *albumArray = [NSMutableArray array];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        
        __block BOOL haveResource = NO;

        PHFetchResult *group = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        [group enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PHAsset class]]) {
                PHAsset *asset = (PHAsset *)obj;
                if ((asset.mediaType == PHAssetMediaTypeImage && mediaType != MDAssetMediaTypeOnlyVideo) || (asset.mediaType == PHAssetMediaTypeVideo && mediaType != MDAssetMediaTypeOnlyPhoto)){
                    haveResource = YES;
                    *stop = YES;
                }
            }
        }];
        if (group.count > 0 && haveResource) {
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                [albumArray insertObject:collection atIndex:0];
            } else {
                [albumArray addObject:collection];
            }
        }
    }];
    
    
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        
        __block BOOL haveResource = NO;
        
        PHFetchResult *group = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        [group enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PHAsset class]]) {
                PHAsset *asset = (PHAsset *)obj;
                if ((asset.mediaType == PHAssetMediaTypeImage && mediaType != MDAssetMediaTypeOnlyVideo) || (asset.mediaType == PHAssetMediaTypeVideo && mediaType != MDAssetMediaTypeOnlyPhoto)){
                    haveResource = YES;
                    *stop = YES;
                }
            }
        }];
        if (group.count > 0 && haveResource) {
            [albumArray addObject:collection];
        }
    }];
    
    return albumArray;
}


- (void)_wrapItemWithFetchResult:(PHFetchResult<PHAsset*> *)assetsGroup mediaType:(MDAssetMediaType)mediaType completeBlock:(void(^)(NSArray<MDPhotoItem*> *itemArray))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *assetsArray = [[NSMutableArray alloc] init];
        [assetsGroup enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([asset isKindOfClass:[PHAsset class]]) {
                if ( (asset.mediaType == PHAssetMediaTypeImage && mediaType != MDAssetMediaTypeOnlyVideo) ||
                    (asset.mediaType == PHAssetMediaTypeVideo && mediaType != MDAssetMediaTypeOnlyPhoto) ) {
                    MDPhotoItem *item = [MDPhotoItem photoItemWithAsset:asset];
                    [assetsArray addObject:item];
                }
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(assetsArray);
        });
    });
}

/**
 获取指定相册的所有资源
 
 @param assetCollection 指定相册
 @param mediaType 指定资源类型
 @param block 完成回调
 */
- (void)fetchAssetsWithAssetCollection:(PHAssetCollection *)assetCollection options:(PHFetchOptions *)options mediaType:(MDAssetMediaType)mediaType completeBlock:(void(^)(NSArray<MDPhotoItem*> *itemArray))block {
    PHFetchResult<PHAsset*> *assetsGroup = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];    
    [self _wrapItemWithFetchResult:assetsGroup mediaType:mediaType completeBlock:block];
}

/**
 获取全部相册中，指定资源类型的所有资源
 
 @param mediaType 指定资源类型
 @param maxCount 指定获取的最大数量，为0不限制。如果大于0，则按创建时间排序获取最新的指定数量
 @param block 完成回调
 */
- (void)fetchAllAssetsWithMediaType:(MDAssetMediaType)mediaType completeBlock:(void(^)(NSArray<MDPhotoItem*> *itemArray))block {
    [self fetchAllAssetsWithMediaType:mediaType maxCount:0 completeBlock:block];
}
- (void)fetchAllAssetsWithMediaType:(MDAssetMediaType)mediaType maxCount:(NSUInteger)maxCount completeBlock:(void(^)(NSArray<MDPhotoItem*> *itemArray))block {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    if (maxCount > 0) { // 按创建日期排序获取最新的maxCount张 照片
        options.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"ascending:NO]];
    }
    options.fetchLimit = maxCount;
    
    PHFetchResult<PHAsset*> *group = [MDAlbumAssetLibrary fetchAllAssetsWithOption:options];
    [self _wrapItemWithFetchResult:group mediaType:mediaType completeBlock:block];
}

// 获取相册中的前置摄像头的照片
-(void)fetchSelfieAssetsWithMediaType:(MDAssetMediaType)mediaType completeBlock:(void(^)(NSArray<MDPhotoItem*> *itemArray))block {
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits options:nil];
    PHAssetCollection *assetCollection = smartAlbums.firstObject;
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors= @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    [self fetchAssetsWithAssetCollection:assetCollection options:options mediaType:mediaType completeBlock:block];
}

// 获取最近一个月的照片
-(void)fetchRecentAssetsWithMediaType:(MDAssetMediaType)mediaType completeBlock:(void(^)(NSArray<MDPhotoItem*> *itemArray))block {
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
    PHAssetCollection *assetCollection = smartAlbums.firstObject;
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors= @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    [self fetchAssetsWithAssetCollection:assetCollection options:options mediaType:mediaType completeBlock:block];
}


#pragma mark - 获取图片

// 获取像素大小为120*120低质量的缩略图，适用于快速滑动列表时展示
- (void)fetchLowQualityImageWithPhotoItem:(MDPhotoItem *)item complete:(void(^)(UIImage *image, NSString *identifer))block {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    [self _fetchImageWithAsset:item.asset targetSize:CGSizeMake(120, 120) option:option complete:block];
}

// 获取列表静止时显示的缩略图（cellSize的大小）
- (void)fetchThumbImageFromPhotoItem:(MDPhotoItem *)item completeBlock:(void(^)(UIImage *image, NSString *identifer))block {
    static CGFloat cellSize = 0;
    if (!cellSize) cellSize = floor((MDScreenWidth-30.0)/3.0)*2;
    [self _fetchImageWithAsset:item.asset targetSize:CGSizeMake(cellSize, cellSize) complete:block];
}
// 获取全屏显示的大图
- (void)fetchBigImageFromPhotoItem:(MDPhotoItem *)item completeBlock:(void(^)(UIImage *image, NSString *identifer))block {
    [self _fetchImageWithAsset:item.asset targetSize:CGSizeMake(MDScreenWidth*2, MDScreenHeight*2) complete:block];
}
// 获取指定尺寸的缩略图
- (void)fetchSmallImageWithAsset:(PHAsset *)asset targetSize:(CGSize)size complete:(void(^)(UIImage *image, NSString *identifer))complete {
    [self _fetchImageWithAsset:asset targetSize:size complete:complete];
}
// 获取指定尺寸的缩略图
- (void)synFetchSmallImageWithAsset:(PHAsset *)asset targetSize:(CGSize)size complete:(void(^)(UIImage *image, NSString *identifer))complete {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.synchronous = YES;
    [self _fetchImageWithAsset:asset targetSize:size option:option complete:complete];
}

- (void)_fetchImageWithAsset:(PHAsset *)asset targetSize:(CGSize)size complete:(void(^)(UIImage *image, NSString *identifer))complete {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [self _fetchImageWithAsset:asset targetSize:size option:option complete:complete];
}

- (void)_fetchImageWithAsset:(PHAsset *)asset targetSize:(CGSize)size option:(PHImageRequestOptions *)option complete:(void(^)(UIImage *image, NSString *identifer))complete {
    [self.imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * result, NSDictionary * info) {
        if (complete) complete(result, asset.localIdentifier);
    }];
}


#pragma mark - 视频相关
// 获取指定视频
-(void)fetchAVAssetFromPHAsset:(PHAsset *)phAsset completeBlock:(void(^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info))completeBlock {
    if (phAsset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        [self.imageManager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if (completeBlock) {
                completeBlock(asset, audioMix, info);
            }
        }];
    }
}

// 从iCloud下载相应的视频
- (PHImageRequestID)fetchAvassetFromICloudWithPHAsset:(PHAsset *)phAsset progressBlock:(void(^)(double progress))progressBlock completeBlock:(void(^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info))completeBlock {
    if (phAsset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progressBlock) {
                    progressBlock(progress);
                }
            });
        };
        return [self.imageManager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if (completeBlock) {
                completeBlock(asset, audioMix, info);
            }
        }];
    }
    if (completeBlock) {
        completeBlock(nil, nil, nil);
    }
    return 0;
}

// 取消iCloud下载
- (void)cancelVideoRequest:(PHImageRequestID)requestID {
    [self.imageManager cancelImageRequest:requestID];
}

@end
