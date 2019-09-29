//
//  MDMediaEditorModuleAggregate.m
//  MDChat
//
//  Created by 符吉胜 on 2017/8/24.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMediaEditorModuleAggregate.h"
//导出相关
#import "MDDocument.h"
#import "MDBeautySettings.h"
#import "MDMomentVideoTrimViewController.h"
#import "MDRecordVideoResult.h"
//滤镜相关
#import "MDRecordFilterDrawerController.h"
#import "MDRecordFilterModel.h"
//动态贴纸相关
#import "MDMomentExpressionViewController.h"
#import "MDMomentExpressionCellModel.h"
@import RecordSDK;
@import CXBeautyKit;

//文字编辑相关
#import "MDMomentTextOverlayEditorView.h"
#import "MDMomentTextAdjustmentView.h"
//配乐相关
#import "MDMusicEditPalletController.h"
#import "MDMusicCollectionItem.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
//封面相关
#import "MDMomentThumbDataManager.h"
#import "MDMomentThumbSelectViewController.h"
//涂鸦相关
#import "BBMediaGraffitiEditorViewController.h"
//变速相关
#import "MDVideoSpeedVaryViewController.h"
//特效滤镜相关
#import "MDSpecialEffectsController.h"
#import "MDRecordSpecialImageDataManager.h"
#import "MDRecordSpecialEffectsManager.h"

#import "MDRecordFilterModelLoader.h"

#import "Toast/Toast.h"
#import "MDRecordVideoSettingManager.h"

#import "MDRStickerViewController.h"

static const NSInteger kMaxImageStickerCount = 20;

@interface MDMediaEditorModuleAggregate()
<
    MDMomentThumbSelectDelegate,
    MDMomentThumbDataManagerDelegate,
    MDVideoSpeedVaryDelegate,
    MDRecordFilterDrawerControllerDelegate,
    MDSpecialEffectsControllerDelegate,
    MDRecordSpecialImageDataManagerDelegate,
    MDMusicEditPalletControllerDelegate,
    MDRStickerViewControllerDelegate
>

@property (nonatomic, weak) UIViewController<MDMediaEditorModuleControllerDelegate>   *viewController;
//播放相关
@property (nonatomic, strong) NSURL                                 *soundPitchURL;
//导出相关
@property (nonatomic, strong) MDDocument                            *document;
@property (nonatomic, assign) CGFloat                               maxUploadDuration;
@property (nonatomic, assign) BOOL                                  saveMode;      //下载或上传
@property (nonatomic, assign,getter=isExporting) BOOL               exporting;
//滤镜相关
@property (nonatomic,  copy) NSArray<MDRecordFilter *>                *filters;
@property (nonatomic, strong) NSArray<MDRecordFilterModel *>            *filterModels;
@property (nonatomic, strong) MDRecordFilterDrawerController        *filterDrawerController;
@property (nonatomic, strong) NSMutableDictionary                   *beautySettingDict;
@property (nonatomic, strong) NSMutableDictionary                   *realBeautySettingDict;
@property (nonatomic, assign) NSInteger                             filterIndex;
//动态贴纸相关
//@property (nonatomic, strong) MDMomentExpressionViewController      *stickerChooseController;
@property (nonatomic, strong) MDRStickerViewController *stickerViewController;
//文字编辑相关
@property (nonatomic, strong) NSMutableArray                        *textStickers;
@property (nonatomic, strong) MDMomentTextOverlayEditorView         *textEditView;
//配乐相关
@property (nonatomic, strong) MDMusicEditPalletController           *musicSelectPicker;
@property (nonatomic, assign) BOOL                                  didChangeMusic; //是否换过音乐
//封面相关
@property (nonatomic, strong) MDMomentThumbDataManager              *thumbDataManager;
@property (nonatomic, assign) BOOL                                  coverLoaded;
@property (nonatomic,   copy) AVAsset                               *coverCopyedAsset;
@property (nonatomic, strong) UIImage                               *originVideoCover;
@property (nonatomic, assign) NSInteger                             originVideoCoverIndex;
//涂鸦相关
@property (nonatomic, strong) UIImage                               *initialGraffitiCanvasImage;
@property (nonatomic, assign) BOOL                                  hasGraffiti;
//变速相关
@property (nonatomic, strong) MDVideoSpeedVaryViewController        *speedVaryVc;
//特效滤镜相关
@property (nonatomic, strong) MDSpecialEffectsController            *specialEffectsVc;
@property (nonatomic, strong) MDRecordSpecialImageDataManager       *specialImageManager;
@property (nonatomic, strong) NSOperation                           *reserveOperation;


//是否已经编辑过（贴纸、文字、配乐、变速、涂鸦）
@property (nonatomic, assign) BOOL                                  isBackground;

@property (nonatomic, strong) id<MDCancellable> exportTask;
@property (nonatomic, strong) MDVideoEditorAdapter *adapter;

@property (nonatomic, assign) NSInteger currentFilterIndex;

@property (nonatomic, strong) NSMutableArray<MDRecordDynamicSticker *> *tmpDynamicStickers;

@end

@implementation MDMediaEditorModuleAggregate

- (MDVideoEditorAdapter *)adapter {
    if (!_adapter) {
        _adapter = [[MDVideoEditorAdapter alloc] initWithToken:@""];
    }
    return _adapter;
}

- (void)dealloc
{
//    [self.context pause];
    [self pause];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //清除变声后的文件
    if (_soundPitchURL && [[NSFileManager defaultManager] fileExistsAtPath:_soundPitchURL.path]) {
        [[NSFileManager defaultManager] removeItemAtPath:_soundPitchURL.path error:nil];
    }
}

- (instancetype)initWithController:(UIViewController<MDMediaEditorModuleControllerDelegate> *)viewController
{
    if (self = [self init]) {
        _viewController = viewController;
        
        [self addNotifiations];
        
        [self activateSlidingFilters];
        
        _tmpDynamicStickers = [NSMutableArray array];
    }
    return self;
}

