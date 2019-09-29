//
//  MDUnifiedRecordCoordinator.m
//  MDChat
//
//  Created by 符吉胜 on 2017/7/19.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordCoordinator.h"
#import "MDUnifiedRecordContainerView.h"
#import "MDUnifiedRecordViewController.h"
#import "MDUnifiedRecordModuleAggregate.h"
#import "MDBluredProgressView.h"
#import "MDUnifiedRecordSettingItem.h"
#import "MDRecordVideoResult.h"
#import "MDRecordImageResult.h"

//拍照相关
#import "MDImageClipAndScaleViewController.h"
#import "MDImageEditorViewController.h"
#import "MDPhotoLibraryProvider.h"

#import "MDMediaEditorSettingItem.h"
#import "MDNewMediaEditorViewController.h"

#import "Toast/Toast.h"
@import RecordSDK;
#import "MDRecordVideoSettingManager.h"
#import "MDRecordRecordingSettingMananger.h"

static const NSInteger  kMaxVideoRecordTipShowTimes     = 3;
static NSString * const kVideoRecordTipString           = @"换个场景拍一拍";

@interface MDUnifiedRecordCoordinator()
<
    MDUnifiedRecordModuleAggregateDelegate,
    MDImageClipAndScaleViewControllerDelegate
>

@property (nonatomic,  weak) MDUnifiedRecordContainerView   *containerView;
@property (nonatomic, strong) MDBluredProgressView          *processingHUD;

@property (nonatomic,  weak) MDUnifiedRecordModuleAggregate *moduleAggregate;
@property (nonatomic,strong) MDUnifiedRecordSettingItem     *settingItem;

@property (nonatomic,assign) BOOL                           isFirstPause;
//图片打点模型
@property (nonatomic,strong) MDImageUploadParamModel        *imageUploadModel;

@property (nonatomic, assign) BOOL                          didRecordAnalysis;//拍摄动作是否已经打点

@end

@implementation MDUnifiedRecordCoordinator

- (void)dealloc
{
    NSLog(@"MDUnifiedRecordCoordinator dealloc");
}

- (instancetype)initWithContainerView:(MDUnifiedRecordContainerView *)containerView
                          settingItem:(MDUnifiedRecordSettingItem *)settingItem
                      moduleAggregate:(MDUnifiedRecordModuleAggregate *)moduleAggregate
{
    if (self = [self init]) {
        _settingItem = settingItem;
        _containerView = containerView;
        _moduleAggregate = moduleAggregate;
        _moduleAggregate.delegate = self;
        
        _isFirstPause = YES;
    }
    return self;
}

#pragma mark - MDUnifiedRecordModuleAggregateDelegate
- (void)captureSessionDidStartOrStop:(BOOL)isStart
{
    [self.containerView setRecordBtnEnable:isStart];
}

- (void)didStartRecording
{
    //开始录制后不可替换音乐
    [self.containerView musicViewShow:NO animated:YES];
    //如果是延时拍摄应该关闭动画
    BOOL animated = (self.moduleAggregate.countDownType == MDVideoRecordCountDownType_None);
    [self.containerView updateForVideoRecording:YES animated:animated];
    
    if (_moduleAggregate.isArDecoration) {
        self.containerView.slidingFilterView.userInteractionEnabled = YES;
    }
    
    //打点
    if (!self.didRecordAnalysis) {
        self.didRecordAnalysis = YES;
//        [MDActionManager handleLocaRecord:@"start_take_video_click"];
    }
}

- (void)didPauseRecording
{
    [self.containerView updateForVideoRecording:NO animated:YES];
}

- (void)didCancelRecording
{
    [self.containerView updateForVideoRecording:NO animated:YES];
}

- (void)willStopRecording
{
    [self parentVcBottomViewShouldShow:YES animated:NO];
    [self.containerView setRecordBtnEnable:NO];
    [self.containerView setEditButtonEnable:NO];
    [self.containerView updateForVideoRecording:NO animated:NO];
}

