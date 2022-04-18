//
//  MDUnifiedRecordModuleAggregate.m
//  MDChat
//
//  Created by 符吉胜 on 2017/7/19.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordModuleAggregate.h"
#import "MDMomentRecordHandler.h"
#import "MDUnifiedRecordViewController.h"
#import "MDRecordVideoResult.h"
#import "ReactiveCocoa/ReactiveCocoa.h"

#import "MDRecordFilterModelLoader.h"

//变脸模块
#import "MDFaceDecorationDataHandle.h"
#import "MDFaceDecorationItem.h"
//配乐模块
#import "MDNavigationTransitionExtra.h"
#import "MDMusicFavouriteManager.h"

//滤镜抽屉模块
#import "MDRecordFilterDrawerController.h"
#import "MDRecordFilterModel.h"
//拍照模块
#import "MDPhotoLibraryProvider.h"
#import "MDBeautySettings.h"

//权限
#import "MDUnifiedRecordViewController+Permission.h"
#import "Toast/Toast.h"
@import RecordSDK;

#import "MDBackgroundMusicDownloader.h"
#import "MDDecorationPannelView.h"

#import "MDMusicEditPalletController.h"
#import "MDMusicResourceUtility.h"

@interface MDUnifiedRecordModuleAggregate()
<
    MDRecordFilterDrawerControllerDelegate,
    BBMediaEditorSlidingOverlayViewDelegate,
    MDFaceDecorationDataHandleDelegate,
    MDMusicEditPalletControllerDelegate
>

@property (nonatomic,  weak) MDUnifiedRecordViewController<MDRecordModuleControllerDelegate>   *recordViewController;
@property (nonatomic,strong) MDMomentRecordHandler                      *recordHandler;
//video basic info
@property (nonatomic, strong) MDRecordVideoResult                       *videoResult;
@property (nonatomic, assign) MDRecordCaptureFlashMode                        currentFlashMode;
@property (nonatomic, assign) NSTimeInterval                            minDuration;
//变脸模块 (不应该记录太多信息，待重构！！！)
@property (nonatomic, strong) MDFaceDecorationDataHandle                *decorationDataHandler;
@property (nonatomic, strong) FDKDecoration                             *beautySettingDecoration;
@property (nonatomic, strong) FDKDecoration                             *selectedDecoration;
@property (nonatomic, strong) MDFaceDecorationItem                      *selectedDecorationItem;
@property (nonatomic, assign) BOOL                                      isArDecoration;
@property (nonatomic, strong) FDKBeautySettings                         *originBeautySettings;
//配乐模块
@property (nonatomic, assign) BOOL                                      hasUsePreMusic; //是否已经使用自动配乐
@property (nonatomic, strong) AVAsset                                   *musicAsset;
@property (nonatomic, strong) NSURL                                     *musicUrl;
@property (nonatomic, assign) CMTimeRange                               musicTimeRange;
@property (nonatomic, strong) MDMusicCollectionItem                     *currentSelectMusicItem;
@property (nonatomic, strong) MDMusicCollectionItem                     *sameStyleMusicItem;
//滤镜抽屉模块
@property (nonatomic, strong) NSArray<MDRecordFilterModel *>            *filterModels;
@property (nonatomic, strong) MDRecordFilterDrawerController            *filterDrawerController;
@property (nonatomic, strong) NSMutableDictionary                       *beautySettingDict;
@property (nonatomic, strong) NSMutableDictionary                       *realBeautySettingDict;
@property (nonatomic, assign) NSInteger                                 filterIndex;
//延时动画模块
@property (nonatomic, strong) MDUnifiedRecordCountDownAnimation         *countDownAnimation;
@property (nonatomic, assign) MDVideoRecordCountDownType                countDownType;
//图片打点模型
@property (nonatomic, strong) MDImageUploadParamModel                   *imageUploadModel;

@property (nonatomic, strong) MDMusicEditPalletController           *musicSelectPicker;
@property (nonatomic, strong) AVPlayer *musicPlayer;

@property (nonatomic, strong) MDRecordFilter *currentRecordFilter;

@property (nonatomic, strong) MDDecorationPannelView *decorationView;

@property (nonatomic, copy) NSString *makeupType;
@property (nonatomic, copy) NSString *microSurgeryType;

@end

@implementation MDUnifiedRecordModuleAggregate

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithRecordViewController:(MDUnifiedRecordViewController<MDRecordModuleControllerDelegate> *)recordViewController
{
    if (self = [self init]) {
        _recordViewController = recordViewController;
        
        BOOL supportRotateCamera = YES;
        if ([recordViewController respondsToSelector:@selector(supportRotateCamera)]) {
            supportRotateCamera = [recordViewController supportRotateCamera];
        }
        
        _decorationDataHandler = [[MDFaceDecorationDataHandle alloc] initWithFilterARDecoration:!supportRotateCamera];
        _decorationDataHandler.delegate = self;
        
        _beautySettingDict = [@{@"MDBeautySettingsEyesEnhancementAmountKey":@3, @"MDBeautySettingsFaceThinningAmountKey":@4, @"MDBeautySettingsLongLegAmountKey":@-1, @"MDBeautySettingsSkinSmoothingAmountKey":@3, @"MDBeautySettingsSkinWhitenAmountKey":@3, @"MDBeautySettingsThinBodyAmountKey":@-1} mutableCopy];
        
        [self addNotificationObserver];
    }
    return self;
}

- (void)setupCameraSourceHandlerWithMaxDuration:(NSTimeInterval)maxDuration minDuration:(NSTimeInterval)minDuration contentView:(UIView *)contentView devicePosition:(AVCaptureDevicePosition)position {
    
    _minDuration = minDuration;
    if (!_recordHandler) {
        _recordHandler = [[MDMomentRecordHandler alloc] initWithContentView:contentView maxRecordDuration:maxDuration cameraPosition:position openXengine:YES];

    }
    
    //激活光膀子检测
    if ([self.recordViewController respondsToSelector:@selector(supportBarenessDetectorFunction)]) {
        if ([self.recordViewController supportBarenessDetectorFunction]) {
            [_recordHandler activateBarenessDetectorEnable:YES];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    
    //空变脸露脸提示
    if ([self shouldShowFaceTipForEmptyDecoration]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.recordHandler configFaceTipManagerForEmptyDecoration];
        });
    }
    
    [self.recordHandler setRecordProgressChangedHandler:^(double progress) {
        [weakSelf.delegate didRecordProgressChange:progress];
    }];
    
    [self.recordHandler setCompleteProgressUpdateHandler:^(double progress) {
        [weakSelf.delegate didRecordFinishWithProgress:progress];
    }];
    
    [self.recordHandler setRecordSegmentsChangedHandler:^(NSArray *durations, NSArray *presentDurations, BOOL valid) {
        [weakSelf.delegate didRecordSegmentChangedWithDurations:durations presentDurations:presentDurations valid:valid];
        [weakSelf.recordViewController enableRecordOriginButton:durations.count == 0];
    }];
    
    [self.recordHandler setRecordDurationReachedHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.delegate didRecordReachMaxDuration];
        });
    }];
    
    [self.recordHandler setNewFrameTipHandler:^(NSString *tip) {
        NSDictionary *defaultFaceDic = @{}; //[[MDContext appConfig] momentDefaultFaceInfo];
        NSString *faceId = [defaultFaceDic stringForKey:@"id" defaultValue:nil];
        if ([faceId isNotEmpty] && [faceId isEqualToString:weakSelf.videoResult.faceID]) {
            //服务器默认配置美颜变脸,不需要提示信息
        } else {
            [weakSelf.delegate didGetFaceDecorationTip:tip];
        }
    }];
    
    [self.recordHandler setCaptureStillImageHandler:^(UIImage *stillImage, NSDictionary *metaInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf stopCaptureWithImage:stillImage];
        });
    }];
    
#ifdef ENABLE_GAMEPET
    [self.recordHandler setfaceFeatureHandler:_faceFeatureHandler];
#endif
    
    self.recordViewController.containerView.slidingFilterView.delegate = self;
}

- (void)setupCameraSourceHandlerWithMaxDuration:(NSTimeInterval)maxDuration
                                    minDuration:(NSTimeInterval)minDuration
                                    contentView:(UIView *)contentView
{
    [self setupCameraSourceHandlerWithMaxDuration:maxDuration minDuration:minDuration contentView:contentView devicePosition:AVCaptureDevicePositionUnspecified];
}

