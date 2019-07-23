//
//  MDUnifiedRecordViewController.m
//  MDChat
//
//  Created by 符吉胜 on 2017/6/2.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordViewController.h"
#import "MDUnifiedRecordViewController+Permission.h"
#import "MDUnifiedRecordSettingItem.h"
#import "MDNavigationTransitionExtra.h"
//横屏拍摄模块
#import "MDUnifiedRecordViewController+horizontalRecording.h"
//
#import "MDUnifiedRecordModuleAggregate.h"
#import "MDUnifiedRecordCoordinator.h"
#import "MDRecordVideoResult.h"
#import "MDAssetPickerController.h"
#import "Toast/Toast.h"

@interface MDUnifiedRecordViewController ()
<
    UIAlertViewDelegate,
    UIGestureRecognizerDelegate,
    MDUnifiedRecordViewDelegate,
    MDRecordModuleControllerDelegate,
    MDNavigationBarAppearanceDelegate,
    MDCameraBottomViewDelegate
>

@property (nonatomic, strong) MDUnifiedRecordContainerView              *containerView;

//video basic info
@property (nonatomic, assign) NSTimeInterval                            maxRecordDuration;
//是否获取过语音句柄
@property (nonatomic,assign) BOOL                                       hasPrimeBizType;
@property (nonatomic,assign) BOOL                                       hasShownNormalRecordTip;
@property (nonatomic,assign) BOOL                                       hasSetupCamera;
//
@property (nonatomic,strong) MDUnifiedRecordModuleAggregate             *moduleAggregate;
@property (nonatomic,strong) MDUnifiedRecordCoordinator                 *recordCoordinator;


@property (nonatomic, strong) MDCameraBottomView                        *bottomView;
@property (nonatomic, assign) CGPoint                                   acturalTranslation;
@property (nonatomic,assign) BOOL                                       fromAlbum;
@end

@implementation MDUnifiedRecordViewController

#pragma mark - life cycles
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self closeVideoRecording];
}

- (instancetype)initWithSettingItem:(MDUnifiedRecordSettingItem *)settingItem fromAlbum:(BOOL)fromAlbum{
    if (self = [self init]) {
        _settingItem = settingItem;
        [self setFromAlbum:fromAlbum];
    }
    return self;
}

