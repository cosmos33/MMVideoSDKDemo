//
//  MDMomentRecordHandler.m
//  MDChat
//
//  Created by wangxuan on 17/1/18.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMomentRecordHandler.h"
#import "MDFaceDecorationFileHelper.h"
#import "MDFaceTipItem.h"
#import "MDFaceTipManager.h"
#import "UIConst.h"
#import "MDRecordContext.h"
#import "MDRecordRecordingSettingMananger.h"
#import "MDRDebugHandler.h"
#import "MDRCameraEngine+MDAudioPitch.h"

//AI美颜
//#import "MLRoomDecorationDataSource.h"

#import "MDBeautySettings.h"
#import <RecordSDK/MDRCameraEngine.h>
#import <RecordSDK/MDRMediaSegmentInfo.h>
#import <RecordSDK/MDRCaptureDeviceCapability.h>
#import <RecordSDK/MDRFaceFeatureInfo.h>
@import RecordSDK;
@import CXBeautyKit;

#define kDefaultRecordBitRate   (5.0 * 1000 * 1000)

static AVCaptureSession *__weak MDTimelineRecordViewControllerCurrentCaptureSession = nil;

@interface MDMomentRecordHandler ()
<
    MDFaceTipShowDelegate,
    MDRCameraEngineDelegate
>

@property (atomic,    strong) MDFaceTipManager *faceTipManager;
@property (nonatomic, strong) MDRCameraEngine *cameraEngine;
@property (nonatomic, strong) MDRecordFilter *currentFilter;
@property (nonatomic, strong) NSArray<MDRMediaSegmentInfo *> *segmentInfos;

@property (nonatomic, assign) BOOL hasDetectorBareness;

@property (nonatomic, assign) MDRCaptureDeviceType captureDeviceType;
@property (nonatomic, assign) MDRCaptureFlagOption captureFlags;
@property (nonatomic, assign) MDRRecordingFlagOption recordingFlags;

@end

@implementation MDMomentRecordHandler

- (void)dealloc {
    //清理gpu和变脸资源缓存
    [self cleanCache];
}

- (instancetype)initWithContentView:(UIView *)containerView
                  maxRecordDuration:(NSTimeInterval)maxDuration
                     cameraPosition:(AVCaptureDevicePosition)position
                        openXengine:(BOOL)isOpen {
    self = [super init];
    if (self) {
        NSAssert(maxDuration != 0, @"max Duration is 0");
        
        // https://www.sunyazhou.com/2018/01/12/20180112AVAudioSession-Category/
        
        _captureDeviceType = position == AVCaptureDevicePositionBack ? MDRCaptureDeviceType_Back : MDRCaptureDeviceType_Front;
        
        // 相机设置
        _cameraEngine = [[MDRCameraEngine alloc] initWithDelegate:self];
        _cameraEngine.captureFrameRate = MDRecordRecordingSettingMananger.frameRate;
        _cameraEngine.recordMaxDuration = maxDuration;
        _cameraEngine.segmentMinDuration = kRecordSegmentMinDuration;
        [_cameraEngine configSlidingFilterMode:MDRGPUImageSlidingFilterModeVertical];
        
//        [_cameraEngine autoConfigAudioSessionDisable:YES];
        
        if (@available(iOS 10.0, *)) {
            [_cameraEngine setCanUseAIBeautySetting:[MTIContext defaultMetalDeviceSupportsMPS]];
        }

        _cameraEngine.canUseBodyThinSetting = YES;
        
        UIView<MLPixelBufferDisplay> *previewView = _cameraEngine.previewView;
        
        switch (MDRecordRecordingSettingMananger.ratio) {
            case RecordScreenRatioFullScreen:
                previewView.frame = containerView.bounds;
                break;
            case RecordScreenRatio9to16:
                previewView.frame = (CGRect) {
                    .origin = containerView.origin,
                    .size = CGSizeMake(containerView.width, containerView.width / 9 * 16)
                };
                break;
            case RecordScreenRatio3to4:
                previewView.frame = (CGRect) {
                    .origin = containerView.origin,
                    .size = CGSizeMake(containerView.width, containerView.width / 3 * 4)
                };
                break;
            case RecordScreenRatio1to1:
                previewView.frame = (CGRect) {
                    .origin = containerView.origin,
                    .size = CGSizeMake(containerView.width, containerView.width)
                };
                break;
            default:
                previewView.frame = containerView.bounds;
        }
        
        previewView.centerY = containerView.centerY;
        [containerView addSubview:previewView];
        
        // 启动3D引擎
        if (isOpen) {
            [_cameraEngine runXESEngineWithDecorationRootPath:[MDFaceDecorationFileHelper FaceDecorationBasePath]];
        }
        
#if defined(DEBUG) || defined(INHOUSE)
        [self debugStateChangeObserve];
        
        MDRDebugHandler *debugHandler = [MDRDebugHandler shareInstance];
        
        if ([debugHandler isOnWithDebugType:MDDebugCellTypeReverseVideo]) {
            _recordingFlags |= MDRRecordingFlagOption_ReverseVideo;
        }
        
        if ([debugHandler isOnWithDebugType:MDDebugCellTypeRecordDisableAllEffects]) {
            _recordingFlags |= MDRRecordingFlagOption_DisableAllEffects;
        }
        
        if ([debugHandler isOnWithDebugType:MDDebugCellTypeDisableAudio]) {
            _captureFlags |= MDRCaptureFlagOption_DisableAudio;
        }
        
        [self.cameraEngine setCanUseAIBeautySetting:[debugHandler isOnWithDebugType:MDDebugCellTypeUseAIBeauty]];
#endif
    }
    
    return self;
}

