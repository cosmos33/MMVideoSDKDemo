//
//  MDPhotoLibraryProvider.m
//  MDChat
//
//  Created by 杜林 on 16/6/6.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDPhotoLibraryProvider.h"
#import "UIImage+MDUtility.h"
#import "MDImageDataProvider.h"
#import <MMFoundation/QMSafeMutableArray.h>
#import "ImageFixOrientationHelper.h"
#import "MDAlbumAssetLibrary.h"
#import <MMFoundation/MMFoundation.h>
#import "JSONKit.h"
#import "MDRecordUtility.h"

#define kImageDataKEY           @"kImageDataKEY"
#define kOriginalImageKEY       @"kOriginalImageKEY"
#define kThumbKEY               @"kThumbKEY"
#define kLocalIdentifier        @"kLocalIdentifier"
#define kOriginalLength         @"kOriginalLength"
#define kAsset                  @"kAsset"
#define kAVAssetKEY             @"kAVAssetKEY"
#define kAVAssetURLKEY          @"kAVAssetURLKEY"

@implementation MDPhotoItem
- (void)dealloc
{
}

+ (instancetype)photoItemWithAsset:(PHAsset *)asset
{
    MDPhotoItem *item = [[MDPhotoItem alloc] init];
    item.asset = asset;
    item.type = [self typeWith:asset.mediaType];
    return item;
}

+ (MDPhotoItemType)typeWith:(PHAssetMediaType)assetType{
    
    switch (assetType) {
        case PHAssetMediaTypeImage:
            return MDPhotoItemTypeImage;
        case PHAssetMediaTypeVideo:
            return MDPhotoItemTypeVideo;
        default:
            break;
    }
    return MDPhotoItemTypeUnknown;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (NSString *)localIdentifierForAsset:(id)asset
{
    if (asset && [asset isKindOfClass:[PHAsset class]]) {
        //IOS8及以上
        PHAsset *phAsset = asset;
        return phAsset.localIdentifier;
    }else if(asset && [asset isKindOfClass:[ALAsset class]]){
        //IOS8以下
        ALAsset *alAsset = asset;
        return alAsset.defaultRepresentation.filename;
    }
    return nil;
}

+ (NSDate *)creationDateForAsset:(id)asset
{
    if (asset && [asset isKindOfClass:[PHAsset class]]) {
        //IOS8及以上
        PHAsset *phAsset = asset;
        return phAsset.creationDate;
    }else if(asset && [asset isKindOfClass:[ALAsset class]]){
        //IOS8以下
        ALAsset *alAsset = asset;
        return [alAsset valueForProperty:ALAssetPropertyDate];
    }
    return nil;
}
#pragma clang diagnostic pop

-(MDImageUploadParamModel *)imageUploadParamModel {
    if (!_imageUploadParamModel) {
        _imageUploadParamModel = [[MDImageUploadParamModel alloc]init];
    }
    return _imageUploadParamModel;
}

@end

@implementation MDPhotoLibraryProvider

#pragma mark - 读取资源库

//读取资源库的 asset,返回一个装有 PHAsset 的数组
+ (void)loadPhotolibraryMaxCount:(NSInteger)maxCount type:(MDPhotoItemType)type complite:(MDReadAssetsCallBack)callBack
{
    NSMutableArray *array = [NSMutableArray array];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {//判断适配
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                // 获取所有资源的集合，并按资源的在相册的默认排序返回
                PHFetchResult *assetsFetchResults = [MDAlbumAssetLibrary fetchAllAssets];
                
                //反序，按照最晚的图片 到 最早的图片 倒序遍历
                [assetsFetchResults enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([obj isKindOfClass:[PHAsset class]]) {
                        PHAsset *asset = obj;
                        
                        if (type & MDPhotoItemTypeImage) {
                            if (asset.mediaType == PHAssetMediaTypeImage) {
                                [array addObject:asset];
                            }
                        }
                        
                        if (type & MDPhotoItemTypeVideo) {
                            if (asset.mediaType == PHAssetMediaTypeVideo) {
                                [array addObject:asset];
                            }
                        }
                        
                        if (maxCount > 0) {
                            if ([array count] >= maxCount) {
                                *stop = YES;
                            }
                        }
                        
                    }
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    callBack(array);
                });
            } else {
                NSLog(@"load photo library failed , status %ld",(long)status);
                dispatch_async(dispatch_get_main_queue(), ^{
                    callBack(array);
                });
            }
        }];
    }
}

