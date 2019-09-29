//
//  MDNewMediaEditorViewController.m
//  MDChat
//
//  Created by 符吉胜 on 2017/8/24.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDNewMediaEditorViewController.h"
#import "MDMediaEditorSettingItem.h"
#import "MDMediaEditorContainerView.h"
#import "MDMediaEditorCoordinator.h"
#import "MDMediaEditorModuleAggregate.h"
#import "MDRecordVideoResult.h"

#import "MDNavigationTransitionExtra.h"

static const CGFloat kCloseEditAlertTag = 100011;

@interface MDNewMediaEditorViewController ()
<
    MDMediaEditorContainerViewDelegate,
    MDMediaEditorModuleControllerDelegate,
    MDNavigationBarAppearanceDelegate,
    MDPopGestureRecognizerDelegate,
    UIAlertViewDelegate
>

@property (nonatomic,strong) MDMediaEditorSettingItem       *settingItem;
@property (nonatomic,strong) MDMediaEditorContainerView     *containerView;
@property (nonatomic,strong) MDMediaEditorModuleAggregate   *moduleAggregate;
@property (nonatomic,strong) MDMediaEditorCoordinator       *coordinator;


@property (nonatomic,assign,getter=isFirstIn) BOOL          firstIn;

@end

@implementation MDNewMediaEditorViewController

#pragma mark - life cycle
- (void)dealloc
{
//    MDLogDebug(@"%s",__func__);
}

- (instancetype)initWithSettingItem:(MDMediaEditorSettingItem *)setttingItem
{
    if (self = [super init]) {
        _settingItem = setttingItem;
        _firstIn = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupModuleAggregate];
    [self.moduleAggregate activatePlayer];
    
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if (self.isFirstIn) {
        self.firstIn = NO;
        [self.moduleAggregate preloadThumbs];
        [self.moduleAggregate preloadSpecialImage];
        
//        if (self.settingItem.qualityResult) {
//            [self.containerView addArPetAlertPopView];
//        }
    }
    
    if (![self.moduleAggregate isDoingExportOperation]) {
        [self.moduleAggregate play];
    }
    
//    [self.containerView doGuideAnimation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.moduleAggregate pause];
}

- (void)configUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _containerView = [[MDMediaEditorContainerView alloc] initWithDelegate:self whRatio:[self whRatioOfVideo]];
    [self.view addSubview:_containerView];
    [_containerView.cancelButton setTitle: self.settingItem.fromAlbum ? @"返回" : @"重拍" forState:UIControlStateNormal];
    NSTimeInterval duration = CMTimeGetSeconds(self.settingItem.videoTimeRange.duration);
    NSString *result =[self timeFormatted:duration];
    _containerView.timeLabel.text = result;
//    _containerView.qualityResult = self.settingItem.qualityResult;
    _coordinator = [[MDMediaEditorCoordinator alloc] initWithContainerView:_containerView settingItem:_settingItem moduleAggregate:_moduleAggregate];
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (void)setupModuleAggregate
{
    _moduleAggregate = [[MDMediaEditorModuleAggregate alloc] initWithController:self];
    
    [_moduleAggregate configDocumentWithVideoAsset:_settingItem.videoAsset
                                    videoTimeRange:_settingItem.videoTimeRange
                                          musicURL:_settingItem.backgroundMusicURL
                                    musicTimeRange:_settingItem.backgroundMusicTimeRange
                                         musicItem:_settingItem.backgroundMusicItem];
    [_moduleAggregate applySoudPitchFunction:_settingItem.soundPitchURL];
}