- (void)debugStateChangeObserve {
    __weak typeof(self) weakSelf = self;
    [MDRDebugHandler shareInstance].stateChangeBlock = ^(MDDebugCellType debugType, BOOL isOn) {
        switch (debugType) {
            case MDDebugCellTypeReverseVideo:
                [weakSelf enableReverseVideoSampleBuffer:isOn];
                break;
            case MDDebugCellTypeDisableAudio:
                [weakSelf enableRecordAudio:!isOn];
                break;
            case MDDebugCellTypeUseAIBeauty:
                [weakSelf.cameraEngine setCanUseAIBeautySetting:isOn];
                break;
            case MDDebugCellTypeRecordDisableAllEffects:
                [weakSelf disableAllEffectsWhenRecording:isOn];
                break;
                
            default:
                break;
        }
        
    };
}

- (instancetype)initWithContentView:(UIView *)containerView maxRecordDuration:(NSTimeInterval)maxDuration {
    return [self initWithContentView:containerView maxRecordDuration:maxDuration cameraPosition:AVCaptureDevicePositionUnspecified];
}

- (instancetype)initWithContentView:(UIView *)containerView maxRecordDuration:(NSTimeInterval)maxDuration cameraPosition:(AVCaptureDevicePosition)pisition {
    return [self initWithContentView:containerView maxRecordDuration:maxDuration cameraPosition:pisition openXengine:YES];
}

- (void)setRecordDuration:(NSTimeInterval)recordDuration {
    self.cameraEngine.recordMaxDuration = recordDuration;
}

- (void)setMinRecordDuration:(NSTimeInterval)minRecordDuration {
    self.cameraEngine.segmentMinDuration = minRecordDuration;
}

- (void)purgeGPUCache {
    [self cleanCache];
}

//获取最大录制时长
- (NSTimeInterval)recordDuration {
    return self.cameraEngine.recordMaxDuration;
}

- (NSArray *)segmentDurations {
    NSMutableArray *durations = nil;
    if (_segmentInfos.count) {
        durations = [NSMutableArray arrayWithCapacity:_segmentInfos.count];
        for (MDRMediaSegmentInfo *aSegment in _segmentInfos) {
            [durations addObject:@(aSegment.duration)];
        }
    }
    return durations;
}

- (NSArray *)segmentPresentDurations {
    NSMutableArray *durations = nil;
    if (_segmentInfos.count) {
        durations = [NSMutableArray arrayWithCapacity:_segmentInfos.count];
        for (MDRMediaSegmentInfo *aSegment in _segmentInfos) {
            [durations addObject:@(aSegment.presentDuration)];
        }
    }
    return durations;
}


#pragma mark - background music
- (void)setBackgroundAudio:(AVAsset *)backgroundAudio {
    self.cameraEngine.backgroundAudio = backgroundAudio;
}

- (AVAsset *)backgroundAudio {
    return self.cameraEngine.backgroundAudio;
}

- (BOOL)isReadyToPlayMusic {
    return self.cameraEngine.isReadyToPlayMusic;
}

- (BOOL)stopMerge {
    return self.cameraEngine.engineState == MDRCameraEngineState_Exporting;
}