- (void)configDocumentWithVideoAsset:(AVAsset *)videoAsset
                      videoTimeRange:(CMTimeRange)videoTimeRange
                            musicURL:(NSURL *)musicURL
                      musicTimeRange:(CMTimeRange)musicTimeRange
                           musicItem:(MDMusicCollectionItem *)musicItem
{
    
    __weak typeof(self) weakself = self;
    self.adapter.playToEndTime = ^(AVPlayer * _Nonnull player) {
        __strong typeof(self) self = weakself;
        if (![self.speedVaryVc isViewVisible] && self.exportTask == nil && !self.specialEffectsVc.isShow) {
            [player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [self play];
        }
    };
    
    self.adapter.playerPeriodicTimeCallback = ^(CMTime time) {
        __strong typeof(self) self = weakself;
        if ([self.musicSelectPicker viewIsShowing]) {
            [self.musicSelectPicker periodicTimeCallback:time];
        }
    };
    
    [self.adapter enableAIBeauty:YES];
    
    self.document = [[MDDocument alloc] initWithAsset:videoAsset documentContent:nil];
    self.document.videoInsertTimeRange = videoTimeRange;
    self.document.videoExportTimeRange = videoTimeRange;
    self.document.backgroundMusicURL = musicURL;
    self.document.backgroundMusicTimeRange = musicTimeRange;
    self.document.adapter = self.adapter;
//    self.document.specialPipline = self.adapter.specialEffectsFilter.pipline;
    
    self.document.sourceAudioVolume =  1.0;
    self.document.backgroundMusicVolume = 0.0;
    if (musicURL) {
        self.document.sourceAudioVolume = 0;
        self.document.muteSourceAudioVolume = YES;
        self.document.backgroundMusicVolume = 1.0;
    }
    
    AVAssetTrack *track = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize presentationSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    presentationSize.width = ABS(presentationSize.width);
    presentationSize.height = ABS(presentationSize.height);
    _videoSize = presentationSize;
    
    [self setupMusicPicker];
    [self.musicSelectPicker setOriginDefaultMusicVolume:self.document.backgroundMusicVolume];
    [self.musicSelectPicker updateMusicItem:musicItem timeRange:musicTimeRange];
    
    [self updateComposition];
}

- (void)releaseSetAfterEditing {
    [self pause];
}

- (CGFloat)whRatioOfVideo:(AVAsset *)videoAsset {
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize presentationSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    if (isnan(presentationSize.width) || isFloatEqual(presentationSize.width, 0) || isnan(presentationSize.height) || isFloatEqual(presentationSize.height, 0)) {
        return MDScreenWidth / MDScreenHeight;
    }
    return fabsf(presentationSize.width / presentationSize.height);
}

#pragma mark - 通知注册 & 处理
- (void)addNotifiations
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)  name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    
    NSInteger reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    //耳机拔出, 在当前前台页面
    if (AVAudioSessionRouteChangeReasonOldDeviceUnavailable==reason
        && self.isBackground == NO
        && [self isViewVisible]
        && !self.specialEffectsVc.isShow) {
        [self play];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    self.isBackground = YES;
    [self pause];
    
    [self.adapter waitUntilAllOperationsAreFinished];
    [self.exportTask cancel];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    self.isBackground = NO;
    
    self.adapter.overlayImage = nil;
    [self updateComposition];
    
    if ([_speedVaryVc isViewVisible]) {
        [_speedVaryVc synchronizePlayerTime];
    }
    else if (self.specialEffectsVc.isShow){
        //从后台进入前台 'updateComposition' 会重置时间, 所以要把进度条seek到0
        [self.specialEffectsVc seekPlayTime:kCMTimeZero];
    }
    else if ([self isViewVisible]){
        [self play];
    }
}

- (void)updateBuilderSetting {
    MDVideoEditorAdapter *adapter = self.adapter;
    // 更新所有builder相关属性
    [adapter setVideoTimeRange:self.document.videoExportTimeRange];
//    [adapter setVideoPerferredTransform:self.document.videoPreferredTransform];
    [adapter setPitchShiftURL:self.document.sourcePitchShiftURL];
    [adapter setMediaSourceRepeatRange:self.document.mediaSourceRepeatRange];
    
    if (self.document.timeEffectsItem) {
        [adapter setTimeRangeMappingEffects:@[self.document.timeEffectsItem]];
    } else if (self.document.timeRangeMappingEffects.count > 0) {
        [adapter setTimeRangeMappingEffects:MLTimeRangeMappingEffectSquenceGetMappedSquence(self.document.timeRangeMappingEffects)];
    } else {
        [adapter setTimeRangeMappingEffects:@[]];
    }
    
    adapter.backgroundAudioURL = self.document.backgroundMusicURL;
    adapter.backgroundAudioRange = self.document.backgroundMusicTimeRange;
    [adapter setSourceVolume:self.document.sourceAudioVolume];
    [adapter setBackgroundMusicVolume:self.document.backgroundMusicVolume];
//    [adapter setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    // 更新视频源
    [adapter loadVideo:self.document.assetToBeProcessed];
}

- (void)updateComposition {
    
    [self updateBuilderSetting];
    NSError *error = nil;
    [self.adapter compositeVideoWithError:&error];
    NSLog(@"error = %@", error);
}

- (void)updateAudioMix {
    [self updateBuilderSetting];
    [self.adapter updateAudioMix];
}

- (void)topicListDidRefresh
{
    [self.delegate topicListDidRefresh];
}

#pragma mark - 播放相关
- (void)activatePlayer
{
    self.adapter.playerViewController.view.frame = self.viewController.view.bounds;
    
    [self.viewController addChildViewController:self.adapter.playerViewController];
    [self.viewController.view insertSubview:self.adapter.playerViewController.view atIndex:0];
    [self.adapter.playerViewController didMoveToParentViewController:self.viewController];
}

- (void)applySoudPitchFunction:(NSURL *)soundPitchURL
{
    if (soundPitchURL) {
        self.document.sourcePitchShiftURL = soundPitchURL;
        [self updateComposition];
    }
}

- (void)play
{
    if (self.isBackground || !self.viewController.view.window) {
        return;
    }
    [self.adapter play];
}

- (void)pause
{
    [self.adapter pause];
}

- (void)stop {
    [self.adapter stop];
}

#pragma mark - 滤镜相关(瘦身)

- (void)activateSlidingFilters
{
    if (_filterModels.count == 0) {
        //上下切换滤镜资源
        MDRecordFilterModelLoader *loader = [[MDRecordFilterModelLoader alloc] init];
        _filterModels = [loader getFilterModels];
        _filters = [loader filtersArray];
    }
}

