//
//  MDMomentRecordHandler.h
//  MDChat
//
//  Created by wangxuan on 17/1/18.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@import RecordSDK;
#import <MomoCV/MomoCV.h>


@class FDKDecoration;

@interface MDMomentRecordHandler : NSObject

@property (nonatomic, assign, readonly) BOOL                    isRecording;
@property (nonatomic, assign, readonly) NSInteger               savedSegmentCount;
@property (nonatomic, assign, readonly) NSTimeInterval          currentRecordingDuration;
@property (nonatomic, assign, readonly) NSTimeInterval          currentRecordingPresentDuration;
@property (nonatomic, assign, readonly) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, strong)           AVAsset                 *backgroundAudio;
@property (nonatomic, assign)           UIDeviceOrientation     outputOrientation;
@property (nonatomic, assign)           NSTimeInterval          recordDuration;
@property (nonatomic, assign, readonly) BOOL                    stopMerge;
@property (nonatomic, assign, readonly) NSInteger               soundEnergyRank;
@property (nonatomic, assign, readonly) BOOL                    isReadyToPlayMusic;

//人脸是否有检测到
@property (nonatomic, readonly)           BOOL                    isFaceCaptured;
//是否检测到光膀子
@property (nonatomic, readonly)            BOOL                    hasDetectorBareness;

@property (nonatomic, assign) BOOL                              shouldContinue;
@property (nonatomic, assign)NSUInteger                         currentSignal;

/** 是否开启ai 美白 默认关闭*/
@property (nonatomic, assign) BOOL useAISkinWhiten;

/** 是否开启ai 磨皮 默认关闭 */
@property (nonatomic, assign) BOOL useAISkinSmooth;

/** 是否开启ai 大眼 瘦脸 默认关闭 */
@property (nonatomic, assign) BOOL useAIBigEyeThinFace;


/* Callbacks */
@property (nonatomic, copy) void (^recordProgressChangedHandler)(double progress);

@property (nonatomic, copy) void (^recordSegmentsChangedHandler)(NSArray *durations, NSArray *presentDurations, BOOL valid);

@property (nonatomic, copy) void (^recordDurationReachedHandler)(void);

@property (nonatomic, copy) void (^newFrameTipHandler)(NSString *tip);

@property (nonatomic, copy) void (^completeProgressUpdateHandler)(double progress);

@property (nonatomic, copy) void (^captureStillImageWillHandler)(void);
@property (nonatomic, copy) void (^captureStillImageHandler)(UIImage *image, NSDictionary *metaInfo);

@property (nonatomic, copy) void(^_Nullable faceFeatureHandler)(CVPixelBufferRef pixelbuffer, NSArray<MMFaceFeature *> * _Nullable faceFeatures, NSArray<MMBodyFeature *> * _Nullable bodyFeatures);

- (instancetype)initWithContentView:(UIView *)view maxRecordDuration:(NSTimeInterval)maxDuration;

- (instancetype)initWithContentView:(UIView *)view maxRecordDuration:(NSTimeInterval)maxDuration cameraPosition:(AVCaptureDevicePosition)pisition;

- (instancetype)initWithContentView:(UIView *)containerView maxRecordDuration:(NSTimeInterval)maxDuration cameraPosition:(AVCaptureDevicePosition)pisition openXengine:(BOOL)isOpen;

- (void)setVideoZoomFactor:(CGFloat)factor;
- (CGFloat)videoZoomFactor;

///启动3D引擎
-(void)runXESEngine;


/* Camera Controls */
- (void)startCapturing;
- (void)stopCapturing;
- (void)pauseCapturing;     //capture还是会捕捉图像，但是不会有输出

- (void)rotateCamera;
- (void)focusCameraInPoint:(CGPoint)pointInCamera;

- (BOOL)hasVideoInput;

/* Flash */
- (BOOL)hasFlash;
- (NSArray *)supportFlashModes;
- (void)setFlashMode:(MDRecordCaptureFlashMode)mode;
- (MDRecordCaptureFlashMode)flashMode;        // 设置的模式

- (void)setBeautyThinFace:(CGFloat)value;
- (void)setBeautyBigEye:(CGFloat)value;
- (void)setBeautySkinWhite:(CGFloat)value;
- (void)setBeautySkinSmooth:(CGFloat)value;
- (void)setBeautyLongLeg:(CGFloat)value;
- (void)setBeautyThinBody:(CGFloat)value;
/* video process */
- (void)addDecoration:(FDKDecoration *)decoration;
- (void)muteDecorationAudio:(BOOL)mute;
- (void)removeAllDecoration;
- (void)configureFilterA:(MDRecordFilter *)filterA filterB:(MDRecordFilter *)filterB offset:(double)filterOffset;
- (FDKDecoration *)makeDecorationWithBeautySettingsDict:(NSDictionary *)beautySettingsDict;
- (void)updateDecorationWithBeautySettingsDict:(NSDictionary *)beautySettingsDict decoration:(FDKDecoration *)decoration;

// purge cache buffer
- (void)cleanCache;         //all
- (void)purgeGPUCache;      //gpu alone

/* recording relates */
- (void)captureStillImage;
- (void)startRecording;
- (void)stopVideoCaptureWithCompletionHandler:(void (^)(NSURL *videoFileURL, NSError *error))completionHandler;
- (void)pauseRecording;
- (void)cancelRecording;

- (void)deleteLastSavedSegment;
- (void)resetRecorder;
- (BOOL)canStartRecording;
- (void)clearStashVideo;

/* audio pitch */
- (void)handleSoundPitchWithAssert:(AVAsset *)videoAsset
                    andPitchNumber:(NSInteger)pitchNumber
                 completionHandler:(void (^) (NSURL *))completionHandler;

//activate barenessDetector
- (void)activateBarenessDetectorEnable:(BOOL)enable;

//为空变脸添加变脸提示
- (void)configFaceTipManagerForEmptyDecoration;

- (void)enableReverseVideoSampleBuffer:(BOOL)enable;

//设置将要录制的视频的变速倍数
- (void)setNextRecordSegmentSpeedVaryFactor:(CGFloat)factor;
- (CGFloat)nextRecordSegmentSpeedVaryFactor;
- (void)speedVaryShouldAllow:(BOOL)isAllow;
- (BOOL)hasPerSpeedEffect;


// 背景模糊
- (void)addBlurEffect;
- (void)removeBlurEffect;

- (void)muteSticker:(BOOL)mute;
- (void)enableRecordAudio:(BOOL)enable;

- (void)recordOrigin:(BOOL)enable;

- (void)updateExposureBias:(float)bias;

- (BOOL)restartCapturingWithCameraPreset:(AVCaptureSessionPreset)preset;

- (BOOL)hitTestTouch:(CGPoint)point withView:(UIView *)view;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

// 美妆相关操作

// 美妆、风格妆
/// 添加美妆子项或整装风格妆
/// @params makeupEffect 美妆资源路径
- (void)addMakeupEffect:(NSString *)makeupEffect;

/// 设置美妆强度
/// @params intensity 强度 [0-1]
/// @params makeupType 美妆子项类型
- (void)setMakeupEffectIntensity:(CGFloat)intensity makeupType:(XEngineMakeupKey)makeupType;

/// 按美妆子项移除美妆
/// @params makeupType 美妆子项类型
- (void)removeMakeupEffectWithType:(XEngineMakeupKey)makeupType;

/// 移除所有美妆效果
- (void)removeAllMakeupEffect;

- (void)adjustBeauty:(CGFloat)value forKey:(NSString *)type;

- (void)setRenderStatus:(BOOL)status;
@end