- (void)didStopRecordingWithError:(NSError *)error
                     videoFileURL:(NSURL *)videoFileURL
                        musicItem:(MDMusicCollectionItem *)musicItem
                   musicTimeRange:(CMTimeRange)musicTimeRange
                      videoResult:(MDRecordVideoResult *)videoResult
                    soundPitchURL:(NSURL *)soundPitchURL
                  soundEnergyRank:(NSInteger)soundEnergyRank
{
    if (!error) {
        videoResult.topicID = self.settingItem.topicId;
        videoResult.themeID = self.settingItem.themeId;
        videoResult.videoRecordSource  = (self.settingItem.levelType == MDUnifiedRecordLevelTypeHigh) ? 10 : 0;
        videoResult.accessSource = self.settingItem.accessSource;
        videoResult.isNeedSameStyle = self.settingItem.isAllowedSameStyle;
        videoResult.followVideoId = self.settingItem.followVideoId;
        videoResult.hasPerSpeedEffect = self.moduleAggregate.hasPerSpeedEffect;

        if (_settingItem.levelType == MDUnifiedRecordLevelTypeNormal) {
            musicItem = nil;
            musicTimeRange = kCMTimeRangeZero;
        }
        
        //跳转到编辑页
        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoFileURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)}];

        AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        CMTimeRange videoTimeRange = videoTrack.timeRange;
        [self _handleResultInfo:videoResult editAsset:videoAsset timeRange:videoTimeRange];
        
        MDMediaEditorSettingItem *mediaEditorSetting = [[MDMediaEditorSettingItem alloc] init];
        mediaEditorSetting.videoAsset = videoAsset;
        mediaEditorSetting.videoTimeRange = videoTimeRange;
        mediaEditorSetting.backgroundMusicItem = musicItem;
        mediaEditorSetting.backgroundMusicURL = musicItem.resourceUrl;
        mediaEditorSetting.backgroundMusicTimeRange = musicTimeRange;
        mediaEditorSetting.maxUploadDuration = self.settingItem.maxUploadDurationOfScene;
        mediaEditorSetting.doneButtonTitle = self.settingItem.doneBtnText;
        mediaEditorSetting.videoInfo = videoResult;
        mediaEditorSetting.hideTopicEntrance = self.settingItem.hideTopicEntrance;
        mediaEditorSetting.lockTopic = self.settingItem.lockTopic;
        mediaEditorSetting.soundPitchURL = soundPitchURL;
        mediaEditorSetting.needWaterMark = self.settingItem.needWaterMark;
        mediaEditorSetting.maxThumbImageSize = (self.settingItem.accessSource == MDVideoRecordAccessSource_QVProfile ? 1280 : 640);
        
        mediaEditorSetting.isFaceCaptured = self.moduleAggregate.isFaceCaptured;
        mediaEditorSetting.isDetectorBareness = self.moduleAggregate.isDetectorBareness;
        mediaEditorSetting.supportMultiSegmentsRecord = [self supportMultiSegmentsRecord];
        mediaEditorSetting.fromAlbum = NO;
        mediaEditorSetting.completeBlock = ^ (id videoInfo) {
            //记录用户是否应用了变脸
//            [[[MDContext currentUser] dbStateHoldProvider] setHasEverUseFaceDecoration:(self.moduleAggregate.selectedDecoration != nil)];
            
            [self.moduleAggregate resetRecorder];
            [self.moduleAggregate clearStashVideo];
            
            if (self.settingItem.completeHandler) {
                self.settingItem.completeHandler(videoInfo);
            }
        };
        
        MDRecordVideoSettingManager.exportBitRate = MDRecordRecordingSettingMananger.bitRate;
        MDRecordVideoSettingManager.exportFrameRate = MDRecordRecordingSettingMananger.frameRate;
        MDNewMediaEditorViewController *vc = [[MDNewMediaEditorViewController alloc] initWithSettingItem:mediaEditorSetting];
        [self.viewController.navigationController pushViewController:vc animated:YES];
        
        
    } else {
        // 错误提示并且关闭页面 window
        [[MDRecordContext appWindow] makeToast:@"录制失败" duration:1.5f position:CSToastPositionCenter];
        self.settingItem.completeHandler(nil);
    }
    
    [self hideProcessingHUD];
    _processingHUD = nil;
    [self.containerView setRecordBtnEnable:YES];
    
    if (![self supportMultiSegmentsRecord]) {
        [self.moduleAggregate resetRecorder];
    }
    
    [self.containerView setEditButtonEnable:YES];
}

