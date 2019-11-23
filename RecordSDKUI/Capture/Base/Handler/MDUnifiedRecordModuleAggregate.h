//
//  MDUnifiedRecordModuleAggregate.h
//  MDChat
//
//  Created by 符吉胜 on 2017/7/19.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDUnifiedRecordCountDownAnimation.h"
#import "MDMusicCollectionItem.h"
#import "MDRecordVideoResult.h"
#import <RecordSDK/MDRecordCameraAdapter.h>
#import <RecordSDK/MDRecordFilter.h>
@import MomoCV;

@class MDUnifiedRecordViewController;
@class MDMomentMusicListCellModel;
@class MDImageUploadParamModel;
@class FDKDecoration;

@protocol MDUnifiedRecordModuleAggregateDelegate <NSObject>

@required
//录制相关
- (void)captureSessionDidStartOrStop:(BOOL)isStart;
- (void)didStartRecording;
- (void)didPauseRecording;
- (void)didCancelRecording;
- (void)willStopRecording;
- (void)didStopRecordingWithError:(NSError *)error
                     videoFileURL:(NSURL *)videoFileURL
                        musicItem:(MDMusicCollectionItem *)musicItem
                   musicTimeRange:(CMTimeRange)timeRange
                      videoResult:(MDRecordVideoResult *)videoResult
                    soundPitchURL:(NSURL *)soundPitchURL
                  soundEnergyRank:(NSInteger)soundEnergyRank;

- (void)didRecordProgressChange:(CGFloat)progress;
- (void)didRecordFinishWithProgress:(CGFloat)progress;
- (void)didRecordSegmentChangedWithDurations:(NSArray *)durations presentDurations:(NSArray *)presentDurations valid:(BOOL)valid;
- (void)didRecordReachMaxDuration;

- (void)didRotateCamera;
- (void)didFocusCameraInPoint:(CGPoint)point;

- (void)didSwitchToArDecoration:(BOOL)isArDecoration;
- (void)didSwitchToMDCameraSourceType:(MDRecordCameraSourceType)cameraSourceType;

//拍照相关
- (void)didStopCaptureStillImage:(UIImage *)image
                imageUploadModel:(MDImageUploadParamModel *)imageUploadModel;

//moduleView : 变脸、滤镜、配乐
- (void)moduleViewWillShowOrHide:(BOOL)isShow;
- (void)moduleViewDidShowOrHide:(BOOL)isShow;
//滤镜相关
- (void)didGetFilters:(NSArray<MDRecordFilter *> *)filters;
- (void)didSeletetedFilterIndex:(NSInteger)filterIndex;
- (void)didShowFilter:(MDRecordFilter *)filter;
//配乐相关
- (void)didCloseMusicPickerControllerWithItem:(MDMusicCollectionItem *)item;
- (void)didResetMusicPicker;
//变脸相关
- (void)didGetFaceDecorationTip:(NSString *)tip;
- (void)didResetFaceDecoration;
- (void)startLoadingFaceDecoration;
- (void)endLoadingFaceDecoration;
- (void)loadingFaceDecorationFail;

//延时动画相关
- (void)didStartCountDownAnimation;
- (void)didFinishCountDownAnimation:(BOOL)isFinish;
- (void)didSwitchToCountDownType:(MDVideoRecordCountDownType)countDownType;

//闪光灯相关
- (void)didSwitchToFlashMode:(MDRecordCaptureFlashMode)flashMode;

@end

@protocol MDRecordModuleControllerDelegate <NSObject>

@optional
- (BOOL)supportMusicFunction;
- (BOOL)supportBarenessDetectorFunction;
- (BOOL)shouldShowFaceTipForEmptyDecoration;
- (BOOL)supportRotateCamera;
- (NSTimeInterval)maxRecordDurationCurrentLevel;

- (void)faceDecorationViewRecordButtonTapped;

@end

@interface MDUnifiedRecordModuleAggregate : NSObject

@property (nonatomic,weak) id<MDUnifiedRecordModuleAggregateDelegate> delegate;

@property (nonatomic,assign,readonly) MDVideoRecordCountDownType  countDownType;

@property (nonatomic,assign,readonly) NSTimeInterval        currentRecordDuration;
@property (nonatomic,assign,readonly) NSTimeInterval        currentRecordPresentDuration;
@property (nonatomic,assign,readonly) BOOL                  currentRecordDurationSmallerThanMinSegmentDuration;
@property (nonatomic,assign,readonly) BOOL                  currentRecordDurationBiggerThanMinDuration;
@property (nonatomic,assign,readonly) NSTimeInterval        recordDuration;
@property (nonatomic,assign,readonly) NSInteger             savedSegmentCount;
@property (nonatomic,assign,readonly) MDRecordCaptureFlashMode    currentFlashMode;
@property (nonatomic,assign,readonly) BOOL                  stopMerge;
@property (nonatomic,strong,readonly) MDRecordVideoResult   *videoResult;

/** 是否开启ai 美白 默认关闭*/
@property (nonatomic, assign) BOOL useAISkinWhiten;

/** 是否开启ai 磨皮 默认关闭 */
@property (nonatomic, assign) BOOL useAISkinSmooth;

/** 是否开启ai 大眼 瘦脸 默认关闭 */
@property (nonatomic, assign) BOOL useAIBigEyeThinFace;