- (instancetype)initWithSettingItem:(MDUnifiedRecordSettingItem *)settingItem
{
    if (self = [self init]) {
        _settingItem = settingItem;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    BOOL didShow = [[MDContext currentUser].dbStateHoldProvider hasShowedMomentRecordSpeedVaryGuide];
//    if (!didShow) {
//        NSArray *availableTaps = [self tapsByAccessSource:_settingItem.accessSource];
//        if ([self checkCanRecordingNeedToast:NO] && [availableTaps containsObject:@(MDUnifiedRecordLevelTypeHigh)]) {
//            [[MDContext currentUser].dbStateHoldProvider setHasShowedMomentRecordSpeedVaryGuide:YES];
//            _settingItem.levelType = MDUnifiedRecordLevelTypeHigh;
//        }
//    }
    
    [self configUI];
    [self addNotification];
    
    if (!_useFastInit) {
        [self doViewInitEvent];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_hasSetupCamera) {
        [self doViewEnterEvent];
    }
}

- (void)doViewInitEvent
{
    [[self class] checkDevicePermission];
    
    [self setupCamera];
}

- (void)doViewEnterEvent
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    if (_hasSetupCamera) {
        //外界可控制是否禁用横屏录制
        if (!_settingItem.forbidHorizontalRecord) {
            [self startMotionManager];
        }
        
        if (_settingItem.levelType != MDUnifiedRecordLevelTypeAsset) {
            [self.moduleAggregate startCapturing];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.moduleAggregate resumePlayWhenPickVCShow];

    if (!_hasSetupCamera) {
        
        //原viewDidLoad 逻辑
        [self doViewInitEvent];
        
        //原viewWillAppear逻辑
        [self doViewEnterEvent];
    }
    
    ///延后3D引擎启动时机
//    AVCaptureDevicePosition postion =  AVCaptureDevicePositionFront; //(AVCaptureDevicePosition)[[[MDContext currentUser] dbStateHoldProvider] momentCameraPosition];
//    [self.moduleAggregate runXESEngineWithPosition:postion];
    
    //下载自动配乐
    if (_settingItem.levelType == MDUnifiedRecordLevelTypeHigh) {
        [self.moduleAggregate activateAutoMusicWithMusicItem:_settingItem.musicItem needSameStyle:_settingItem.isAllowedSameStyle];
    }
    
    //变速根据不同拍摄界面设置
    if (_settingItem.levelType == MDUnifiedRecordLevelTypeNormal) {
        [self.moduleAggregate speedVaryShouldAllow:YES];
    } else {
        [self.moduleAggregate speedVaryShouldAllow:YES];
    }
    
    //展示引导
//    if (_settingItem.levelType == MDUnifiedRecordLevelTypeNormal || _settingItem.levelType == MDUnifiedRecordLevelTypeHigh) {
//        [self.containerView doGuideAnimationWithLevelType:_settingItem.levelType];
//    }
    
    //展示普通录制按钮引导
//    if (_settingItem.levelType == MDUnifiedRecordLevelTypeNormal) {
//        [self.containerView normalRecordBtnTipViewShow:YES animated:YES];
//    }
    
    if (_hasSetupCamera) {
        //重新获取语音句柄
        if (!_hasPrimeBizType && ![self.settingItem.alertForForbidRecord isNotEmpty]) {
            _hasPrimeBizType = YES;
        }
        
        [self.moduleAggregate activateSlidingFilters];
        [self.moduleAggregate setDefaultBeautySetting];
        [self muteFaceDecorationAudio:NO];
        
        //开始录制 TODO:yzk
        [self.moduleAggregate startCapturing];
    }
    
    [self.moduleAggregate clearStashVideo];
    
    [self.containerView.slidingFilterView setCurrentPageIndex:1 animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self stopMotionManager];
    
    [self.moduleAggregate saveAllmoduleSettingConfig];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self muteFaceDecorationAudio:YES];
    [self.moduleAggregate stopCapturing];
    [self.moduleAggregate setFlashMode:MDRecordCaptureFlashModeOff];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //清理gpu缓存
    [self.moduleAggregate purgeGPUCache];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupCamera
{
    if (self.settingItem.levelType == MDUnifiedRecordLevelTypeAsset || _hasSetupCamera) {
        return;
    }
    
    _hasSetupCamera = YES;
    
    _moduleAggregate = [[MDUnifiedRecordModuleAggregate alloc] initWithRecordViewController:self];
    AVCaptureDevicePosition postion = AVCaptureDevicePositionFront; //(AVCaptureDevicePosition)[[[MDContext currentUser] dbStateHoldProvider] momentCameraPosition];
    [_moduleAggregate setupCameraSourceHandlerWithMaxDuration:[self maxRecordDurationWithLevelType:_settingItem.levelType]  minDuration:self.settingItem.minUploadDurationOfScene contentView:self.containerView.contentView devicePosition:postion];
    
    _recordCoordinator = [[MDUnifiedRecordCoordinator alloc] initWithContainerView:self.containerView settingItem:self.settingItem moduleAggregate:_moduleAggregate];
    _recordCoordinator.viewController = self;
    
    [self.moduleAggregate activateAutoFaceDecorationWithFaceID:_settingItem.faceId classID:_settingItem.faceClassId];
    
    //需要录制功能
    if (![self.settingItem.alertForForbidRecord isNotEmpty]) {
        _hasPrimeBizType = YES;
    }
    
}

#pragma mark - config UI
- (void)configUI
{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.containerView];
    
    UIButton *stickerMuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    stickerMuteButton.frame = CGRectMake(120, 20, 100, 40);
    stickerMuteButton.backgroundColor = UIColor.redColor;
    [stickerMuteButton setTitle:@"贴纸静音" forState:UIControlStateNormal];
    [stickerMuteButton setTitle:@"贴纸开音" forState:UIControlStateSelected];
    [stickerMuteButton addTarget:self action:@selector(stickerMuteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stickerMuteButton];
    
    UIButton *enableRecordAudioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enableRecordAudioButton.frame = CGRectMake(220, 20, 100, 40);
    enableRecordAudioButton.backgroundColor = UIColor.greenColor;
    [enableRecordAudioButton setTitle:@"启用麦克风" forState:UIControlStateNormal];
    [enableRecordAudioButton setTitle:@"禁用麦克风" forState:UIControlStateSelected];
    [enableRecordAudioButton addTarget:self action:@selector(enableRecordAudioButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enableRecordAudioButton];
    
    NSArray *availableTaps = [self tapsByAccessSource:_settingItem.accessSource];
    if (availableTaps.count>=2) {
        self.bottomView = [[MDCameraBottomView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44 + SAFEAREA_BOTTOM_MARGIN)];
        self.bottomView.bottom = MDScreenHeight;
        self.bottomView.delegate = self;
        [self.view addSubview:self.bottomView];
        
        [self.bottomView setAvailableTapList:availableTaps];
        [self.bottomView updateLayoutWithSelectedTap:self.settingItem.levelType];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanEvent:)];
        pan.delegate = self;
        [self.view addGestureRecognizer:pan];
    }
    
//    [[MDContext currentUser].dbStateHoldProvider setLastMomentRecordLevel:self.settingItem.levelType];
}