//-(void)runXESEngineWithPosition:(AVCaptureDevicePosition)position {
//    [self.recordHandler runXESEngineWithPosition:position];
//}

#ifdef ENABLE_GAMEPET
- (void)setFaceFeatureHandler:(MDVideoDetectorBlock)faceFeatureHandler {

    _faceFeatureHandler = faceFeatureHandler;
    [self.recordHandler setfaceFeatureHandler:faceFeatureHandler];
}
#endif

- (BOOL)shouldShowFaceTipForEmptyDecoration
{
    if ([self.recordViewController respondsToSelector:@selector(shouldShowFaceTipForEmptyDecoration)]) {
        return [self.recordViewController shouldShowFaceTipForEmptyDecoration];
    }
    return NO;
}

#pragma mark - 通知注册 & 处理
- (void)addNotificationObserver
{
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [notifyCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [notifyCenter addObserver:self selector:@selector(captureSessionDidStartRunning:) name:AVCaptureSessionDidStartRunningNotification object:nil];
    [notifyCenter addObserver:self selector:@selector(captureSessionDidStopRunning:) name:AVCaptureSessionDidStopRunningNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (![self isViewVisible]) {
        return;
    }
    
    if ([self isRecording]) {
        [self pauseRecording];
    }
    [self stopCapturing];
    if (_countDownAnimation) {
        [self.countDownAnimation cancelAnimation];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (![self isViewVisible]) {
        return;
    }
    
    [self startCapturing];
    [self.recordHandler setFlashMode:_currentFlashMode];
}

- (void)captureSessionDidStartRunning:(NSNotification *)notification {
    BOOL hasVideoInput = [self.recordHandler hasVideoInput];
    
    void (^action)(void) = ^{
        [self.delegate captureSessionDidStartOrStop:hasVideoInput];
    };
    
    if ([NSThread isMainThread]) {
        action();
    } else {
        dispatch_async(dispatch_get_main_queue(), action);
    }
}

- (void)captureSessionDidStopRunning:(NSNotification *)notification {
    [self.delegate captureSessionDidStartOrStop:NO];
}

- (BOOL)isViewVisible
{
    if (_recordViewController) {
        return _recordViewController.isViewLoaded && _recordViewController.view.window;
    }
    return NO;
}

#pragma mark - 录制相关
- (void)startCapturing
{
    [self.recordHandler startCapturing];
    if (self.selectedDecoration) {
        [self updateBeautySetting];
    }
}

- (BOOL)restartCapturingWithCameraPreset:(AVCaptureSessionPreset)preset
{
    return [self.recordHandler restartCapturingWithCameraPreset:preset];
}

- (void)pauseCapturing
{
    [self.recordHandler pauseCapturing];
}

- (void)stopCapturing
{
    if (self.selectedDecoration) {
        [self.recordHandler removeAllDecoration];
    }
    [self.recordHandler stopCapturing];
}

- (void)startRecording
{
    if (![self checkDevicePermission]) return;
    
    BOOL canStart = [self canStartRecording];
    if (canStart) {
        [self.recordViewController enableRecordOriginButton:NO];
        [self.delegate didStartRecording];
        [self.recordHandler startRecording];
    }
}

- (void)pauseRecording
{
    [self.delegate didPauseRecording];
    [self.recordHandler pauseRecording];
}

- (void)cancelRecording
{
    [self.delegate didCancelRecording];
    [self.recordHandler cancelRecording];
}

- (void)stopRecording
{
    self.videoResult.hasVideoSegments = self.recordHandler.savedSegmentCount > 1;
    self.videoResult.faceID = self.selectedDecorationItem.identifier;
    
    [self.delegate willStopRecording];
    
    __weak __typeof(self) weakSelf = self;
    [self.recordHandler stopVideoCaptureWithCompletionHandler:^(NSURL *videoFileURL, NSError *error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (videoFileURL && !error) {
            
            [strongSelf configVideoResult];
            
            //变声处理
            __block NSURL *soundPitchURL = nil;
            AVAsset *videoAsset = [AVURLAsset assetWithURL:videoFileURL];
            NSInteger pitchNumber = [strongSelf chooseRealPitchNumber];
            [strongSelf.recordHandler handleSoundPitchWithAssert:videoAsset andPitchNumber:pitchNumber completionHandler:^(NSURL *destinationURL) {
                soundPitchURL = destinationURL;
                [strongSelf.delegate didStopRecordingWithError:error
                                                  videoFileURL:videoFileURL
                                                     musicItem:strongSelf.currentSelectMusicItem
                                                musicTimeRange:strongSelf.musicTimeRange
                                                   videoResult:strongSelf.videoResult
                                                 soundPitchURL:soundPitchURL
                                               soundEnergyRank:strongSelf.recordHandler.soundEnergyRank];
            }];
            
        } else {
            [strongSelf.delegate didStopRecordingWithError:error
                                              videoFileURL:nil
                                                 musicItem:nil
                                            musicTimeRange:kCMTimeRangeZero
                                               videoResult:nil
                                             soundPitchURL:nil
                                           soundEnergyRank:0];
        }
        
    }];
}

- (void)setOutputOrientation:(UIDeviceOrientation)orientation
{
    self.videoResult.recordOrientation = orientation == UIDeviceOrientationLandscapeLeft || orientation   == UIDeviceOrientationLandscapeRight;
    self.recordHandler.outputOrientation = orientation;
}

- (BOOL)switchRecordingStatus
{
    if (self.recordHandler.isRecording || self.recordHandler.isReadyToPlayMusic) {
        [self pauseRecording];
        return NO;
    } else if (self.countDownType != MDVideoRecordCountDownType_None){
        [self startCountDownAnimation];
        return YES;
    } else {
        [self startRecording];
        return YES;
    }
}

- (BOOL)canStartRecording
{
    BOOL supportMusicFunction = NO;
    if ([self.recordViewController respondsToSelector:@selector(supportMusicFunction)]) {
        supportMusicFunction = [self.recordViewController supportMusicFunction];
    }
    if (supportMusicFunction && self.currentSelectMusicItem) {
        if (![self.currentSelectMusicItem resourceExist]) {
            [self.recordViewController.view makeToast:@"请等待音乐加载完成" duration:1.5f position:CSToastPositionCenter];
            return NO;
        }
    }
    return self.recordHandler.canStartRecording;
}

- (BOOL)checkDevicePermission
{
    return [MDUnifiedRecordViewController checkDevicePermission];
}

- (void)deleteLastSavedSegment
{
    [self.recordHandler deleteLastSavedSegment];
}

- (void)rotateCamera
{
    [self.recordHandler rotateCamera];
    [self setFlashLightWithFlashMode:_currentFlashMode];
    
    [self.delegate didRotateCamera];
}

- (void)focusCameraInPoint:(CGPoint)point
{
    [self.recordHandler focusCameraInPoint:point];
}

- (void)resetRecorder
{
    [self.recordHandler resetRecorder];
}

- (void)updateRecordMaxDuration:(NSTimeInterval)maxDuration
{
    self.recordHandler.recordDuration = maxDuration;
}

#pragma mark - 拍照相关
- (void)captureStillImage
{
    if (![self checkDevicePermission]) return;
    
    [self.recordHandler captureStillImage];
}

- (void)stopCaptureWithImage:(UIImage *)image
{
    [self.recordHandler stopCapturing];
    
    if (image == nil) {
        return;
    }
    
    UIImage *newImage = image;
    BOOL needRedraw = NO;
    CGFloat roate = 0;
    CGFloat translateX = 0;
    CGFloat translateY = 0;
    
    CGRect rect = CGRectMake(0, 0, image.size.height, image.size.width);
    
    if (self.recordHandler.outputOrientation == UIDeviceOrientationLandscapeLeft) {
        
        needRedraw = YES;
        roate = M_PI_2;
        translateX = 0;
        translateY = -rect.size.width;
        
    } else if (self.recordHandler.outputOrientation == UIDeviceOrientationLandscapeRight) {
        needRedraw = YES;
        roate = -M_PI_2;
        translateX = -rect.size.height;
        translateY = 0;
    }
    
    if (needRedraw) {
        
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        //做CTM变换
        CGContextTranslateCTM(context, 0.0, rect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextRotateCTM(context, roate);
        CGContextTranslateCTM(context, translateX,  translateY);
        CGContextScaleCTM(context, rect.size.height/rect.size.width, rect.size.width/rect.size.height);
        
        CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    [self configImageUploadModel];
    [self.delegate didStopCaptureStillImage:newImage imageUploadModel:self.imageUploadModel];
}

- (void)configImageUploadModel
{
    self.imageUploadModel.paramsOfPicturing.isFrontCamera = self.recordHandler.cameraPosition == AVCaptureDevicePositionFront ? 1 : 0 ;
    
    self.imageUploadModel.paramsOfPicturing.recordOrientation = self.videoResult.recordOrientation;
    
    MDRecordFilterModel *filterModel = [self.filterModels objectAtIndex:self.recordViewController.containerView.slidingFilterView.currentFilterIndex defaultValue:nil];
    self.imageUploadModel.paramsOfPicturing.filterID = filterModel.identifier;
    
    self.imageUploadModel.paramsOfPicturing.beautyFaceLevel = [self.beautySettingDict integerForKey:MDBeautySettingsSkinSmoothingAmountKey defaultValue:0];
    self.imageUploadModel.paramsOfPicturing.bigEyeLevel = [self.beautySettingDict integerForKey:MDBeautySettingsEyesEnhancementAmountKey defaultValue:0];
    
    self.imageUploadModel.paramsOfPicturing.thinBodyLevel = [self.beautySettingDict integerForKey:MDBeautySettingsThinBodyAmountKey defaultValue:0];

    self.imageUploadModel.paramsOfPicturing.longLegLevel = [self.beautySettingDict integerForKey:MDBeautySettingsLongLegAmountKey defaultValue:0];

    
    self.imageUploadModel.paramsOfPicturing.flashLightState = self.currentFlashMode;
    
    self.imageUploadModel.paramsOfPicturing.faceID = self.selectedDecorationItem.identifier;
}

#pragma mark - 变声处理相关
- (NSInteger)soundPitchNumber
{
    NSInteger pitchNumber = 0;
    
    for (FDKDecorationItem *item in self.selectedDecoration.items) {
        if (item.additionalInfo) {
            pitchNumber  = [item.additionalInfo integerForKey:@"soundPitchShift" defaultValue:0];
            if (pitchNumber != 0) {
                break;
            }
        }
    }
    
    return pitchNumber;
}

- (NSInteger)chooseRealPitchNumber
{
    __block NSInteger pitchNumber = 0;
    
    [self.pitchNumbers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *tempPitchNumber = obj;
        if ([tempPitchNumber isKindOfClass:[NSNumber class]] && [tempPitchNumber integerValue] != 0) {
            pitchNumber = [tempPitchNumber integerValue];
            *stop = YES;
        }
    }];
    
    return pitchNumber;
}

#pragma mark - 美妆

- (void)activateMakeUpViewController {
    [self setupFilterDrawer];
    
    if (self.filterDrawerController.isAnimating) {
        return;
    }
    
    if (self.filterDrawerController.isShowed) {
        [self updateUiForBeforeSubViewIsShow:NO completeBlock:nil];
        return;
    }
    [self.filterDrawerController setDefaultSelectIndex:6];

    __weak typeof(self) weakSelf = self;
    [self updateUiForBeforeSubViewIsShow:YES completeBlock:^{
        [weakSelf.filterDrawerController showAnimation];
    }];
}

// delegates

#pragma mark - 变脸模块

- (void)activateAutoFaceDecorationWithFaceID:(NSString *)faceID classID:(NSString *)classID
{
    if (![faceID isNotEmpty] && [classID isNotEmpty]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self activateFaceDecoration];
//            [self.faceDecorationVC setSelectedClassWithIdentifier:classID];
            [self.decorationView setSelectedClassWithIdentifier:classID];
        });
        
    }else if ([faceID isNotEmpty] && [classID isNotEmpty]) {
        [self.decorationDataHandler setOperationItemWithFaceId:faceID classId:classID];
        //定位到2号位
//        [self.decorationDataHandler setRecommendScrollToIndex:1];
        MDFaceDecorationItem* item = [self.decorationDataHandler.recommendDataArray objectAtIndex:1 defaultValue:nil];
        [self.decorationDataHandler drawerDidSelectedItem:item];
        self.decorationDataHandler.currentSelectItem = item;
        
    }
    else {
        //定位到1号位
    }
}

- (void)setDefaultBeautySetting
{
    if (self.selectedDecoration) {
        return;
    }
    
    [self setBeautySetting];
}

- (void)activateFaceDecoration
{
    [self setupFaceDecorationVC];
    
    if (self.decorationView.isAnimating) {
        return;
    }
    
    if (self.decorationView.isShowed) {
        [self updateUiForBeforeSubViewIsShow:NO completeBlock:nil];
        return;
    }
    [self.decorationView setRecordLevelType:MDUnifiedRecordLevelTypeHigh];
    
    __weak typeof(self) weakSelf = self;
    [self updateUiForBeforeSubViewIsShow:YES completeBlock:^{
        [weakSelf.decorationView showAnimate];
    }];
}

- (void)setupFaceDecorationVC
{
    if (!_decorationView) {
        __weak typeof(self) weakSelf = self;
        MDDecorationPannelView *pannelView = [[MDDecorationPannelView alloc] initWithFrame:CGRectMake(0, MDScreenHeight-383, MDScreenWidth, 383)];
        [self.recordViewController.view addSubview:pannelView];
        pannelView.dataHandle = _decorationDataHandler;
        [pannelView setSelectedClassWithIndex:1];
        pannelView.vc = self.recordViewController;
        pannelView.recordHandler = ^{
            __strong typeof(self) strongself = weakSelf;
            [strongself hideModuleView];
            if ([strongself.recordViewController respondsToSelector:@selector(faceDecorationViewRecordButtonTapped)]) {
                [strongself.recordViewController faceDecorationViewRecordButtonTapped];
            }

        };
        _decorationView = pannelView;
    }
}

- (void)resetFaceDecoration
{
    [self.delegate didResetFaceDecoration];
    self.videoResult.faceID = nil;
    self.imageUploadModel.paramsOfPicturing.faceID = nil;
    self.selectedDecoration = nil;
    self.selectedDecorationItem = nil;
    self.originBeautySettings = nil;
}

- (void)handleFaceDecorationDidSelectedGift:(MDFaceDecorationItem *)gift
{
   
}

- (void)handleFaceDecorationDidSelectedItem:(MDFaceDecorationItem *)item
{
    // 变脸切换拦截
    if ([item.identifier isNotEmpty] && [self.videoResult.faceID isEqualToString:item.identifier]) {
        return;
    }
    
    [self resetFaceDecoration];
    BOOL hasFaceEffect = NO;
    self.isArDecoration = NO;
    
    if (item) {
        NSString *urlStr = item.resourcePath;
        
        if ([urlStr isNotEmpty]) {
            NSURL *resourceUrl = [NSURL fileURLWithPath:urlStr];
			if ([[NSFileManager defaultManager] fileExistsAtPath:resourceUrl.path]) {
				FDKDecoration *decoration = [FDKDecoration decorationWithContentsOfURL:resourceUrl];
				
				if (decoration) {
					hasFaceEffect = YES;
					self.selectedDecoration = decoration;
					self.selectedDecorationItem = item;
					self.isArDecoration = item.isNeedAR;
				} else {
					//下载的资源异常，重新下载
					[self.recordViewController.view makeToast:@"资源文件异常" duration:1.5f position:CSToastPositionCenter];
				}
			} else {
				[self.recordViewController.view makeToast:@"资源文件异常" duration:1.5f position:CSToastPositionCenter];
			}
            
        }
    }
    
    if (!hasFaceEffect) {
        [self.recordHandler removeAllDecoration];
    }
    
    [self setBeautySetting];
}

- (BOOL)isLoadingOfCurrentSelectedFace
{
    return self.decorationDataHandler.currentSelectItem.isDownloading;
}

- (void)selectEmptyFaceItem
{
    [self.decorationDataHandler setRecommendScrollToIndex:0];
}

- (void)tapArDecorationWithGesture:(UITapGestureRecognizer *)tapGesture
{
    [self hideModuleView];
    CGPoint pointInPreview = [tapGesture locationInView:tapGesture.view];
    [self focusCameraInPoint:pointInPreview];
    
    if ([self.delegate respondsToSelector:@selector(didFocusCameraInPoint:)]) {
        [self.delegate didFocusCameraInPoint:pointInPreview];
    }
}

- (void)pinchVideoZoomFactorWithGesture:(UIPinchGestureRecognizer *)pinchGesture {
    CGFloat scale = pinchGesture.scale - 1.0;
    pinchGesture.scale = 1.0;
    scale *= 1.5;
    
    CGFloat factor = self.recordHandler.videoZoomFactor;
    factor += scale;
    factor = MIN(factor, 6); //最大只能放大6倍
    [self.recordHandler setVideoZoomFactor:factor];
}

#pragma mark - 外传decoration
- (FDKDecoration*)updateDecorationFromDict:(NSDictionary*)infoDict {
    
    [self.recordHandler cleanCache];
    [self resetFaceDecoration];
    
    NSString *urlStr = [infoDict objectForKey:@"resource" defaultValue:nil];
    NSString *identifier = [infoDict objectForKey:@"id" defaultValue:nil];
    
    FDKDecoration *decoration = nil;
    if ([urlStr isNotEmpty]) {
        NSURL *resourceUrl = [NSURL fileURLWithPath:urlStr];
        FDKDecoration *decoration = [FDKDecoration decorationWithContentsOfURL:resourceUrl];
        
        if (decoration) {
            
            //变脸id打点
            self.videoResult.faceID = identifier;
            self.imageUploadModel.paramsOfPicturing.faceID = identifier;
            self.selectedDecoration = decoration;
        }
    }
    [self setBeautySetting];
    
    
    return decoration;
}

- (void)purgeGPUCache
{
    [self.recordHandler purgeGPUCache];
}

- (void)muteFaceDecorationAudio:(BOOL)mute
{
    [self.recordHandler muteDecorationAudio:mute];
}

#pragma mark - MDFaceDecorationDataHandleDelegate
- (void)recommendFaceDecorationDidLoadingItem:(MDFaceDecorationItem *)item
{
    [self handleFaceDecorationDidSelectedItem:nil];
    [self.delegate startLoadingFaceDecoration];
}

- (void)recommendFaceDecorationDidSelectedItem:(MDFaceDecorationItem *)item
{
    [self.delegate endLoadingFaceDecoration];
    [self handleFaceDecorationDidSelectedItem:item];
    
    if (!item && [self shouldShowFaceTipForEmptyDecoration]) {
        [_recordHandler configFaceTipManagerForEmptyDecoration];
    }
}

- (void)drawerFaceDecorationDidSelectedItem:(MDFaceDecorationItem *)item
{
    [self.delegate endLoadingFaceDecoration];
    [self handleFaceDecorationDidSelectedItem:item];
    
    if (!item && [self shouldShowFaceTipForEmptyDecoration]) {
        [_recordHandler configFaceTipManagerForEmptyDecoration];
    }
}

- (void)drawerFaceDecorationDidSelectedGift:(MDFaceDecorationItem *)item {
    [self.delegate endLoadingFaceDecoration];
    [self handleFaceDecorationDidSelectedGift:item];
    
    if (!item && [self shouldShowFaceTipForEmptyDecoration]) {
        [_recordHandler configFaceTipManagerForEmptyDecoration];
    }
}

- (void)drawerFaceDecorationDidClearAllGift {
    
}

- (void)recommendFaceDecorationDidDownLoadFail:(MDFaceDecorationItem *)item
{
    [self.delegate loadingFaceDecorationFail];
}

#pragma mark - 上下滑动滤镜

- (void)activateSlidingFilters
{
    if (_filterModels.count == 0) {
        //上下切换滤镜资源
        MDRecordFilterModelLoader *loader = [[MDRecordFilterModelLoader alloc] init];
        _filterModels = [loader getFilterModels];
        NSArray<MDRecordFilter *> *filters = [loader filtersArray];
        [self.delegate didGetFilters:filters];
    }
}

#pragma mark - 滤镜抽屉模块
- (void)activateFilterDrawer
{
    [self setupFilterDrawer];
    
    if (self.filterDrawerController.isAnimating) {
        return;
    }
    
    if (self.filterDrawerController.isShowed) {
        [self updateUiForBeforeSubViewIsShow:NO completeBlock:nil];
        return;
    }
    [self.filterDrawerController setDefaultSelectIndex:0];
    [self.filterDrawerController setFilterIndex:self.recordViewController.containerView.slidingFilterView.currentFilterIndex];
    
    __weak typeof(self) weakSelf = self;
    [self updateUiForBeforeSubViewIsShow:YES completeBlock:^{
        [weakSelf.filterDrawerController showAnimation];
    }];
}

- (void)activateThinDrawer
{
    [self setupFilterDrawer];
    
    if (self.filterDrawerController.isAnimating) {
        return;
    }
    
    if (self.filterDrawerController.isShowed) {
        [self updateUiForBeforeSubViewIsShow:NO completeBlock:nil];
        return;
    }
    [self.filterDrawerController setDefaultSelectIndex:1];

    __weak typeof(self) weakSelf = self;
    [self updateUiForBeforeSubViewIsShow:YES completeBlock:^{
        [weakSelf.filterDrawerController showAnimation];
    }];
    
}

- (void)setupFilterDrawer
{
    if (!_filterDrawerController) {
        _filterDrawerController = [[MDRecordFilterDrawerController alloc] init];
        _filterDrawerController.delegate = self;
        
        [self.recordViewController addChildViewController:_filterDrawerController];
        [self.recordViewController.view addSubview:_filterDrawerController.view];
        
        //设置滤镜数据源
        [_filterDrawerController setFilterModels:_filterModels];
        
        //设置 美颜 & 大眼瘦脸参数
        NSInteger makeupIndex = [_beautySettingDict integerForKey:MDBeautySettingsSkinWhitenAmountKey defaultValue:0];
        NSInteger thinFaceIndex = [_beautySettingDict integerForKey:MDBeautySettingsEyesEnhancementAmountKey defaultValue:0];
        NSInteger thinBodyIndex = [_beautySettingDict integerForKey:MDBeautySettingsThinBodyAmountKey defaultValue:-1];
        NSInteger longLegIndex = [_beautySettingDict integerForKey:MDBeautySettingsLongLegAmountKey defaultValue:-1];
        
        [_filterDrawerController setMakeUpIndex:makeupIndex];
        [_filterDrawerController setThinFaceIndex:thinFaceIndex];
        [_filterDrawerController setThinBodyIndex:thinBodyIndex];
        [_filterDrawerController setLongLegIndex:longLegIndex];
        [_filterDrawerController setMakeupBeautyIndex:0];
        [_filterDrawerController setMakeupStyleIndex:0];
        [_filterDrawerController setFilterIndex:self.recordViewController.containerView.slidingFilterView.currentFilterIndex];
    }
}

#pragma mark - MDRecordFilterDrawerControllerDelegate

- (void)didSelectedFilterItem:(NSInteger)index
{
    [self.delegate didSeletetedFilterIndex:index];
}

//美颜
- (void)didSelectedMakeUpItem:(NSInteger)index
{
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsSkinSmoothingAmountKey];
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsSkinWhitenAmountKey];
    
    [self setBeautySetting];
}