- (void)setupFilterDrawer
{
    if (!_filterDrawerController) {
        NSArray *tagArray = @[kDrawerControllerFilterKey,
                              kDrawerControllerMakeupKey,
                              kDrawerControllerChangeFacialKey,
                              ];
        _filterDrawerController = [[MDRecordFilterDrawerController alloc] initWithTagArray:tagArray];
        _filterDrawerController.delegate = self;
        
        [self.viewController addChildViewController:_filterDrawerController];
        [self.viewController.view addSubview:_filterDrawerController.view];

        [_filterDrawerController setFilterModels:self.filterModels];
        [_filterDrawerController setFilterIndex:0];
        
        //设置 美颜 & 大眼瘦脸参数
        NSInteger makeupIndex = [_beautySettingDict integerForKey:MDBeautySettingsSkinWhitenAmountKey defaultValue:0];
        NSInteger thinFaceIndex = [_beautySettingDict integerForKey:MDBeautySettingsEyesEnhancementAmountKey defaultValue:0];
        NSInteger thinBodyIndex = [_beautySettingDict integerForKey:MDBeautySettingsThinBodyAmountKey defaultValue:-1];
        NSInteger longLegIndex = [_beautySettingDict integerForKey:MDBeautySettingsLongLegAmountKey defaultValue:-1];
        
        [_filterDrawerController setMakeUpIndex:makeupIndex];
        [_filterDrawerController setThinFaceIndex:thinFaceIndex];
        [_filterDrawerController setThinBodyIndex:thinBodyIndex];
        [_filterDrawerController setLongLegIndex:longLegIndex];
    }
}

- (void)activateFilterDrawer2 {
    [self.delegate willShowFilterDrawer];
    
    [self setupFilterDrawer];
    
    [self.filterDrawerController setDefaultSelectIndex:0];
    
    [self.filterDrawerController showAnimation];
}

- (void)activateFilterDrawer {
    
    [self.delegate willShowFilterDrawer];

    [self setupFilterDrawer];

    [self.filterDrawerController setDefaultSelectIndex:1];

    [self.filterDrawerController showAnimation];
}

- (void)hideFilterDrawer {
    if ([_filterDrawerController isShowed]) {
        __weak typeof(self) weakSelf = self;
        
        [self setBeautySetting];
        [_filterDrawerController hideAnimationWithCompleteBlock:^{
            [weakSelf.delegate didHideFilterDrawer];
        }];
    }
}

- (void)didSetFilterIntensity:(CGFloat)value {
    MDRecordFilter *filterA = [self.filters objectAtIndex:self.currentFilterIndex defaultValue:nil];
    [filterA setLutIntensity:value];
}

//MDRecordFilterDrawerControllerDelegate
///瘦身
- (void)didSelectedThinBodyItem:(NSInteger)index {
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsThinBodyAmountKey];
    [self setBeautySetting];
}
///长腿
- (void)didSelectedLongLegItem:(NSInteger)index {
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsLongLegAmountKey];
    [self setBeautySetting];
}

- (void)didSelectedFilterItem:(NSInteger)index {
    runSynchronouslyOnVideoProcessingQueue(^{
        if (self.filters.count >= 2) {
            self.currentFilterIndex = index;
            MDRecordFilter *filterA = [self.filters objectAtIndex:index defaultValue:nil];
            [self.adapter configCurrentFilter:filterA];
        }
        
    });
}

- (void)didSelectedMakeUpItem:(NSInteger)index {
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsSkinSmoothingAmountKey];
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsSkinWhitenAmountKey];
    
    [self setBeautySetting];
}

- (void)didSelectedFaceLiftItem:(NSInteger)index {
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsEyesEnhancementAmountKey];
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsFaceThinningAmountKey];
    
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

- (void)updateBeautySetting {
    MDBeautySettings *beautySettings = [[MDBeautySettings alloc] initWithDictionary:self.realBeautySettingDict];

    [self.adapter setBeautyBigEyeValue:[self.realBeautySettingDict floatForKey:MDBeautySettingsEyesEnhancementAmountKey defaultValue:0.0f]];
    [self.adapter setBeautyThinFaceValue:[self.realBeautySettingDict floatForKey:MDBeautySettingsFaceThinningAmountKey defaultValue:0.0f]];
    [self.adapter setSkinWhitenValue: [self.realBeautySettingDict floatForKey:MDBeautySettingsSkinWhitenAmountKey defaultValue:0.0f]];
    [self.adapter setSkinSmoothValue:[self.realBeautySettingDict floatForKey:MDBeautySettingsSkinSmoothingAmountKey defaultValue:0.0f]];
//    [self.adapter setBeautyLenghLegValue:[self.realBeautySettingDict floatForKey:MDBeautySettingsLongLegAmountKey defaultValue:-1]];
//    [self.adapter setBeautyThinBodyValue:[self.realBeautySettingDict floatForKey:MDBeautySettingsThinBodyAmountKey defaultValue:-1]];
    
    // 打点相关
    if ([self.delegate respondsToSelector:@selector(didSelectedBeautySetting:)]) {
        [self.delegate didSelectedBeautySetting:self.beautySettingDict];
    }
}

- (void)setBeautySetting {
    [self transferBeautySettingToRealBeautySetting];

    [self updateBeautySetting];
}

- (NSDictionary *)transferBeautySettingToRealBeautySetting
{
    __weak typeof(self) weakself = self;
    [self.beautySettingDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            CGFloat realValue = [[MDRecordContext beautySettingDataManager] realValueWithIndex:[obj integerValue] beautySettingTypeStr:key];
            [weakself.realBeautySettingDict setFloat:realValue forKey:key];
    }];
    return self.realBeautySettingDict;
}