#pragma mark - 获取缩略图

//读取asset里的缩略图，会返回MDPhotoItem，里面只有缩略图 和 原图的大小，无原图
//本方法只针对需要显示原图尺寸的业务逻辑，读取速度较慢。
+ (void)loadThumbImageAndOriginalLength:(PHAsset *)asset thumbSize:(CGSize)thumbSize readItem:(MDReadPhotoItemCallBack)readItemCallBack
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self readSmallImageAndOriginLength:asset thumbSize:thumbSize info:^(NSDictionary *info) {
            
            UIImage *originalImage = [info objectForKey:kOriginalImageKEY defaultValue:nil];
            NSNumber *imageLen = [info objectForKey:kOriginalLength defaultValue:nil];
            PHAsset *asset = [info objectForKey:kAsset defaultValue:nil];
            
            MDPhotoItem *item = [MDPhotoItem photoItemWithAsset:asset];
            item.originImage = nil;
            item.nailImage = originalImage;
            item.originLength = [imageLen unsignedIntegerValue];
            item.localIdentifier = [info objectForKey:kLocalIdentifier defaultValue:nil];
            item.creationDate = asset.creationDate;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (readItemCallBack) {
                    readItemCallBack(item);
                }
            });
        }];
    });
 }

+ (BOOL)isLongImage:(id)imageOrAsset
{
    if ([imageOrAsset isKindOfClass:[UIImage class]]) {
        UIImage *image = imageOrAsset;
        CGFloat rate = (CGFloat)image.size.height / image.size.width;
        CGFloat wRate = (CGFloat)(CGFloat)image.size.width / image.size.height;
        
        if ((rate > 3.1 && rate < 60) || (wRate > 3.1 && wRate < 60)) {
            return YES;
        }
    } else if ([imageOrAsset isKindOfClass:[PHAsset class]]) {
        PHAsset *asset = imageOrAsset;
        CGFloat rate = (CGFloat)asset.pixelHeight / asset.pixelWidth;
        CGFloat wRate = (CGFloat)asset.pixelWidth / asset.pixelHeight;
        
        if ((rate > 3.1 && rate < 60) || (wRate > 3.1 && wRate < 60)) {
            return YES;
        }
    }
    return NO;
}

//读取asset里的缩略图，会返回MDPhotoItem，里面只有有缩略图
//速度最快，针对于不需要原图尺寸的缩略图显示逻辑，大部分业务场景都应该使用这个接口来读取缩略图
+ (void)loadThumbImage:(PHAsset *)asset thumbSize:(CGSize)thumbSize contentMode:(PHImageContentMode)contentMode readItem:(MDReadPhotoItemCallBack)readItemCallBack
{
    [self ansycReadThumbImage:asset thumbSize:thumbSize contentMode:contentMode info:^(NSDictionary *info) {
        UIImage *originalImage = [info objectForKey:kOriginalImageKEY defaultValue:nil];
        PHAsset *asset = [info objectForKey:kAsset defaultValue:nil];
        //是否是长图
        if (![self isLongImage:originalImage]) {
            originalImage = [MDRecordUtility oldCompressImage:originalImage];
        }
        UIImage *thumbImage = [originalImage clipImageWithFinalSize:thumbSize cornerRadius:0];
        
        MDPhotoItem *item = [MDPhotoItem photoItemWithAsset:asset];
        item.originImage = nil;
        item.nailImage = thumbImage;
        item.localIdentifier = [info objectForKey:kLocalIdentifier defaultValue:nil];
        item.creationDate = asset.creationDate;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (readItemCallBack) {
                readItemCallBack(item);
            }
        });
    }];
}

#pragma mark - 获取原图

