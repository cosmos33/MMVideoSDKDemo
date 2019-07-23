//
//  MDCameraRenderPipline.h
//  MomoChat
//
//  Created by sunfei on 2019/1/2.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MDCameraRenderFilter.h"
#import "MDCameraDetectorPipline.h"
#import "MDProcessImageProtocol.h"

@class MDCameraEditorContext, FDKDecoration, FDKBeautySettings;

NS_ASSUME_NONNULL_BEGIN

@interface MDCameraRenderPipline : NSObject <MDProcessImageProtocol>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContext:(MDCameraEditorContext *)context;
- (instancetype)initWithContext:(MDCameraEditorContext *)context slidingMode:(MDRGPUImageSlidingFilterMode)mode NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak, readonly) MDCameraEditorContext *context;

@property (nonatomic, readonly) MDCameraRenderFilter *renderFilter;
@property (nonatomic, readonly) MDCameraDetectorPipline *detector;
@property (nonatomic, readonly) BOOL isFaceCaptured;

- (void)updateDecoration:(FDKDecoration *)decoration;
- (void)removeDecoration;

- (void)updateBeautySetting:(FDKBeautySettings *)beautySetting;

- (void)resetState;

- (void)activateBarenessDetectorEnable:(BOOL)enable;
@property (nonatomic, copy) void(^ _Nullable detectFace)(BOOL tracking);

// 3D
-(void)runXESEngineWithPosition:(NSString *)decorationBastPath;
- (void)rotateCamera:(AVCaptureDevicePosition)position;
- (void)enableRecording:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