- (void)didSelectedMakeUpModel:(NSString *)modelType{
    NSLog(@"波仔看看是 : %@",modelType);
    if ([modelType isEqualToString: @"无"]) {
        [self.recordHandler removeAllMakeupEffect];
        return;
    }
    self.makeupType = [self getTypeWithName:modelType];
    [self.recordHandler removeAllMakeupEffect];
    NSString *rescousePath = [self getPathWithName:modelType];
    [self.recordHandler addMakeupEffect:rescousePath];
    [self.recordHandler setMakeupEffectIntensity:1 makeupType:self.makeupType];
}
/*
 XEngineMakeupKey const  MAKEUP_BLUSH            = @"makeup_blush";   // 腮红 0 - 1
 XEngineMakeupKey const  MAKEUP_FACIAL           = @"makeup_facial";   // 修容 0 - 1
 XEngineMakeupKey const  MAKEUP_EYEBROW          = @"makeup_eyebrow";   // 眼眉 0 - 1
 XEngineMakeupKey const  MAKEUP_EYES             = @"makeup_eyes";   // 眼妆 0 - 1
 XEngineMakeupKey const  MAKEUP_LIPS             = @"makeup_lips";   // 口红 0 - 1
 XEngineMakeupKey const  MAKEUP_PUPIL            = @"makeup_pupil";   // 瞳孔 0 - 1
 */