- (BOOL)isFaceCaptured {
    return self.cameraEngine.isFaceCaptured;
}
// ---

#pragma mark - record relates
- (BOOL)isRecording {
    return self.cameraEngine.engineState == MDRCameraEngineState_Recording;
}

- (void)captureStillImage {
    if (self.captureStillImageWillHandler) {
        self.captureStillImageWillHandler();
    }
    __weak typeof(self) weakSelf = self;
    [self.cameraEngine takePhotoWithCompletionHandler:^(UIImage * _Nonnull image, NSDictionary * _Nonnull metaInfo, NSError * _Nonnull error) {
        if (weakSelf.captureStillImageHandler) {
            weakSelf.captureStillImageHandler(image, metaInfo);
        }
    }];
}

- (void)startRecording {
    NSMutableDictionary *encodeParams = [NSMutableDictionary dictionary];
    encodeParams[MDRVideoEncodeBitRateKey] = @(MDRecordRecordingSettingMananger.bitRate ?: kDefaultRecordBitRate);
    encodeParams[MDRVideoEncodeScaleModeKey] = @(MDRVideoEncodeScaleMode_ResizeAspectFill);
    
    //设置录制分辨率
//    MDRVideoResolution resolution = {720, 720};
//    NSValue *resolutionObj = [NSValue value:&resolution withObjCType:@encode(MDRVideoResolution)];
//    encodeParams[MDRVideoEncodeResolutionKey] = resolutionObj;
    
    [self.cameraEngine startRecordingWithFlag:_recordingFlags andEncodeParams:encodeParams];
}

- (void)stopVideoCaptureWithCompletionHandler:(void (^)(NSURL *videoFileURL, NSError *error))completionHandler {
    [self.cameraEngine exportVideoWithCompletionHandler:^(NSURL * _Nonnull videoFileURL, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(videoFileURL, error);
            }
        });
    }];

}

- (void)clearStashVideo {
    
}

- (void)pauseRecording {
    [self.cameraEngine pauseRecording];
}

- (void)cancelRecording {
    [self.cameraEngine cancelRecording];
}

- (void)resetRecorder {
    [self.cameraEngine resetRecorder];
}

- (void)deleteLastSavedSegment {
    [self.cameraEngine deleteLastSavedSegment];
}

- (NSTimeInterval)currentRecordingDuration {
    return self.cameraEngine.currentRecordingDuration;
}

- (NSTimeInterval)currentRecordingPresentDuration {
    return self.cameraEngine.currentRecordingPresentDuration;
}

- (NSInteger)savedSegmentCount {
    return self.cameraEngine.segmentInfos.count;
}

- (BOOL)canStartRecording {
    return [self.cameraEngine canStartRecording];
}

- (void)setOutputOrientation:(UIDeviceOrientation)outputOrientation {
    self.cameraEngine.outputOrientation = outputOrientation;
}

- (UIDeviceOrientation)outputOrientation {
    return self.cameraEngine.outputOrientation;
}

- (void)setFaceFeatureHandler:(void(^)(CVPixelBufferRef pixelbuffer, NSArray<MMFaceFeature *> * faceFeatures, NSArray<MMBodyFeature *> * bodyFeatures))faceFeatureHandler {
    self.cameraEngine.faceFeatureHandler = faceFeatureHandler;
}

- (void(^)(CVPixelBufferRef pixelbuffer, NSArray<MMFaceFeature *> * faceFeatures, NSArray<MMBodyFeature *> * bodyFeatures))faceFeatureHandler {
    return self.cameraEngine.faceFeatureHandler;
}

#pragma mark - process
- (void)configureFilterA:(MDRecordFilter *)filterA filterB:(MDRecordFilter *)filterB offset:(double)filterOffset {
    [self.cameraEngine configFilterA:filterA configFilterB:filterB offset:filterOffset];
    self.currentFilter = filterA;
}

- (FDKDecoration *)makeDecorationWithBeautySettingsDict:(NSDictionary *)beautySettingsDict {
    MDBeautySettings *beautySettings = [[MDBeautySettings alloc] initWithDictionary:beautySettingsDict];
    return [beautySettings makeDecoration];
}

- (void)updateDecorationWithBeautySettingsDict:(NSDictionary *)beautySettingsDict decoration:(FDKDecoration *)decoration {
    MDBeautySettings *beautySettings = [[MDBeautySettings alloc] initWithDictionary:beautySettingsDict];
    [beautySettings updateDecorationBeautySetting:decoration];
}