//读取指定item里的原图，如果传入的item里有缩略图，则返回的item也带有缩略图， 返回 MDSelectedImageItem 对象，内部持有原图
+ (void)loadOriginalImage:(MDPhotoItem *)item readedImageItem:(MDReadImageItemCallBack)readedItemCallBack
{
    UIImage *thumbImage = item.nailImage;
    
    [self ansycReadImage:item.asset info:^(NSDictionary *info) {
        
        UIImage *originalImage = [info objectForKey:kOriginalImageKEY defaultValue:nil];
        NSNumber *imageLen = [info objectForKey:kOriginalLength defaultValue:nil];
        
        MDSelectedImageItem *newItem = [MDSelectedImageItem itemWithImage:originalImage];
        newItem.nailImage = thumbImage;
        newItem.originLength = [imageLen unsignedIntegerValue];
        newItem.localIdentifier = [info objectForKey:kLocalIdentifier defaultValue:nil];
        newItem.imgData = [info objectForKey:kImageDataKEY defaultValue:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (readedItemCallBack) {
                readedItemCallBack(newItem);
            }
        });
        
    }];
}

//读取指定asset里的原图，返回一个MDSelectedImageItem， 返回 MDSelectedImageItem 对象，内部持有原图
+ (void)loadOriginalImage:(PHAsset *)asset thumbSize:(CGSize)thumbSize readedImageItem:(MDReadImageItemCallBack)readedItemCallBack
{
    if (asset && [asset isKindOfClass:[PHAsset class]]) {
        [self ansycReadImage:asset info:^(NSDictionary *info) {
            UIImage *originalImage = [info objectForKey:kOriginalImageKEY defaultValue:nil];
            NSNumber *imageLen = [info objectForKey:kOriginalLength defaultValue:nil];
            UIImage *thumbImage = [originalImage clipImageWithFinalSize:thumbSize cornerRadius:0];
            
            MDSelectedImageItem *newItem = [MDSelectedImageItem itemWithImage:originalImage];
            newItem.nailImage = thumbImage;
            newItem.originLength = [imageLen unsignedIntegerValue];
            newItem.localIdentifier = [info objectForKey:kLocalIdentifier defaultValue:nil];
            newItem.imgData = [info objectForKey:kImageDataKEY defaultValue:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (readedItemCallBack) {
                    readedItemCallBack(newItem);
                }
            });
        }];
    }
}

+ (void)loadOriginalImageItem:(MDPhotoItem *)item thumbSize:(CGSize)thumbSize readedImageItem:(MDReadImageItemCallBack)readedItemCallBack
{
    PHAsset *asset = item.asset;
    if (asset && [asset isKindOfClass:[PHAsset class]]) {
        [self ansycReadImage:asset info:^(NSDictionary *info) {
            
            info = [self fixDic:info ifHaveEditedImage:item.editedImage];
            UIImage *originalImage = [info objectForKey:kOriginalImageKEY defaultValue:nil];
            NSNumber *imageLen = [info objectForKey:kOriginalLength defaultValue:nil];
            UIImage *thumbImage = [originalImage clipImageWithFinalSize:thumbSize cornerRadius:0];
            
            MDSelectedImageItem *newItem = [MDSelectedImageItem itemWithImage:originalImage];
            newItem.nailImage = thumbImage;
            newItem.originLength = [imageLen unsignedIntegerValue];
            newItem.localIdentifier = [info objectForKey:kLocalIdentifier defaultValue:nil];
            newItem.imgData = [info objectForKey:kImageDataKEY defaultValue:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (readedItemCallBack) {
                    readedItemCallBack(newItem);
                }
            });
        }];
    }
}

#pragma mark - 批量读取图片