- (NSMutableDictionary *)beautySettingDict
{
    if (!_beautySettingDict) {
        _beautySettingDict = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return _beautySettingDict;
}

- (NSMutableDictionary *)realBeautySettingDict
{
    if (!_realBeautySettingDict) {
        _realBeautySettingDict = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return _realBeautySettingDict;
}

- (BOOL)needBeautySettingFilter {
    __block BOOL need = NO;
    [self.beautySettingDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        CGFloat realValue = [[MDRecordContext beautySettingDataManager] realValueWithIndex:[obj integerValue] beautySettingTypeStr:key];
        if (realValue>0) {
            need = YES;
            *stop = YES;
        }
    }];
    return need;
}


#pragma mark - 贴纸相关
- (void)activateSticker
{
    [self.delegate willShowStickerChooseView];
    
    [self setupStickerChooseController];
    [self.stickerViewController showWithAnimated:YES completion: ^{
        if ([self.delegate respondsToSelector:@selector(videoPlayerChangeWith:transform:)]) {
            UIView *view = self.adapter.playerViewController.view;
            [self.delegate videoPlayerChangeWith:view.center transform:view.transform];
        }
    }];
}

- (void)removeASticker:(MDRecordBaseSticker *)aSticker
{
    if ([aSticker isKindOfClass:[MDRecordDynamicSticker class]]) {
        [self.stickerViewController removeSticker:aSticker];
        [self.adapter removeDynamicSticker:aSticker];
    }
}

- (void)selectSticker:(MDRecordDynamicSticker *)sticker {
    [self.stickerViewController selectSticker:sticker];
}

- (void)setupStickerChooseController {
    if (!_stickerViewController) {
        _stickerViewController = [[MDRStickerViewController alloc] initWithPlayerViewController:self.adapter.playerViewController
                                                                                          asset:self.document.asset];
        _stickerViewController.delegate = self;
    }
    
    [_stickerViewController willMoveToParentViewController:self.viewController];
    [self.viewController.containerView insertSubview:_stickerViewController.view atIndex:0];
    [self.viewController addChildViewController:_stickerViewController];
    [_stickerViewController didMoveToParentViewController:self.viewController];
}

#pragma mark - MDRStickerViewControllerDelegate Methods

- (void)didCompleteEditSticker:(MDRStickerViewController *)controller {
    
    [self.delegate didHideStickerChooseView];
    
    [self.tmpDynamicStickers removeAllObjects];
    [self.viewController.view insertSubview:self.adapter.playerViewController.view atIndex:0];
    if ([self.delegate respondsToSelector:@selector(videoPlayerChangeWith:transform:)]) {
        UIView *view = self.adapter.playerViewController.view;
        [self.delegate videoPlayerChangeWith:view.center transform:view.transform];
    }
}

- (void)cancelEditSticker:(MDRStickerViewController *)controller {
    [self.delegate didHideStickerChooseView];
    
    NSArray *currentStickers = self.tmpDynamicStickers.copy;
    for (MDRecordDynamicSticker *sticker in currentStickers) {
        [self.delegate didDeleteSticker:sticker];
    }
    [self.tmpDynamicStickers removeAllObjects];

    [self.viewController.view insertSubview:self.adapter.playerViewController.view atIndex:0];
    if ([self.delegate respondsToSelector:@selector(videoPlayerChangeWith:transform:)]) {
        UIView *view = self.adapter.playerViewController.view;
        [self.delegate videoPlayerChangeWith:view.center transform:view.transform];
    }
}

- (void)didSelecedSticker:(MDRStickerViewController *)controller
                  sticker:(MDRecordDynamicSticker *)sticker
                   center:(CGPoint)center {
    [self handleSticker:sticker center:center];
}

- (NSArray *)stickers {
    return self.stickerViewController.stickerArray;
}

- (void)handleSticker:(MDRecordDynamicSticker *)sticker center:(CGPoint)center {
    if (!sticker) {
        return;
    }
    
    [self.tmpDynamicStickers addObject:sticker];
    
    [self.adapter addDynamicSticker:sticker];
        
    [self.delegate didHidestickerChooseViewWithSticker:sticker center:center errorMsg:nil];
}

#pragma mark - 文字编辑相关
- (void)activateTextEdit
{
    if (!_textStickers) {
        _textStickers = [NSMutableArray array];
    }
    
    [self.delegate willShowTextEditingView];
    
    [self setupTextEditView];
    [_textEditView active];
}

- (void)removeATextSticker:(MDMomentTextSticker *)aTextSticker
{
    [self.textStickers removeObject:aTextSticker];
}

- (void)configTextEditViewDefaultText:(NSString *)defaultText colorIndex:(NSInteger)colorIndex
{
    self.textEditView.text = defaultText;
    [self activateTextEdit];
    [self.textEditView configSelectedColor:colorIndex];
}

- (void)setupTextEditView
{
    if (!_textEditView) {
        _textEditView = [[MDMomentTextOverlayEditorView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)];
        
        __weak __typeof(self) weakSelf = self;
        
        [_textEditView setEndEditingHandler:^(UILabel *label, NSInteger colorIndex) {
            
            weakSelf.textEditView.text = @"";
            MDMomentTextSticker *sticker = nil;
            NSString *errorMsg = nil;
            
            if (weakSelf.textStickers.count < kMaxImageStickerCount) {
                
                if ([label.text isNotEmpty]) {
                    sticker = [[MDMomentTextSticker alloc] initWithLabel:label];
                    sticker.colorIndex = colorIndex;
                    [weakSelf.textStickers addObjectSafe:sticker];
                }
            }
            else {
                errorMsg = @"最多使用20个贴纸";
            }
            
            [weakSelf.delegate didEndEditingWithTextSticker:sticker errorMsg:errorMsg];
        }];
        _textEditView.placeholder = @"描述这个视频";
        
        [self.viewController.view addSubview:_textEditView];
    }
}

#pragma mark - 配乐相关
- (void)activateMusicPicker
{
    [self.delegate willShowMusicPicker];
    [self setupMusicPicker];
    
    [self.viewController.view addSubview:self.musicSelectPicker.view];
    [self.musicSelectPicker showAnimateWithCompleteBlock:nil];
}

- (void)hideMusicPicker
{
    if (self.musicSelectPicker.isShowed) {
        [self.musicSelectPicker hideAnimationWithCompleteBlock:nil];
        [self.delegate didCloseMusicPickerViewWithSelectedMusicTitle:self.musicSelectPicker.currentSelectMusicItem.musicVo.title];
    }
}

- (void)setupMusicPicker
{
    if(!_musicSelectPicker) {
        _musicSelectPicker = [[MDMusicEditPalletController alloc] init];
        _musicSelectPicker.delegate = self;
        [self.viewController addChildViewController:self.musicSelectPicker];
        [self.musicSelectPicker didMoveToParentViewController:self.viewController];
    }
}

//MDMusicEditPalletControllerDelegate
- (void)musicEditPallet:(MDMusicEditPalletController *)musicEditPallet didPickMusicItems:(MDMusicCollectionItem *)musicItem timeRange:(CMTimeRange)timeRange {
    [self updateAudioMixWithMusicItem:musicItem timeRange:timeRange];
}
- (void)musicEditPallet:(MDMusicEditPalletController *)musicEditPallet didEditOriginalVolume:(CGFloat)originalVolume musicVolume:(CGFloat)musicVolume {
    self.document.sourceAudioVolume = originalVolume;
    self.document.backgroundMusicVolume = musicVolume;
    [self updateAudioMix];
}
- (void)musicEditPalletDidClearMusic:(MDMusicEditPalletController *)musicEditPallet {
    [self updateAudioMixWithMusicItem:nil timeRange:kCMTimeRangeZero];
}


- (void)updateAudioMixWithMusicItem:(MDMusicCollectionItem *)musicItem timeRange:(CMTimeRange)timeRange
{
    self.didChangeMusic = YES;
    
    if (![musicItem resourceExist]) {
        self.document.backgroundMusicURL = nil;
    }else {
        NSURL *musicUrl = musicItem.resourceUrl;
        AVAsset *musicAsset = [AVAsset assetWithURL:musicUrl];
        CMTimeRange musicTimeRange = CMTimeRangeMake(kCMTimeZero, musicAsset.duration);
        if (!CMTIMERANGE_IS_EMPTY(timeRange) && CMTimeRangeContainsTimeRange(musicTimeRange, timeRange)) {
            musicTimeRange = timeRange;
        }
        
        self.document.backgroundMusicURL = musicUrl;
        self.document.backgroundMusicTimeRange = musicTimeRange;
    }
    [self updateComposition];
    
    // 不再调用stop或者replay临时解决因为调用pause再调用compositeVideoWithError: 造成视频卡住，mediaServiceWereReset & mediaServiceWereLost的问题
    [self.adapter seekTime:kCMTimeZero];
    [self play];
}

#pragma mark - 封面选取相关
- (void)activateThumbPicker
{
    [self.delegate willShowThumbPicker];

    [self setupThumbDataManager];
    [self presentThumbSelectVC];
}

- (void)preloadThumbs
{
    self.coverCopyedAsset = [self.adapter.composition copy];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.f) {
        [self setupThumbDataManager];
    }
}

