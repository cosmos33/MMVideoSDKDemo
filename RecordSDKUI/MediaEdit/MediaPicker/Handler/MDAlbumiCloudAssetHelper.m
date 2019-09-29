//
//  MDAlbumiCloudAssetHelper.m
//  MDChat
//
//  Created by YZK on 2018/12/6.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDAlbumiCloudAssetHelper.h"
#import "MDPhotoLibraryProvider.h"
#import "MDBluredProgressView.h"
#import "ImageFixOrientationHelper.h"
#import "MDRecordHeader.h"

@interface MDAlbumiCloudAssetHelper ()
@property (nonatomic, strong) NSMutableArray *requestIDArray;
@property (nonatomic, strong, readwrite) PHImageManager *imageManager;
@end

@implementation MDAlbumiCloudAssetHelper

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
        self.requestIDArray = [NSMutableArray array];
        self.imageManager = [PHImageManager defaultManager];
    }
    return self;
}

- (void)getOriginImageFromPhotoItem:(MDPhotoItem *)item
                    progressHandler:(void (^)(double progress, MDPhotoItem *item))progressHandler
                      completeBlock:(void (^)(UIImage *result, MDPhotoItem *item))block
{
    [self getImageFromPhotoItem:item targetSize:PHImageManagerMaximumSize progressHandler:progressHandler completeBlock:block];
}

- (void)getImageFromPhotoItem:(MDPhotoItem *)item
                   targetSize:(CGSize)targetSize
              progressHandler:(void (^)(double progress, MDPhotoItem *item))progressHandler
                completeBlock:(void (^)(UIImage *result, MDPhotoItem *item))block
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = NO;
    options.networkAccessAllowed = NO;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;

    __weak typeof(self) weakSelf = self;
    [self.imageManager requestImageForAsset:item.asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFit
                                    options:options
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  id isiCloud = [info objectForKey:PHImageResultIsInCloudKey];
                                  if (isiCloud && [isiCloud boolValue]) {
                                      [weakSelf iCloudImageFromPhotoItem:item targetSize:targetSize progressHandler:progressHandler completeBlock:block];
                                  } else {
                                      item.originImage = result;
                                      if (progressHandler) progressHandler(1.0f, item);
                                      if (block) block(result, item);
                                  }
                              }];
}

- (void)getDegradedImageFromPhotoItem:(MDPhotoItem *)item
                           targetSize:(CGSize)targetSize
                        completeBlock:(void (^)(UIImage *result, MDPhotoItem *item, BOOL isDegraded))block
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = NO;
    options.networkAccessAllowed = NO;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    __weak typeof(self) weakSelf = self;
    [self.imageManager requestImageForAsset:item.asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFit
                                    options:options
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  id isiCloud = [info objectForKey:PHImageResultIsInCloudKey];
                                  BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                                  if (isiCloud && [isiCloud boolValue]) {
                                      [weakSelf iCloudImageFromPhotoItem:item targetSize:targetSize progressHandler:nil completeBlock:^(UIImage *result, MDPhotoItem *item) {
                                          if (block) block(result, item, NO);
                                      }];
                                  } else {
                                      if (block) block(result, item, isDegraded);
                                  }
                              }];
}


- (PHImageRequestID)iCloudImageFromPhotoItem:(MDPhotoItem *)item
                                  targetSize:(CGSize)targetSize
                             progressHandler:(void (^)(double progress, MDPhotoItem *item))progressHandler
                               completeBlock:(void (^)(UIImage *result, MDPhotoItem *item))block
{
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.synchronous = NO;
    requestOptions.networkAccessAllowed = YES;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;

    requestOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) progressHandler(progress, item);
        });
    };
    
    __weak typeof(self) weakSelf = self;
    PHImageRequestID requestID = [self.imageManager requestImageForAsset:item.asset
                                                              targetSize:targetSize
                                                             contentMode:PHImageContentModeAspectFit
                                                                 options:requestOptions
                                                           resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                               BOOL isiCloudownloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                                                               PHImageRequestID currentRequestID = [[info objectForKey:PHImageResultRequestIDKey] intValue];
                                                               BOOL isCancel = [[info objectForKey:PHImageCancelledKey] boolValue];
                                                               if (isiCloudownloadFinined) {
                                                                   item.originImage = result;
                                                                   if (block) block(result, item);
                                                               }else if (!isCancel) {
                                                                   if (block) block(nil, item);
                                                               }
                                                               [weakSelf.requestIDArray removeObject:@(currentRequestID)];
                                                           }];
    [self.requestIDArray addObjectSafe:@(requestID)];
    return requestID;
}


