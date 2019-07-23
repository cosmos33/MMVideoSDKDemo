//
//  BBCamera.h
//  BiBi
//
//  Created by YuAo on 3/29/16.
//  Copyright © 2016 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MDRecordCamera : NSObject

@property (nonatomic, strong, readonly) AVCaptureDevice *currentCameraDevice;

@property (nonatomic, strong, readonly) AVCaptureConnection *videoCaptureConnection;

@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

@property (nonatomic, strong, readonly) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong, readonly) AVCaptureAudioDataOutput *audioDataOutput;

- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition;

- (void)enableVideoDataOutputWithDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate queue:(dispatch_queue_t)queue;

- (void)enableAudioDataOutputWithDelegate:(id<AVCaptureAudioDataOutputSampleBufferDelegate>)delegate queue:(dispatch_queue_t)queue;

- (void)startRunningCaptureSession;

- (void)stopRunningCaptureSession;

- (void)removeSampleBufferDelegateAndQueue;
- (void)addVideoSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate queue:(dispatch_queue_t)queue;
- (void)addAudioSampleBufferDelegate:(id<AVCaptureAudioDataOutputSampleBufferDelegate>)delegate queue:(dispatch_queue_t)queue;

- (void)rotateCamera;

//camera的一些清理工作
- (void)cleanCamera;

@property (nonatomic) NSInteger videoCaptureDeviceFrameRate;

@end