- (void)_handleResultInfo:(MDRecordVideoResult *)videoResult editAsset:(AVURLAsset *)asset timeRange:(CMTimeRange)timeRange {
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize presentationSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    presentationSize.width = ABS(presentationSize.width);
    presentationSize.height = ABS(presentationSize.height);
    
    videoResult.editVideoDuration = CMTimeGetSeconds(asset.duration);
    videoResult.editVideoNaturalWidth = presentationSize.width;
    videoResult.editVideoNaturalHeight = presentationSize.height;
    videoResult.editVideoBitRate = [track estimatedDataRate];
    videoResult.editVideoFrameRate = [track nominalFrameRate];
    
    NSDictionary *resourceValues = [asset.URL resourceValuesForKeys:@[NSURLFileSizeKey,NSURLTotalFileSizeKey] error:nil];
    videoResult.editVideoFileSize = [resourceValues longLongValueForKey:NSURLFileSizeKey defaultValue:0] ?: [resourceValues longLongValueForKey:NSURLTotalFileSizeKey defaultValue:0];
}

- (void)didRecordProgressChange:(CGFloat)progress
{
    [self parentVcBottomViewShouldShow:isFloatEqual(progress, 0.0) animated:YES];
    
    if (_settingItem.levelType == MDUnifiedRecordLevelTypeHigh) {
        [self.containerView.progressView setProgress:progress];
        
        if (isFloatEqual(progress, 0.f)) {
            [self.containerView setRecordDurationLabelTextWithSecond:0];
            [self.containerView setRecordDurationLabelAlpha:0.0f];
        } else {
            [self.containerView setRecordDurationLabelTextWithSecond:self.moduleAggregate.currentRecordDuration];
        }
        
    } else if (_settingItem.levelType == MDUnifiedRecordLevelTypeNormal) {
        [self.containerView setRecordBtnProgress:progress];
    }
}

- (void)didRecordFinishWithProgress:(CGFloat)progress
{
    if (!self.processingHUD) {
        [self showProcessingHUD];
    }
    
    if (progress >= 1) {
        [self hideProcessingHUD];
    } else {
        [self updateProcessing:progress];
    }
}

- (void)didRecordSegmentChangedWithDurations:(NSArray *)durations presentDurations:(NSArray *)presentDurations valid:(BOOL)valid
{
    [self handleRecordSegmentChanged:durations presentDurations:presentDurations valid:valid];
}

- (void)didRecordReachMaxDuration
{
    //单段拍摄直接跳转编辑页
    if (self.moduleAggregate.savedSegmentCount <= 1) {
        [self.moduleAggregate stopRecording];
    } else {
        //多段拍摄本页停留
        [self.containerView updateForVideoRecording:NO animated:NO];
    }
}

- (void)didRotateCamera
{
    [self.containerView switchFlashLightAfterRotateCamera];
}

- (void)didSwitchToArDecoration:(BOOL)isArDecoration
{
    self.containerView.slidingFilterView.scrollEnabled = !isArDecoration;
}

- (void)didSwitchToMDCameraSourceType:(MDRecordCameraSourceType)cameraSourceType
{
    CGFloat alpha = 1.0f;
    if (cameraSourceType == MDRecordCameraSourceType_ARKIT) {
        alpha = 0.0f;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.containerView.currentTopView.flashLightView.alpha = alpha;
        self.containerView.currentTopView.switchCameraView.alpha = alpha;
    }];
}