- (void)stickerMuteButtonTapped:(UIButton *)button {
    [self.moduleAggregate muteSticker:!button.selected];
    button.selected = !button.selected;
}

- (void)enableRecordAudioButtonTapped:(UIButton *)button {
    [self.moduleAggregate enableRecordAudio:!button.selected];
    button.selected = !button.selected;
}

- (MDUnifiedRecordContainerView *)containerView
{
    if (!_containerView) {
        _containerView = [[MDUnifiedRecordContainerView alloc] initWithDelegate:self levelType:self.settingItem.levelType fromAlbum:self.fromAlbum];
        _containerView.delegate = self;
    }
    return _containerView;
}

#pragma mark - 通知注册 & 处理
- (void)addNotification
{
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [notifyCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self.moduleAggregate doPause];
    [self muteFaceDecorationAudio:YES];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self.moduleAggregate resumePlayWhenPickVCShow];
    [self muteFaceDecorationAudio:NO];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.moduleAggregate resetRecorder];
    }
}

#pragma mark - MDUnifiedRecordViewDelegate
- (BOOL)isRecording
{
    return self.moduleAggregate.isRecording;
}

- (BOOL)currentRecordDurationBiggerThanMinDuration
{
    return self.moduleAggregate.currentRecordDurationBiggerThanMinDuration;
}

- (BOOL)currentRecordDurationSmallerThanMinSegmentDuration
{
    return self.moduleAggregate.currentRecordDurationSmallerThanMinSegmentDuration;
}

- (BOOL)hasModuleViewShowed
{
    return [self.moduleAggregate isModuleViewShowed];
}

- (BOOL)isModuleViewShowed
{
    BOOL isShowed = NO;
    
    isShowed = [self.moduleAggregate isModuleViewShowed];
    
    if (isShowed) {
        [self.moduleAggregate hideModuleView];
    }
    
    return isShowed;
}

- (MDRecordCaptureFlashMode)currentFlashMode
{
    return self.moduleAggregate.currentFlashMode;
}

- (BOOL)shouldShowNormalBtnTipView
{
    BOOL shouldShow = YES;
    
    if (_settingItem.levelType == MDUnifiedRecordLevelTypeHigh || _hasShownNormalRecordTip) {
        shouldShow = NO;
    }
    
    return shouldShow;
}

- (NSString *)normalBtnTip
{
//    NSString *tip = @"点击拍照，长按录像";
    NSString *tip = @"点击拍照";
    
    if ([self.settingItem.alertForForbidRecord isNotEmpty]) {
        tip = @"点击拍照";
    }
//    else if ([self.settingItem.alertForForbidPicture isNotEmpty]) {
//        tip = @"长按录像";
//    }
    
    return tip;
}

- (MDVideoRecordAccessSource)videoRecordAccessSource
{
    return _settingItem.accessSource;
}

- (BOOL)canUseRecordFunction
{
    return [self checkCanRecording];
}

- (NSString *)musicIDFromOperation
{
    return _settingItem.musicItem.musicVo.musicID;
}

- (void)didClickCancelBtn:(UIView *)cancelBtn
{
    if (self.moduleAggregate.stopMerge) {
        return;
    }
    
    if ([self isRecording]) {
        [self.moduleAggregate pauseRecording];
    } else {
        if (self.moduleAggregate.savedSegmentCount > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"你想放弃录制视频吗"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"放弃", nil];
            [alert show];
            
        } else {
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            if (self.fromAlbum && [self.aDelegate respondsToSelector:@selector(unifiedRecordViewControllerDidTapBackByTransition)]) {
                [self.aDelegate unifiedRecordViewControllerDidTapBackByTransition];
            }else{
                [self closeVideoRecording];
                self.settingItem.completeHandler(nil);
            }
        }
    }
}

