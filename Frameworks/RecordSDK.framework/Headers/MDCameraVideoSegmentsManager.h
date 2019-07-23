//
//  MDCameraVideoSegmentsManager.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/19.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MDRecordSegmentStatus)
{
    MDSegmentNumberStatusSame = 0,
    MDSegmentNumberStatusDecrease,
    MDSegmentNumberStatusIncrease
};

@interface MDCameraVideoSegmentsManager : NSObject

- (instancetype)init;
- (instancetype)initWithMaxDuration:(NSTimeInterval)recordDuration NS_DESIGNATED_INITIALIZER;

// 最大录制时长
@property (nonatomic, assign) NSTimeInterval maxRecordDuration;

// all segment's URLs
@property (nonatomic, readonly) NSArray<NSURL *> *videoSegmentURLs;
@property (nonatomic, readonly) NSArray<AVAsset *> *assets;

// 当前已录制的时长
@property (nonatomic, readonly) NSTimeInterval currentRecordingDuration;
@property (nonatomic, readonly) NSTimeInterval currentRecordingPresentDuration;

// 各个segment的时长
@property (nonatomic, readonly) NSArray *videoSegmentDurations;
@property (nonatomic, readonly) NSArray *videoSegmentPresentDurations;

// number of the segments
@property (nonatomic, readonly) NSInteger savedSegmentCount;

// 录制时长小于最短录制时长，并且呈现时长小于限制最大时长
@property (nonatomic, readonly) BOOL canExport;

// 呈现时长大于等于限制最大时长
@property (nonatomic, readonly) BOOL hasReachMaxVideoDuration;

// 存储文件总时长是不是超过限制最大时长
@property (nonatomic, readonly) BOOL savedVideoReachMaxVideoDuration;

// 进度(currentRecordingPresentDuration / maxRecordDuration)
@property (nonatomic, readonly) double progress;

// 录制状态更新
- (void)updateCurrentVideoSegmentDuration:(NSTimeInterval)duration;

// callback when segments changed(delete/add)
@property (nonatomic, copy) void(^recordSegmentsChangedHandler)(NSArray *durations, NSArray *presentDurations, BOOL valid , MDRecordSegmentStatus segmentStatus);

// append a segment
- (void)addVideoSegment:(NSURL *)segmentURL;

// delete last segment
- (void)deleteLastVideoSegment;

// reset all states
- (void)reset;

// speed vary
- (void)setNextRecordSegmentSpeedVaryFactor:(CGFloat)factor; //设置将要录制的视频的变速倍数
- (CGFloat)nextRecordSegmentSpeedVaryFactor;
- (void)speedVaryShouldAllow:(BOOL)isAllow;
- (BOOL)hasPerSpeedEffect; //是否添加前置变速

@end

NS_ASSUME_NONNULL_END