- (void)didFocusCameraInPoint:(CGPoint)point
{
//    self.containerView.cameraFocusView.center = point;
//    self.containerView.cameraFocusView.hidden = NO;
//    [UIView animateWithDuration:0.2 animations:^{
//        self.containerView.cameraFocusView.transform = CGAffineTransformMakeScale(0.8, 0.8);
//    }completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.3 animations:^{
//            self.containerView.cameraFocusView.transform = CGAffineTransformIdentity;
//        } completion:^(BOOL finished) {
//            self.containerView.cameraFocusView.hidden = YES;
//        }];
//    }];
    
    self.containerView.exposureSlider.center = point;
    self.containerView.exposureSlider.hidden = NO;
    [UIView animateKeyframesWithDuration:0.1 delay:0.0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.4 animations:^{
            self.containerView.exposureSlider.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.6 animations:^{
            self.containerView.exposureSlider.transform = CGAffineTransformIdentity;
        }];
    } completion:nil];
}

- (void)didStopCaptureStillImage:(UIImage *)image imageUploadModel:(MDImageUploadParamModel *)imageUploadModel
{
    _imageUploadModel = imageUploadModel;
    if (self.settingItem.accessSource == MDVideoRecordAccessSource_Profile || self.settingItem.accessSource == MDVideoRecordAccessSource_QVProfile || self.settingItem.accessSource == MDVideoRecordAccessSource_SoulMatch ||
        self.settingItem.accessSource == MDVideoRecordAccessSource_RegLogin) {
        [self goToImageCutViewWithImage:image];
        
    } else {
        [self goToImageEditorWithImage:image];
    }
}

- (void)didGetFilters:(NSArray<MDRecordFilter *> *)filters
{
    [self.containerView.slidingFilterView setFilters:filters];
    self.containerView.slidingFilterView.currentPageIndex = 0;
}

- (void)didSeletetedFilterIndex:(NSInteger)filterIndex
{
    [self.containerView.slidingFilterView setCurrentPageIndex:filterIndex];
}

- (void)didShowFilter:(MDRecordFilter *)filter
{
    [self.containerView showFilterNameTipAnimateWithText:filter.name];
    [self.containerView.currentRightView didShowFilter:filter];
}

- (void)didCloseMusicPickerControllerWithItem:(MDMusicCollectionItem *)item;
{
    [self.containerView.rightViewForHigh didSelectMusicTitle:item.musicVo.title];
    [self.containerView.rightViewForNormal didSelectMusicTitle:item.musicVo.title];
}

- (void)didResetMusicPicker
{
    [self.containerView.rightViewForHigh didSelectMusicTitle:nil];
    [self.containerView.rightViewForNormal didSelectMusicTitle:nil];
}

- (void)didResetFaceDecoration
{
   [self.containerView showFaceDecorationTip:nil]; 
}

- (void)didGetFaceDecorationTip:(NSString *)tip
{
    [self.containerView showFaceDecorationTip:tip];
}

- (void)startLoadingFaceDecoration
{
    //屏蔽录制按钮的交互事件
    [self.containerView setRecordBtnEnable:NO];
    
    [self.containerView normalRecordBtnTipViewShow:NO animated:NO];
    self.containerView.loadingTipView.text = @"下载中";
    [self.containerView loadingTipViewShow:YES animated:YES];
}

- (void)endLoadingFaceDecoration
{
    [self.containerView setRecordBtnEnable:YES];
    
    [self.containerView loadingTipViewShow:NO animated:NO];
    [self.containerView normalRecordBtnTipViewShow:YES animated:YES];
}

- (void)loadingFaceDecorationFail
{
    [self.containerView setRecordBtnEnable:YES];
    self.containerView.loadingTipView.text = @"下载失败";
}

- (void)moduleViewWillShowOrHide:(BOOL)isShow
{
    CGFloat alpha = isShow ? 0.0 : 1.0;
    [self.containerView setBottomViewAlpha:alpha];
    [self.containerView highMiddleBottomViewShow:!isShow animated:YES];
}

- (void)moduleViewDidShowOrHide:(BOOL)isShow
{
    [self parentVcBottomViewShouldShow:!isShow animated:YES];
}

- (void)didStartCountDownAnimation
{
    [self parentVcBottomViewShouldShow:NO animated:NO];
    [self.containerView updateForCountDownAnimation:YES];
    [self.containerView setDelayCloseViewHidden:NO];
}