- (void)didTapGotoEditView:(UIImageView *)view
{
    [self.moduleAggregate stopRecording];
}

- (void)filterViewTapped:(UITapGestureRecognizer *)tapGesture
{
    [self.moduleAggregate tapArDecorationWithGesture:tapGesture];
}

- (void)didDoubleTapCamera
{
    //防止频繁点击
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchCameraPosition) object:nil];
    [self performSelector:@selector(switchCameraPosition) withObject:nil afterDelay:0.3f];
}

- (void)filterViewPinched:(UIPinchGestureRecognizer *)pinchGesture {
    [self.moduleAggregate pinchVideoZoomFactorWithGesture:pinchGesture];
}

- (void)didTapSwitchCameraView:(UIImageView *)view
{
    [self switchCameraPosition];
}

- (void)didTapFlashLightView:(UIImageView *)view
{
    [self.moduleAggregate switchFlashLight];
}

- (void)didTapCountDownView:(UIImageView *)view
{
    [self.moduleAggregate switchCountDownType];
}

- (void)didTapMusicView:(UIImageView *)view
{
    [self.moduleAggregate activateMusicPicker];
}

- (void)didTapMakeUpView:(UIImageView *)view {
    [self.moduleAggregate activateMakeUpViewController];
}

- (void)didTapDeleSegmentView:(UIImageView *)view isSelected:(BOOL)isSelected
{
    [self.containerView setHighRecordBtnTipViewTextWithDeleteSelected:!isSelected];
    
    if (self.containerView.progressView.hilighted) {
        [self.moduleAggregate deleteLastSavedSegment];
    }
    
    [self.containerView setDeleSegmentViewSelected:!isSelected];
    self.containerView.progressView.hilighted = !isSelected;
}

- (void)didTapFaceDecorationView:(UIImageView *)view
{
    if (self.isRecording) {
        return;
    }
    [self.moduleAggregate activateFaceDecoration];
}

- (void)didTapFilterView:(UIImageView *)view
{
    [self.moduleAggregate activateFilterDrawer];
}

- (void)didTapThinView:(UIImageView *)view
{
    [self.moduleAggregate activateThinDrawer];
}

- (void)didTapSpeedView:(UIImageView *)view {
    
}

- (void)didTapRecordButton
{
    if (self.settingItem.levelType == MDUnifiedRecordLevelTypeHigh) {
        //高级拍摄
        [self didTapRecordButtonForHighCapture];
        
    } else {
        
        if (self.moduleAggregate.countDownType == MDVideoRecordCountDownType_None) {
            [self.containerView normalRecordBtnTipViewShow:NO animated:NO];
            _hasShownNormalRecordTip = YES;
            [self didTapRecordButtonForNormalCapture];
        } else {
            [self didTapRecordButtonForHighCapture];
        }
        
    }
}

- (void)faceDecorationViewRecordButtonTapped {
    [self didTapRecordButton];
}

- (void)didTapRecordButtonForHighCapture
{
    if ([self checkCanRecording]) {
        BOOL shouldStart = [self.moduleAggregate switchRecordingStatus];
        if (shouldStart) {
        }
    }
}

- (void)didTapRecordButtonForNormalCapture
{
    if ([self checkCanPicturing]) {
        [self.moduleAggregate captureStillImage];
    }
}

- (void)didLongPressBegan
{
    if ([self isRecording]) {
        return;
    }
    
    if (self.settingItem.levelType == MDUnifiedRecordLevelTypeHigh) {
        //高级拍摄
        [self didTapRecordButtonForHighCapture];
    } else {
        // 普通拍照
//        [self.containerView normalRecordBtnTipViewShow:NO animated:YES];
//        _hasShownNormalRecordTip = YES;
//
//        if (self.moduleAggregate.countDownType != MDVideoRecordCountDownType_None) {
//            return;
//        }
//
//        if ([self checkCanRecording]) {
//            [self.moduleAggregate startRecording];
//        }
    }
}