- (UIImage *)defaultLargeCoverImage
{
    [self setupThumbDataManager];
    return _thumbDataManager.defaultLargeCoverImage;
}

- (void)presentThumbSelectVC
{
    MDMomentThumbSelectViewController *thumbSelectVC = [[MDMomentThumbSelectViewController alloc] init];
    thumbSelectVC.deleagte = self;
    thumbSelectVC.thumbDataArray = self.thumbDataManager.momentThumbDataArray;
    thumbSelectVC.thumbTimeArray = self.thumbDataManager.momentThumbTimeArray;
    thumbSelectVC.preLoadIndex = self.originVideoCoverIndex;
    thumbSelectVC.maxThumbSize = [self.viewController maxThumbImageSize];
    [self.viewController presentViewController:thumbSelectVC animated:YES completion:nil];
}

- (void)setupThumbDataManager
{
    if (!_thumbDataManager) {
        _thumbDataManager = [MDMomentThumbDataManager momentThumbManager];
        _thumbDataManager.maxThumbSize = [self.viewController maxThumbImageSize];
    }
    
    if (!self.coverLoaded) {
        self.coverLoaded = YES;
        [_thumbDataManager getMomentThumbGroupsByAsset:self.coverCopyedAsset
                                                frameCount:[self frameCountWithAsset:self.coverCopyedAsset]
                                               addObserver:self];
    }
}

#pragma mark MDMomentThumbSelectDelegate
- (void)momentCoverImage:(UIImage *)coverImage atThumbIndex:(NSInteger)index
{
    BOOL selected = (self.originVideoCover != nil || coverImage != nil) ? YES : NO;
    [self.delegate didPickAThumbImage:selected];
    
    if (coverImage) {
        self.originVideoCover = coverImage;
        self.originVideoCoverIndex = index;
    }
}

- (AVAsset *)momentCoverSourceAsset
{
    return self.thumbDataManager.asset;
}

#pragma mark MDMomentThumbDataManagerDelegate
- (void)momentThumbDataReload
{
    if ([self.viewController.presentedViewController isKindOfClass:[MDMomentThumbSelectViewController class]]) {
        MDMomentThumbSelectViewController *thumbSelect = (id)self.viewController.presentedViewController;
        [thumbSelect reloadCollectionView];
    }
}

#pragma mark - 涂鸦相关
- (void)activateGraffitiEditor
{
    BBMediaGraffitiEditorViewController *graffitiEditorVC = [[BBMediaGraffitiEditorViewController alloc] init];
    graffitiEditorVC.initialGraffitiCanvasImage = self.initialGraffitiCanvasImage;
    graffitiEditorVC.initialMosaicCanvasImage = self.adapter.mosaicCanvasImage;
    graffitiEditorVC.renderFrame = [self.adapter videoRenderFrame];
    
    [self.delegate willShowGraffitiEditor];
    
    [self showPainterViewController:graffitiEditorVC];
}

- (void)showPainterViewController:(BBMediaGraffitiEditorViewController *)vc
{
    __weak __typeof(self) weakSelf = self;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [vc setCompletionHandler:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.delegate willHideGraffitiEditor];
        [strongSelf.viewController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [vc setCanvasImageUpdatedHandler:^(UIImage *canvasImage, UIImage *mosaicCanvasImage) {
        [self.adapter setGraffitiCanvasImage:nil mosaicCanvasImage:mosaicCanvasImage];
        weakSelf.hasGraffiti = !(canvasImage == nil && mosaicCanvasImage == nil);
        weakSelf.initialGraffitiCanvasImage = canvasImage;
        [weakSelf.delegate graffitiEditorUpdateWithCanvasImage:canvasImage mosaicCanvasImage:mosaicCanvasImage];
    }];
    
    [self.viewController presentViewController:vc animated:YES completion:^{
        [weakSelf.delegate didShowGraffitiEditor];
    }];
}

#pragma mark - 特效滤镜相关

- (void)preloadSpecialImage {
    if (!_specialImageManager) {
        _specialImageManager = [[MDRecordSpecialImageDataManager alloc] init];
        [_specialImageManager getSpecialImageGroupsByAsset:self.coverCopyedAsset
                                                frameCount:15
                                                  delegate:self];
    }
}
//MDRecordSpecialImageDataManagerDelegate
- (void)recordSpecialImageFinished{
    [self.specialEffectsVc updateSpecialImageArray:self.specialImageManager.momentThumbDataArray];
}

- (void)activateSpecialEffectsVc {
    if (self.document.timeRangeMappingEffects.count>0) {
        [self.viewController.view makeToast:@"特效滤镜与变速不能叠加使用" duration:1.5f position:CSToastPositionCenter];
        return;
    }
    if (!self.document.reserveAsset) {
        //反转视频
        [self.delegate willBeginReverseVideoOpertion];

        __weak typeof(self) weakSelf = self;
        self.reserveOperation = [MDRecordAssetReversedManager assetReverseOperationForURL:((AVURLAsset *)self.document.asset).URL completion:^(NSURL *outputURL) {
            weakSelf.reserveOperation = nil;
            weakSelf.document.reserveAsset = [AVURLAsset URLAssetWithURL:outputURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)}];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate didEndReverseVideoOpertion];
                [weakSelf activateSpecialEffectsVc];
            });
        } failure:^(NSError *error) {
            BOOL isCancelled = weakSelf.reserveOperation.isCancelled;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate didEndReverseVideoOpertion];
                if (!isCancelled) {
                    [self.viewController.view makeToast:@"特效滤镜视频处理失败" duration:1.5f position:CSToastPositionCenter];
                }
            });
            weakSelf.reserveOperation = nil;
        } progress:^(float progress) {
            progress = MAX(0, MIN(1, progress));
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate reverseVideoWithProgress:progress];
            });
        }];
        return;
    }
    

    [self pause];
    [self setupSpecialEffectsVc];
