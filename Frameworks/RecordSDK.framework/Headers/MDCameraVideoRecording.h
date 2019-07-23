//
//  MDCameraVideoFilteOutput.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/19.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "MDCameraVideoSegmentsManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDCameraVideoRecording : NSObject

- (instancetype)init;

@property (nonatomic,copy) NSDictionary *videoCompressionSettings;
@property (nonatomic,copy) NSDictionary *audioCompressionSettings;

@property (nonatomic, assign) NSTimeInterval recordDuration;
@property (nonatomic, assign) int oritation;

@property (nonatomic, readonly, getter=isRecording) BOOL recording;

@property (nonatomic,readonly) NSTimeInterval currentRecordingDuration; //当前的录制时长
@property (nonatomic,readonly) NSTimeInterval currentRecordingPresentDuration; //变速后的展现时长

@property (nonatomic, readonly) NSInteger savedSegmentCount;

@property (nonatomic,copy) void (^recordProgressChangedHandler)(double progress);
@property (nonatomic,copy) void (^recordSegmentsChangedHandler)(NSArray *durations, NSArray *presentDurations, BOOL valid , MDRecordSegmentStatus segmentStatus);
@property (nonatomic,copy) void (^recordDurationReachedHandler)(void);
@property (nonatomic,copy) void (^completeProgressUpdateHandler)(double progress);

- (BOOL)startVideoCapture;

- (BOOL)pauseVideoCapture;

- (void)cancelCurrentSegmentCapture;

- (void)deleteLastVideoSegment;

- (void)stopVideoCaptureWithCompletionHandler:(void (^)(NSURL *videoFileURL, NSError *error, BOOL doNothing))completionHandler;

- (void)reset;

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer;

// 变速
- (void)setNextRecordSegmentSpeedVaryFactor:(CGFloat)factor; //设置将要录制的视频的变速倍数
- (CGFloat)nextRecordSegmentSpeedVaryFactor;
- (void)speedVaryShouldAllow:(BOOL)isAllow;
- (BOOL)hasPerSpeedEffect; //是否添加前置变速

@end

NS_ASSUME_NONNULL_END