- (void)didFinishCountDownAnimation:(BOOL)isFinish
{
    [self.containerView updateForCountDownAnimation:NO];
    [self.containerView setDelayCloseViewHidden:YES];
    
    if (isFinish) {
        if (_settingItem.levelType == MDUnifiedRecordLevelTypeHigh) {
            [self.containerView topViewShow:NO animated:NO];
            [self.moduleAggregate startRecording];
        } else {
            [self.moduleAggregate captureStillImage];
            [self parentVcBottomViewShouldShow:YES animated:NO];
        }
        
    } else {
        [self parentVcBottomViewShouldShow:YES animated:YES];
    }
}

- (void)didSwitchToCountDownType:(MDVideoRecordCountDownType)countDownType
{
    UIImage *img = nil;
    
    switch (countDownType) {
        case MDVideoRecordCountDownType_None:
        {
            img = [UIImage imageNamed:@"delayTime"];
            break;
        }
        case MDVideoRecordCountDownType_3:
        {
            img = [UIImage imageNamed:@"count_down_on_three"];
            break;
        }
        case MDVideoRecordCountDownType_10:
        {
            img = [UIImage imageNamed:@"count_down_on_ten"];
            break;
        }
    }
    [self.containerView setCountDownViewWithImage:img];
}

- (void)didSwitchToFlashMode:(MDRecordCaptureFlashMode)flashMode
{
    [self.containerView setFlashViewImageWithFlashMode:flashMode];
}

#pragma mark - 拍照相关
//编辑图片
- (void)goToImageEditorWithImage:(UIImage *)originImage
{
    //拍摄完成后进入编辑页面
    __weak typeof(self) weakSelf = self;
    MDImageEditorViewController *imageEditorVC = [[MDImageEditorViewController alloc] initWithImage:originImage completeBlock:^(UIImage *image, BOOL isEdited) {
        
        if (weakSelf.settingItem.completeHandler) {
            MDRecordImageResult *imageResult = [[MDRecordImageResult alloc] init];
            imageResult.fromAlbum = NO;
            
            MDPhotoItem *photoItem = [[MDPhotoItem alloc] init];
            photoItem.type = MDPhotoItemTypeImage;
            photoItem.originImage = image;
            photoItem.imageUploadParamModel = weakSelf.imageUploadModel;
            imageResult.photoItems = @[photoItem];
            weakSelf.settingItem.completeHandler(imageResult);
            
            //拍摄的图片，如果已编辑过则在编辑页面保存
            if (!isEdited) {
                //异步保存拍摄的未编辑的图片
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [PHPhotoLibrary savePhoto:image toAlbumWithName:@"VideoSDK" completion:NULL];
                });
            }
            
            //记录用户是否应用了变脸
//            [[[MDContext currentUser] dbStateHoldProvider] setHasEverUseFaceDecoration:(weakSelf.moduleAggregate.selectedDecoration != nil)];
        }
    }];
    imageEditorVC.imageUploadParamModel = self.imageUploadModel;
    
    __weak MDImageEditorViewController *weakImageEditorVC = imageEditorVC;
    imageEditorVC.cancelBlock = ^(BOOL isEdit) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"要放弃该图片吗?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf popBackToSelfWithAnimated:NO];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        
        [weakImageEditorVC presentViewController:alertController animated:YES completion:nil];
    };
    
    imageEditorVC.doneButtonTitle = self.settingItem.doneBtnText;
    [self.viewController.navigationController pushViewController:imageEditorVC animated:YES];
}

//裁剪图片
- (void)goToImageCutViewWithImage:(UIImage *)originImage
{
    if(self.settingItem.photoTypeSelectedCompleted) {
        self.settingItem.photoTypeSelectedCompleted(MDRegLoginSelectImageTypeTakePhoto);
    }
    
    //拍摄完成后进入裁剪页面
    MDImageClipAndScaleViewController *imageCutController = [[MDImageClipAndScaleViewController alloc] initWithImage:originImage];
    imageCutController.delegate = (id<MDImageClipAndScaleViewControllerDelegate>)self;
    imageCutController.imageClipScale = self.settingItem.imageClipScale;
    [self.viewController.navigationController pushViewController:imageCutController animated:YES];
}