//    [self activateSpecialEffectsVc];
}

- (void)cancelReverseOpertion {
    [MDRecordAssetReversedManager cancelReverseOperation];
}

- (void)setupSpecialEffectsVc {
    if (!self.specialEffectsVc) {
        self.specialEffectsVc = [[MDSpecialEffectsController alloc] initWithDocument:self.document
                                                                playerViewController:(id)self.adapter.playerViewController
                                                                            delegate:self];
        self.specialEffectsVc.specialImageArray = self.specialImageManager.momentThumbDataArray;
    }
    
    if ([self.specialEffectsVc.view superview]) {
        [self.specialEffectsVc willMoveToParentViewController:nil];
        [self.specialEffectsVc.view removeFromSuperview];
        [self.specialEffectsVc removeFromParentViewController];
    }
    [self.viewController addChildViewController:self.specialEffectsVc];
    [self.viewController.view addSubview:self.specialEffectsVc.view];
    [self.specialEffectsVc didMoveToParentViewController:self.viewController];
    
    [self.specialEffectsVc showWithAnimated:YES];
}

// MDSpecialEffectsControllerDelegate
- (void)specialEffectsDidChange {
    [self updateComposition];
}

- (void)specialEffectsDidFinishedEditing {
    MDVideoEditorAdapter *adapter = self.adapter;
    [adapter replay];
    
    [self.viewController addChildViewController:adapter.playerViewController];
    [self.viewController.view insertSubview:adapter.playerViewController.view atIndex:0];
    [adapter.playerViewController didMoveToParentViewController:self.viewController];
}

- (NSArray *)specialEffectsTypeArray {
    NSMutableSet *set = [NSMutableSet set];
    for (GPUImageOutput<GPUImageInput,MDRSpecialFilterLifeStyleProtocol> *filter in [self.adapter.specialFilters copy]) {
        MDRecordSpecialEffectsType type = [MDRecordSpecialEffectsManager getSpecialEffectsTypeWithFilter:filter];
        [set addObject:@(type)];
    }
    if (self.document.timeEffectsItem) {
        CMTime duration = self.document.timeEffectsItem.timeRange.duration;
        CMTime targetDuration = self.document.timeEffectsItem.targetDuration;
        if (CMTimeCompare(duration, targetDuration)>=0) {
            [set addObject:@(MDRecordSpecialEffectsTypeQuickMotion)];
        }else {
            [set addObject:@(MDRecordSpecialEffectsTypeSlowMotion)];
        }
    }
    if (!CMTIMERANGE_IS_INVALID(self.document.mediaSourceRepeatRange)) {
        [set addObject:@(MDRecordSpecialEffectsTypeRepeat)];
    }
    if (self.document.reserve) {
        [set addObject:@(MDRecordSpecialEffectsTypeReverse)];
    }
    return [set allObjects];
}

#pragma mark - 变速相关
- (void)activateSpeedVaryVc {
    if (self.stickers.count > 0) {
        [self.viewController.view makeToast:@"贴纸不能与变速叠加使用" duration:1.5f position:CSToastPositionCenter];
        return;
    }
    
    if ([self.document hasSpecialEffects]) {
        [self.viewController.view makeToast:@"特效滤镜与变速不能叠加使用" duration:1.5f position:CSToastPositionCenter];
        return;
    }
    
    [self.delegate willShowSpeedVaryVC];
    [self setupSpeedVaryVc];
}

- (void)setupSpeedVaryVc
{
    if (!self.speedVaryVc) {
        _speedVaryVc = [[MDVideoSpeedVaryViewController alloc] initWithAsset:[self.adapter.composition copy]
                                                                        document:self.document
                                                                        delegate:self];
        _speedVaryVc.player =self.adapter.player;
    }
    
    if ([self.speedVaryVc.view superview]) {
        [self.speedVaryVc.view removeFromSuperview];
        [self.speedVaryVc removeFromParentViewController];
    }
    [self.viewController.view addSubview:_speedVaryVc.view];
    [self.viewController addChildViewController:_speedVaryVc];
}

#pragma mark MDVideoSpeedVaryDelegate

- (void)speedEffectWillChanged{}

- (void)speedEffectDidStartChanged{}

- (void)speedEffectDidEndChanged:(CMTimeRange)targetTimeRange
{
    [self updateComposition];
}

- (void)videoSpeedVarydidFinishedEditing
{
    [self.delegate didHideSpeedVaryVC];
    [self play];
}