- (void)didLongPressEnded:(BOOL)pointInside
{
    if(![self isRecording]) {
        return;
    }
    if (pointInside) {
        [self.moduleAggregate pauseRecording];
    } else {
        [self.moduleAggregate cancelRecording];
    }
}

- (void)didTapDelayCloseView:(UIImageView *)view
{
    [self.moduleAggregate cancelCountDownAnimation];
}

- (void)didTapAlbumButton:(BOOL)hadShowAlert{
    if ([self.aDelegate respondsToSelector:@selector(unifiedRecordViewControllerDidTapAlbum:)]) {
        [self.aDelegate unifiedRecordViewControllerDidTapAlbum:hadShowAlert];
    }
}

- (BOOL)couldShowAlbumVideoAlert{
    if (self.settingItem.accessSource == MDVideoRecordAccessSource_QuickMatch || self.settingItem.accessSource == MDVideoRecordAccessSource_Profile || self.settingItem.accessSource == MDVideoRecordAccessSource_BackGround || self.settingItem.accessSource == MDVideoRecordAccessSource_SoulMatch) {
        return NO;
    }
    
    return YES;
}

//变速按钮点击
- (void)speedControlViewDidChangeWithFactor:(CGFloat)factor {
    if (factor != 1.0) {
    }
    [self.moduleAggregate setSpeedVaryFactor:factor];
}

#pragma mark - 辅助方法

//根据入口显示可用tap
- (NSArray*)tapsByAccessSource:(MDVideoRecordAccessSource)source {
    
    NSMutableArray *availableTaps = [NSMutableArray array];
    
    switch (source) {
        case MDVideoRecordAccessSource_GroupFeed:
        case MDVideoRecordAccessSource_QuickMatch:
        case MDVideoRecordAccessSource_SoulMatch:
        case MDVideoRecordAccessSource_Feed_photo:
        case MDVideoRecordAccessSource_RegLogin:
        {
            [availableTaps addObjectsFromArray:@[@(MDUnifiedRecordLevelTypeNormal)]];
            break;
        }
        default:
        {
            [availableTaps addObjectsFromArray:@[@(MDUnifiedRecordLevelTypeNormal), @(MDUnifiedRecordLevelTypeHigh)]];
            break;
        }
    }
    
    return availableTaps;
}

- (BOOL)checkCanRecording {
    return [self checkCanRecordingNeedToast:YES];
}

- (BOOL)checkCanRecordingNeedToast:(BOOL)toast {
    return YES;
}

- (BOOL)checkCanPicturing
{
    BOOL result = YES;
    
    if ([self.settingItem.alertForForbidPicture isNotEmpty]) {
        [[MDRecordContext appWindow] makeToast:self.settingItem.alertForForbidPicture duration:1.5f position:CSToastPositionCenter];
        result = NO;
    }
    
    return result;
}

- (NSTimeInterval)maxRecordDurationWithLevelType:(MDUnifiedRecordLevelType)levelType
{
    NSTimeInterval maxRecordDuration = 0.0f;
    
    if (levelType == MDUnifiedRecordLevelTypeNormal) {
        if (_settingItem.costumMaxDurationOfNormal > 0.f) {
            maxRecordDuration = _settingItem.costumMaxDurationOfNormal;
            
        } else {
            NSTimeInterval maxDuration = 0.0; //[[MDContext appConfig] momentRecordMaxDuration];
            maxRecordDuration = maxDuration ?: kMaxVideoDurationForNormalLevel;
        }
        
    } else if (levelType == MDUnifiedRecordLevelTypeHigh) {
        if (_settingItem.costumMaxDurationOfHigh > 0.f) {
            maxRecordDuration = _settingItem.costumMaxDurationOfHigh;
            
        } else {
            NSTimeInterval maxDuration = 0.0; //[[MDContext appConfig] superMomentRecordMaxDuration];
            maxRecordDuration = maxDuration ?: kMaxVideoDurationForHighLevel;
        }
        
    }
    
    return maxRecordDuration;
}

- (void)switchCameraPosition
{
    [self.moduleAggregate rotateCamera];
}

- (void)closeVideoRecording
{
    //重要（谨慎更改）
//    if (_hasPrimeBizType && [MDContext currentUser].isVideoRecording) {
        [self.moduleAggregate stopCapturing];
        [self.moduleAggregate stopRecording];
//        [MDContext currentUser].isVideoRecording = NO;
//    }
}

