//
//  MDPhotoLibraryProvider.h
//  MDChat
//
//  Created by 杜林 on 16/6/6.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "MDSelectedImageItem.h"

@class MDImageUploadParamModel;

typedef NS_OPTIONS(NSUInteger, MDPhotoItemType) {
    MDPhotoItemTypeUnknown                  = 0,
    MDPhotoItemTypeImage                    = 1 << 0,
    MDPhotoItemTypeVideo                    = 1 << 1,
};

@interface MDPhotoItem : NSObject

@property (nonatomic, copy) NSString                    *localIdentifier;
@property (nonatomic, strong) PHAsset                   *asset;

@property (nonatomic, strong)UIImage                    *originImage;//大图
@property (nonatomic, strong)UIImage                    *nailImage;//大图的缩略图

@property (nonatomic, assign) NSUInteger                *originLength; //原图的字节数
@property (nonatomic, assign) BOOL                      choosed;//default is NO

@property (nonatomic, strong)UIImage                    *editedImage;//编辑过的图片

@property (nonatomic, strong) NSDate                    *creationDate;

@property (nonatomic, assign) BOOL                      selected;
@property (nonatomic, assign) BOOL                      isOrigin;//是否勾选了发原图的选项
@property (nonatomic, assign) BOOL                      edited;//是否编辑过

@property (nonatomic, assign) MDPhotoItemType           type;
@property (nonatomic, assign) BOOL                      disabelVideo;//视频不可选状态记录

@property (nonatomic, strong) AVAsset                   *avasset;//相册视频的avsset,正常情况下，应该是一个AVURLAsset
@property (nonatomic, assign) NSURL                     *avassetURL;//相册视频的avsset的url
@property (nonatomic, assign) NSInteger                 idxNumber;//相册中的标号
@property (nonatomic, strong) NSIndexPath               *indexPath;//相册中的序列

@property (nonatomic,strong) MDImageUploadParamModel    *imageUploadParamModel;

+ (instancetype)photoItemWithAsset:(PHAsset *)asset;
+ (NSString *)localIdentifierForAsset:(id)asset;
+ (NSDate *)creationDateForAsset:(id)asset;

@end


typedef void(^MDReadImageCallBack)(NSDictionary *info);
typedef void(^MDReadAssetsCallBack)(NSArray *results);
typedef void(^MDReadPhotoVideoCallBack)(NSDictionary *info);

typedef void(^MDReadPhotoItemCallBack)(MDPhotoItem *item);
typedef void(^MDReadPhotoItemsCallBack)(NSArray *items);

typedef void(^MDReadImageItemCallBack)(MDSelectedImageItem *item);
typedef void(^MDReadImageItemsCallBack)(NSArray *items);
typedef void(^MDReadImageItemsProgressCallBack)(CGFloat progress);


@interface MDPhotoLibraryProvider : NSObject

//读取资源库的 asset
+ (void)loadPhotolibraryMaxCount:(NSInteger)maxCount type:(MDPhotoItemType)type complite:(MDReadAssetsCallBack)callBack;

#pragma mark - 缩略图

//读取asset里的缩略图，会返回MDPhotoItem，里面只有有缩略图
//速度最快，针对于不需要原图尺寸的缩略图显示逻辑，大部分业务场景都应该使用这个接口来读取缩略图
+ (void)loadThumbImage:(PHAsset *)asset thumbSize:(CGSize)thumbSize contentMode:(PHImageContentMode)contentMode readItem:(MDReadPhotoItemCallBack)readItemCallBack;

//读取asset里的缩略图，会返回MDPhotoItem，里面带有原图的大小
//本方法只针对需要显示原图尺寸的业务逻辑，读取速度较慢。
+ (void)loadThumbImageAndOriginalLength:(PHAsset *)asset thumbSize:(CGSize)thumbSize readItem:(MDReadPhotoItemCallBack)readItemCallBack;
#pragma mark - 原图

//读取指定item里的原图，如果传入的item里有缩略图，则返回的item也带有缩略图， 返回 MDSelectedImageItem 对象，内部持有原图
+ (void)loadOriginalImage:(MDPhotoItem *)item readedImageItem:(MDReadImageItemCallBack)readedItemCallBack;