#pragma mark - 导出相关
- (void)exportVideo
{
    //如果时长超出或不足，走原来逻辑。
    if ([self checkVideoDurationValidBeforeExport]) {
        AVAssetTrack *videoTrack = [[self.document.asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        CMTimeRange videoTimeRange = videoTrack.timeRange;
        
        NSInteger clarityStrategy = 1;// [[MDContext currentUser] dbStateHoldProvider].momentRecordClarityStrategy;
        BOOL supportHighResolutionStrategy = [self.viewController supportHighResolutionStrategy];
        if (supportHighResolutionStrategy && clarityStrategy==1 && ![self checkHasEditedVideo] && ![self.viewController originMisicUrl] && CMTimeRangeEqual(videoTimeRange, self.document.videoInsertTimeRange)) {
            //清晰度策略为1
            //时长正常，没有有编辑行为,没有携带配乐,没有截取时长，
            [self.delegate didExportFinishWithVideoURL:((AVURLAsset *)self.document.asset).URL
                                      originVideoCover:self.originVideoCover
                                 originVideoCoverIndex:self.originVideoCoverIndex];
            [self releaseSetAfterEditing];
            return;
        }

        self.document.videoExportTimeRange = [self renderTimeRange:CMTimeRangeMake(kCMTimeZero, self.adapter.composition.duration)];
        [self exportForUpload];
    }
}

- (void)cancelExport
{
    if (self.exportTask) {
        [self.exportTask cancel];
        self.adapter.overlayImage = nil;
    }
    self.exporting = NO;
}

- (void)exportForUpload
{
    if (self.isExporting || self.exportTask) return;

    self.saveMode = NO;
    
    __weak __typeof(self) weakSelf = self;
    [self renderForOutputWithCompeleteHandler:^(NSURL *url) {
        if (!url) {
            return ;
        }
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if (strongSelf.isBackground) {
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            return ;
        }
        
        [strongSelf.delegate didExportFinishWithVideoURL:url
                                        originVideoCover:strongSelf.originVideoCover
                                   originVideoCoverIndex:strongSelf.originVideoCoverIndex];
        
        strongSelf.exporting = NO;
        
        [strongSelf releaseSetAfterEditing];
        
    } failHandler:^(NSError *error) {
        weakSelf.hasGraffiti = NO;
        weakSelf.exporting = NO;
    }] ;
}

- (void)configExportVideoSetting {
    
    [self.adapter setVideoTimeRange:self.document.videoExportTimeRange];
    self.adapter.overlayImage = self.document.customOverlay;
    
    float destBitRate = 0.0; //[[[MDContext currentUser] dbStateHoldProvider] momentRecordExportBitRate];
    if (fabsf(destBitRate) <= 0.00001f) {
        destBitRate = (5.0 * 1024 * 1024);
    }
    
    float sourceBitRate = 0.0;
    
    CGSize naturalSize  = self.adapter.composition.naturalSize;
    for (AVMutableCompositionTrack *track in self.adapter.composition.tracks) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            naturalSize = [track naturalSize];
            sourceBitRate = [track estimatedDataRate];
        }
    }
    
    CGSize presentationSize = CGSizeApplyAffineTransform(naturalSize, self.document.videoPreferredTransform);
    presentationSize.width = ABS(presentationSize.width);
    presentationSize.height = ABS(presentationSize.height);
    if (presentationSize.width <= 0 || presentationSize.height <= 0 ) {
        presentationSize = CGSizeMake(720, 1280);
    }
    
    if (fabsf(sourceBitRate) <= 0.00001f) {
        sourceBitRate = (3.0 * 1024 * 1024);
    }
    
    if (presentationSize.width*presentationSize.height > 1280*720) {
        //走高清策略，且分辨率大于720P，即分辨率1080P，最大码率设为7M
        CGFloat maxBitRate = 7.0 * 1024 *1024;
        if (sourceBitRate > maxBitRate) {
            sourceBitRate = maxBitRate;
        }
    }else {
        if (sourceBitRate > destBitRate) {
            sourceBitRate = (self.document.useOriginalBitRate ? sourceBitRate : destBitRate);
        }
    }
    
    // 设置导出码率
    if (MDRecordVideoSettingManager.exportBitRate <= 0) {
        [self.adapter setTargetBitRate:sourceBitRate];
    } else {
        [self.adapter setTargetBitRate:MDRecordVideoSettingManager.exportBitRate];
    }
    // 设置导出视频大小
//    [self.adapter setPresentationSize:presentationSize];
    // 设置导出帧率
    [self.adapter setTargetFrameRate:MDRecordVideoSettingManager.exportFrameRate ?: 30];
    // 设置是否需要经过滤镜
    BOOL needFilterEffect = self.stickers.count > 0 || self.document.customOverlay || [self needBeautySettingFilter] || self.document.hasPictureSpecialEffects;
    [self.adapter enableFilterEffect:needFilterEffect];
    
}

- (void)renderForOutputWithCompeleteHandler:(void (^)(NSURL *))completionHandler
                                failHandler:(void (^)(NSError *))failHandler
{
    [self.adapter waitUntilAllOperationsAreFinished];
    [self pause];
    self.exporting = YES;
    
    //通知外界即将进行导出工作
    [self.delegate willBeginExportForSaveMode:self.saveMode];
    
    //清空导出指定的目录
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mp4"]];
    [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
    
    //没有编辑行为、不需要加水印则直接导出
    if (![self shouldDoSnapshotWithSaveMode:self.saveMode]) {
        self.document.customOverlay = nil;
    } else {
        //图片合到视频前的配置
        self.document.customOverlay = [self.viewController rendenOverlayImageForSaveMode:self.saveMode];
        CMTime duration = self.adapter.composition.duration;
        float start = MAX(0, CMTimeGetSeconds(duration) -3);
        self.document.watermarkTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(start, duration.timescale), CMTimeMakeWithSeconds(3, duration.timescale));
    }
    
    //根据下载或导出设置码率
    self.document.useOriginalBitRate = self.saveMode;

    //配乐、图片合成到原生视频后生成AVAssetExportSession
    
    [self configExportVideoSetting];
    
    __weak typeof(self) weakSelf = self;
    self.exportTask = [self.adapter exportToURL:url progressHandler:^(double progress) {
        __strong typeof(self) strongself = weakSelf;
        [strongself.delegate exportingWithProgress:progress];
    } completion:^(NSURL * _Nonnull url) {
        __strong typeof(self) strongself = weakSelf;
        [strongself handleExportFinishWithUrl:url error:nil];
        completionHandler(url);
    } failure:^(NSError * _Nullable error) {
        __strong typeof(self) strongself = weakSelf;
        [strongself handleExportFinishWithUrl:url error:error];
        failHandler(error);
    }];
}

- (void)handleExportFinishWithUrl:(NSURL *)url error:(NSError *)error
{
    self.exportTask = nil;
    self.adapter.overlayImage = nil;
    [self updateComposition];
    if ((error || !url) && !self.isBackground) {
        [self play];
    }
    
    [self.delegate willExportFinishWithVideoURL:url error:error];
}