//items 里需要传入MDPhotoItem
//获取 MDSelectedImageItem 里的 原图， 返回一个装有 MDSelectedImageItem 的数组，MDSelectedImageItem持有原图
+ (void)loadPHAssetImages:(NSArray *)items readedImageItems:(MDReadImageItemsCallBack)readedItemsCallBack
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    QMSafeMutableArray *Itemsloaded = [QMSafeMutableArray array];
    for (MDPhotoItem *item in items) {
        
        UIImage *thumbImage = item.nailImage;
        
        dispatch_group_async(group, queue, ^{
            
            [self readImage:item.asset info:^(NSDictionary *info) {
                
                info = [self fixDic:info ifHaveEditedImage:item.editedImage];
                UIImage *originalImage = [info objectForKey:kOriginalImageKEY defaultValue:nil];
                NSNumber *imageLen = [info objectForKey:kOriginalLength defaultValue:nil];
                
                MDSelectedImageItem *newItem = [MDSelectedImageItem itemWithImage:originalImage];
                newItem.nailImage = thumbImage;
                newItem.originLength = [imageLen unsignedIntegerValue];
                newItem.localIdentifier = [info objectForKey:kLocalIdentifier defaultValue:nil];
                newItem.imgData = [info objectForKey:kImageDataKEY defaultValue:nil];
                [Itemsloaded addObject:newItem];
                
            }];
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        if (readedItemsCallBack) {
            readedItemsCallBack(Itemsloaded);
        }
    });
    
}

//items 里需要传入MDPhotoItem 仅给影集使用
//获取 MDPhotoItem 里的 原图， 返回一个装有 MDPhotoItem 的数组，MDPhotoItem持有原图
+ (void)loadOriginPHAssetImages:(NSArray *)items progressBlock:(MDReadImageItemsProgressCallBack)progressCallBack readedImageItems:(MDReadImageItemsCallBack)readedItemsCallBack
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        QMSafeMutableArray *Itemsloaded = [QMSafeMutableArray array];
        for (MDPhotoItem *originItem in items) {
            
            MDPhotoItem *item = [MDPhotoItem photoItemWithAsset:originItem.asset];
            item.nailImage = originItem.nailImage;
            item.editedImage = originItem.originImage;
            if (originItem.editedImage) {
                item.editedImage = originItem.editedImage;
            }
            
            PHAsset *phAsset = (PHAsset *)item.asset;
            CGFloat maxWidth =  1080;//最大宽边
            float width = phAsset.pixelWidth;
            float height = phAsset.pixelHeight;
            float scale = maxWidth / width;
            scale = MIN(scale, 1);
            //这个系统方法 会返回大于等于且最接近于targetSize的图片 所有还需要对获取后的图片进行裁剪
            CGSize targetSize = CGSizeMake(round(width*scale), round(height*scale));
            
            
            void (^handleImageBlock)(UIImage *result, NSDictionary *info) = ^(UIImage *result, NSDictionary *info) {
                if (result) {
                    UIImage *img = [ImageFixOrientationHelper fixOrientation:result];
                    
                    UIGraphicsBeginImageContextWithOptions(targetSize, YES, 1);
                    CGRect rect = {.origin=CGPointZero, .size=targetSize};
                    [img drawInRect:rect];
                    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    item.editedImage =  newimg;
                }
                
                [Itemsloaded addObjectSafe:item];
                progressCallBack((Itemsloaded.count * 1.0)/items.count);
                
                if (Itemsloaded.count == items.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (readedItemsCallBack) {
                            readedItemsCallBack(Itemsloaded);
                        }
                    });
                }
            };

            if (item.editedImage) {
                handleImageBlock(item.editedImage, nil);
            }else {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:handleImageBlock];
            }
        }
    });
}

#pragma mark - 视频
//读取视频的url，返回的MDPhotoItem 中只有视频url，没有avasset
+ (void)loadVideoURL:(PHAsset *)asset readItem:(MDReadPhotoItemCallBack)readItemCallBack
{
    [self ansycReadVideo:asset info:^(NSDictionary *info) {
        NSURL *url = [info objectForKey:kAVAssetURLKEY defaultValue:nil];
        AVAsset *avAsset = [info objectForKey:kAVAssetKEY defaultValue:nil];
        PHAsset *asset = [info objectForKey:kAsset defaultValue:nil];
        
        MDPhotoItem *item = [MDPhotoItem photoItemWithAsset:asset];
        item.avassetURL = url;
        item.avasset = avAsset;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (readItemCallBack) {
                readItemCallBack(item);
            }
        });
    }];
}
#pragma mark - privite

