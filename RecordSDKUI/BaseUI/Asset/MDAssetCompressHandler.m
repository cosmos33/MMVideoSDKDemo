//
//  MDAssetCompressHandler.m
//  MDChat
//
//  Created by YZK on 2018/11/1.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDAssetCompressHandler.h"
#import <MMFoundation/MMFoundation.h>
#import "MDMomentDownloadMaskView.h"

@import MLMediaFoundation;


static NSString * const kMDAssetCompressInfoKeyPresetName = @"presetName";
static NSString * const kMDAssetCompressInfoKeyVideoSize = @"videoSize";
static NSString * const kMDAssetCompressInfoKeyBitRate = @"bitRate";
static NSString * const kMDAssetCompressInfoKeyFrameRate = @"frameRate";
static NSString * const kMDAssetCompressInfoKeyFileSize = @"fileSize";


@interface MDAssetCompressHandler () <MDMomentDownloadMaskViewDelegate>

@property (nonatomic, strong) MLAVAssetExportSession   *exportSession;
@property (nonatomic, strong) MDMomentDownloadMaskView *compressorProgressView;
@property (nonatomic, strong) NSDictionary             *compressorDict;

@property (nonatomic, copy) void (^cancelHandler)(void);

@end


@implementation MDAssetCompressHandler

- (void)dealloc
{
    [self.exportSession cancelExport];
    self.exportSession = nil;
}

#pragma mark - public

- (void)applicationWillResignActive {
    [self.compressorProgressView dismissDownloadMaskViewCompletion:nil];
    [self.exportSession cancelExport];
    self.exportSession = nil;
}


- (BOOL)needCompressWithAsset:(AVAsset *)asset
                     mediaURL:(NSURL *)mediaURL
{
    BOOL result = NO;
    
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize presentationSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    presentationSize.width = ABS(presentationSize.width);
    presentationSize.height = ABS(presentationSize.height);
    CGFloat videoSize = presentationSize.width * presentationSize.height;
    
    NSMutableDictionary *compressorDict = [NSMutableDictionary dictionary];
    NSDictionary *dict = [[self class] compressStrategyDict];
    
    //判断分辨率
    CGFloat maxVideoSize = [dict floatForKey:kMDAssetCompressInfoKeyVideoSize defaultValue:0];
    if (videoSize > maxVideoSize) {
        CGFloat scale = sqrt(videoSize/maxVideoSize);
        presentationSize.width = roundf(presentationSize.width / scale);
        presentationSize.height = roundf(presentationSize.height / scale);
        if ((int)presentationSize.width%4 !=0) {
            presentationSize.width = floor(presentationSize.width/4)*4;
        }
        if ((int)presentationSize.height%4 !=0) {
            presentationSize.height = floor(presentationSize.height/4)*4;
        }
        result = YES;
    }
    [compressorDict setObject:[NSValue valueWithCGSize:presentationSize] forKey:kMDAssetCompressInfoKeyVideoSize];

    //判断文件大小
    NSDictionary *resourceValues = [mediaURL resourceValuesForKeys:@[NSURLFileSizeKey,NSURLTotalFileSizeKey] error:nil];
    unsigned long long originalFileSize = [resourceValues longLongValueForKey:NSURLFileSizeKey defaultValue:0] ?: [resourceValues longLongValueForKey:NSURLTotalFileSizeKey defaultValue:0];
    unsigned long long maxFileSize = [dict longLongValueForKey:kMDAssetCompressInfoKeyFileSize defaultValue:0];
    if (originalFileSize > maxFileSize) {
        unsigned long long maxDataRate = [dict longLongValueForKey:kMDAssetCompressInfoKeyBitRate defaultValue:0];
        [compressorDict setObject:@(maxDataRate) forKey:kMDAssetCompressInfoKeyBitRate];
        result = YES;
    }
    
    //判断帧率
    CGFloat maxFrameRate = [dict floatForKey:kMDAssetCompressInfoKeyFrameRate defaultValue:0];
    if (floor([track nominalFrameRate]) > maxFrameRate) {
        [compressorDict setObject:@(maxFrameRate) forKey:kMDAssetCompressInfoKeyFrameRate];
        result = YES;
    }
    
    //判断编码格式
    AVVideoCodecType codecType = [self videoCodecTypeWithAsset:asset];
    if (![codecType isEqualToString:AVVideoCodecH264]) {
        result = YES;
    }
    
    self.compressorDict = [compressorDict copy];
    return result;
}