- (CGFloat)whRatioOfVideo
{
    AVAssetTrack *videoTrack = [[_settingItem.videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize presentationSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    return fabsf(presentationSize.width / presentationSize.height);
}

- (void)playVideo {
    [self.moduleAggregate play];
}

#pragma mark - MDMediaEditorModuleControllerDelegate
- (CGFloat)maxUploadDuration
{
    return self.settingItem.maxUploadDuration ?: kMaxUploadDurationForGeneralScene;
}

- (BOOL)isSelectedMusic
{
    return self.settingItem.backgroundMusicURL != nil;
}

- (CGPoint)topicLayoutOrigin
{
//    return self.containerView.topicEntranceView.origin;
    return CGPointZero;
}

- (UIImage *)rendenOverlayImageForSaveMode:(BOOL)isSaveMode
{
    return [self.containerView renderOverlaySnapshot:self.containerView.costumContentView needWatermark:self.settingItem.needWaterMark];
}

- (BOOL)isNeedWaterMarkWithSaveMode:(BOOL)saveMode
{
    return (saveMode && self.settingItem.needWaterMark);
}

- (CGFloat)maxThumbImageSize
{
    return self.settingItem.maxThumbImageSize;
}

- (NSURL *)originMisicUrl {
    return self.settingItem.backgroundMusicURL;
}
- (BOOL)isFromAlbum {
    return self.settingItem.videoInfo.isFromAlbum;
}

- (BOOL)supportHighResolutionStrategy {
    return self.settingItem.videoInfo.accessSource == MDVideoRecordAccessSource_Feed ||
    self.settingItem.videoInfo.accessSource == MDVideoRecordAccessSource_Feed_video;
}


#pragma mark - MDMediaEditorContainerViewDelegate
- (void)arPetQualityCancelBlockEvent {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (CGRect)videoRenderFrame
{
    return self.moduleAggregate.videoRenderFrame;
}

- (NSString *)doneButtonTitle
{
    NSString *title = @"完成";
    if ([self.settingItem.doneButtonTitle isNotEmpty]) {
        title = self.settingItem.doneButtonTitle;
    }
    return title;
}

- (NSString *)currentTopicName
{
    if ([self.settingItem.videoInfo.topicID isNotEmpty]) {
//        self.settingItem.videoInfo.topicName = [self.moduleAggregate topicNameWithTopicId:self.settingItem.videoInfo.topicID];
//        return self.settingItem.videoInfo.topicName;
    }
    return nil;
}

- (BOOL)shouldShowTopicView
{
    return !self.settingItem.hideTopicEntrance;
}

- (BOOL)shouldReSendVideo
{
    BOOL shouldReSend = NO;
    return shouldReSend;
}

- (BOOL)isCaptureFace
{
    return _settingItem.isFaceCaptured;
}

- (void)custumContentViewTapped
{
    [self.moduleAggregate hideMusicPicker];
    [self.moduleAggregate hideFilterDrawer];
}

- (void)doneButtonTapped
{
    [self.moduleAggregate exportVideo];
}

- (void)reSendBtnTapped
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)cancelButtonTapped
{
    //fix
    if ([self.moduleAggregate isDoingExportOperation]) {
        return;
    }
    
    //回录制页
    [self.moduleAggregate pause];
    
    //从相册进来且未编辑则直接返回
    BOOL hasEdited = [self.moduleAggregate checkHasEditedVideo];
    if (self.settingItem.videoInfo.isFromAlbum && !hasEdited) {
        [self goback];
        return;
    }
    
    //支持多段合成录制的
    if (self.settingItem.supportMultiSegmentsRecord) {
        BOOL hasChanged = [self.moduleAggregate checkHasChangeVideo];
        if (hasChanged) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"继续拍摄之前的特效会被清空，是否继续？"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"继续", nil];
            alert.tag = kCloseEditAlertTag;
            [alert show];
        }else {
            [self goback];
        }
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"要放弃该视频吗"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"放弃", nil];
        alert.tag = kCloseEditAlertTag;
        [alert show];
    }
}

- (void)goback {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:NO];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showTopicSelectTable
{
//    [self.moduleAggregate activateTopicSeletedManagerWithSelectedTopic:self.containerView.topicEntranceView.textString];
}

- (void)filterButtonTapped {
    [self.moduleAggregate activateFilterDrawer2];
}

- (void)thinBodyBtnTapped
{
    // 点击打点统计
//    [MDActionManager handleLocaRecord:@"thinBody_videoEdit_click"];
    [self.moduleAggregate activateFilterDrawer];
}
- (void)specialEffectsBtnTapped
{
    [self.moduleAggregate activateSpecialEffectsVc];
}


- (void)stickerEditButtonTapped
{
    [self.moduleAggregate activateSticker];
}

- (void)textButtonTapped
{
    [self.moduleAggregate activateTextEdit];
}

- (void)audioMixButtonTapped
{
//    [MDActionManager handleLocaRecord:@"edit_music_panel_click"];
    [self.moduleAggregate activateMusicPicker];
}

- (void)thumbSelectButtonTapped
{
    [self.moduleAggregate activateThumbPicker];
}

- (void)saveButtonTapped
{
    [self.moduleAggregate saveVideo];
}

- (void)speedVaryButtonTapped
{
//    [MDActionManager handleLocaRecord:@"speed_edit_page_click"];
    [self.moduleAggregate activateSpeedVaryVc];
}

- (void)painterEditButtonTapped
{
    [self.moduleAggregate activateGraffitiEditor];
}

- (void)moreActionsBtnTapped
{
    [self.coordinator  moreActionsBtnTapped];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kCloseEditAlertTag) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self goback];
        } else {
            [self.moduleAggregate play];
        }
    }
}

#pragma mark - MDNavigationBarAppearanceDelegate
- (UINavigationBar *)md_CustomNavigationBar
{
    return nil;
}

#pragma mark - MDPopGestureRecognizerDelegate
- (BOOL)md_popGestureRecognizerEnabled
{
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
