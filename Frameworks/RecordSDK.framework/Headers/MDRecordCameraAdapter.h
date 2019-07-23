//
//  MDCameraAdapter.h
//  MomoChat
//
//  Created by 符吉胜 on 2018/1/15.
//  Copyright © 2018年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger,MDRecordCameraSourceType)
{
    MDRecordCameraSourceType_captureSession,
    MDRecordCameraSourceType_ARKIT
};

typedef NS_ENUM(NSUInteger, MDRecordCaptureFlashMode) {
    MDRecordCaptureFlashModeOff   = 0,
    MDRecordCaptureFlashModeOn    = 1,
    MDRecordCaptureFlashModeAuto  = 2,
};

@class MDRecordCameraAdapter;

@protocol MDRecordCameraAdapterDelegate <NSObject>

- (void)cameraAdapter:(MDRecordCameraAdapter *)cameraAdapter didOutputVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer timinginfo:(CMSampleTimingInfo)timingInfo;

- (void)cameraAdapter:(MDRecordCameraAdapter *)cameraAdapter didOutputAudioSampleBuffer:(CMSampleBufferRef)audioSampleBuffer;


@end

@interface MDRecordCameraAdapterConfigure : NSObject

@property (nonatomic,   copy) NSString                  *sessionPreset;
@property (nonatomic, assign) NSUInteger                frameRate;
//AR模式只支持后置
@property (nonatomic, assign) AVCaptureDevicePosition   devicePosition;
@property (nonatomic, strong) dispatch_queue_t          sampleBufferVideoProcessingQueue;
@property (nonatomic, strong) dispatch_queue_t          sampleBufferAudioProcessingQueue;

@end

@interface MDRecordCameraAdapter : NSObject

@property (nonatomic,assign,readonly) MDRecordCameraSourceType       sourceType;
@property (nonatomic,assign,readonly) AVCaptureDevicePosition  devicePosition;
@property (nonatomic,assign,readonly) AVCaptureDevice          *currentDevice;
@property (nonatomic,assign,readonly) AVCaptureConnection      *captureConnection;
@property (nonatomic,assign,readonly) MDRecordCaptureFlashMode       activeFlashMode;

@property (nonatomic,weak) id<MDRecordCameraAdapterDelegate> delegate;

- (instancetype)initWithCameraSourceType:(MDRecordCameraSourceType)sourceType
                           configuration:(MDRecordCameraAdapterConfigure *)config;

- (void)switchToCameraSourceType:(MDRecordCameraSourceType)sourceType;

- (void)startCapturing;
- (void)stopCapturing;
- (void)pauseCapturing;

- (void)rotateCamera;
- (void)focusCamera:(CGPoint)point;
- (void)setVideoZoomFactor:(CGFloat)factor;
- (CGFloat)videoZoomFactor;
- (BOOL)hasVideoInput;

- (void)forceConfigureFlashMode:(MDRecordCaptureFlashMode)mode;
- (BOOL)hasFlash;
- (NSArray *)supportFlashModes;

- (void)cleanCamera;

- (void)changeAdapeterCOnfigurationPosition:(AVCaptureDevicePosition)devicePosition;

@end