- (void)muteFaceDecorationAudio:(BOOL)mute
{
    if (![self isViewVisible] && !mute) return;
    
    if (_settingItem.levelType == MDUnifiedRecordLevelTypeAsset) {
        [self.moduleAggregate muteFaceDecorationAudio:YES];
    } else {
        [self.moduleAggregate muteFaceDecorationAudio:mute];
    }
}

- (BOOL)isViewVisible
{
    return self.isViewLoaded && self.view.window;
}

#pragma mark - MDRecordModuleControllerDelegate
- (BOOL)supportMusicFunction
{
    return YES; //_settingItem.levelType == MDUnifiedRecordLevelTypeHigh;
}

//是否支持光膀子模型检测
- (BOOL)supportBarenessDetectorFunction
{
    return  NO;
}

- (BOOL)shouldShowFaceTipForEmptyDecoration
{
    return  NO;
}

- (BOOL)supportRotateCamera
{
    return YES;
}

- (NSTimeInterval)maxRecordDurationCurrentLevel {
    return [self maxRecordDurationWithLevelType:_settingItem.levelType];
}


#pragma mark - bottomView

- (BOOL)isBottomViewHidden {
    if (self.bottomView) {
        return isFloatEqual(self.bottomView.top, MDScreenHeight);
    }
    return YES;
}

- (void)showBottomViewWithAnimation:(BOOL)animated {
    [UIView animateWithDuration:animated?0.1f:0.0001f animations:^{
        self.bottomView.bottom = MDScreenHeight;
    }];
}

- (void)hideBottomViewWithAnimation:(BOOL)animated {
    [UIView animateWithDuration:animated?0.1f:0.0001f animations:^{
        self.bottomView.top = MDScreenHeight;
    }];
}


#pragma mark - MDCameraBottomViewDelegate & UIGestureRecognizerDelegate

- (MDUnifiedRecordLevelType)selectedTap {
    return [self.bottomView getCurrentLevelType];
}

- (BOOL)isEnableSwitch {
    BOOL isEnableSwitch = isFloatEqual(self.moduleAggregate.currentRecordDuration, 0.0f) && ![self isBottomViewHidden] && ![self.containerView video3DTouchViewAcceptTouch];
    return isEnableSwitch;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGesture {
    if (![self isEnableSwitch]) {
        return NO;
    }
    return YES;
}


- (void)handlePanEvent:(UIPanGestureRecognizer*)panGesture {
    
    CGPoint p = [panGesture translationInView:self.view];
    
    //1. 开始切换前准备
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        _acturalTranslation = CGPointZero;
        [self scrollWillBegin];
        return;
    }
    
    _acturalTranslation.x += p.x;
    [panGesture setTranslation:CGPointZero inView:self.view];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateChanged:
        {
            BOOL isHandled = [self isScrollHandledWithOffset:_acturalTranslation.x];
            if (isHandled) {
                [self.bottomView viewDidScroll:(_acturalTranslation.x)/MDScreenWidth];
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            //4. 结束后确认切换到的tap
            MDUnifiedRecordLevelType type = self.selectedTap;
            if (_acturalTranslation.x >= MDScreenWidth/5) {
                type = [self.bottomView getPreLevelType];
                
            }  else if (_acturalTranslation.x < -MDScreenWidth/5) {
                type = [self.bottomView getNextLevelType];
            }
            
            [self scrollEndToLevelType:type];
            _acturalTranslation = CGPointZero;
            break;
        }
        default:
            break;
    }
}

- (void)didClicButtonWithType:(MDUnifiedRecordLevelType)levelType {
    //pan手势有效的情况下, 点击事件失效
    if (!CGPointEqualToPoint(_acturalTranslation,  CGPointZero)) {
        return;
    }
    
    //当前页面是否允许切换操作
    if (![self isEnableSwitch]) {
        return;
    }
    
    //当前页面是否允许切换到对应tap
    if (levelType == MDUnifiedRecordLevelTypeHigh && ![self checkCanRecording]) {
        return;
    }
    
    //开始切换前，同步设置参数
    [self scrollWillBegin];
    
    [self scrollEndToLevelType:levelType];
}


- (void)scrollWillBegin {
    //同步设置参数
    [self.containerView syschronizaRightView];
}

