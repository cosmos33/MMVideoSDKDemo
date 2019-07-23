//
//  MDRecordingAdapter.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/27.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MDRecordFilter.h"
#import "MDCameraDetectorPipline.h"
#import "MDRecordCameraAdapter.h"
#import "MDBBGPUImageSlidingFilter.h"

@class CXBeautyConfiguration;
@protocol MLPixelBufferDisplay;

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordingAdapter : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithToken:(NSString *)token;

@property (nonatomic, strong, readonly) UIView<MLPixelBufferDisplay> *previewView;

@end

@interface MDRecordingAdapter (Capture)

- (void)setMaxRecordDuration:(NSTimeInterval)duration;
- (void)setMinRecordDuration:(NSTimeInterval)duration;

- (void)setVideoCodecKey:(NSString *)codeckey;
- (void)setVideoBitRate:(float)bitrate;

- (void)setVideoResolution:(CGSize)resolution;
- (void)setVideoScaleMode:(NSString *)scaleMode;

- (void)setCameraPreset:(NSString *)preset;
- (void)setCameraPosition:(AVCaptureDevicePosition)position;

- (void)setupRecorder;
    
- (void)setVideoZoomFactor:(CGFloat)factor;
- (CGFloat)videoZoomFactor;

- (NSTimeInterval)recordDuration;

// 是否支持闪光灯
- (BOOL)hasFlash;

// 闪光灯模式
- (NSArray *)supportFlashModes;

// 设置闪光灯模式
@property (nonatomic, assign) MDRecordCaptureFlashMode flashMode;

- (BOOL)hasVideoInput;

@property (nonatomic, assign, readonly) AVCaptureDevicePosition cameraPosition;

- (void)switchCameraPosition;
- (void)focusCameraInPoint:(CGPoint)pointInCamera;
- (void)startCapturing;
- (void)pauseCapturing;
- (void)stopCapturing;

- (void)switchToCameraSourceType:(MDRecordCameraSourceType)cameraSourceType;
- (MDRecordCameraSourceType)cameraSourceType;

- (void)takePhoto;
// 即将开始拍照
@property (nonatomic, copy) void (^captureStillImageWillHandler)(void);
// 拍照结果回调
@property (nonatomic, copy) void (^captureStillImageHandler)(UIImage *image);

@property (nonatomic, assign)           UIDeviceOrientation     outputOrientation;

@end

@interface MDRecordingAdapter (Recording)

- (BOOL)canStartRecording;
- (void)startRecording;
- (void)pauseRecording;
- (void)cancelRecording;
- (void)stopVideoCaptureWithOutputURL:(NSURL *)URL
                    completionHandler:(void (^)(NSURL *videoFileURL, NSError *error))completionHandler;
- (NSInteger)savedSegmentCount;

- (void)deleteLastSavedSegment;
- (void)resetRecorder;

- (void)cleanStashFile;

@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, readonly) NSTimeInterval currentRecordingDuration;
@property (nonatomic, readonly) NSTimeInterval currentRecordingPresentDuration;
@property (nonatomic, assign, readonly) BOOL                    stopMerge;
@property (nonatomic, strong, readonly) id                      periodicTimeObserver;//配乐播放开始观察者

@property (nonatomic, copy) void (^recordProgressChangedHandler)(double progress);
@property (nonatomic, copy) void (^recordDurationReachedHandler)(void);
@property (nonatomic, copy) void (^completeProgressUpdateHandler)(double progress);
@property (nonatomic,copy) void (^recordSegmentsChangedHandler)(NSArray *durations, NSArray *presentDurations, BOOL valid);

@end

@interface MDRecordingAdapter (Effect)

- (void)configSlidingFilterMode:(MDRGPUImageSlidingFilterMode)mode; // need be called before setupRecorder;
- (void)configCurrentFilter:(MDRecordFilter *)filter;
- (void)configFilterA:(MDRecordFilter *)filterA configFilterB:(MDRecordFilter *)filterB offset:(float)offset;

- (void)updateDecoration:(FDKDecoration *)decoration;
- (void)removeDecoration;
- (void)adjustStikcerVolume:(float)volume;

- (void)activateBarenessDetectorEnable:(BOOL)enable;
- (BOOL)hasDetectorBareness;
- (void)setDetectBareness:(void (^)(void))detectBareness;

@property (nonatomic, copy) void(^ _Nullable detectFace)(BOOL tracking);

@property (nonatomic, copy) void (^faceFeatureHandler)(CVPixelBufferRef pixelBuffer);

@property (nonatomic, assign) BOOL canUseAIBeautySetting;
@property (nonatomic, assign) BOOL canUseBodyThinSetting;
@property (nonatomic, readonly) BOOL isFaceCaptured;

- (void)clean;
- (void)resetState;

@end

@interface MDRecordingAdapter (Music)

// 音乐资源
@property (nonatomic, strong) AVAsset *backgroundAudio;

@end

@interface MDRecordingAdapter (BeautySetting)

- (void)setBeautyConfiguration:(CXBeautyConfiguration *)config;

- (void)setSkinWhitenValue:(float)value;
- (void)setSkinSmoothValue:(float)value;
- (void)setBeautyBigEyeValue:(float)value;
- (void)setBeautyThinFaceValue:(float)value;
- (void)setBeautyThinBodyValue:(float)value;
- (void)setBeautyLenghLegValue:(float)value;

@end

@interface MDRecordingAdapter (XESEngin)

- (void)runXESEngineWithDecorationRootPath:(NSString *)path;


@end

@interface MDRecordingAdapter (SpeedVary)

- (void)setNextRecordSegmentSpeedVaryFactor:(CGFloat)factor;
- (CGFloat)nextRecordSegmentSpeedVaryFactor;
- (void)speedVaryShouldAllow:(BOOL)isAllow;
- (BOOL)hasPerSpeedEffect;

@end

NS_ASSUME_NONNULL_END
