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

//AI美颜
//#import "MLRoomDecorationDataSource.h"

#import "MDBeautySettings.h"
#import "MDRecordingAdapter+MDAudioPitch.h"
@import RecordSDK;
@import CXBeautyKit;

#define kDefaultRecordBitRate   (5.0 * 1024 * 1024)

static AVCaptureSession *__weak MDTimelineRecordViewControllerCurrentCaptureSession = nil;

@interface MDMomentRecordHandler ()
<
    MDFaceTipShowDelegate
>

@property (atomic,    strong) MDFaceTipManager      *faceTipManager;

//@property (nonatomic, strong) MDCameraEditorContext *context;
//@property (nonatomic, strong) MDCameraRenderPipline *renderPipline;
@property (nonatomic, strong) MDRecordingAdapter *adapter;

@property (nonatomic, strong) MDRecordFilter *currentFilter;

@end

@implementation MDMomentRecordHandler

- (MDRecordingAdapter *)adapter {
    if (!_adapter) {
        _adapter = [[MDRecordingAdapter alloc] initWithToken:@""];
    }
    return _adapter;
}

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
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                         withOptions:AVAudioSessionCategoryOptionDuckOthers | AVAudioSessionCategoryOptionDefaultToSpeaker
                                               error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        // 相机设置
        MDRecordingAdapter *adapter = self.adapter;
        [adapter setVideoBitRate:MDRecordRecordingSettingMananger.bitRate ?: kDefaultRecordBitRate];
        [adapter setCameraFrameRate:MDRecordRecordingSettingMananger.frameRate];
        [adapter setVideoFrameRate:MDRecordRecordingSettingMananger.frameRate];
        [adapter setCameraPreset:MDRecordRecordingSettingMananger.cameraPreset];
        [adapter setCameraPosition:AVCaptureDevicePositionFront];
        [adapter setVideoScaleMode:AVVideoScalingModeResizeAspectFill];
        [adapter setVideoResolution:MDRecordRecordingSettingMananger.exportResolution];
//        adapter.shouldRecordAudio = NO;
        [adapter setupRecorder];
        
//        adapter.saveOrigin = YES;
        
        if (@available(iOS 10.0, *)) {
//            [adapter setCanUseAIBeautySetting:[MTIContext defaultMetalDeviceSupportsMPS]];
            
        }

//        [adapter setMaxRecordDuration:maxDuration];
        self.recordDuration = maxDuration;
        [self setMinRecordDuration:kRecordSegmentMinDuration];

        __weak typeof(self) weakself = self;
        adapter.detectFace = ^(BOOL tracking) {
            // 变脸提示
            [weakself updateFaceTipWithAFaceFeature:tracking];
        };
        
        [adapter enableReverseVideoSampleBuffer:NO];
        
        UIView<MLPixelBufferDisplay> *previewView = adapter.previewView;
        
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
            [adapter runXESEngineWithDecorationRootPath:[MDFaceDecorationFileHelper FaceDecorationBasePath]];
        }
    }
    
    return self;
}

- (instancetype)initWithContentView:(UIView *)containerView maxRecordDuration:(NSTimeInterval)maxDuration {
    return [self initWithContentView:containerView maxRecordDuration:maxDuration cameraPosition:AVCaptureDevicePositionUnspecified];
}

- (instancetype)initWithContentView:(UIView *)containerView maxRecordDuration:(NSTimeInterval)maxDuration cameraPosition:(AVCaptureDevicePosition)pisition {
    return [self initWithContentView:containerView maxRecordDuration:maxDuration cameraPosition:pisition openXengine:YES];
}

- (void)setRecordDuration:(NSTimeInterval)recordDuration {
    [self.adapter setMaxRecordDuration:recordDuration];
}

- (void)setMinRecordDuration:(NSTimeInterval)minRecordDuration {
    [self.adapter setMinRecordDuration:minRecordDuration];
}

- (void)purgeGPUCache {
    [self cleanCache];
}

- (void)setRecordProgressChangedHandler:(void (^)(double))recordProgressChangedHandler {
    [self.adapter setRecordProgressChangedHandler:recordProgressChangedHandler];
}

- (void (^)(double))recordProgressChangedHandler {
    return [self.adapter recordProgressChangedHandler];
}

- (void)setRecordDurationReachedHandler:(void (^)(void))recordDurationReachedHandler {
    [self.adapter setRecordDurationReachedHandler:recordDurationReachedHandler];
}

- (void (^)(void))recordDurationReachedHandler {
    return [self.adapter recordDurationReachedHandler];
}

- (void)setCompleteProgressUpdateHandler:(void (^)(double))completeProgressUpdateHandler {
    [self.adapter setCompleteProgressUpdateHandler:completeProgressUpdateHandler];
}

- (void (^)(double))completeProgressUpdateHandler {
    return [self.adapter completeProgressUpdateHandler];
}

- (void)setRecordSegmentsChangedHandler:(void (^)(NSArray *, NSArray *, BOOL))recordSegmentsChangedHandler {
    [self.adapter setRecordSegmentsChangedHandler:recordSegmentsChangedHandler];
}