- (NSString *)getTypeWithName:(NSString*)name{
    if ([name hasPrefix:@"腮红"]) {
        return  @"makeup_blush";
    }
    if ([name hasPrefix:@"修容"]) {
        return  @"makeup_facial";
    }
    if ([name hasPrefix:@"眉毛"]) {
        return  @"makeup_eyebrow";
    }
    if ([name hasPrefix:@"眼妆"]) {
        return  @"makeup_eyes";
    }
    if ([name hasPrefix:@"口红"]) {
        return  @"makeup_lips";
    }
    if ([name hasPrefix:@"美瞳"]){
        return @"makeup_pupil";
    }
    return @"makeup_all";
}

- (NSString *)getPathWithName:(NSString *)name{
    NSString *rootPath = [[NSBundle mainBundle] pathForResource:@"makeup" ofType:@"bundle"];
    NSURL *path = [[NSBundle bundleForClass:self.class] URLForResource:@"makeup" withExtension:@"bundle"];
    NSURL *jsonPath = [[NSBundle bundleWithURL:path] URLForResource:@"makeup_list" withExtension:@"geojson"];
    NSArray *items = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:jsonPath] options:0 error:nil];
    NSDictionary *dict = @{
        @"甜拽":@"makeup_style/abg",
        @"白雪":@"makeup_style/baixue",
        @"芭比":@"makeup_style/babi",
        @"黑童话":@"makeup_style/heitonghua",
        @"裸装":@"makeup_style/luozhuang",
        @"韩式":@"makeup_style/hanshi",
        @"玉兔":@"makeup_style/yutu",
        @"闪闪":@"makeup_style/hanshi",
        @"秋日":@"makeup_style/qiuri",
        @"跨年装":@"makeup_style/kuanianzhuang",
        @"蜜桃":@"makeup_style/mitao",
        @"元气":@"makeup_style/yuanqi",
        @"混血":@"makeup_style/hunxue",
        @"神秘":@"makeup_style/shenmi",
    };
    if ([dict objectForKey:name]) {
        return [NSString stringWithFormat:@"%@/%@",rootPath,[dict objectForKey:name]];;
    }
    
    for (NSDictionary *item in items) {
        NSString *title = [item objectForKey:@"title"];
        if ([title isEqualToString:name]) {
            NSString *path = [item objectForKey:@"highlight"] ;
            if ([path isEqualToString:@"none"]) {
                path = @"";
            }
            return [NSString stringWithFormat:@"%@/%@",rootPath,path];
        }
    }
    return  @"";
}