//读取指定asset里的原图，返回一个MDSelectedImageItem， 返回 MDSelectedImageItem 对象，内部持有原图
+ (void)loadOriginalImage:(PHAsset *)asset thumbSize:(CGSize)thumbSize readedImageItem:(MDReadImageItemCallBack)readedItemCallBack;
+ (void)loadOriginalImageItem:(MDPhotoItem *)item thumbSize:(CGSize)thumbSize readedImageItem:(MDReadImageItemCallBack)readedItemCallBack;
//处理编辑过的图片，让其取代字典中原图的数据
+(NSDictionary *)fixDic:(NSDictionary *)dic ifHaveEditedImage:(UIImage *)editedImage;
#pragma mark - 批量读取图片

//items 里需要传入MDPhotoItem
//获取 MDSelectedImageItem 里的 原图， 返回一个装有 MDSelectedImageItem 的数组，MDSelectedImageItem持有原图
+ (void)loadPHAssetImages:(NSArray *)items readedImageItems:(MDReadImageItemsCallBack)readedItemsCallBack;

//items 里需要传入MDPhotoItem 仅给影集使用 内部限制最大长宽为 1280 * 720
//获取 MDPhotoItem 里的 原图， 返回一个装有 MDPhotoItem 的数组，MDPhotoItem持有原图
+ (void)loadOriginPHAssetImages:(NSArray *)items progressBlock:(MDReadImageItemsProgressCallBack)progressCallBack readedImageItems:(MDReadImageItemsCallBack)readedItemsCallBack;
#pragma mark - 视频
//读取视频的url，返回的MDPhotoItem 中只有视频url，没有avasset
+ (void)loadVideoURL:(PHAsset *)asset readItem:(MDReadPhotoItemCallBack)readItemCallBack;

@end

#pragma mark - 图片统计打点

@interface MDImageUploadParamsOfPicturing : NSObject

//是否使用了前置摄像头
@property (nonatomic, assign) BOOL                  isFrontCamera;
//横屏拍照
@property (nonatomic, assign) BOOL                  recordOrientation;
//滤镜id
@property (nonatomic, strong) NSString              *filterID;
//美白磨皮等级
@property (nonatomic, assign) NSInteger             beautyFaceLevel;
//大眼瘦脸等级
@property (nonatomic, assign) NSInteger             bigEyeLevel;
//闪光灯状态
@property (nonatomic, assign) NSInteger             flashLightState;
//变脸素材id
@property (nonatomic, strong) NSString              *faceID;

//瘦身等级
@property (nonatomic, assign) NSInteger             thinBodyLevel;
//长腿等级
@property (nonatomic, assign) NSInteger             longLegLevel;


- (NSDictionary *)paramsForPicturing;

@end

@interface MDImageUploadParamsOfEditing : NSObject;

//滤镜id
@property (nonatomic, strong) NSString              *filterID;
//美白磨皮等级
@property (nonatomic, assign) NSInteger             beautyFaceLevel;
//大眼瘦脸等级
@property (nonatomic, assign) NSInteger             bigEyeLevel;
//静态贴纸id
@property (nonatomic, strong) NSMutableArray        *stickerIds;
//文字贴纸
@property (nonatomic, strong) NSMutableArray        *decorateTexts;
//是否有涂鸦
@property (nonatomic, assign) BOOL                  hasGraffiti;

//瘦身等级
@property (nonatomic, assign) NSInteger             thinBodyLevel;
//长腿等级
@property (nonatomic, assign) NSInteger             longLegLevel;

- (NSDictionary *)paramsForEditing;

@end

@interface MDImageUploadParamModel : NSObject

#pragma mark - 数据打点
@property (nonatomic,strong) MDImageUploadParamsOfPicturing *paramsOfPicturing;
@property (nonatomic,strong) MDImageUploadParamsOfEditing   *paramsOfEditing;

//上传图片时需要上传的打点参数
- (NSDictionary *)paramsForUploadImage;

@end