//@property (nonatomic,strong,readonly) MDBeautyMusicSelectViewController         *musicSelectPicker;
//@property (nonatomic,strong,readonly) NSArray                                   *musicDataSourceArray;

@property (nonatomic,strong,readonly) FDKDecoration                             *selectedDecoration;

@property (nonatomic,assign,readonly,getter=isRecording) BOOL                   recording;
@property (nonatomic,assign,readonly,getter=isFaceCaptured) BOOL                faceCaptured;
@property (nonatomic,assign,readonly,getter=isDetectorBareness) BOOL            detectorBareness;

@property (nonatomic, assign,readonly) BOOL                                      isArDecoration;

//变声模块(不应该暴露，待重构）
@property (nonatomic, strong) NSMutableArray *pitchNumbers;

@property (nonatomic, copy) void(^_Nullable faceFeatureHandler)(CVPixelBufferRef pixelbuffer, NSArray<MMFaceFeature *> * _Nullable faceFeatures, NSArray<MMBodyFeature *> * _Nullable bodyFeatures);

@property (nonatomic, assign) BOOL closeXengine;

#pragma mark -仅category可以调用
@property (nonatomic,strong,readonly) MDMomentMusicListCellModel      *preloadCellModel;

- (instancetype)initWithRecordViewController:(MDUnifiedRecordViewController<MDRecordModuleControllerDelegate> *)recordViewController;

//minDuration : 允许录制的最短时长 ，传 0 则用默认时长
- (void)setupCameraSourceHandlerWithMaxDuration:(NSTimeInterval)maxDuration
                                    minDuration:(NSTimeInterval)minDuration
                                    contentView:(UIView *)contentView;

- (void)setupCameraSourceHandlerWithMaxDuration:(NSTimeInterval)maxDuration
                                            minDuration:(NSTimeInterval)minDuration
                                            contentView:(UIView *)contentView
                                         devicePosition:(AVCaptureDevicePosition)position;

///启动3D引擎
//-(void)runXESEngineWithPosition:(AVCaptureDevicePosition)position;

//录制相关
- (void)startCapturing;
- (BOOL)restartCapturingWithCameraPreset:(AVCaptureSessionPreset)preset;
- (void)pauseCapturing;
- (void)stopCapturing;

- (void)startRecording;
- (void)pauseRecording;
- (void)cancelRecording;
- (void)stopRecording;
- (void)setOutputOrientation:(UIDeviceOrientation)orientation;

- (BOOL)switchRecordingStatus;
- (BOOL)canStartRecording;
- (void)resetRecorder;

- (void)updateRecordMaxDuration:(NSTimeInterval)maxDuration;

- (void)deleteLastSavedSegment;
- (void)rotateCamera;
- (void)focusCameraInPoint:(CGPoint)point;

- (void)captureStillImage;

//滤镜相关
- (void)activateSlidingFilters;
- (void)activateFilterDrawer;

//配乐相关
- (void)activateMusicPicker;
- (void)activateAutoMusicWithMusicItem:(MDMusicCollectionItem *)musicItem needSameStyle:(BOOL)needSameStyle;
- (void)musicPlayShouldAllow:(BOOL)isAllow;

- (void)resumePlayWhenPickVCShow;
- (void)doPause;

//变脸美颜相关
- (void)activateAutoFaceDecorationWithFaceID:(NSString *)faceID classID:(NSString *)classID;
- (void)setDefaultBeautySetting;
- (void)activateFaceDecoration;
- (void)activateThinDrawer;
//在录制按钮中的变脸当前是否在下载中
- (BOOL)isLoadingOfCurrentSelectedFace;
- (void)selectEmptyFaceItem;
- (void)purgeGPUCache;
//带有音效的变脸是否应该播放
- (void)muteFaceDecorationAudio:(BOOL)mute;

- (void)tapArDecorationWithGesture:(UITapGestureRecognizer *)tapGesture;
- (void)pinchVideoZoomFactorWithGesture:(UIPinchGestureRecognizer *)pinchGesture;

//倒计时录制
- (void)startCountDownAnimation;
- (void)cancelCountDownAnimation;
- (void)setCountDownType:(MDVideoRecordCountDownType)countDownType;
- (void)switchCountDownType;

//闪光灯
- (void)switchFlashLight;
- (void)setFlashMode:(MDRecordCaptureFlashMode)flashMode;

- (void)saveAllmoduleSettingConfig;
- (void)resetAllModuleSettingToDefaut;
- (void)clearStashVideo;
//变速相关
- (void)setSpeedVaryFactor:(CGFloat)factor;
- (void)speedVaryShouldAllow:(BOOL)isAllow;
- (BOOL)hasPerSpeedEffect;

// 美妆
- (void)activateMakeUpViewController;


//辅助方法
- (BOOL)isModuleViewShowed;
- (void)hideModuleView;
- (BOOL)isDoingCountDownAnimation;
- (NSInteger)soundPitchNumber;

- (void)muteSticker:(BOOL)mute;
- (void)enableRecordAudio:(BOOL)enable;

- (void)recordOrigin:(BOOL)enable;

- (void)enableReverseVideoSampleBuffer:(BOOL)enable;

- (void)updateExposureBias:(float)bias;

#pragma mark - 外传decoration
- (FDKDecoration*)updateDecorationFromDict:(NSDictionary*)infoDict;

@end