//大眼瘦脸
- (void)didSelectedFaceLiftItem:(NSInteger)index
{
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsEyesEnhancementAmountKey];
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsFaceThinningAmountKey];
    
    [self setBeautySetting];
}

// 瘦身
- (void)didSelectedThinBodyItem:(NSInteger)index
{
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsThinBodyAmountKey];
    [self setBeautySetting];
}

// 长腿
- (void)didSelectedLongLegItem:(NSInteger)index
{
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsLongLegAmountKey];
    [self setBeautySetting];
}

- (void)didSetSkinWhitenValue:(CGFloat)value {
    [self.realBeautySettingDict setFloat:value forKey:MDBeautySettingsSkinWhitenAmountKey];
    [self updateBeautySetting];
}

- (void)didSetSmoothSkinValue:(CGFloat)value {
    [self.realBeautySettingDict setFloat:value forKey:MDBeautySettingsSkinSmoothingAmountKey];
    [self updateBeautySetting];
}

- (void)didSetBigEyeValue:(CGFloat)value {
    [self.realBeautySettingDict setFloat:value forKey:MDBeautySettingsEyesEnhancementAmountKey];
    [self updateBeautySetting];
}

- (void)didSetThinFaceValue:(CGFloat)value {
    [self.realBeautySettingDict setFloat:value forKey:MDBeautySettingsFaceThinningAmountKey];
    [self updateBeautySetting];
}

- (void)didSetFilterIntensity:(CGFloat)value {
    [self.currentRecordFilter setLutIntensity:value];
}

- (void)didSetMakeUpLookIntensity:(CGFloat)value{
    [self.recordHandler setMakeupEffectIntensity:value makeupType:@"makeup_lut"];
}
- (void)didSetMakeUpBeautyIntensity:(CGFloat)value{
    [self.recordHandler setMakeupEffectIntensity:value makeupType:self.makeupType];
}

- (void)didSetMicroSurgeryIntensity:(CGFloat)value{
    if (self.microSurgeryType) {
        [self.recordHandler adjustBeauty:value forKey:self.microSurgeryType];
    }
}

- (void)longTounchBtnClickEnd{
    [self.recordHandler setRenderStatus:YES];
}

- (void)longTounchBtnClickStart{
    [self.recordHandler setRenderStatus:NO];
}

- (void)didselectedMicroSurgeryModel:(NSString *)index{
    if (index) {
        self.microSurgeryType = index;
        [self.recordHandler adjustBeauty:1.0 forKey:index];
    }
}

// 关闭瘦身长腿功能
- (void)_removeThinBodySetting
{
    [self.beautySettingDict setInteger:0 forKey:MDBeautySettingsThinBodyAmountKey];
    [self.beautySettingDict setInteger:0 forKey:MDBeautySettingsLongLegAmountKey];
    [self transferBeautySettingToRealBeautySetting];
    [self.filterDrawerController setThinBodyIndex:0];
    [self.filterDrawerController setLongLegIndex:0];
}

- (void)updateBeautySetting {
    BOOL supportRotateCamera = YES;
    if ([self.recordViewController respondsToSelector:@selector(supportRotateCamera)]) {
        supportRotateCamera = [self.recordViewController supportRotateCamera];
    }
    
    if ([self.delegate respondsToSelector:@selector(didSwitchToArDecoration:)]) {
        [self.delegate didSwitchToArDecoration:self.isArDecoration];
    }
    
    //如果切换成功需要禁用一些功能
    if (self.selectedDecoration) {
        
//        if (self.selectedDecoration.filterDisable) {
            //如果选择的变脸携带滤镜，去掉滤镜,选择原图滤镜
//            [self didSelectedFilterItem:0];
//        }
        
        if (self.selectedDecoration.requiresImageSegmentation) {// 需要抠图
            [self _removeThinBodySetting];
        }
        
        if (!_originBeautySettings) {
            _originBeautySettings = self.selectedDecoration.beautySettings;
        }
        
        
        //读出美颜贴纸自带的效果
        CGFloat bigEyeFactor = _originBeautySettings.bigEyeFactor;
        CGFloat thinFaceFactor = _originBeautySettings.thinFaceFactor;
        CGFloat skinSmoothFactor = _originBeautySettings.skinSmoothingFactor;
        CGFloat skinWhitenFactor = _originBeautySettings.skinWhitenFactor;
        CGFloat skinRuddyFactor = _originBeautySettings.skinRuddyFactor;
        CGFloat thinBodyFactor = _originBeautySettings.bodyWidthFactor;
        CGFloat longLegFactor = _originBeautySettings.legsLenghtFactor;
        
        bigEyeFactor = bigEyeFactor == (-1) ? [self.realBeautySettingDict floatForKey:MDBeautySettingsEyesEnhancementAmountKey defaultValue:0.0f] : bigEyeFactor;
        
        thinFaceFactor = thinFaceFactor == (-1) ? [self.realBeautySettingDict floatForKey:MDBeautySettingsFaceThinningAmountKey defaultValue:0.0f] : thinFaceFactor;
        
        skinSmoothFactor = skinSmoothFactor == (-1) ? [self.realBeautySettingDict floatForKey:MDBeautySettingsSkinSmoothingAmountKey defaultValue:0.0f] : skinSmoothFactor;
        
        skinWhitenFactor = skinWhitenFactor == (-1) ? [self.realBeautySettingDict floatForKey:MDBeautySettingsSkinWhitenAmountKey defaultValue:0.0f] : skinWhitenFactor;
        
        skinRuddyFactor = skinRuddyFactor == (-1) ? [self.realBeautySettingDict floatForKey:MDBeautySettingsSkinRuddyAmountKey defaultValue:0.0f] : skinRuddyFactor;
        
        thinBodyFactor = thinBodyFactor == (-1) ? [self.realBeautySettingDict floatForKey:MDBeautySettingsThinBodyAmountKey defaultValue:-1.0f] : thinBodyFactor;
        
        longLegFactor = longLegFactor == (-1) ? [self.realBeautySettingDict floatForKey:MDBeautySettingsLongLegAmountKey defaultValue:-1.0f] : longLegFactor;
        
        FDKBeautySettings *beautySettings = [[FDKBeautySettings alloc] init];
        beautySettings.bigEyeFactor = bigEyeFactor;
        beautySettings.thinFaceFactor = thinFaceFactor;
        beautySettings.skinRuddyFactor = skinRuddyFactor;
        beautySettings.skinWhitenFactor = skinWhitenFactor;
        beautySettings.bodyWidthFactor = thinBodyFactor;
        beautySettings.legsLenghtFactor = longLegFactor;
        beautySettings.skinSmoothingFactor = skinSmoothFactor;

        self.selectedDecoration.beautySettings = beautySettings;
        
        [self.recordHandler addDecoration:self.selectedDecoration];
        
    } else {
        if (!self.beautySettingDecoration) {
            self.beautySettingDecoration = [[FDKDecoration alloc] init];
        }
        
        [self.recordHandler updateDecorationWithBeautySettingsDict:self.realBeautySettingDict decoration:self.beautySettingDecoration];
        [self.recordHandler addDecoration:self.beautySettingDecoration];
    }
}