- (void)compressorVideoWithPHAsset:(PHAsset *)phAsset
                             asset:(AVAsset *)asset
                          mediaURL:(NSURL *)mediaURL
                         timeRange:(CMTimeRange)timeRange
                       hasCutVideo:(BOOL)hasCutVideo
                 progressSuperView:(UIView *)view
                 completionHandler:(void (^)(NSURL *))completionHandler
                     cancelHandler:(nonnull void (^)(void))cancelHandler
{
    self.cancelHandler = cancelHandler;
    
    
    NSURL *outputURL = [self generateMovieTempURL];
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    
    BOOL needCompress = [self needCompressWithAsset:asset mediaURL:mediaURL];
    if (hasCutVideo || needCompress) {
        
        _compressorProgressView = [MDMomentDownloadMaskView showDownloadMaskViewWithBlurView:view infoStr:@"正在处理中"];
        _compressorProgressView.delegate = self;
        
        CGSize presentationSize = [[self.compressorDict objectForKey:kMDAssetCompressInfoKeyVideoSize] CGSizeValue];
        AVMutableVideoComposition *videoComposition = [self createVideoCompositionWithAsset:asset targetSize:presentationSize];
        CGFloat maxFrameRate = [self.compressorDict floatForKey:kMDAssetCompressInfoKeyFrameRate defaultValue:0];
        if (maxFrameRate>0) {
            if (@available(iOS 11.0, *)) {
                videoComposition.sourceTrackIDForFrameTiming = kCMPersistentTrackID_Invalid;
            }
            videoComposition.frameDuration = CMTimeMake(1, (int)(maxFrameRate));
        }
        
        unsigned long long bitRate = [self.compressorDict floatForKey:kMDAssetCompressInfoKeyBitRate defaultValue:0];
        
        MLAVAssetExportSession *exportSession = [MLAVAssetExportSession exportSessionWithAsset:asset];
        if (!exportSession) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler(nil);
            });
            return;
        }
        self.exportSession = exportSession;
        exportSession.timeRange = timeRange;
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.videoComposition = videoComposition;
        exportSession.outputURL = outputURL;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        NSMutableDictionary *compressionPropertiesDict = [NSMutableDictionary dictionary];
        [compressionPropertiesDict setValue:AVVideoProfileLevelH264HighAutoLevel forKey:AVVideoProfileLevelKey];
        if (bitRate) {
            [compressionPropertiesDict setValue:@(bitRate) forKey:AVVideoAverageBitRateKey];
        }
        
        exportSession.videoSettings = @{AVVideoWidthKey : @(presentationSize.width),
                                        AVVideoHeightKey : @(presentationSize.height),
                                        AVVideoCodecKey : AVVideoCodecH264,
                                        AVVideoCompressionPropertiesKey : compressionPropertiesDict,
                                        };
        
        
        AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        CMFormatDescriptionRef sourceFormatHint = (__bridge CMFormatDescriptionRef)([audioTrack formatDescriptions].firstObject);
        
        NSUInteger numberOfChannels = 1;
        if (sourceFormatHint != NULL) {
            const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(sourceFormatHint);
            if (asbd != NULL) {
                numberOfChannels = asbd->mChannelsPerFrame;
            }
        }
        
        NSData *currentChannelLayoutData = [NSData data];
        if (sourceFormatHint != NULL) {
            size_t aclSize = 0;
            const AudioChannelLayout *currentChannelLayout =  CMAudioFormatDescriptionGetChannelLayout(sourceFormatHint, &aclSize);
            if (currentChannelLayout != nil && aclSize > 0) {
                currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
            }
        }
        
        exportSession.audioSettings = @{AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                        AVNumberOfChannelsKey : @(numberOfChannels),
                                        AVChannelLayoutKey : currentChannelLayoutData,
                                        AVSampleRateKey : @(44100),
                                        AVEncoderBitRatePerChannelKey : @(64 * 1024)
                                        };

        __weak typeof(self) weakSelf = self;
        exportSession.progressUpdateHandler = ^(float progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.compressorProgressView.progress = progress >= 1.0 ? 0.99 : progress;
            });
        };
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.compressorProgressView dismissDownloadMaskViewCompletion:nil];
                
                NSError *error = weakSelf.exportSession.error;
                if (error || weakSelf.exportSession.status != AVAssetExportSessionStatusCompleted) {
//                    [MDClientLog uploadLogWithKey:@"ios_compressorVideo_log" content:[NSString stringWithFormat:@"compressorVideo Fail error_code:%ld error_msg:%@ u serInfo:%@", (long)error.code, error.localizedDescription,error.userInfo]];
                    if (completionHandler) completionHandler(nil);
                } else {
                    if (completionHandler) completionHandler(outputURL);
                }
                weakSelf.exportSession = nil;
            });
        }];

        
    }else {
        //单纯的导出
        [self getVideoPathFromPHAsset:phAsset outputURL:outputURL complete:^(NSURL *finalURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler(finalURL);
            });
        }];
    }
}