- (void)setBeautyThinFace:(CGFloat)value {
    [self.cameraEngine setBeautyThinFaceValue:value];
}

- (void)setBeautyBigEye:(CGFloat)value {
    [self.cameraEngine setBeautyBigEyeValue:value];
}

- (void)setBeautySkinWhite:(CGFloat)value {
    [self.cameraEngine setSkinWhitenValue:value];
}

- (void)setBeautySkinSmooth:(CGFloat)value {
    [self.cameraEngine setSkinSmoothValue:value];
}

- (void)setBeautyLongLeg:(CGFloat)value {
    [self.cameraEngine setBeautyLenghLegValue:value];
}

- (void)setBeautyThinBody:(CGFloat)value {
    [self.cameraEngine setBeautyThinBodyValue:value];
}

- (void)addDecoration:(FDKDecoration *)decoration {
    
    if (decoration) {
        [self.cameraEngine updateDecoration:decoration];
    
        [self configFaceTipManager:decoration.additionalInfo];
    }
}

- (void)addGift:(MDRGift *)gift {
    [self.cameraEngine addGift:gift];
}

- (void)removeGift:(NSString *)giftID {
    [self.cameraEngine removeGiftWithGiftID:giftID];
}

- (void)clearAllGifts {
    [self.cameraEngine clearAllGifts];
}

- (void)configFaceTipManager:(NSDictionary *)additionalInfo {
    [self.faceTipManager stop];
    self.faceTipManager = [MDFaceTipManager managerWithDictionary:additionalInfo
                                                         position:self.cameraPosition
                                                       showTarget:self];
    
    [self.faceTipManager start];
}

- (void)configFaceTipManagerForEmptyDecoration {
    [self.faceTipManager stop];
    MDFaceTipItem *faceTipItem = [[MDFaceTipItem alloc] init];
    faceTipItem.content = @"露个脸吧";
    faceTipItem.shouldFaceTrack = YES;
    self.faceTipManager = [[MDFaceTipManager alloc] initWithFaceTipItem:faceTipItem position:self.cameraPosition showTarget:self];
    [self.faceTipManager start];
}

- (void)showFaceTipText:(NSString *)text {
    if (self.newFrameTipHandler) {
        self.newFrameTipHandler(text);
    }
}

- (void)faceTipDidFinishAllTask {
    self.faceTipManager = nil;
}

- (void)muteDecorationAudio:(BOOL)mute {
    [self.cameraEngine adjustStikcerVolume:mute ? .0f : 1.0f];
}

- (void)removeAllDecoration {
    [self.cameraEngine removeDecoration];
    
    [self.faceTipManager stop];
}

- (void)cleanCache {
    [self.cameraEngine clean];
}

#pragma mark - camera control
- (void)startCapturing {
    [_cameraEngine startCaptureWithResolution:MDRecordRecordingSettingMananger.cameraPreset
                                   deviceType:self.captureDeviceType
                                         flag:self.captureFlags
                                  aspectRatio:MDRecordRecordingSettingMananger.videoRatioValue];
}

- (void)stopCapturing {
    [self.cameraEngine updateExposureTargetBias:0];
    [self.cameraEngine stopCapturing];
}

- (void)pauseCapturing {
    [self.cameraEngine pauseCapturing];
}

- (void)rotateCamera {
    self.captureDeviceType = self.captureDeviceType == MDRCaptureDeviceType_Back ? MDRCaptureDeviceType_Front : MDRCaptureDeviceType_Back;
    [self.cameraEngine switchCaptureDeviceType:self.captureDeviceType];
    
    [self.faceTipManager input:MDFaceTipSignalCameraRotate];
}

- (void)focusCameraInPoint:(CGPoint)pointInCamera {
    [self.cameraEngine focusCameraInPoint:pointInCamera];
}

- (BOOL)hasVideoInput {
    return [self.cameraEngine hasVideoInput];
}

- (BOOL)hasFlash {
    return self.cameraEngine.currentDeviceCapability.supportFlash;
}

- (NSArray *)supportFlashModes {
    return self.cameraEngine.currentDeviceCapability.supportFlashModes;
}

- (void)setFlashMode:(MDRecordCaptureFlashMode)mode {
    self.cameraEngine.flashMode = mode;
}