- (void (^)(NSArray *, NSArray *, BOOL))recordSegmentsChangedHandler {
    return [self.adapter recordSegmentsChangedHandler];
}

- (NSTimeInterval)recordDuration {
    return [self.adapter recordDuration];
}

- (BOOL)hasDetectorBareness {
    return  [self.adapter hasDetectorBareness];
}

#pragma mark - background music
- (void)setBackgroundAudio:(AVAsset *)backgroundAudio {
   self.adapter.backgroundAudio = backgroundAudio;
}

- (AVAsset *)backgroundAudio {
    return self.adapter.backgroundAudio;
}

// ---
- (id)periodicTimeObserver {
    return self.adapter.periodicTimeObserver;
}

- (BOOL)stopMerge {
    return self.adapter.stopMerge;
}

- (BOOL)isFaceCaptured {
    return self.adapter.isFaceCaptured;
}
// ---

#pragma mark - record relates
- (BOOL)isRecording {
    return self.adapter.isRecording;
}

- (void)captureStillImage {
    self.adapter.captureStillImageWillHandler = self.captureStillImageWillHandler;
    self.adapter.captureStillImageHandler = self.captureStillImageHandler;
    [self.adapter takePhoto];
}

- (void)startRecording {
    [self.adapter startRecording];
}

- (void)stopVideoCaptureWithCompletionHandler:(void (^)(NSURL *videoFileURL, NSError *error))completionHandler {
    NSString *originalVideoFilePath = [MDRecordContext videoTmpPath];
    NSURL *finalUrl = [NSURL fileURLWithPath:originalVideoFilePath];
    
    [self.adapter stopVideoCaptureWithOutputURL:finalUrl completionHandler:completionHandler];
}

- (void)clearStashVideo {
    [self.adapter cleanStashFile];
}

- (void)pauseRecording {
    [self.adapter pauseRecording];
}

- (void)cancelRecording {
    [self.adapter cancelRecording];
}

- (void)resetRecorder {
    [self.adapter resetRecorder];
}

- (void)deleteLastSavedSegment {
    [self.adapter deleteLastSavedSegment];
}

- (NSTimeInterval)currentRecordingDuration {
    return self.adapter .currentRecordingDuration;
}

- (NSTimeInterval)currentRecordingPresentDuration {
    return self.adapter .currentRecordingPresentDuration;
}

- (NSInteger)savedSegmentCount {
    return [self.adapter savedSegmentCount];
}

- (BOOL)canStartRecording {
    return [self.adapter canStartRecording];
}

- (void)setOutputOrientation:(UIDeviceOrientation)outputOrientation {
    self.adapter.outputOrientation = outputOrientation;
}

- (UIDeviceOrientation)outputOrientation {
    return self.adapter.outputOrientation;
}

- (void)setFaceFeatureHandler:(MDVideoDetectorBlock)faceFeatureHandler {
    self.adapter.faceFeatureHandler = faceFeatureHandler;
}

- (MDVideoDetectorBlock)faceFeatureHandler {
    return self.adapter.faceFeatureHandler;
}

#pragma mark - process
- (void)configureFilterA:(MDRecordFilter *)filterA filterB:(MDRecordFilter *)filterB offset:(double)filterOffset {
    [self.adapter configFilterA:filterA configFilterB:filterB offset:filterOffset];
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
    [self.adapter setBeautyThinFaceValue:value];
}

- (void)setBeautyBigEye:(CGFloat)value {
    [self.adapter setBeautyBigEyeValue:value];
}

- (void)setBeautySkinWhite:(CGFloat)value {
    [self.adapter setSkinWhitenValue:value];
}

- (void)setBeautySkinSmooth:(CGFloat)value {
    [self.adapter setSkinSmoothValue:value];
}

- (void)setBeautyLongLeg:(CGFloat)value {
    [self.adapter setBeautyLenghLegValue:value];
}

- (void)setBeautyThinBody:(CGFloat)value {
    [self.adapter setBeautyThinBodyValue:value];
}

- (void)addDecoration:(FDKDecoration *)decoration {
    
    if (decoration) {
        [self.adapter updateDecoration:decoration];
    
        [self configFaceTipManager:decoration.additionalInfo];
    }
}

- (void)addGift:(MDRGift *)gift {
    [self.adapter addGift:gift];
}

- (void)removeGift:(NSString *)giftID {
    [self.adapter removeGiftWithGiftID:giftID];
}

- (void)clearAllGifts {
    [self.adapter clearAllGifts];
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
    [self.adapter adjustStikcerVolume:mute ? .0f : 1.0f];
}

- (void)removeAllDecoration {
    [self.adapter removeDecoration];
    
    [self.faceTipManager stop];
}

- (void)cleanCache {
    [self.adapter clean];
}

#pragma mark - camera control
- (void)startCapturing {
    [self.adapter startCapturing];
}

- (void)stopCapturing {
    [self.adapter stopCapturing];
}