- (void)getOriginImageFromPhotoItemArray:(NSArray<MDPhotoItem*> *)itemArray
                         progressHandler:(void (^)(double progress))progressHandler
                           completeBlock:(void (^)(NSArray<MDPhotoItem*> *resultArray))block {
    [self getImageFromPhotoItemArray:itemArray targetSize:PHImageManagerMaximumSize progressHandler:progressHandler completeBlock:block];
}

- (void)getImageFromPhotoItemArray:(NSArray<MDPhotoItem*> *)itemArray
                        targetSize:(CGSize)targetSize
                   progressHandler:(void (^)(double progress))progressHandler
                     completeBlock:(void (^)(NSArray<MDPhotoItem*> *resultArray))block {
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *progressDict = [NSMutableDictionary dictionary];
    
    __weak __typeof(self) weakSelf = self;
    for (MDPhotoItem *item in itemArray) {
        [self getImageFromPhotoItem:item targetSize:targetSize progressHandler:^(double progress, MDPhotoItem *item) {
            [progressDict setValue:@(progress) forKey:item.asset.localIdentifier?:@""];
            double totalProgress = [weakSelf progressWithDict:progressDict count:itemArray.count];
            if (progressHandler) progressHandler(totalProgress);
        } completeBlock:^(UIImage *result, MDPhotoItem *item) {
            [resultDict setValue:item forKey:item.asset.localIdentifier?:@""];
            if (resultDict.allValues.count == itemArray.count) {
                NSArray *resultArray = [weakSelf converToArrayWithDict:resultDict itemArray:itemArray];
                if (block) block(resultArray);
            }
        }];
    }
}

- (void)canceliCloudImageDownload {
    for (NSNumber *requestID in self.requestIDArray) {
        [self.imageManager cancelImageRequest:requestID.intValue];
    }
    [self.requestIDArray removeAllObjects];
}

- (void)loadOriginImageFromPhotoItemArray:(NSArray<MDPhotoItem*> *)itemArray
                              cancelBlock:(void (^)(void))cancelBlock
                            completeBlock:(void (^)(NSArray<MDPhotoItem*> *resultArray))block {
    MDBluredProgressView *processingHUD = [[MDBluredProgressView alloc] initWithBlurView:[MDRecordContext appWindow] descText:@"正在加载图片" needClose:YES];
    processingHUD.userInteractionEnabled = YES;
    processingHUD.progress = 0;
    __weak __typeof(self) weakSelf = self;
    [processingHUD setViewCloseHandler:^{
        [weakSelf canceliCloudImageDownload];
        if (cancelBlock) cancelBlock();
    }];
    [[MDRecordContext appWindow] addSubview:processingHUD];
    
    [self getOriginImageFromPhotoItemArray:itemArray progressHandler:^(double progress) {
        processingHUD.progress = progress;
    } completeBlock:^(NSArray<MDPhotoItem *> *resultArray) {
        [processingHUD removeFromSuperview];
        if (block) block(resultArray);
    }];
}