- (MDRecordCaptureFlashMode)flashMode {
    return self.cameraEngine.flashMode;
}

- (AVCaptureDevicePosition)cameraPosition {
    return self.cameraEngine.currentDeviceType == MDRCaptureDeviceType_Back ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
}

- (void)updateFaceTipWithAFaceFeature:(BOOL)isTracking {
    if (self.shouldContinue && _faceTipManager) {
        MDFaceTipSignal signal = isTracking ? MDFaceTipSignalFaceTrack:MDFaceTipSignalFaceNoTrack;
        
        if (self.currentSignal != signal) {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.faceTipManager input:signal];
            });
        }
    }
}

- (void)setVideoZoomFactor:(CGFloat)factor {
    [self.cameraEngine setVideoZoomFactor:factor];
}

- (CGFloat)videoZoomFactor {
    return self.cameraEngine.currentVideoZoomFactor;
}

- (void)runXESEngine {
    [self.cameraEngine runXESEngineWithDecorationRootPath:[MDFaceDecorationFileHelper FaceDecorationBasePath]];
}

#pragma mark - audio pitch
- (void)handleSoundPitchWithAssert:(AVAsset *)videoAsset
                    andPitchNumber:(NSInteger)pitchNumber
                 completionHandler:(void (^) (NSURL *))completionHandler {
    [self.cameraEngine handleSoundPitchWithAssert:videoAsset andPitchNumber:pitchNumber completionHandler:completionHandler];
}

//activateBarenessDetector
- (void)activateBarenessDetectorEnable:(BOOL)enable {
    [self.cameraEngine activateBarenessDetectorEnable:enable];
}

#pragma mark - avcaptureSession 切 arkit
- (void)switchToCameraSourceType:(MDRecordCameraSourceType)cameraSourceType {
    [self.cameraEngine switchToCameraSourceType:cameraSourceType];
}

- (MDRecordCameraSourceType)cameraSourceType {
    return self.cameraEngine.currentCameraSourceType;
}

- (void)enableReverseVideoSampleBuffer:(BOOL)enable {
    if (enable) {
        _recordingFlags |= MDRRecordingFlagOption_ReverseVideo;
    } else {
        _recordingFlags &= ~MDRRecordingFlagOption_ReverseVideo;
    }
}

- (void)disableAllEffectsWhenRecording:(BOOL)disable {
    if (disable) {
        _recordingFlags |= MDRRecordingFlagOption_DisableAllEffects;
    } else {
        _recordingFlags &= ~MDRRecordingFlagOption_ReverseVideo;
    }
}

#pragma mark - 变速

- (void)setNextRecordSegmentSpeedVaryFactor:(CGFloat)factor {
    self.cameraEngine.speedVaryFactor = factor;
}

- (CGFloat)nextRecordSegmentSpeedVaryFactor {
    return self.cameraEngine.speedVaryFactor;
}

- (void)speedVaryShouldAllow:(BOOL)isAllow {
    //已经废弃
}

- (BOOL)hasPerSpeedEffect {
    return self.cameraEngine.hasPerSpeedEffect;
}

- (void)removeAllMakeupEffect {
//    [self.adapter enableMakeup:NO];
//    [self.adapter removeAllMakeUpEffect];
}

- (void)addBlurEffect {
//    [self.adapter enableBackgroundBlur:YES];
//    [self.adapter setBackgroundBlurMode:CXBackgroundBlurModePixel];
//    [self.adapter setBackgroundBlurIntensity:1.0];
}

- (void)removeBlurEffect {
//    [self.adapter enableBackgroundBlur:NO];
}

- (void)muteSticker:(BOOL)mute {
    [self.cameraEngine adjustStikcerVolume:mute ? 0 : 1];
}

- (void)enableRecordAudio:(BOOL)enable {
    if (!enable) {
        _captureFlags |= MDRCaptureFlagOption_DisableAudio;
    } else {
        _captureFlags &= ~MDRCaptureFlagOption_DisableAudio;
    }
    
    [self startCapturing];
}

- (void)recordOrigin:(BOOL)enable {
    
}
- (void)setUseAISkinWhiten:(BOOL)useAISkinWhiten{
//    self.adapter.useAISkinWhiten = useAISkinWhiten;
}

- (BOOL)useAISkinWhiten{
//    return self.adapter.useAISkinWhiten;
    return NO;
}