- (void)setBeautySetting
{
    [self transferBeautySettingToRealBeautySetting];
    
    [self updateBeautySetting];
}

- (void)transferBeautySettingToRealBeautySetting
{
    __weak __typeof(self) weakSelf = self;
    [self.beautySettingDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        CGFloat realValue = [[MDRecordContext beautySettingDataManager] realValueWithIndex:[obj integerValue] beautySettingTypeStr:key];
        [weakSelf.realBeautySettingDict setFloat:realValue forKey:key];
    }];
}

#pragma mark - BBMediaEditorSlidingOverlayViewDelegate
- (void)mediaEditorSlidingOverlayView:(BBMediaEditorSlidingOverlayView *)overlayView filterOffsetDidChange:(double)filterOffset filterA:(MDRecordFilter *)filterA filterB:(MDRecordFilter *)filterB
{
    //排重
    if (self.filterIndex != overlayView.currentFilterIndex && isFloatEqual(filterOffset, 1.0f)) {
        self.filterIndex = overlayView.currentFilterIndex;
        [_filterDrawerController setFilterIndex:self.filterIndex];
        //滤镜名称提示
        MDRecordFilter *currentFilter = [overlayView filterAtPageIndex:self.filterIndex];
        [self.delegate didShowFilter:currentFilter];
    }
    [self.recordHandler configureFilterA:filterA filterB:filterB offset:filterOffset];
    
    self.currentRecordFilter = filterA;
}

- (void)mediaEditorSlidingOverlayViewDidEndDecelerating:(BBMediaEditorSlidingOverlayView *)overlayView fromPageIndex:(NSInteger)pageIndex{}

- (BOOL)mediaEditorSlidingOverlayView:(BBMediaEditorSlidingOverlayView *)overlayView shouldHandleTouchAtPoint:(CGPoint)point withEvent:(UIEvent *)event defaultValue:(BOOL)defaultValue
{
    return defaultValue;
}

#pragma mark - 配乐模块
- (void)activateAutoMusicWithMusicItem:(MDMusicCollectionItem *)musicItem needSameStyle:(BOOL)needSameStyle
{
    if (!self.hasUsePreMusic && !self.currentSelectMusicItem && [musicItem.musicVo.musicID isNotEmpty]) {
        self.hasUsePreMusic = YES;
        
        CMTimeRange timeRange = kCMTimeRangeZero;
        BOOL resourceExist = [musicItem resourceExist];
        if (resourceExist) {
            AVAsset *asset = [AVAsset assetWithURL:musicItem.resourceUrl];
            timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        }

        if (needSameStyle && resourceExist) {
            //如果背景音乐已经下载好，且走拍同款逻辑
            self.sameStyleMusicItem = musicItem;
            [[MDMusicFavouriteManager getCurrentFavouriteManager] insertMusicItemToFavourite:musicItem];
        }
        [self didSeletedMusicItem:musicItem timeRange:timeRange];
        
        if (!resourceExist) { //下载配置的音乐
            musicItem.downLoading = YES;
            [[MDBackgroundMusicDownloader shared] downloadItem:musicItem.musicVo completion:^(MDMusicBVO * bvo, NSURL * _Nonnull fileUrl, BOOL success) {
                musicItem.downLoading = NO;
                if (success && self.currentSelectMusicItem && [self.currentSelectMusicItem.musicVo.musicID isEqualToString:bvo.musicID]) {
                    [self didSeletedMusicItem:musicItem timeRange:CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity)];
                    [[MDMusicFavouriteManager getCurrentFavouriteManager] insertMusicItemToFavourite:musicItem];
                }
            }];
        }
    }
}

#pragma mark - music player

- (BOOL)checkShouldPlay {
    return [self viewIsShowing] && [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
}

- (BOOL)viewIsShowing {
    return self.recordViewController.isViewLoaded && self.recordViewController.view.window;
}

- (void)doPlay {
    if([self checkShouldPlay]) {
        [self.musicPlayer play];
    }
}

- (void)doPause {
    [self.musicPlayer pause];
}

- (void)resumePlayWhenPickVCShow {
    if (self.musicSelectPicker.isShowed && self.musicPlayer.currentItem) {
        [self doPlay];
    }
}

- (AVPlayer *)musicPlayer {
    if(!_musicPlayer) {
        _musicPlayer = [[AVPlayer alloc] init];
    }
    return _musicPlayer;
}


# pragma mark - music view

- (BOOL)playWithCheckAssetValid:(MDMusicCollectionItem *)item timeRange:(CMTimeRange)timeRange {
    BOOL isValid = YES;
    if (![MDMusicResourceUtility checkAssetValidWithURL:item.resourceUrl sizeConstraint:NO]) {
        isValid = NO;
    } else {
        [self configPlayerWithItem:item timeRange:timeRange];
        [self doPlay];
    }
    return isValid;
}

- (void)configPlayerWithItem:(MDMusicCollectionItem *)item timeRange:(CMTimeRange)timeRange {
    if(![item resourceExist]) {
        return;
    }
    
    AVAsset *songAsset = [AVURLAsset assetWithURL:item.resourceUrl];
    AVMutableComposition *composition = [AVMutableComposition composition];
    CMTimeRange resultRange = CMTimeRangeGetIntersection(CMTimeRangeMake(kCMTimeZero, songAsset.duration), timeRange);
    [composition insertTimeRange:resultRange ofAsset:songAsset atTime:kCMTimeZero error:nil];
    AVPlayerItem *songItem = [[AVPlayerItem alloc] initWithAsset:composition];
    
    [self.musicPlayer replaceCurrentItemWithPlayerItem:songItem];
    [self doPause];
}

- (void)musicPlayShouldAllow:(BOOL)isAllow
{
    if (isAllow) {
        [self.recordHandler setBackgroundAudio:_musicAsset];
    } else {
        [self.recordHandler setBackgroundAudio:nil];
    }
}

- (void)activateMusicPicker
{
    [self hideModuleView];
    
    [self setupMusicPicker];
    
    if (!self.musicSelectPicker.view.superview) {
        [self.recordViewController.view addSubview:self.musicSelectPicker.view];
    }
    
    if (self.musicSelectPicker.isShowed) {
        [self hideMusicPicker];
    } else {
        [self.musicSelectPicker showAnimateWithCompleteBlock:nil];
        
        if (self.musicPlayer.currentItem) {
            [self.musicPlayer play];
        }
    }
}

- (void)hideMusicPicker
{
    [self doPause];
    if (self.musicSelectPicker.isShowed) {
        [self.musicSelectPicker hideAnimationWithCompleteBlock:nil];
    }
}

- (void)setupMusicPicker
{
    if(!_musicSelectPicker) {
        _musicSelectPicker = [[MDMusicEditPalletController alloc] init];
        [_musicSelectPicker updateMusicItem:self.currentSelectMusicItem timeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(15, 1000))];
        _musicSelectPicker.delegate = self;
        [self.recordViewController addChildViewController:self.musicSelectPicker];
        [self.musicSelectPicker didMoveToParentViewController:self.recordViewController];
    }
}

