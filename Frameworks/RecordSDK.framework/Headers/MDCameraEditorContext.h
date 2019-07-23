//
//  MDCameraEditorContext.h
//  MDRecordSDK
//
//  Created by sunfei on 2018/10/30.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "MDMediaEditorContext.h"
#import "MDRecordCameraAdapter.h"
#import "MDImageDetectorProtocol.h"

@class MMFaceFeature;
@protocol MLPixelBufferDisplay;

typedef struct {
    NSInteger faceTrackingIdentifier;
    NSInteger faceTrackingCount;
    CGRect    faceRect;
    BOOL manualFocus;
} MDRecordAutoFocusCameraFaceTracking;

FOUNDATION_EXPORT BOOL RecorderFaceDeviation(CGRect oldFaceRect, CGRect newFaceRect);

NS_ASSUME_NONNULL_BEGIN

@interface MDCameraEditorContext : MDMediaEditorContext

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)position sessionPreset:(NSString *)preset;

@property (nonatomic, strong) id<MDProcessImageProtocol> filter;

@property (nonatomic,assign,readonly) MDRecordCameraSourceType cameraSourceType;

@property (nonatomic, readonly) UIView<MLPixelBufferDisplay> *previewView;

@property (nonatomic, strong) AVAsset *backgroundAudio;
@property (nonatomic, strong, readonly) id periodicTimeObserver;

@property (nonatomic, assign) MDRecordCaptureFlashMode flashMode;

@property (nonatomic, readonly) BOOL isRecording;

@property (nonatomic, assign) NSTimeInterval recordDuration;

@property (nonatomic, assign) UIDeviceOrientation outputOrientation;


// example:
//_recorder.videoCompressionSettings = @{
//                                       AVVideoCodecKey : AVVideoCodecH264,
//                                       AVVideoWidthKey : @(720),
//                                       AVVideoHeightKey : @(1280),
//                                       AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
//                                       AVVideoCompressionPropertiesKey: @{
//                                                                          AVVideoAverageBitRateKey : @(recordVideoBitRate),
//                                                                          AVVideoMaxKeyFrameIntervalKey : @(30)
//                                                                         }
//                                      };
@property (nonatomic, strong) NSDictionary *videoCompressionSettings;

/* Callbacks */

// 关于录制的进度
@property (nonatomic, copy) void (^recordProgressChangedHandler)(double progress);

// 删除/增加一段录制内容
@property (nonatomic, copy) void (^recordSegmentsChangedHandler)(NSArray *durations, NSArray *presentDurations, BOOL valid);

// 到达最大录制时间
@property (nonatomic, copy) void (^recordDurationReachedHandler)(void);

// 将分段录制的内容合并成一个文件进度
@property (nonatomic, copy) void (^completeProgressUpdateHandler)(double progress);

@property (nonatomic, copy) void (^captureStillImageWillHandler)(void);
@property (nonatomic, copy) void (^captureStillImageHandler)(UIImage *image);

@property (nonatomic, copy) void (^faceFeatureHandler)(CVPixelBufferRef pixelBuffer);

@end

@interface MDCameraEditorContext (MDSpeedVary)

//设置将要录制的视频的变速倍数
- (void)setNextRecordSegmentSpeedVaryFactor:(CGFloat)factor;

- (CGFloat)nextRecordSegmentSpeedVaryFactor;

- (void)speedVaryShouldAllow:(BOOL)isAllow;

- (BOOL)hasPerSpeedEffect;

@end

// 由于变音库放到pod中会造成k歌及语音通话crash，因此暂时现将该模块移到主工程中实现。
//@interface MDCameraEditorContext (MDAudioPitch)
//
//- (void)handleSoundPitchWithAssert:(AVAsset *)videoAsset
//                    andPitchNumber:(NSInteger)pitchNumber
//                 completionHandler:(void (^) (NSURL *))completionHandler;
//
//@end

@interface MDCameraEditorContext (MDRecord)

- (void)startRecording;
- (void)stopVideoCaptureWithOutputURL:(NSURL *)URL
                    completionHandler:(void (^)(NSURL *videoFileURL, NSError *error))completionHandler;
- (void)pauseRecording;
- (void)cancelRecording;

@property (nonatomic, readonly) BOOL stopMerge;

- (NSInteger)savedSegmentCount;
- (void)deleteLastSavedSegment;
- (void)resetRecorder;
- (BOOL)canStartRecording;
- (void)clearStashVideo;

@property (nonatomic, readonly) NSTimeInterval currentRecordingDuration;
@property (nonatomic, readonly) NSTimeInterval currentRecordingPresentDuration;
@property (nonatomic, readonly) AVCaptureDevicePosition cameraPosition;

@end

@interface MDCameraEditorContext (MDCaptureStillImage)

- (void)captureStillImage;

@end

@interface MDCameraEditorContext (MDCameraControl)

- (void)startCapturing;
- (void)stopCapturing;
- (void)pauseCapturing;     //capture还是会捕捉图像，但是不会有输出

- (void)rotateCamera;
- (void)focusCameraInPoint:(CGPoint)pointInCamera;
- (void)updateAutoFocusCameraFaceTracking:(MMFaceFeature * _Nullable)faceFeature;

- (void)setVideoZoomFactor:(CGFloat)factor;
- (CGFloat)videoZoomFactor;

- (BOOL)hasVideoInput;

/* Flash */
- (BOOL)hasFlash;
- (NSArray *)supportFlashModes;
- (void)setFlashMode:(MDRecordCaptureFlashMode)mode;
- (MDRecordCaptureFlashMode)flashMode;        // 设置的模式

- (void)switchToCameraSourceType:(MDRecordCameraSourceType)cameraSourceType;

@end

NS_ASSUME_NONNULL_END
