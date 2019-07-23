//
//  MDAlbumiCloudAssetHelper.h
//  MDChat
//
//  Created by YZK on 2018/12/6.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class MDPhotoItem;

@interface MDAlbumiCloudAssetHelper : NSObject

@property (nonatomic, strong, readonly) PHImageManager *imageManager;

+ (instancetype)sharedInstance;

/**
 获取单张图片的原图(包含iCloud图片)

 @param item 选中的item
 @param progressHandler 进度回调
 @param block 获取完成的回调
 */
- (void)getOriginImageFromPhotoItem:(MDPhotoItem *)item
                    progressHandler:(void (^)(double progress, MDPhotoItem *item))progressHandler
                      completeBlock:(void (^)(UIImage *result, MDPhotoItem *item))block;


/**
 获取单张大图的指定大小(包含iCloud图片)

 @param item 选中的item
 @param targetSize 指定大小，注意图片大小不是targetSize，而是系统最接近targetSize的一张
 @param progressHandler 进度回调
 @param block 获取完成的回调
 */
- (void)getImageFromPhotoItem:(MDPhotoItem *)item
                   targetSize:(CGSize)targetSize
              progressHandler:(void (^)(double progress, MDPhotoItem *item))progressHandler
                completeBlock:(void (^)(UIImage *result, MDPhotoItem *item))block;

/**
 获取单张图片的指定大小(包含iCloud图片)，先同步返回小图，然后再返回大图
 
 @param item 选中的item
 @param targetSize 指定大小，注意图片大小不是targetSize，而是系统最接近targetSize的一张
 @param block 获取完成的回调
 */
- (void)getDegradedImageFromPhotoItem:(MDPhotoItem *)item
                           targetSize:(CGSize)targetSize
                        completeBlock:(void (^)(UIImage *result, MDPhotoItem *item, BOOL isDegraded))block;

/**
 不包含loadding进度条框的获取原图数组(包含iCloud图片)

 @param itemArray 选中的item数组
 @param progressHandler 进度回调
 @param block 获取完成的回调
 */
- (void)getOriginImageFromPhotoItemArray:(NSArray<MDPhotoItem*> *)itemArray
                         progressHandler:(void (^)(double progress))progressHandler
                           completeBlock:(void (^)(NSArray<MDPhotoItem*> *resultArray))block;


/**
 不包含loadding进度条框的获取指定图数组(包含iCloud图片)

 @param itemArray 选中的item数组
 @param targetSize 指定大小，注意图片大小不是targetSize，而是系统最接近targetSize的一张
 @param progressHandler 进度回调
 @param block 获取完成的回调
 */
- (void)getImageFromPhotoItemArray:(NSArray<MDPhotoItem*> *)itemArray
                        targetSize:(CGSize)targetSize
                   progressHandler:(void (^)(double progress))progressHandler
                     completeBlock:(void (^)(NSArray<MDPhotoItem*> *resultArray))block;


/**
 带loadding进度条框的获取原图数组(包含iCloud图片)

 @param itemArray 选中的item数组
 @param cancelBlock 取消回调
 @param block 获取完成的回调
 */
- (void)loadOriginImageFromPhotoItemArray:(NSArray<MDPhotoItem*> *)itemArray
                              cancelBlock:(void (^)(void))cancelBlock
                            completeBlock:(void (^)(NSArray<MDPhotoItem*> *resultArray))block;

/**
 带loadding进度条框的获取影集图片数组(包含iCloud图片)
 
 @param itemArray 选中的item数组
 @param cancelBlock 取消回调
 @param block 获取完成的回调
 */
- (void)loadLivePhotoImageFromPhotoItemArray:(NSArray<MDPhotoItem*> *)itemArray
                                 cancelBlock:(void (^)(void))cancelBlock
                               completeBlock:(void (^)(NSArray<MDPhotoItem*> *resultArray))block;



/**
 带loadding进度条框的获取单张图片的大图(包含iCloud图片)

 @param item 指定图片
 @param isNeedThumb iCloud图片下载失败是否使用缩略图
 @param cancelBlock 取消回调
 @param completeBlock 获取完成的回调
 */
- (void)loadBigImageFromPhotoItem:(MDPhotoItem *)item
                      isNeedThumb:(BOOL)isNeedThumb
                      cancelBlock:(void (^)(void))cancelBlock
                    completeBlock:(void (^)(UIImage *))completeBlock;

/**
 取消iCloud图片下载请求
 */
- (void)canceliCloudImageDownload;

@end