- (void)musicEditPallet:(MDMusicEditPalletController *)musicEditPallet didPickMusicItems:(MDMusicCollectionItem *)musicItem timeRange:(CMTimeRange)timeRange {
    [self playWithCheckAssetValid:musicItem timeRange:timeRange];
    [self didSeletedMusicItem:musicItem timeRange:timeRange];
}

- (void)musicEditPallet:(MDMusicEditPalletController *)musicEditPallet didEditOriginalVolume:(CGFloat)originalVolume musicVolume:(CGFloat)musicVolume {
    self.musicPlayer.volume = musicVolume;
}

- (void)musicEditPalletDidClearMusic:(MDMusicEditPalletController *)musicEditPallet {
    [self.musicPlayer pause];
    [self didSeletedMusicItem:nil timeRange:kCMTimeRangeZero];
}

- (void)didSeletedMusicItem:(MDMusicCollectionItem *)musicItem timeRange:(CMTimeRange)timeRange {
    //业务是否支持配乐功能
    BOOL supportMusicFunction = NO;
    if ([self.recordViewController respondsToSelector:@selector(supportMusicFunction)]) {
        supportMusicFunction = [self.recordViewController supportMusicFunction];
    }
    
    //已经开始录制直接返回
    if (!isFloatEqual(self.currentRecordDuration, 0) || !supportMusicFunction) return;
    
    self.currentSelectMusicItem = musicItem;
    [self.delegate didCloseMusicPickerControllerWithItem:musicItem];
    if (!musicItem) {
        self.musicAsset = nil;
        self.recordHandler.backgroundAudio = nil;
        self.musicUrl = nil;
        self.musicTimeRange = kCMTimeRangeInvalid;
    }

    if (![musicItem resourceExist] || CMTIMERANGE_IS_EMPTY(timeRange)) {
        return;
    }
    
    NSURL *url = musicItem.resourceUrl;
    AVAsset *musicAsset = [AVURLAsset assetWithURL:url];
    CMTimeRange musicTimeRange = CMTimeRangeMake(kCMTimeZero, musicAsset.duration);
    if (CMTimeRangeContainsTimeRange(musicTimeRange, timeRange)) {
        musicTimeRange = timeRange;
    }

    if (self.sameStyleMusicItem && [self.sameStyleMusicItem.musicVo.musicID isEqualToString:musicItem.musicVo.musicID]) {
        CMTime duration = musicTimeRange.duration;
        NSTimeInterval time = CMTimeGetSeconds(duration);
        [self updateRecordMaxDuration: MIN(time, kMaxVideoDurationForHighLevel)];
    }else {
        NSTimeInterval maxDuration = kMaxVideoDurationForHighLevel;
        if ([self.recordViewController respondsToSelector:@selector(maxRecordDurationCurrentLevel)]) {
            maxDuration = [self.recordViewController maxRecordDurationCurrentLevel];
        }
        [self updateRecordMaxDuration:maxDuration];
    }

    AVAsset *newMusicAsset = [self musicAssetWithUrl:url timeRange:musicTimeRange];
    self.musicAsset = newMusicAsset;
    
    self.recordHandler.backgroundAudio = newMusicAsset;
    self.musicUrl = url;
    self.musicTimeRange = musicTimeRange;
}