- (void)pauseCapturing {
    [self.adapter pauseCapturing];
}

- (void)rotateCamera {
    [self.adapter switchCameraPosition];
    
    [self.faceTipManager input:MDFaceTipSignalCameraRotate];
}

- (void)focusCameraInPoint:(CGPoint)pointInCamera {
    [self.adapter focusCameraInPoint:pointInCamera];
}

- (BOOL)hasVideoInput {
    return [self.adapter hasVideoInput];
}

- (BOOL)hasFlash {
    return [self.adapter hasFlash];
}

- (NSArray *)supportFlashModes {
    return [self.adapter supportFlashModes];
}

- (void)setFlashMode:(MDRecordCaptureFlashMode)mode {
    self.adapter.flashMode = mode;
}

- (MDRecordCaptureFlashMode)flashMode {
    return self.adapter.flashMode;
}

- (AVCaptureDevicePosition)cameraPosition {
    return self.adapter.cameraPosition;
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
    [self.adapter setVideoZoomFactor:factor];
}

- (CGFloat)videoZoomFactor {
    return self.adapter.videoZoomFactor;
}

- (void)runXESEngine {
    [self.adapter runXESEngineWithDecorationRootPath:[MDFaceDecorationFileHelper FaceDecorationBasePath]];
}

#pragma mark - audio pitch
- (void)handleSoundPitchWithAssert:(AVAsset *)videoAsset
                    andPitchNumber:(NSInteger)pitchNumber
                 completionHandler:(void (^) (NSURL *))completionHandler {
    [self.adapter handleSoundPitchWithAssert:videoAsset andPitchNumber:pitchNumber completionHandler:completionHandler];
}

//activateBarenessDetector
- (void)activateBarenessDetectorEnable:(BOOL)enable {
    [self.adapter activateBarenessDetectorEnable:enable];
}

#pragma mark - avcaptureSession 切 arkit
- (void)switchToCameraSourceType:(MDRecordCameraSourceType)cameraSourceType {
    [self.adapter switchToCameraSourceType:cameraSourceType];
}

- (MDRecordCameraSourceType)cameraSourceType {
    return self.adapter.cameraSourceType;
}

- (void)enableReverseVideoSampleBuffer:(BOOL)enable {
    [self.adapter enableReverseVideoSampleBuffer:enable];
}

#pragma mark - 变速

- (void)setNextRecordSegmentSpeedVaryFactor:(CGFloat)factor {
    [self.adapter setNextRecordSegmentSpeedVaryFactor:factor];
}

- (CGFloat)nextRecordSegmentSpeedVaryFactor {
    return [self.adapter nextRecordSegmentSpeedVaryFactor];
}

- (void)speedVaryShouldAllow:(BOOL)isAllow {
    [self.adapter speedVaryShouldAllow:isAllow];
}

- (BOOL)hasPerSpeedEffect {
    return [self.adapter hasPerSpeedEffect];
}

- (void)addMakeupEffectWithItem:(MDMomentMakeupItem *)item {
    [self.adapter removeAllMakeUpEffect];
    [self.adapter enableMakeup:YES];
    for (NSURL *url in item.items) {
        NSString *identifier = [self.adapter addMakeUpEffectWithResourceURL:url];
        [self.adapter setIntensity:0.5 forIdentifiler:identifier];
    }
}

- (void)removeAllMakeupEffect {
    [self.adapter enableMakeup:NO];
    [self.adapter removeAllMakeUpEffect];
}

- (void)addBlurEffect {
    [self.adapter enableBackgroundBlur:YES];
    [self.adapter setBackgroundBlurMode:CXBackgroundBlurModePixel];
    [self.adapter setBackgroundBlurIntensity:1.0];
}

- (void)removeBlurEffect {
    [self.adapter enableBackgroundBlur:NO];
}

- (void)muteSticker:(BOOL)mute {
    [self.adapter adjustStikcerVolume:mute ? 0 : 1];
}

- (void)enableRecordAudio:(BOOL)enable {
    [self.adapter enableAudioRecording:enable];
}

- (void)recordOrigin:(BOOL)enable {
    self.adapter.saveOrigin = enable;
}
- (void)setUseAISkinWhiten:(BOOL)useAISkinWhiten{
    self.adapter.useAISkinWhiten = useAISkinWhiten;
}

- (BOOL)useAISkinWhiten{
    return self.adapter.useAISkinWhiten;
}

- (void)setUseAISkinSmooth:(BOOL)useAISkinSmooth{
    self.adapter.useAISkinSmooth = useAISkinSmooth;
    
}

- (BOOL)useAISkinSmooth{
    return self.adapter.useAISkinSmooth;
}

- (void)setUseAIBigEyeThinFace:(BOOL)useAIBigEyeThinFace{
    self.adapter.useAIBigEyeThinFace = useAIBigEyeThinFace;
}

- (BOOL)useAIBigEyeThinFace{
    return self.adapter.useAIBigEyeThinFace;
}
@end
