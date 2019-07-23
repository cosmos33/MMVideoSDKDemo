//
//  MDRecordSpecialImageDataManager.m
//  MDChat
//
//  Created by YZK on 2018/8/9.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDRecordSpecialImageDataManager.h"
#import <AVFoundation/AVFoundation.h>
#import "MDRecordHeader.h"

@interface MDRecordSpecialImageDataManager ()

@property (nonatomic ,weak) id<MDRecordSpecialImageDataManagerDelegate> delegate;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@end

@implementation MDRecordSpecialImageDataManager

- (void)getSpecialImageGroupsByAsset:(AVAsset *)asset
                          frameCount:(NSUInteger)frameCount
                            delegate:(id<MDRecordSpecialImageDataManagerDelegate>)delegate
{
    NSAssert(frameCount > 0, @"framecount must > 0");
    
    self.delegate = delegate;
    [self.momentThumbTimeArray removeAllObjects];
    [self.momentThumbDataArray removeAllObjects];
    
    __weak __typeof(self) weakSelf = self;
    [self getVideoThumbGroupsByAsset:[asset copy] frameCount:frameCount andAsyncCallblock:^(UIImage *thumbImage, CMTime thumbTime) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf.momentThumbTimeArray addObjectSafe:[NSValue valueWithCMTime:thumbTime]];
        if (thumbImage) {
            [strongSelf.momentThumbDataArray addObjectSafe:thumbImage];
            [strongSelf notifyDelegateReload];
        }
        if (strongSelf.momentThumbTimeArray.count == frameCount) {
            [strongSelf notifyDelegateFinish];
        }
    }];
}

- (void)getVideoThumbGroupsByAsset:(AVAsset *)asset frameCount:(NSUInteger)frameCount andAsyncCallblock:(void(^)(UIImage *thumbImage, CMTime thumbTime))callBackBlock
{
    if (asset) {
        self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        self.imageGenerator.appliesPreferredTrackTransform = YES;
        self.imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        self.imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        self.imageGenerator.maximumSize = CGSizeMake(38*2, 50*2);
        
        CMTime perSection = CMTimeMultiplyByFloat64(asset.duration, 1.0f/frameCount);
        NSMutableArray *timeArray = [NSMutableArray array];
        for (int i=0; i<frameCount; i++) {
            CMTime time = CMTimeMultiply(perSection, i);
            [timeArray addObjectSafe:[NSValue valueWithCMTime:time]];
        }
        
        [self.imageGenerator generateCGImagesAsynchronouslyForTimes:timeArray completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable cgImage, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
            switch (result) {
                case AVAssetImageGeneratorFailed:
                {
                    callBackBlock(nil, kCMTimeInvalid);
                }
                    break;
                case AVAssetImageGeneratorCancelled:
                {
                    callBackBlock(nil, kCMTimeInvalid);
                }
                    break;
                case AVAssetImageGeneratorSucceeded:
                {
                    UIImage *image = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                    callBackBlock(image, actualTime);
                }
                    break;
                default:
                    break;
            }
        }];
    }
}

#pragma mark - image utilit

- (void)notifyDelegateReload {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(recordSpecialImageReload)]) {
            [self.delegate recordSpecialImageReload];
        }
    });
}
- (void)notifyDelegateFinish {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(recordSpecialImageFinished)]) {
            [self.delegate recordSpecialImageFinished];
        }
    });
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