//异步获取原图
+ (void)ansycReadImage:(PHAsset *)asset info:(MDReadImageCallBack)infoCallBack
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self readImage:asset info:infoCallBack];
    });
}

//异步获取缩略图
+ (void)ansycReadThumbImage:(PHAsset *)asset thumbSize:(CGSize)thumbSize contentMode:(PHImageContentMode)contentMode info:(MDReadImageCallBack)infoCallBack
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self readThumbImage:asset thumbSize:thumbSize contentMode:contentMode info:infoCallBack];
    });
}

//异步获取缩略图
+ (void)ansycReadVideo:(PHAsset *)asset info:(MDReadPhotoVideoCallBack)infoCallBack
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self readVideo:asset info:infoCallBack];
    });
}

//获取原图，读取到NSData做处理
+ (void)readImage:(PHAsset *)phAsset info:(MDReadImageCallBack)infoCallBack
{
    //IOS8及以上
    if (phAsset && [phAsset isKindOfClass:[PHAsset class]]) {
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        options.networkAccessAllowed = YES;
        
        //获取原图
        //  - (PHImageRequestID)requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode options:(nullable PHImageRequestOptions *)options resultHandler:(void (^)(UIImage *__nullable result, NSDictionary *__nullable info))resultHandler;
        //  这个方法，获得的原图的data的length不准
        [[PHImageManager defaultManager] requestImageDataForAsset:phAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            if (imageData && infoCallBack) {
                UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
                NSNumber *len = [NSNumber numberWithUnsignedInteger:[imageData length]];
                
                NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
                [resultDic setObjectSafe:image forKey:kOriginalImageKEY];
                [resultDic setObjectSafe:phAsset.localIdentifier forKey:kLocalIdentifier];
                [resultDic setObjectSafe:len forKey:kOriginalLength];
                [resultDic setObjectSafe:phAsset forKey:kAsset];
                [resultDic setObjectSafe:imageData forKey:kImageDataKEY];
                
                infoCallBack(resultDic);
            }
        }];
    }
}

//获取缩略图和原图length，读取到NSData做处理
+ (void)readSmallImageAndOriginLength:(PHAsset *)phAsset thumbSize:(CGSize)size info:(MDReadImageCallBack)infoCallBack
{
    //IOS8及以上
    if (phAsset && [phAsset isKindOfClass:[PHAsset class]]) {

        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        options.networkAccessAllowed = YES;

        //获取原图
        //  - (PHImageRequestID)requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode options:(nullable PHImageRequestOptions *)options resultHandler:(void (^)(UIImage *__nullable result, NSDictionary *__nullable info))resultHandler;
        //  这个方法，获得的原图的data的length不准
        [[PHImageManager defaultManager] requestImageDataForAsset:phAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {

            if (imageData && infoCallBack) {
                UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
                NSNumber *len = [NSNumber numberWithUnsignedInteger:[imageData length]];

                NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
                //是否是长图
                UIImage *originalImage = [MDRecordUtility oldCompressImage:image];
                UIImage *thumbImage = [originalImage clipImageWithFinalSize:size cornerRadius:0];
                [resultDic setObjectSafe:thumbImage forKey:kOriginalImageKEY];
                [resultDic setObjectSafe:phAsset.localIdentifier forKey:kLocalIdentifier];
                [resultDic setObjectSafe:len forKey:kOriginalLength];
                [resultDic setObjectSafe:phAsset forKey:kAsset];
//                [resultDic setObjectSafe:imageData forKey:kImageDataKEY];

                infoCallBack(resultDic);
            }
        }];
    }
}

+(NSDictionary *)fixDic:(NSDictionary *)dic ifHaveEditedImage:(UIImage *)editedImage {
    if (!editedImage) {
        return dic;
    } else {
        NSMutableDictionary *mDic = [dic mutableCopy];
        NSData *imageData = UIImageJPEGRepresentation(editedImage, 1.0);
        NSNumber *len = [NSNumber numberWithUnsignedInteger:[imageData length]];
        
        [mDic setObjectSafe:editedImage forKey:kOriginalImageKEY];
        [mDic setObjectSafe:len forKey:kOriginalLength];
        [mDic setObjectSafe:imageData forKey:kImageDataKEY];
        return mDic;
    }
}