- (void)popBackToSelfWithAnimated:(BOOL)animated {
    if ([self.viewController.parentViewController isKindOfClass:[UINavigationController class]]) {
        [self.viewController.navigationController popToViewController:self.viewController animated:animated];
    }else {
        [self.viewController.navigationController popToViewController:self.viewController.parentViewController animated:animated];
    }
}

#pragma mark - MDImageClipAndScaleViewControllerDelegate
-(void)clipControllerDidCancel:(MDImageClipAndScaleViewController *)controller
{
    [controller.navigationController popViewControllerAnimated:YES];
}

-(void)clipController:(MDImageClipAndScaleViewController *)controller didClipImage:(UIImage *)image
{
    [self goToImageEditorWithImage:image];
}

#pragma mark - 多段录制：段数更新的UI变化
- (void)handleRecordSegmentChanged:(NSArray *)durations presentDurations:(NSArray *)presentDurations valid:(BOOL)valid
{
    if ([self supportMultiSegmentsRecord]) {
        [self handleRecordSegmentChangedForHighLevelWithDurations:durations presentDurations:presentDurations valid:valid];
    } else {
        [self handleRecordSegmentChangedForNormalLevelWithDurations:durations presentDurations:presentDurations valid:valid];
    }
}

- (void)handleRecordSegmentChangedForNormalLevelWithDurations:(NSArray *)durations presentDurations:(NSArray *)presentDurations valid:(BOOL)valid
{
    NSString *toastStr = [_settingItem.alertForDurationTooShort isNotEmpty] ? _settingItem.alertForDurationTooShort : @"拍摄时间过短";
    
    if (!valid) {
        [[MDRecordContext appWindow] makeToast:toastStr duration:1.5f position:CSToastPositionCenter];
        [self parentVcBottomViewShouldShow:YES animated:YES];
        [self.containerView topViewShow:YES animated:YES];
        
    } else {
        if (durations.count) {
            if (self.moduleAggregate.currentRecordDurationBiggerThanMinDuration) {
                [self.moduleAggregate.pitchNumbers addObjectSafe:@([self.moduleAggregate soundPitchNumber])];
                [self.moduleAggregate stopRecording];
            } else {
                [[MDRecordContext appWindow] makeToast:toastStr duration:1.5f position:CSToastPositionCenter];
                [self.moduleAggregate deleteLastSavedSegment];
                [self.moduleAggregate.pitchNumbers removeLastObject];
                [self parentVcBottomViewShouldShow:YES animated:YES];
            }
            
        } else {
            [self.containerView updateForVideoRecording:NO animated:YES];
            [self.moduleAggregate.pitchNumbers removeAllObjects];
        }
    }
}