- (void)setUseAISkinSmooth:(BOOL)useAISkinSmooth{
//    self.adapter.useAISkinSmooth = useAISkinSmooth;
    
}

- (BOOL)useAISkinSmooth{
//    return self.adapter.useAISkinSmooth;
    return NO;
}

- (void)setUseAIBigEyeThinFace:(BOOL)useAIBigEyeThinFace{
//    self.adapter.useAIBigEyeThinFace = useAIBigEyeThinFace;
}

- (BOOL)useAIBigEyeThinFace{
//    return self.adapter.useAIBigEyeThinFace;
    return NO;
}

- (void)updateExposureBias:(float)bias {
    
    CGFloat low = MDRecordRecordingSettingMananger.lowExposureBias;
    CGFloat upper = MDRecordRecordingSettingMananger.upperExposureBias;
    
    if (bias < 0.5) {
        bias = low + (bias / 0.5 * (- low));
    } else {
        bias = (bias - 0.5) / 0.5 * upper;
    }

    [self.cameraEngine updateExposureTargetBias:bias];
}

- (BOOL)restartCapturingWithCameraPreset:(AVCaptureSessionPreset)preset
{
    return YES;
}

#pragma mark - MDRCameraEngineDelegate
//recordProgressChangedHandler

- (void)cameraEngine:(MDRCameraEngine *)cameraEngine didChangeEngineState:(MDRCameraEngineState)state {
    NSLog(@"引擎当前状态： %zd",state);
}

- (void)cameraEngine:(MDRCameraEngine *)cameraEngine didChangeRecordProgress:(double)progress {
    if (_recordProgressChangedHandler) {
        _recordProgressChangedHandler(progress);
    }
}

- (void)cameraEngine:(MDRCameraEngine *)cameraEngine didChangeExportProgress:(double)progress {
    if (_completeProgressUpdateHandler) {
        _completeProgressUpdateHandler(progress);
    }
}

- (void)didReachRecordMaxDuration:(MDRCameraEngine *)cameraEngine {
    if (_recordDurationReachedHandler) {
        _recordDurationReachedHandler();
    }
}

- (void)cameraEngine:(MDRCameraEngine *)cameraEngine
didASegmentGenerateFailType:(MDRSegmentGenerateFailType)failType {
    if (failType == MDRSegmentGenerateFailType_RecodingDuration2Short) {
        if (self.recordSegmentsChangedHandler) {
            self.recordSegmentsChangedHandler([self segmentDurations], [self segmentPresentDurations], NO);
        }
    }
}

- (void)didVideoSegmentNumbnerChange:(MDRCameraEngine *)cameraEngine
                        segmentInfos:(NSArray<MDRMediaSegmentInfo *> *)segmentInfos {
    _segmentInfos = segmentInfos;
    if (self.recordSegmentsChangedHandler) {
        self.recordSegmentsChangedHandler([self segmentDurations], [self segmentPresentDurations], YES);
    }
}

- (void)cameraEngine:(MDRCameraEngine *)cameraEngine didOutputFaceFeatureInfo:(MDRFaceFeatureInfo *)faceFeatureInfo {
    [self updateFaceTipWithAFaceFeature:(faceFeatureInfo.faceFeatures.count > 0)];
    self.hasDetectorBareness = faceFeatureInfo.hasDetectorBareness;
}

- (void)cameraEngine:(MDRCameraEngine *)cameraEngine didOutputVideoSampleBuffer:(CVPixelBufferRef)sampleBuffer {
    
}

- (void)cameraEngine:(MDRCameraEngine *)cameraEngine didOutputAudioSampleBuffer:(CMSampleBufferRef)audioSampleBuffer {
    
}

- (void)cameraEngine:(MDRCameraEngine *)cameraEngine didOccurError:(NSError *)error {
    
}

- (void)cameraEngine:(MDRCameraEngine *)cameraEngine
       didOccurError:(MDRCameraErrorCode)errorCode
           errorInfo:(NSString *)errorInfo {
    NSLog(@"cameraEngine didOccurError code = %@, errorInfo = %@",@(errorCode),errorInfo);
}

- (void)cameraEngine:(MDRCameraEngine *)cameraEngine
     didOccurWarning:(MDRCameraWarningCode)warningCode
         warningInfo:(NSString *)warningInfo {
    NSLog(@"cameraEngine didOccurWarning code = %@, errorInfo = %@",@(warningCode),warningInfo);
}

@end
