//
//  MDAssetWriter.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/5.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class MTIImage;

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetWriter : NSObject

@property (nonatomic, assign) CGAffineTransform transform;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithURL:(NSURL *)URL size:(CGSize)size fileType:(AVFileType)fileType liveVideo:(BOOL)liveVideo;

- (BOOL)startRecording;
- (void)cancelRecording;
- (void)finishRecording;
- (void)finishRecordingWithCompletionHandler:(void(^ _Nullable)(void))completion;

@property (nonatomic, readonly) NSURL *outputURL;
@property (nonatomic, readonly) AVAssetWriterStatus status;

// 设置视频输出
- (BOOL)activateVideoTrackWithSetting:(NSDictionary *)videoOutputSetting
                     sourceFormatHint:(CMFormatDescriptionRef _Nullable)sourceFormatHint;

// 设置音频输出
- (BOOL)activateAudioTrackWithSetting:(NSDictionary * _Nullable)audioOutputSetting
                     sourceFormatHint:(CMFormatDescriptionRef _Nullable)sourceFormatHint;

@property (nonatomic, copy) BOOL(^videoInputReadyCallback)(void);
@property (nonatomic, copy) BOOL(^_Nullable audioInputReadyCallback)(void);

@property (nonatomic, assign) BOOL shouldOptimizeForNetworkUse;
@property (nonatomic, copy) NSArray<AVMetadataItem *> * _Nullable metadata;

@property (nonatomic, readonly) NSError * _Nullable error;

- (void)processVideoBuffer:(CMSampleBufferRef)videoBuffer;
- (void)processAudioBuffer:(CMSampleBufferRef)audioBuffer;

@end

@interface MDPixelBufferAssetWriter : MDAssetWriter

- (void)processVideoPixelBuffer:(CVPixelBufferRef)videoPixelBuffer presentationTime:(CMTime)presentationTime;

@end

@interface MDMTIImageAssetWriter : MDPixelBufferAssetWriter

@property (nonatomic, copy) CVPixelBufferRef(^processed)(CVPixelBufferRef pixelBuffer, CMTime presentationTime, CVPixelBufferPoolRef preferredPixelBufferPool);

- (void)processImage:(MTIImage *)image presentationTime:(CMTime)time;

@end

NS_ASSUME_NONNULL_END