- (void)handleRecordSegmentChangedForHighLevelWithDurations:(NSArray *)durations presentDurations:(NSArray *)presentDurations valid:(BOOL)valid
{
    NSString *toastStr = [_settingItem.alertForDurationTooShort isNotEmpty] ? _settingItem.alertForDurationTooShort : @"拍摄时间过短";
    
    [self.containerView setDeleSegmentViewEnable:NO];
    
    NSNumber *duration = durations.lastObject;
    if (!valid) {
        [[MDRecordContext appWindow] makeToast:toastStr duration:1.5f position:CSToastPositionCenter];
        
    } else if (duration && _isFirstPause) {
        //只有高级拍摄才有断点提示
        [self showRecordTipString];
    }

    if (durations.count < self.moduleAggregate.pitchNumbers.count) {
        [self.moduleAggregate.pitchNumbers removeLastObject];
    } else if (durations.count > self.moduleAggregate.pitchNumbers.count) {
        [self.moduleAggregate.pitchNumbers addObjectSafe:@([self.moduleAggregate soundPitchNumber])];
    }
    
    if (!durations.count) {
        [self.containerView setDeleSegmentViewAlpha:.0f];
        [self.containerView setHighRecordBtnTipViewTextWithDeleteSelected:NO];
        [self.containerView setBottomAlbumButtonHidden:NO];
        
        [self.containerView musicViewShow:YES animated:YES];
        [self parentVcBottomViewShouldShow:YES animated:YES];

        [self.containerView topViewShow:YES animated:YES];
        [self.moduleAggregate.pitchNumbers removeAllObjects];
    }
    
    [self.containerView setEditButtonEnableEvent:self.moduleAggregate.currentRecordDurationBiggerThanMinDuration];
    
    NSMutableArray *progress = [NSMutableArray array];
    for (NSNumber *duration in presentDurations) {
        double durationPercent = [duration doubleValue] / self.moduleAggregate.recordDuration;
        [progress addObjectSafe:[NSNumber numberWithDouble:durationPercent]];
    }
    
    //视频片段更改后重置删除按钮和进度条状态
    [self.containerView setHighRecordBtnTipViewTextWithDeleteSelected:NO];
    [self.containerView setDeleSegmentViewSelected:NO];
    self.containerView.progressView.hilighted = NO;
    [self.containerView.progressView refreshSegmentsAppearrence:progress];
    [self.containerView setDeleSegmentViewEnable:YES];
}

- (void)showRecordTipString
{
    self.isFirstPause = NO;
    NSInteger tipCount = 0; //[[[MDContext currentUser] dbStateHoldProvider] videoRecordTipCount];
    
    //检查是否已经展示过断点续拍的提示信息
    if (tipCount < kMaxVideoRecordTipShowTimes && self.moduleAggregate.canStartRecording) {
        [[MDRecordContext appWindow]  makeToast:kVideoRecordTipString duration:1.5f position:CSToastPositionCenter];
//        [[[MDContext currentUser] dbStateHoldProvider] setVideoRecordTipCount:(tipCount+1)];
    }
}

//合成进度条相关
#pragma mark -
- (void)setUpProgressHUD
{
    if (!_processingHUD) {
        _processingHUD = [[MDBluredProgressView alloc] initWithBlurView:[MDRecordContext appWindow] descText:@"正在处理中" needClose:NO];
        _processingHUD.progress = 0;
        [[MDRecordContext appWindow] addSubview:_processingHUD];
    }
}

- (void)showProcessingHUD
{
    if (!_processingHUD) {
        [self setUpProgressHUD];
    }
    self.processingHUD.progress = 0;
    if (_processingHUD.superview) {
        [[MDRecordContext appWindow] bringSubviewToFront:self.processingHUD];
    } else {
        [[MDRecordContext appWindow] addSubview:_processingHUD];
    }
    [self.processingHUD setHidden:NO];
}

- (void)hideProcessingHUD
{
    _processingHUD.progress = 1;
    [_processingHUD setHidden:YES];
}

- (void)updateProcessing:(CGFloat)process
{
    _processingHUD.progress = process;
}

#pragma mark - 辅助方法
- (void)parentVcBottomViewShouldShow:(BOOL)shouldShow animated:(BOOL)animated
{
    if (!self.viewController.bottomView) return;
    
    BOOL isModuleViewShowed = [self.moduleAggregate isModuleViewShowed];
    BOOL isBottomViewHidden = [self.viewController isBottomViewHidden];
    
    if (shouldShow && isBottomViewHidden && !isModuleViewShowed) {
        if (_settingItem.levelType == MDUnifiedRecordLevelTypeNormal) {
            [self.viewController showBottomViewWithAnimation:animated];
        }else if ( isFloatEqual(self.moduleAggregate.currentRecordDuration, 0.0f) ) {
            [self.viewController showBottomViewWithAnimation:animated];
        }
    }
    else if (!shouldShow && !isBottomViewHidden){
        [self.viewController hideBottomViewWithAnimation:animated];
    }
}

- (BOOL)supportMultiSegmentsRecord {
    return _settingItem.levelType == MDUnifiedRecordLevelTypeHigh;
}


@end