#pragma mark - 延时动画模块
- (void)startCountDownAnimation
{
    if (self.countDownType == MDVideoRecordCountDownType_None || ![self canStartRecording]) {
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    
    [self.delegate didStartCountDownAnimation];
    
    [self.countDownAnimation startAnimationWithCompletionHandler:^(BOOL finished) {
        [weakSelf.delegate didFinishCountDownAnimation:finished];
    }];

}

- (void)cancelCountDownAnimation
{
    if ([_countDownAnimation isAnimating]) {
        [self.countDownAnimation cancelAnimation];
    }
}

- (void)setCountDownType:(MDVideoRecordCountDownType)countDownType
{
    _countDownType = countDownType;
    [self.delegate didSwitchToCountDownType:self.countDownType];
}

- (void)switchCountDownType
{
    NSString *desc = nil;
    
    switch (self.countDownType) {
        case MDVideoRecordCountDownType_None:
        {
            self.countDownType = MDVideoRecordCountDownType_3;
            desc = [NSString stringWithFormat:@"%ld",MDVideoRecordCountDownType_3];
        }
            break;
        case MDVideoRecordCountDownType_3:
        {
//            self.countDownType = MDVideoRecordCountDownType_10;
//            desc = [NSString stringWithFormat:@"%ld",MDVideoRecordCountDownType_10];
            self.countDownType = MDVideoRecordCountDownType_None;
            desc = [NSString stringWithFormat:@"OFF"];
        }
            break;
//        case MDVideoRecordCountDownType_10:
//        {
//            self.countDownType = MDVideoRecordCountDownType_None;
//            desc = [NSString stringWithFormat:@"OFF"];
//        }
//            break;
            
        default:
            break;
    }
    
    [self setCountDownType:self.countDownType];
    self.countDownAnimation.count = self.countDownType;
    [self.countDownAnimation showPrepareAnimationWithString:desc];
}

#pragma mark - 闪光灯相关
- (void)switchFlashLight
{
    if (_currentFlashMode == MDRecordCaptureFlashModeAuto) {
        _currentFlashMode = MDRecordCaptureFlashModeOff;
        
    } else if (_currentFlashMode == MDRecordCaptureFlashModeOff) {
        _currentFlashMode = MDRecordCaptureFlashModeAuto;
    }
    
    [self setFlashMode:_currentFlashMode];
}

- (void)setFlashMode:(MDRecordCaptureFlashMode)flashMode
{
    _currentFlashMode = flashMode;
    [self setFlashLightWithFlashMode:flashMode];
    [self.delegate didSwitchToFlashMode:flashMode];
}

- (void)setFlashLightWithFlashMode:(MDRecordCaptureFlashMode)flashMode
{
    if ([self.recordHandler hasFlash]) {
        NSArray *flashModeArray = [self.recordHandler supportFlashModes];
        if ([flashModeArray containsObject:@(flashMode)]) {
            [self.recordHandler setFlashMode:flashMode];
        }
    }
}

#pragma mark - 变速相关

- (void)setSpeedVaryFactor:(CGFloat)factor {
    [self.recordHandler setNextRecordSegmentSpeedVaryFactor:factor];
}

- (void)speedVaryShouldAllow:(BOOL)isAllow {
    [self.recordHandler speedVaryShouldAllow:isAllow];
}

- (BOOL)hasPerSpeedEffect {
    return [self.recordHandler hasPerSpeedEffect];
}


#pragma mark - 辅助方法
- (BOOL)isDoingCountDownAnimation
{
    return _countDownAnimation.isAnimating;
}

- (BOOL)isModuleViewShowed
{
    BOOL isModuleViewShowed = _filterDrawerController.isShowed || _decorationView.isShowed || _musicSelectPicker.isShowed;
//    BOOL isModuleViewShowed = _filterDrawerController.isShowed || _faceDecorationVC.isShowed;
    return isModuleViewShowed;
}

- (void)hideModuleView
{
    [self updateUiForBeforeSubViewIsShow:NO completeBlock:nil];
}

// 滤镜抽屉、变脸抽屉、配乐抽屉 出现时 isShow 为 YES，消失是为NO
- (void)updateUiForBeforeSubViewIsShow:(BOOL)isShow completeBlock:(void(^)(void))completeBlock
{
    [self hideMusicPicker];
    
    [self.delegate moduleViewWillShowOrHide:isShow];
    
    if (isShow) {
        if (_filterDrawerController.isShowed) {
            [_filterDrawerController hideAnimationWithCompleteBlock:^{
                if (completeBlock) {
                    completeBlock();
                }
            }];
            
        } else if (self.decorationView.isShowed) { // _faceDecorationVC.isShowed
            [self.decorationView hideAnimateWithCompleteBlock:^{
                if (completeBlock) {
                    completeBlock();
                }
            }];
//            [_faceDecorationVC hideAnimateWithCompleteBlock:^{
//                if (completeBlock) {
//                    completeBlock();
//                }
//            }];
            
        }  else {
            if (completeBlock) {
                completeBlock();
            }
        }
        [self.delegate moduleViewDidShowOrHide:YES];
        
    } else {
        
        if (_filterDrawerController.isShowed) {
            [_filterDrawerController hideAnimationWithCompleteBlock:nil];
        }
        
        if (self.decorationView.isShowed) { // _faceDecorationVC.isShowed
//            [_faceDecorationVC hideAnimateWithCompleteBlock:nil];
            [self.decorationView hideAnimateWithCompleteBlock:nil];
        }
        
        [self.delegate moduleViewDidShowOrHide:NO];
    }
}

- (void)configVideoResult
{
    self.videoResult.isFromAlbum = NO;
    self.videoResult.delayCapture = self.countDownType;

    //打点参数
    MDRecordFilterModel *filterModel    = [self.filterModels objectAtIndex:self.recordViewController.containerView.slidingFilterView.currentFilterIndex defaultValue:nil];
    
    self.videoResult.filterID           = filterModel.identifier;
    
    self.videoResult.beautyFaceLevel    = [self.beautySettingDict integerForKey:MDBeautySettingsSkinSmoothingAmountKey defaultValue:0];
    
    self.videoResult.thinBodayLevel = [self.beautySettingDict integerForKey:MDBeautySettingsThinBodyAmountKey defaultValue:0];
    self.videoResult.longLegLevel = [self.beautySettingDict integerForKey:MDBeautySettingsLongLegAmountKey defaultValue:0];
    
    self.videoResult.bigEyeLevel        = [self.beautySettingDict integerForKey:MDBeautySettingsEyesEnhancementAmountKey defaultValue:0];
    
    self.videoResult.flashLightState    = self.currentFlashMode;
}

- (AVAsset *)musicAssetWithUrl:(NSURL *)url timeRange:(CMTimeRange)timeRange
{
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVURLAsset *music = [AVURLAsset assetWithURL:url];
    NSInteger repeatCount = ceil(self.recordHandler.recordDuration / CMTimeGetSeconds(timeRange.duration));
    double segmentStartTime = .0f;
    
    for (int i = 0; i < repeatCount; i++) {
        CMTime insertTime = CMTimeMakeWithSeconds(segmentStartTime, music.duration.timescale);
        [composition insertTimeRange:timeRange ofAsset:music atTime:insertTime error:nil];
        segmentStartTime += CMTimeGetSeconds(timeRange.duration);
    }
    
    return composition;
}

- (void)saveAllmoduleSettingConfig
{
    [self doPause];
    //记录滤镜使用情况
//    NSInteger index = self.recordViewController.containerView.slidingFilterView.currentFilterIndex;
    //TODO这种情况会出现在快速进出拍摄器（待重构）
//    if (self.recordViewController.containerView.slidingFilterView.currentPageIndex == 0) {
//        index = [[[MDContext currentUser] dbStateHoldProvider] recordFilterInedx];
//    }
//    [[[MDContext currentUser] dbStateHoldProvider] setRecordFilterInedx:index];
    
    //记录相机前后置位置
//    [[[MDContext currentUser] dbStateHoldProvider] setMomentCameraPosition:self.recordHandler.cameraPosition];
    
    //保存变脸设置
    // 8.8.1版本   本地不记录瘦身和长腿的配置
//    NSMutableDictionary *dict = [_beautySettingDict mutableCopy];
//    [dict setObject:@(-1.f) forKey:MDBeautySettingsThinBodyAmountKey];
//    [dict setObject:@(-1.f) forKey:MDBeautySettingsLongLegAmountKey];
//    [[[MDContext currentUser] dbStateHoldProvider] setBeautySettingsDic:dict];
}

- (void)resetAllModuleSettingToDefaut
{
    //变脸相关清除
//    [self resetFaceDecoration];
    
    //闪光灯关闭
    [self setFlashMode:MDRecordCaptureFlashModeOff];
    
    //延时关闭
    [self setCountDownType:MDVideoRecordCountDownType_None];
    
    //重置音乐
    self.musicUrl = nil;
    self.musicTimeRange = kCMTimeRangeInvalid;
    self.musicAsset = nil;
    self.recordHandler.backgroundAudio = nil;
    [self.delegate didResetMusicPicker];

    [self.recordHandler muteDecorationAudio:YES];
    [self.recordHandler clearStashVideo];
    self.videoResult = nil;
}

- (void)clearStashVideo {
    [self.recordHandler clearStashVideo];
}

#pragma mark - getter & setter
- (NSMutableDictionary *)realBeautySettingDict
{
    if (!_realBeautySettingDict) {
        _realBeautySettingDict = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return _realBeautySettingDict;
}

- (MDUnifiedRecordCountDownAnimation *)countDownAnimation
{
    if (!_countDownAnimation) {
        _countDownAnimation = [[MDUnifiedRecordCountDownAnimation alloc] initWithContainer:self.recordViewController.view];
    }
    return _countDownAnimation;
}

- (MDRecordVideoResult *)videoResult
{
    if (!_videoResult) {
        _videoResult = [[MDRecordVideoResult alloc] init];
    }
    return  _videoResult;
}

- (MDImageUploadParamModel *)imageUploadModel
{
    if (!_imageUploadModel) {
        _imageUploadModel = [[MDImageUploadParamModel alloc] init];
        _imageUploadModel.paramsOfPicturing = [[MDImageUploadParamsOfPicturing alloc] init];
    }
    return _imageUploadModel;
}

- (NSTimeInterval)currentRecordDuration
{
    return self.recordHandler.currentRecordingDuration;
}
- (NSTimeInterval)currentRecordPresentDuration
{
    return self.recordHandler.currentRecordingPresentDuration;
}


//判断是否开始录制一段，yes表示没有录制，no表示已经录制,使用录制时长判断
- (BOOL)currentRecordDurationSmallerThanMinSegmentDuration
{
    return self.currentRecordDuration < kRecordSegmentMinDuration;
}

//使用呈现时长判断
- (BOOL)currentRecordDurationBiggerThanMinDuration
{
    if (!isFloatEqual(_minDuration, 0.0f)) {
        return self.currentRecordPresentDuration >= _minDuration;
    }
    return self.currentRecordPresentDuration >= kDefaultRecordMinDuration;
}

- (NSTimeInterval)recordDuration
{
    return self.recordHandler.recordDuration;
}

-  (NSInteger)savedSegmentCount
{
    return self.recordHandler.savedSegmentCount;
}

- (BOOL)stopMerge
{
    return self.recordHandler.stopMerge;
}

- (BOOL)isRecording
{
    return self.recordHandler.isRecording;
}

- (BOOL)isFaceCaptured
{
    return self.recordHandler.isFaceCaptured;
}

- (BOOL)isDetectorBareness
{
    return self.recordHandler.hasDetectorBareness;
}

- (NSMutableArray *)pitchNumbers
{
    if (!_pitchNumbers) {
        _pitchNumbers = [NSMutableArray array];
    }
    return _pitchNumbers;
}

- (void)muteSticker:(BOOL)mute {
    [self.recordHandler muteSticker:mute];
}

- (void)enableRecordAudio:(BOOL)enable {
    [self.recordHandler enableRecordAudio:enable];
}
    
- (void)recordOrigin:(BOOL)enable {
    [self.recordHandler recordOrigin:enable];
}

- (void)setUseAISkinWhiten:(BOOL)useAISkinWhiten{
    self.recordHandler.useAISkinWhiten = useAISkinWhiten;
}

- (BOOL)useAISkinWhiten{
    return self.recordHandler.useAISkinWhiten;
}

- (void)setUseAISkinSmooth:(BOOL)useAISkinSmooth{
    self.recordHandler.useAISkinSmooth = useAISkinSmooth;
    
}

- (BOOL)useAISkinSmooth{
    return self.recordHandler.useAISkinSmooth;
}

- (void)setUseAIBigEyeThinFace:(BOOL)useAIBigEyeThinFace{
    self.recordHandler.useAIBigEyeThinFace = useAIBigEyeThinFace;
}

- (BOOL)useAIBigEyeThinFace{
    return self.recordHandler.useAIBigEyeThinFace;
}


- (void)enableReverseVideoSampleBuffer:(BOOL)enable {
    [self.recordHandler enableReverseVideoSampleBuffer:enable];
}

- (void)updateExposureBias:(float)bias {
    [self.recordHandler updateExposureBias:bias];
}

- (BOOL)hitTestTouch:(CGPoint)point withView:(UIView *)view {
    return [self.recordHandler hitTestTouch:point withView:view];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.recordHandler touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.recordHandler touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.recordHandler touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.recordHandler touchesCancelled:touches withEvent:event];
}

@end