- (AVMutableVideoComposition *)createVideoCompositionWithAsset:(AVAsset *)asset targetSize:(CGSize)targetSize {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:asset];

    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize naturalSize = [videoTrack naturalSize];
    CGAffineTransform transform = videoTrack.preferredTransform;
    CGFloat videoAngleInDegree  = atan2(transform.b, transform.a) * 180 / M_PI;
    if (videoAngleInDegree == 90 || videoAngleInDegree == -90) {
        CGFloat width = naturalSize.width;
        naturalSize.width = naturalSize.height;
        naturalSize.height = width;
    }
    videoComposition.renderSize = naturalSize;
    
    //下面注释的代码暂时不要删，如果有问题，使用下面的代码
//    if (videoAngleInDegree != 0) {
//        CGAffineTransform mixedTransform = CGAffineTransformIdentity;
//        if(videoAngleInDegree == 90){
//            //顺时针旋转90°  ,home按键在左
//            CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height,0.0);
//            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
//            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
//        }else if(videoAngleInDegree == 180){
//            //顺时针旋转180°  ,home按键在上
//            CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
//            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
//            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
//        }else if(videoAngleInDegree == -90){
//            //顺时针旋转270°(逆时针旋转90°)  ,home按键在右
//            CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
//            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
//            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
//        }
//
//        AVMutableVideoCompositionInstruction *rotateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//        rotateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
//
//        AVMutableVideoCompositionLayerInstruction *rotateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//        [rotateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
//
//        rotateInstruction.layerInstructions = @[rotateLayerInstruction];
//        //将视频方向旋转加入到视频处理中
//        videoComposition.instructions = @[rotateInstruction];
//    }

    return videoComposition;
}

#pragma mark - 辅助方法

// 获取视频编码格式
static NSString *FourCCString(FourCharCode code) {
    NSString *result = [NSString stringWithFormat:@"%c%c%c%c",
                        (char)((code >> 24) & 0xff),
                        (char)((code >> 16) & 0xff),
                        (char)((code >> 8) & 0xff),
                        (char)(code & 0xff)];
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    return [result stringByTrimmingCharactersInSet:characterSet];
}

- (NSString *)videoCodecTypeWithAsset:(AVAsset *)asset {
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];

    CMVideoFormatDescriptionRef ref = (__bridge CMVideoFormatDescriptionRef)track.formatDescriptions.firstObject;
    FourCharCode codeType = CMVideoFormatDescriptionGetCodecType(ref);
    return FourCCString(codeType);
}


// 导出相册中的视频
- (void)getVideoPathFromPHAsset:(PHAsset *)asset outputURL:(NSURL *)outputURL complete:(void (^)(NSURL *outputURL))complete {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:outputURL
                                                                   options:nil
                                                         completionHandler:^(NSError * _Nullable error) {
                                                             if (error) {
                                                                 complete(nil);
                                                             } else {
                                                                 complete(outputURL);
                                                             }
                                                         }];
    } else {
        complete(nil);
    }
}

// 压缩策略
+ (NSDictionary *)compressStrategyDict {
    // [[[MDContext currentUser] dbStateHoldProvider] momentRecordClarityStrategy]
    if (NO) {
        static NSDictionary *compressDict;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            compressDict = @{
                             kMDAssetCompressInfoKeyPresetName : AVAssetExportPreset1920x1080,
                             kMDAssetCompressInfoKeyVideoSize : @(1920*1080), //2073600
                             kMDAssetCompressInfoKeyFrameRate : @(30),
                             kMDAssetCompressInfoKeyBitRate : @(7 << 20),
                             kMDAssetCompressInfoKeyFileSize : @(60 << 20),
                             };
        });
        return compressDict;
    }else {
        static NSDictionary *compressDict;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            compressDict = @{
                             kMDAssetCompressInfoKeyPresetName : AVAssetExportPreset1280x720,
                             kMDAssetCompressInfoKeyVideoSize : @(1280*720), //921600
                             kMDAssetCompressInfoKeyFrameRate : @(30),
                             kMDAssetCompressInfoKeyBitRate : @(5 << 20),
                             kMDAssetCompressInfoKeyFileSize : @(60 << 20),
                             };
        });
        return compressDict;
    }
}

// 生成临时文件
- (NSURL *)generateMovieTempURL
{
    NSString *fileName = [@([[NSDate date] timeIntervalSince1970]) stringValue];
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(),fileName, @".mp4"]];
}


#pragma mark - MDMomentDownloadMaskViewDelegate
- (void)momentDownloadMaskView:(MDMomentDownloadMaskView *)maskView didClickCloseView:(UIView *)closeView
{
    [self.exportSession cancelExport];
    self.exportSession = nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.cancelHandler) self.cancelHandler();
    });
}


@end
