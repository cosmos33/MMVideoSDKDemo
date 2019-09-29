//
//  MDMomentThumbDataMAnager.m
//  MDChat
//
//  Created by Leery on 16/12/30.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDMomentThumbDataManager.h"
#import "MDRecordHeader.h"
@import MomoCV;

#if !__has_feature(objc_arc)
#error MDMomentThumbDataManager must be built with ARC.
#endif

typedef void(^GetMomentThumbBlock)(UIImage *thumbImage, CMTime thumbTime);

@interface MDMomentThumbDataManager ()
@property (nonatomic ,weak) id<MDMomentThumbDataManagerDelegate>delegate;
@property (nonatomic ,strong) AVAsset *asset;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation MDMomentThumbDataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queue = dispatch_queue_create("com.sdk.get_asset_thumb.queue", NULL);
    }
    return self;
}

- (void)getMomentThumbGroupsByAsset:(AVAsset *)asset
                         frameCount:(NSUInteger)frameCount
                        addObserver:(id<MDMomentThumbDataManagerDelegate>)obj
{
    NSAssert(frameCount > 0, @"framecount must > 0");
    
    self.asset = [asset copy];
    self.delegate = obj;
    
    __weak __typeof(self) weakSelf = self;
    [self getVideoThumbGroupsByAsset:self.asset frameCount:frameCount andAsyncCallblock:^(UIImage *thumbImage, CMTime thumbTime) {
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (thumbImage) {
            [strongSelf.momentThumbDataArray addObjectSafe:thumbImage];
            [strongSelf.momentThumbTimeArray addObjectSafe:[NSValue valueWithCMTime:thumbTime]];
            [strongSelf reloadCollectViewWithDataOntime];
        }
    }];
}

- (void)getVideoThumbGroupsByAsset:(AVAsset *)asset frameCount:(NSUInteger)frameCount andAsyncCallblock:(GetMomentThumbBlock)block
{
    if (asset) {
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        imageGenerator.maximumSize = CGSizeMake(38*2, 50*2);
        
        Float64 duration = CMTimeGetSeconds(asset.duration);
        Float64 durationPerSection = duration / frameCount;
        
        NSMutableArray *requestTimes = [NSMutableArray array];
        for (int i = 0; i < frameCount; i++) {
            CMTime requestTime = CMTimeMakeWithSeconds(i*durationPerSection, asset.duration.timescale);
            [requestTimes addObject:[NSValue valueWithCMTime:requestTime]];
        }
        
        GetMomentThumbBlock callback = ^(UIImage *thumbImage, CMTime thumbTime){
            dispatch_async(self.queue, ^{
                block(thumbImage, thumbTime);
            });
        };
        
        [imageGenerator generateCGImagesAsynchronouslyForTimes:[requestTimes copy]
                                             completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * error) {
                                                 if (result == AVAssetImageGeneratorSucceeded) {
                                                     UIImage *uiimage = [UIImage imageWithCGImage:image scale:2.0 orientation:UIImageOrientationUp];
//                                                     CGImageRelease(image);
                                                     if (image) {
                                                         callback(uiimage, actualTime);
                                                     } else {
                                                         callback(nil, kCMTimeIndefinite);
                                                     }
                                                 } else {
                                                     callback(nil, kCMTimeIndefinite);
                                                 }
                                             }];
        
        _maxThumbSize = (_maxThumbSize == 0.0f) ? 640 : _maxThumbSize;
        imageGenerator.maximumSize = CGSizeMake(_maxThumbSize, _maxThumbSize);
        CMTime requestTime = CMTimeMakeWithSeconds(1.5, asset.duration.timescale);
        CGImageRef defaultImageRef = [imageGenerator copyCGImageAtTime:requestTime actualTime:NULL error:NULL];
        if (defaultImageRef) {
            UIImage *defualtImage = [UIImage imageWithCGImage:defaultImageRef scale:2.0 orientation:UIImageOrientationUp];
            CGImageRelease(defaultImageRef);
            self.defaultLargeCoverImage = defualtImage;
        } else {
            NSLog(@"有失败");
        }
        
        imageGenerator.maximumSize = CGSizeMake(38*2, 50*2);

    }
}

#pragma mark - image utilit
- (CVPixelBufferRef)pixelBufferFaster:(CGImageRef)image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32BGRA,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    CFAutorelease(pxbuffer);
    
    return pxbuffer;
}

- (void)reloadCollectViewWithDataOntime {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(momentThumbDataReload)]) {
            [weakSelf.delegate momentThumbDataReload];
        }
    });
}

+ (MDMomentThumbDataManager *)momentThumbManager {
    MDMomentThumbDataManager *momentThumbManager = [[MDMomentThumbDataManager alloc] init];
    return momentThumbManager;
}

- (NSMutableArray *)momentThumbDataArray {
    if(!_momentThumbDataArray) {
        _momentThumbDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _momentThumbDataArray;
}

- (NSMutableArray *)momentThumbTimeArray
{
    if (!_momentThumbTimeArray) {
        _momentThumbTimeArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _momentThumbTimeArray;
}

@end