//获取缩略图
+ (void)readThumbImage:(PHAsset *)phAsset thumbSize:(CGSize)thumbSize contentMode:(PHImageContentMode)contentMode info:(MDReadImageCallBack)infoCallBack
{
    if (phAsset && [phAsset isKindOfClass:[PHAsset class]]) {
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        
        //获取原图
        [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:thumbSize contentMode:contentMode options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            
            if (result && infoCallBack) {
                
                NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
                [resultDic setObjectSafe:result forKey:kOriginalImageKEY];
                [resultDic setObjectSafe:phAsset.localIdentifier forKey:kLocalIdentifier];
                [resultDic setObjectSafe:phAsset forKey:kAsset];
                
                infoCallBack(resultDic);
            }
        }];
    }
}

//获取缩略图
+ (void)readVideo:(PHAsset *)phAsset info:(MDReadPhotoVideoCallBack)infoCallBack
{
    if (phAsset && [phAsset isKindOfClass:[PHAsset class]]) {
        
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = YES;
        
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            
            NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
            [resultDic setObjectSafe:asset forKey:kAVAssetKEY];
            [resultDic setObjectSafe:phAsset forKey:kAsset];
            
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset *urlAsset = (id)asset;
                [resultDic setObjectSafe:urlAsset.URL forKey:kAVAssetURLKEY];
            }
            infoCallBack(resultDic);
        }];
    }
}

@end

#pragma mark - 统计打点

@implementation MDImageUploadParamsOfPicturing

- (NSDictionary *)paramsForPicturing
{
    // 统计所需参数,key值应该用服务器约定的值
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObjectSafe:@((self.isFrontCamera ? 1:0)) forKey:@"front_camera"];
    [params setObjectSafe:@(self.recordOrientation ? 1: 0) forKey:@"is_across_screen"];
    [params setObjectSafe:self.filterID forKey:@"advanced_filter_id"];
    [params setObjectSafe:@(self.beautyFaceLevel) forKey:@"beauty_face_level"];
    [params setObjectSafe:@(self.bigEyeLevel) forKey:@"bigeye_level"];
    [params setObjectSafe:@(self.flashLightState) forKey:@"flashlight"];
    [params setObjectSafe:self.faceID forKey:@"face_id"];
    [params setObjectSafe:@(self.thinBodyLevel) forKey:@"thin_body_level"];
    [params setObjectSafe:@(self.longLegLevel) forKey:@"long_leg_level"];
    
    return params;
}

@end

@implementation MDImageUploadParamsOfEditing

- (NSDictionary *)paramsForEditing
{
    // 统计所需参数,key值应该用服务器约定的值
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObjectSafe:self.filterID forKey:@"advanced_filter_id"];
    [params setObjectSafe:@(self.beautyFaceLevel) forKey:@"beauty_face_level"];
    [params setObjectSafe:@(self.bigEyeLevel) forKey:@"bigeye_level"];
    [params setObjectSafe:[self.stickerIds componentsJoinedByString:@","] forKey:@"tag_ids"];
    [params setObjectSafe:[self.decorateTexts MDJSONString] forKey:@"decorator_texts"];
    [params setObjectSafe:@(self.hasGraffiti ? 1: 0) forKey:@"is_graffiti"];
    [params setObjectSafe:@(self.thinBodyLevel) forKey:@"thin_body_level"];
    [params setObjectSafe:@(self.longLegLevel) forKey:@"long_leg_level"];

    return params;
}

@end

@implementation MDImageUploadParamModel

- (NSDictionary *)paramsForUploadImage
{
    // 统计所需参数,key值应该用服务器约定的值
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (self.paramsOfPicturing) {
        NSDictionary *paramsDict = [self.paramsOfPicturing paramsForPicturing];
        [params setObjectSafe:paramsDict forKey:@"take_photo"];
    }
    
    if (self.paramsOfEditing) {
        NSDictionary *paramsDict = [self.paramsOfEditing paramsForEditing];
        [params setObjectSafe:paramsDict forKey:@"edit_photo"];
    }
    
    return params;
}

@end