#pragma mark - 下载相关
- (void)saveVideo
{
    if (self.isExporting || self.exportTask) return;
    
    //统计打点
//    [MDActionManager handleLocaRecord:@"video_download"];
    self.saveMode = YES;
    
    [PHPhotoLibrary checkAlbumAuthorizationStatus:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            return;
        }
        
        self.document.videoExportTimeRange = [self renderTimeRange:CMTimeRangeMake(kCMTimeZero, self.adapter.composition.duration)];
        
        __weak __typeof(self) weakSelf = self;
        [self renderForOutputWithCompeleteHandler:^(NSURL *url) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf play];
            
            if (strongSelf.isBackground) {
                [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                strongSelf.exporting = NO;
            }
            else {
                [strongSelf.delegate didSaveVideoFinishWithVideoURL:url completeBlock:^{
                    strongSelf.exporting = NO;
                }];
            }
            
        } failHandler:^(NSError *error) {
            
            weakSelf.exporting = NO;
            [weakSelf play];
        }];
    }];
}

#pragma mark - getter
- (CGRect)videoRenderFrame
{
//    return self.adapter.videoRenderFrame;
    return self.adapter.playerViewController.view.bounds;
}

#pragma mark - 辅助方法
- (NSUInteger)maxStickerCount
{
    if ([MDRecordContext is32bit]) {
        return 1;
    } else {
        return 3;
    }
}

- (NSUInteger)frameCountWithAsset:(AVAsset *)asset
{
    Float64 duration = CMTimeGetSeconds(asset.duration);
    if (duration <= 0) {
        return 0;
    } else if (duration <= 60) {
        return 10;
    } else if (duration <= 180) {
        return 20;
    } else if (duration <= 300) {
        return 30;
    } else {
        return 10;
    }
}

+ (NSOperationQueue *)renderOperationQueue
{
    static NSOperationQueue *renderOperationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        renderOperationQueue = [[NSOperationQueue alloc] init];
        renderOperationQueue.maxConcurrentOperationCount = 1;
    });
    return renderOperationQueue;
}

- (BOOL)isViewVisible
{
    return self.viewController.isViewLoaded && self.viewController.view.window;
}

- (BOOL)isDoingExportOperation
{
    return (self.exportTask != nil);
}

- (BOOL)checkHasEditedVideo
{
    BOOL result = [self checkHasEditVideoPicture];
    
    if (self.document.backgroundMusicURL) {
        result = YES;
    }
    
    return result;
}

//返回是否在编辑页编辑过
- (BOOL)checkHasChangeVideo {
    BOOL result = [self checkHasEditVideoPicture];

    //编辑页是否有选过音乐，(self.document.backgroundMusicURL可能是拍摄页带过来的，编辑页可能没选过)
    if (self.didChangeMusic) {
        result = YES;
    }
    
    return result;
}

//检测是否编辑过视频画面
- (BOOL)checkHasEditVideoPicture {
    // 始终导出
    return YES;
}

//是否需要做截屏操作（加水印、文字编辑、涂鸦（不包括马赛克））
- (BOOL)shouldDoSnapshotWithSaveMode:(BOOL)saveMode
{
    return [self.viewController isNeedWaterMarkWithSaveMode:saveMode] || (self.textStickers.count > 0 || self.hasGraffiti);
}

- (BOOL)checkVideoDurationValidBeforeExport
{
    __weak __typeof(self) weakSelf = self;
    
    BOOL isValid = YES;
    _maxUploadDuration = [self.viewController maxUploadDuration];
    
    //判断时长时fix一下，不要用最精确的时长限制
    if (CMTimeGetSeconds(self.adapter.composition.duration) > self.maxUploadDuration +2) {
        MDMomentVideoTrimViewController *trimVC = [[MDMomentVideoTrimViewController alloc] initWithMaxDuration:self.maxUploadDuration CloseHandler:^(UIViewController *controller, AVAsset *asset,CMTimeRange timeRange) {
            __strong typeof(self) strongself = weakSelf;
            [strongself.viewController.navigationController popViewControllerAnimated:YES];
            
            if (!CMTimeRangeEqual(timeRange, kCMTimeRangeInvalid)) {
                [strongself.delegate didCutVideoFinish];
                strongself.document.videoExportTimeRange = [strongself renderTimeRange:timeRange];
                [strongself exportForUpload];
            }
        }];
        
        trimVC.asset = self.adapter.composition;
        trimVC.needShowConfirm = YES;
        [self.viewController.navigationController pushViewController:trimVC animated:YES];
        isValid = NO;
    }
    else if (CMTimeGetSeconds(self.adapter.composition.duration) < 2.0f) {
        [self.viewController.view makeToast:@"视频时长过短，暂不支持2秒以下视频" duration:1.5f position:CSToastPositionCenter];
        isValid = NO;
    }
    
    return isValid;
}

- (CMTimeRange)renderTimeRange:(CMTimeRange)timeRange
{
    CMTime start = [self.document convertToMediaSouceTimeFromPresentationTime:timeRange.start];
    CMTime convertStart = CMTimeMakeWithSeconds(CMTimeGetSeconds(start) + CMTimeGetSeconds(self.document.videoInsertTimeRange.start), timeRange.duration.timescale);
    CMTime duration = [self.document convertToMediaSouceTimeFromPresentationTime:timeRange.duration];
    
    if (!CMTIMERANGE_IS_INVALID(self.document.mediaSourceRepeatRange)) {
        //TODO:yzk 后续判断timeRange的start和end
        duration = CMTimeSubtract(duration, self.document.mediaSourceRepeatRange.duration);
        duration = CMTimeSubtract(duration, self.document.mediaSourceRepeatRange.duration);
    }
    return CMTimeRangeMake(convertStart, duration);
}

- (BOOL)hasSpeedEffect
{
    return self.document.timeRangeMappingEffects.count > 0;
}

- (NSString *)musicId {
    return self.musicSelectPicker.currentSelectMusicItem.musicVo.musicID;
}
- (BOOL)isLocalMusic {
    return self.musicSelectPicker.currentSelectMusicItem.isLocal;
}

- (BOOL)isMusicCut {
    if (!self.document.backgroundMusicURL) {
        return NO;
    }
    AVAsset *musicAsset = [AVAsset assetWithURL:self.document.backgroundMusicURL];
    if (CMTimeCompare(musicAsset.duration, kCMTimeZero) == 0) {
        return NO;
    }
    
    CMTimeRange musicTimeRange = CMTimeRangeMake(kCMTimeZero, musicAsset.duration);
    if (!CMTimeRangeEqual(musicTimeRange, self.document.backgroundMusicTimeRange)) {
        return YES;
    }
    return NO;
}

@end
