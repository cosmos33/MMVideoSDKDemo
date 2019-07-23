//
//  ARVideoCamera.h
//  FaceDecorationKitDemo
//
//  Created by momo783 on 22/12/2017.
//  Copyright © 2017 Momo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ARVideoCameraDelegate;
@protocol ARVideoSessionDelegate;

@interface MDRecordARVideoCamera : NSObject

+ (BOOL)isARSupported;

@property (nonatomic, readonly) ARSession *session API_AVAILABLE(ios(11.0));

@property (nonatomic, assign) NSUInteger videoCaptureDeviceFrameRate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSessionPreset:(NSString *)sessionPreset error:(NSError **)error;

- (void)enableVideoDataOutputWithDelegate:(nullable id<ARVideoCameraDelegate>)delegate queue:(dispatch_queue_t)queue;

- (void)enableVideoSessionDataOutputWithDelegate:(nullable id<ARVideoSessionDelegate>)delegate;

- (void)startRunningCaptureSession;

- (void)stopRunningCaptureSession;

@end

@protocol ARVideoSessionDelegate <ARSessionDelegate>

- (void)session:(ARSession *)session currentFrame:(ARFrame*)currentFrame API_AVAILABLE(ios(11.0));

@end

@protocol ARVideoCameraDelegate <NSObject>

- (void)camera:(MDRecordARVideoCamera *)camera didOutputVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer frameTime:(CMTime)frameTime;

- (void)camera:(MDRecordARVideoCamera *)camera didOutputAudioSampleBuffer:(CMSampleBufferRef)audioSampleBuffer;

@end

NS_ASSUME_NONNULL_END