- (BOOL)isScrollHandledWithOffset:(CGFloat)offset
{
    if (self.settingItem.accessSource == MDVideoRecordAccessSource_QuickMatch ||
        self.settingItem.accessSource == MDVideoRecordAccessSource_GroupFeed ||
        self.settingItem.accessSource == MDVideoRecordAccessSource_Feed_photo ||
        self.settingItem.accessSource == MDVideoRecordAccessSource_SoulMatch) {
        return NO;
    }
    
    BOOL isHandled = NO;
    if (offset > 0 && _settingItem.levelType==MDUnifiedRecordLevelTypeHigh) {
        isHandled = YES;
        [self.containerView showTopViewWithOffset:offset];
        
    } else if (offset<0 && _settingItem.levelType==MDUnifiedRecordLevelTypeNormal) {
        
        if (![self checkCanRecording]) {
            isHandled = NO;
            
        } else {
            isHandled = YES;
            [self.containerView showTopViewWithOffset:offset];
        }
    }
    
    return isHandled;
}
- (void)scrollEndToLevelType:(MDUnifiedRecordLevelType)toType {
    
    //动画结束
    [self handleEventWhenDidScrollEndWithLevelType:toType];
    
    //开始底部切换动画
    [self.bottomView updateLayoutWithSelectedTap:toType];
//    [[MDContext currentUser].dbStateHoldProvider setLastMomentRecordLevel:toType];
}


- (void)handleEventWhenDidScrollEndWithLevelType:(MDUnifiedRecordLevelType)levelType
{
    self.settingItem.levelType = levelType;

    //UI更新
    [self.containerView setCurrentTopViewWithLevelType:levelType animated:YES];
    [self.containerView setRecordBtnType:levelType];
    [self.containerView highMiddleBottomViewShow:(levelType == MDUnifiedRecordLevelTypeHigh) animated:YES];
    
    if (levelType == MDUnifiedRecordLevelTypeNormal) {
        [self.containerView normalRecordBtnTipViewShow:YES animated:YES];
        self.containerView.loadingTipView.hidden = NO;
    } else {
        [self.containerView normalRecordBtnTipViewShow:NO animated:NO];
        self.containerView.loadingTipView.hidden = YES;
    }
    
    //变速根据不同拍摄界面设置
    if (levelType == MDUnifiedRecordLevelTypeNormal) {
        [self.moduleAggregate speedVaryShouldAllow:YES];
    } else {
        [self.moduleAggregate speedVaryShouldAllow:YES];
    }
    
    
    //下载自动配乐
    if (levelType == MDUnifiedRecordLevelTypeHigh) {
        [self.moduleAggregate activateAutoMusicWithMusicItem:_settingItem.musicItem needSameStyle:_settingItem.isAllowedSameStyle];
    }
    
    //做引导动画
//    [self.containerView doGuideAnimationWithLevelType:levelType];
    
    
    //重新设置闪光灯
    [self.moduleAggregate setFlashMode:self.moduleAggregate.currentFlashMode];
    
    //录制最大时长更新
    self.maxRecordDuration = [self maxRecordDurationWithLevelType:levelType];
    [self.moduleAggregate updateRecordMaxDuration:self.maxRecordDuration];
    
    //配乐根据不同拍摄界面设置
    if (levelType == MDUnifiedRecordLevelTypeNormal) {
        [self.moduleAggregate musicPlayShouldAllow:YES];
    } else {
        [self.moduleAggregate musicPlayShouldAllow:YES];
    }
    
    //如果已经切到高级拍摄且当前在拍摄按钮中的变脸正在下载,变脸推荐栏滚到1号位，空变脸
    if (levelType == MDUnifiedRecordLevelTypeHigh && [self.moduleAggregate isLoadingOfCurrentSelectedFace]) {
        [self.moduleAggregate selectEmptyFaceItem];
    }
}

#pragma mark - category call
- (void)handleRotate:(UIDeviceOrientation)orientation needResponse:(BOOL)needResponse
{
    if (needResponse) {
        [self.moduleAggregate setOutputOrientation:orientation];
        [self.containerView handleViewRotate:orientation];
    }
}

#pragma mark - 来自相册
- (void)setFromAlbum:(BOOL)fromAlbum{
    _fromAlbum = fromAlbum;
}

#pragma mark - MDNavigationBarAppearanceDelegate
- (UINavigationBar *)md_CustomNavigationBar {
    return nil;
}

@end