- (void)loadLivePhotoImageFromPhotoItemArray:(NSArray<MDPhotoItem*> *)itemArray
                                 cancelBlock:(void (^)(void))cancelBlock
                               completeBlock:(void (^)(NSArray<MDPhotoItem*> *resultArray))block {
    MDBluredProgressView *processingHUD = [[MDBluredProgressView alloc] initWithBlurView:[MDRecordContext appWindow] descText:@"正在加载图片" needClose:YES];
    processingHUD.userInteractionEnabled = YES;
    processingHUD.progress = 0;
    __weak __typeof(self) weakSelf = self;
    [processingHUD setViewCloseHandler:^{
        [weakSelf canceliCloudImageDownload];
        if (cancelBlock) cancelBlock();
    }];
    [[MDRecordContext appWindow] addSubview:processingHUD];
    
    [self getImageFromPhotoItemArray:itemArray targetSize:CGSizeMake(720, 1280) progressHandler:^(double progress) {
        processingHUD.progress = progress;
    } completeBlock:^(NSArray<MDPhotoItem *> *resultArray) {
        NSMutableArray *newResultArray = [NSMutableArray array];
        for (MDPhotoItem *originItem in resultArray) {
            MDPhotoItem *item = [MDPhotoItem photoItemWithAsset:originItem.asset];
            item.nailImage = originItem.nailImage;
            item.editedImage = originItem.editedImage ?: (originItem.originImage ?: originItem.nailImage);

            if (item.editedImage) {
                UIImage *img = [ImageFixOrientationHelper fixOrientation:item.editedImage];

                CGFloat maxWidth =  1280;//最大宽边
                float width = img.size.width * img.scale;
                float height = img.size.height * img.scale;
                float scale = maxWidth / width;
                scale = MIN(scale, 1);
                //这个系统方法 会返回大于等于且最接近于targetSize的图片 所有还需要对获取后的图片进行裁剪
                CGSize targetSize = CGSizeMake(round(width*scale), round(height*scale));
                
                UIGraphicsBeginImageContextWithOptions(targetSize, YES, 1);
                CGRect rect = {.origin=CGPointZero, .size=targetSize};
                [img drawInRect:rect];
                UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                item.editedImage =  newimg;
            }
            [newResultArray addObjectSafe:item];
        }
        [processingHUD removeFromSuperview];
        if (block) block(newResultArray);
    }];
}

- (void)loadBigImageFromPhotoItem:(MDPhotoItem *)item
                      isNeedThumb:(BOOL)isNeedThumb
                      cancelBlock:(void (^)(void))cancelBlock
                    completeBlock:(void (^)(UIImage *))completeBlock {
    MDBluredProgressView *processingHUD = [[MDBluredProgressView alloc] initWithBlurView:[MDRecordContext appWindow] descText:@"正在加载图片" needClose:YES];
    processingHUD.userInteractionEnabled = YES;
    processingHUD.progress = 0;
    __weak __typeof(self) weakSelf = self;
    [processingHUD setViewCloseHandler:^{
        [weakSelf canceliCloudImageDownload];
        if (cancelBlock) cancelBlock();
    }];
    [[MDRecordContext appWindow] addSubview:processingHUD];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    [self getImageFromPhotoItem:item targetSize:CGSizeMake(MDScreenWidth*scale, MDScreenHeight*scale) progressHandler:^(double progress, MDPhotoItem *item) {
        progress = MAX(0, MIN(0.999, progress));
        processingHUD.progress = progress;
    } completeBlock:^(UIImage *result, MDPhotoItem *item) {
        [processingHUD removeFromSuperview];
        if (!result && isNeedThumb) {
            if (completeBlock) completeBlock(item.nailImage);
            return;
        }
        if (completeBlock) completeBlock(result);
    }];
}

#pragma mark - 辅助方法

- (NSArray *)converToArrayWithDict:(NSDictionary *)resultDict itemArray:(NSArray<MDPhotoItem*> *)itemArray {
    NSMutableArray *marr = [NSMutableArray array];
    for (MDPhotoItem *item in itemArray) {
        [marr addObjectSafe:[resultDict objectForKey:item.asset.localIdentifier]];
    }
    return marr;
}

- (double)progressWithDict:(NSDictionary *)progressDict count:(NSInteger)count {
    double progress = 0;
    for (NSNumber *progressNumber in progressDict.allValues) {
        progress += [progressNumber doubleValue] / count;
    }
    progress = MAX(0, MIN(0.999, progress));
    return progress;
}

@end
