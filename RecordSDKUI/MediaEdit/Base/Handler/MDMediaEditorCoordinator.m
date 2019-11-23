//
//  MDMediaEditorCoordinator.m
//  MDChat
//
//  Created by 符吉胜 on 2017/8/24.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMediaEditorCoordinator.h"
#import "MDMediaEditorSettingItem.h"
#import "MDMediaEditorContainerView.h"
#import "MDMediaEditorModuleAggregate.h"
#import "MDBluredProgressView.h"

//视频上传相关
#import "MDVideoUploadHelper.h"
#import "MDRecordVideoResult.h"

#import "MDBeautySettings.h"
#import <RecordSDK/MDFastMP4Handler.h>
#import "Toast/Toast.h"

@import RecordSDK;

@interface MDMediaEditorCoordinator()
<
    MDMediaEditorModuleAggregateDelegate,
    BBMediaStickerAdjustmentViewDelegate,
    MDMomentTextAdjustmentViewDelegate
>

@property (nonatomic,strong) MDMediaEditorSettingItem       *settingItem;
@property (nonatomic,  weak) MDMediaEditorModuleAggregate   *moduleAggregate;
@property (nonatomic,  weak) MDMediaEditorContainerView     *containerView;

@property (nonatomic,strong) MDBluredProgressView           *reverseProcessingHUD; //反转视频
@property (nonatomic,strong) MDBluredProgressView           *processingHUD;
@property (nonatomic,assign) BOOL                           saveMode;
@property (nonatomic, strong) MDVideoUploadHelper           *uploadHelper;

@property (nonatomic, assign) BOOL needDeleteSticker; //是否需要删除贴纸
@property (nonatomic, strong) MDMomentTextSticker *handlingSticker; //记录点击的文字贴纸

@property (nonatomic, assign) BOOL isShowStickerVC;

@end

@implementation MDMediaEditorCoordinator

- (void)dealloc
{
//    MDLogDebug(@"%s",__func__);
    
    if (_processingHUD.superview) {
        [_processingHUD removeFromSuperview];
        _processingHUD = nil;
    }
}

- (instancetype)initWithContainerView:(MDMediaEditorContainerView *)containerView
                          settingItem:(MDMediaEditorSettingItem *)settingItem
                      moduleAggregate:(MDMediaEditorModuleAggregate *)moduleAggregate
{
    if (self = [super init]) {
        _settingItem = settingItem;
        _containerView = containerView;
        
        _moduleAggregate = moduleAggregate;
        _moduleAggregate.delegate = self;
        
        _containerView.stickerAdjustView.delegate = self;
        _containerView.textAdjustView.delegate = self;
    }
    return self;
}

#pragma makr - public

- (void)moreActionsBtnTapped
{
//    UIButton *moreActionsButton = [self.containerView.bottomView buttonWithATitle:kBtnTitleForMoreAction];
//    moreActionsButton.selected = !moreActionsButton.selected;
//    [self showMoreActions:moreActionsButton.selected];
}

#pragma mark - MDMediaEditorModuleAggregateDelegate

//滤镜相关
- (void)willShowFilterDrawer {
    [self updateViewElementsWithAlpha:.0f animated:NO];
}
- (void)didHideFilterDrawer {
    [self updateViewElementsWithAlpha:1.0f animated:YES];
}

- (void)didSelectedBeautySetting:(NSDictionary *)beautySettingDict {
    MDRecordVideoResult *videoResult = self.settingItem.videoInfo;
    videoResult.longLegLevel = [beautySettingDict integerForKey:MDBeautySettingsLongLegAmountKey defaultValue:-1];
    videoResult.thinBodayLevel = [beautySettingDict integerForKey:MDBeautySettingsThinBodyAmountKey defaultValue:-1];
}

//贴纸相关
- (void)willShowStickerChooseView {
    [self updateViewElementsWithAlpha:0 animated:YES];
    self.isShowStickerVC = YES;
}

- (void)didHideStickerChooseView {
    [self updateViewElementsWithAlpha:1 animated:YES];
    self.isShowStickerVC = NO;
//    self.containerView.editNavView.hidden = YES;
}

- (void)didHidestickerChooseViewWithSticker:(MDRecordDynamicSticker *)aSticker
                                     center:(CGPoint)center
                                   errorMsg:(NSString *)errorMsg {
//    [self updateViewElementsWithAlpha:1 animated:YES];
    
    if (aSticker) {
        [self.containerView.stickerAdjustView addSticker:aSticker center:center];
    }
    else if ([errorMsg isNotEmpty]) {
        [[MDRecordContext appWindow] makeToast:errorMsg duration:1.5f position:CSToastPositionCenter];
    }
}

- (void)didDeleteSticker:(MDRecordDynamicSticker *)aSticker {
    [self.containerView.stickerAdjustView removeSticker:aSticker];
    [self.moduleAggregate removeASticker:aSticker];
}


//文字编辑相关
- (void)willShowTextEditingView {
    [self updateViewElementsWithAlpha:.0f animated:NO];
}

- (void)didEndEditingWithTextSticker:(MDMomentTextSticker *)aTextSticker errorMsg:(NSString *)errorMsg {
    [self updateViewElementsWithAlpha:1.0f animated:YES];
    
    if (aTextSticker) {
        if (self.handlingSticker) {
            [self.containerView.textAdjustView addSticker:aTextSticker center:self.handlingSticker.center transform:self.handlingSticker.transform];
            self.handlingSticker = nil;
        } else {
            [self.containerView.textAdjustView addSticker:aTextSticker center:CGPointMake(self.containerView.textAdjustView.width *0.5f, self.containerView.textAdjustView.height *0.3f) transform:CGAffineTransformIdentity];
        }
    }else if ([errorMsg isNotEmpty]) {
        [[MDRecordContext appWindow] makeToast:errorMsg duration:1.5f position:CSToastPositionCenter];
    }
}


//配乐相关
- (void)willShowMusicPicker {
    [self updateViewElementsWithAlpha:.0f animated:NO];
}

- (void)didCloseMusicPickerViewWithSelectedMusicTitle:(NSString *)title {
    [self updateViewElementsWithAlpha:1.0f animated:YES];
//    [self.containerView.bottomView buttonWithATitle:kBtnTitleForMusic].selected = ([title isNotEmpty] ? YES : NO);
}


//封面选取相关
- (void)willShowThumbPicker {
}

- (void)didPickAThumbImage:(BOOL)isPick {
//    [self.containerView.bottomView buttonWithATitle:kBtnTitleForthumbSelect].selected = isPick;
}


//涂鸦相关
- (void)willShowGraffitiEditor {
//    [self showMoreActions:NO];
    [self updateViewElementsWithAlpha:0 animated:NO];
}

- (void)didShowGraffitiEditor {
    self.containerView.graffitiCanvasView.alpha = 0;
}

- (void)willHideGraffitiEditor {
    self.containerView.graffitiCanvasView.alpha = 1;
    [self updateViewElementsWithAlpha:1 animated:YES];
}
- (void)graffitiEditorUpdateWithCanvasImage:(UIImage *)canvasImage mosaicCanvasImage:(UIImage *)mosaicCanvasImage {
    self.containerView.graffitiCanvasView.image = canvasImage;
}

//特效滤镜相关
- (void)willBeginReverseVideoOpertion {
    [self showReverseProcessingHUD];
}
- (void)reverseVideoWithProgress:(CGFloat)progress {
    [self updateReverseProcessing:progress];
}
- (void)didEndReverseVideoOpertion {
    [self hideReverseProcessingHUD];
}


//变速相关
- (void)willShowSpeedVaryVC
{
//    [self showMoreActions:NO];
    [self updateViewElementsWithAlpha:0 animated:NO];
}

- (void)didHideSpeedVaryVC {
    [self updateViewElementsWithAlpha:1.0f animated:YES];
}


//话题相关
- (void)willShowTopicSeletedTable {
//    self.containerView.topicEntranceView.hidden = YES;
}

- (void)topicSelectedManagerDidFinishSelectWithTopicID:(NSString *)aTopicID topicName:(NSString *)aTopicName {
//    [self.containerView.topicEntranceView setTextString:aTopicName];
//    self.containerView.topicEntranceView.centerX = MDScreenWidth/2.0;
//    self.settingItem.videoInfo.topicID = aTopicID;
//    self.settingItem.videoInfo.topicName = aTopicName;
}

- (void)topicSelectedManagerDidClose {
//    self.containerView.topicEntranceView.hidden = NO;
}

- (void)topicListDidRefresh
{
//    if (self.settingItem.hideTopicEntrance) return;
//
//    if ([self.settingItem.videoInfo.topicID isNotEmpty]) {
//        NSString *topicName = [self.moduleAggregate topicNameFromLocalWithTopicId:self.settingItem.videoInfo.topicID];
//        [self.containerView.topicEntranceView setTextString:topicName];
//        self.settingItem.videoInfo.topicName = topicName;
//        self.containerView.topicEntranceView.centerX = MDScreenWidth/2.0;
//    }
}

// 视频大小变化相关
- (void)videoPlayerChangeWith:(CGPoint)center transform:(CGAffineTransform)transform
{
    self.containerView.costumContentView.transform = CGAffineTransformIdentity;
    self.containerView.costumContentView.transform = transform;
    self.containerView.costumContentView.center = center;
}

//导出相关
- (void)willBeginExportForSaveMode:(BOOL)isSaveMode
{
    self.saveMode = isSaveMode;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self showProcessingHUD];
}


- (void)exportingWithProgress:(CGFloat)progress
{
    [self updateProcessing:progress];
}

- (void)willExportFinishWithVideoURL:(NSURL *)videoURL error:(NSError *)error
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self hideProcessingHUD];
}

- (void)didExportFinishWithVideoURL:(NSURL *)videoURL
                   originVideoCover:(UIImage *)originVideoCover
              originVideoCoverIndex:(NSInteger)originVideoCoverIndex
{
    if (originVideoCover == nil) {
        originVideoCover = [self.moduleAggregate defaultLargeCoverImage];
        self.uploadHelper.originVideoCoverIndex = 0;
        self.uploadHelper.hasChooseCover = NO;
    } else {
        self.uploadHelper.hasChooseCover = YES;
        self.uploadHelper.originVideoCoverIndex = originVideoCoverIndex;
    }
    
//    NSString *filePath = [NSString stringWithFormat:@"%@%@.mp4", NSTemporaryDirectory(), @([[NSDate date] timeIntervalSince1970])];
//    int result = [MDFastMP4Handler MP4FastWithSrcMP4Path:videoURL.path pDstMP4Path:filePath];
//    if (result >= 1) {
//        videoURL = [NSURL fileURLWithPath:filePath];
//    }

    self.uploadHelper.originVideoCover = originVideoCover;
    [self.uploadHelper prepareVideoResultWithURL:videoURL];

    //配置贴纸、文字、配乐、涂鸦、变速、特效滤镜等数据
    [self configureMomentVideoInfo];

    //从相册选的视频得判断是否有编辑过
    BOOL needSaveAlbum = NO;
    if (self.uploadHelper.videoInfo.path)
    {
        if (self.uploadHelper.videoInfo.isFromAlbum) {
            if ([self.moduleAggregate checkHasEditedVideo] || self.settingItem.hasCutVideo) {
                needSaveAlbum = YES;
            }
        } else {
            needSaveAlbum = YES;
        }
    }

    if (needSaveAlbum) {
        [PHPhotoLibrary saveVideoAtPath:[NSURL fileURLWithPath:self.uploadHelper.videoInfo.path] toAlbumWithName:@"VideoSDK" completion:nil];
    }

    //在主线程抛完成的handler，因为外界可能会更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.settingItem.completeBlock) {
            self.settingItem.completeBlock(self.uploadHelper.videoInfo);
        }
    });
}

- (void)didCutVideoFinish
{
    self.settingItem.videoInfo.hasCutVideo = YES;
}

//下载相关
- (void)didSaveVideoFinishWithVideoURL:(NSURL *)videoURL completeBlock:(void (^)(void))completBlock
{
    if (videoURL.path.isNotEmpty) {
        [PHPhotoLibrary saveVideoAtPath:videoURL toAlbumWithName:@"VideoSDK" completion:^(PHFetchResult<PHAsset *> * _, NSError * error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [[MDRecordContext appWindow] makeToast:[NSString stringWithFormat:@"保存媒体到相册出错: %@",error.localizedDescription] duration:1.5f position:CSToastPositionCenter];
                } else {
                    [[MDRecordContext appWindow] makeToast:@"已保存视频到本地相册" duration:1.5f position:CSToastPositionCenter];
                }
                
                if ([videoURL isKindOfClass:[NSURL class]]) {
                    [[NSFileManager defaultManager] removeItemAtURL:videoURL error:nil];
                }
                
                completBlock();
            });
        }];
        
    }else {
        completBlock();
    }
}

#pragma mark BBMediaStickerAdjustmentViewDelegate

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerWillBeginChange:(MDBaseSticker *)sticker frame:(CGRect)frame {
    [self updateBottomToolsWithAlpha:0 animate:YES];
    self.containerView.stickerDeleteBtn.alpha = 1.0f;
    
    [self.moduleAggregate selectSticker:sticker];
}

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidMove:(MDBaseSticker *)sticker frame:(CGRect)frame touchPoint:(CGPoint)point {
    CGPoint touchPoint = [view convertPoint:point toView:self.containerView.stickerDeleteBtn];
    CGRect touchFrame = CGRectMake(touchPoint.x -35, touchPoint.y -35, 70, 70);
    self.needDeleteSticker = CGRectIntersectsRect(self.containerView.stickerDeleteBtn.bounds, touchFrame);
    
    //除了直接接近删除框之外, 如果超越边界, 删除
    CGPoint viewCenter = CGPointMake(frame.origin.x+frame.size.width/2, frame.origin.y+frame.size.height/2);
    if (viewCenter.x > view.width || viewCenter.x < 0) {
        self.needDeleteSticker = YES;
    }
    
    if (viewCenter.y > view.height || viewCenter.y < 0) {
        self.needDeleteSticker = YES;
    }
    
    if (self.needDeleteSticker) {
        
        CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
        if (!CGAffineTransformEqualToTransform(scale, self.containerView.stickerDeleteBtn.transform)) {
            //需要删除状态使用红色
            UIImage *img = [UIImage imageNamed:@"sticker_delete_btn"];
            [self.containerView.stickerDeleteBtn setImage:img forState:UIControlStateNormal];
            self.containerView.stickerDeleteBtn.transform = scale;
        }
    } else {
        
        //非删除状态需要灰色
        UIImage *img = [UIImage imageNamed:@"sticker_delete_btn_2"];
        [self.containerView.stickerDeleteBtn setImage:img forState:UIControlStateNormal];
        self.containerView.stickerDeleteBtn.transform = CGAffineTransformIdentity;
    }
    
    //映射坐标
    MDRecordDynamicSticker *videoSticker = (MDRecordDynamicSticker *)sticker;
    videoSticker.bounds = [self filterMapRectWithOriginFrame:frame];
}

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidEndChange:(MDBaseSticker *)sticker frame:(CGRect)frame {
    [UIView animateWithDuration:0.3f animations:^{
        self.containerView.stickerDeleteBtn.alpha = .0f;
        self.containerView.stickerDeleteBtn.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (self.containerView.stickerDeleteBtn.alpha == 0.0f) {
            [self updateBottomToolsWithAlpha:self.isShowStickerVC ? 0 : 1 animate:NO];
        }
    }];
    
    
    if (self.needDeleteSticker) {
        [view removeSticker:sticker];
        self.needDeleteSticker = NO;
        [self.moduleAggregate removeASticker:sticker];
    }
}

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidPinch:(MDBaseSticker *)sticker frame:(CGRect)frame {
    MDRecordDynamicSticker *dynamicSticker = (MDRecordDynamicSticker*)sticker;
    
    //将屏幕坐标映射为视频分辨率内部坐标
    dynamicSticker.bounds = [self filterMapRectWithOriginFrame:frame];
}

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidRotate:(MDBaseSticker *)sticker angle:(CGFloat)angle {
    MDRecordDynamicSticker *dynamicSticker = (MDRecordDynamicSticker*)sticker;
    dynamicSticker.roll += angle;
}

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidAfterAdjust:(MDBaseSticker *)sticker frame:(CGRect)frame {
    MDRecordDynamicSticker *videoSticker = (MDRecordDynamicSticker*)sticker;
    
    //完成stickerAdjustView调整Frame后, 将屏幕坐标映射为视频分辨率内部坐标
    videoSticker.bounds = [self filterMapRectWithOriginFrame:frame];
}

#pragma mark MDMomentTextAdjustmentViewDelegate

- (void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerWillBeginChange:(MDMomentTextSticker *)sticker frame:(CGRect)frame {
    [self updateBottomToolsWithAlpha:0 animate:YES];
    self.containerView.stickerDeleteBtn.alpha = 1.0f;
}

- (void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerDidMove:(MDMomentTextSticker *)sticker frame:(CGRect)frame touchPoint:(CGPoint)point {
    CGPoint touchPoint = [view convertPoint:point toView:self.containerView.stickerDeleteBtn];
    CGRect touchFrame = CGRectMake(touchPoint.x -35, touchPoint.y -35, 70, 70);
    self.needDeleteSticker = CGRectIntersectsRect(self.containerView.stickerDeleteBtn.bounds, touchFrame);
    
    //除了直接接近删除框之外, 如果超越边界, 删除
    CGPoint viewCenter = CGPointMake(frame.origin.x+frame.size.width/2, frame.origin.y+frame.size.height/2);
    if (viewCenter.x > view.width || viewCenter.x < 0) {
        self.needDeleteSticker = YES;
    }
    
    if (viewCenter.y > view.height || viewCenter.y < 0) {
        self.needDeleteSticker = YES;
    }
    
    if (self.needDeleteSticker) {
        
        CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
        if (!CGAffineTransformEqualToTransform(scale, self.containerView.stickerDeleteBtn.transform)) {
            //需要删除状态使用红色
            UIImage *img = [UIImage imageNamed:@"sticker_delete_btn"];
            [self.containerView.stickerDeleteBtn setImage:img forState:UIControlStateNormal];
            self.containerView.stickerDeleteBtn.transform = scale;
        }
        
    } else {
        
        //非删除状态需要灰色
        UIImage *img = [UIImage imageNamed:@"sticker_delete_btn_2"];
        [self.containerView.stickerDeleteBtn setImage:img forState:UIControlStateNormal];
        self.containerView.stickerDeleteBtn.transform = CGAffineTransformIdentity;
    }
}

- (void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerDidEndChange:(MDMomentTextSticker *)sticker frame:(CGRect)frame {
    [UIView animateWithDuration:0.3f animations:^{
        self.containerView.stickerDeleteBtn.alpha = .0f;
        self.containerView.stickerDeleteBtn.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (self.containerView.stickerDeleteBtn.alpha == 0.0f) {
            [self updateBottomToolsWithAlpha:self.isShowStickerVC ? 0 : 1 animate:YES];
        }
    }];
    
    
    if (self.needDeleteSticker) {
        [view removeSticker:sticker];
        self.needDeleteSticker = NO;
        [self.moduleAggregate removeATextSticker:sticker];
    }
}

- (void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerDidTap:(MDMomentTextSticker *)sticker frame:(CGRect)frame {
    [view removeSticker:sticker];
    [self updateViewElementsWithAlpha:.0f animated:NO];
    
    [self.moduleAggregate removeATextSticker:sticker];
    
    self.handlingSticker = sticker;
    
    [self.moduleAggregate configTextEditViewDefaultText:sticker.text colorIndex:sticker.colorIndex];
}


#pragma mark - private 

- (void)updateViewElementsWithAlpha:(CGFloat)alpha animated:(BOOL)animated
{
    void(^action)(void) = ^(void) {
        self.containerView.cancelButton.alpha = alpha;
        self.containerView.doneBtn.alpha = alpha;
        self.containerView.reSendBtn.alpha = alpha;
        self.containerView.qualityBlockBtn.alpha = alpha;

        [self updateBottomToolsWithAlpha:alpha animate:NO];
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            action();
        }];
    }else {
        action();
    }
}

- (void)updateBottomToolsWithAlpha:(CGFloat)alpha animate:(BOOL)animated
{
    void(^action)(void) = ^(void) {
        self.containerView.buttonView.hidden = !alpha;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2f animations:^{
            action();
        }];
    }else {
        action();
    }
}

//将视图坐标大小, 映射到屏幕录制里的坐标
- (CGRect)filterMapRectWithOriginFrame:(CGRect)frame {
    CGSize videoSize = self.moduleAggregate.videoSize;
//    CGRect renderFrame = self.moduleAggregate.videoRenderFrame;
//    CGSize renderSize = renderFrame.size;
    CGSize renderSize = self.containerView.stickerAdjustView.bounds.size;
    
    CGFloat x = round((frame.origin.x / renderSize.width) * videoSize.width);
    CGFloat y = round((frame.origin.y / renderSize.height) * videoSize.height);
    CGFloat w = round((frame.size.width / renderSize.width) * videoSize.width);
    CGFloat h = round((frame.size.height / renderSize.height) * videoSize.height);
    
    CGRect videoFrame = CGRectMake(x, y, w, h);
    return videoFrame;
}

#pragma mark - 处理进度视图
- (MDBluredProgressView *)processingHUD {
    if (!_processingHUD) {
        NSString *tip = self.saveMode ? @"正在下载中" : @"正在合成中";
        _processingHUD = [[MDBluredProgressView alloc] initWithBlurView:self.containerView descText:tip needClose:YES];
        _processingHUD.userInteractionEnabled = YES;
        _processingHUD.progress = 0;
        
        __weak __typeof(self)weakSelf = self;
        [_processingHUD setViewCloseHandler:^{
            //防止频繁点击
            [weakSelf handleProgressCancel];
            
        }];
        [self.containerView addSubview:_processingHUD];
    }
    return _processingHUD;
}

- (void)handleProgressCancel
{
    [self.moduleAggregate cancelExport];
}

- (void)showProcessingHUD {
    self.processingHUD.progress = 0;
    if (_processingHUD.superview) {
        [self.containerView bringSubviewToFront:self.processingHUD];
    } else {
        [self.containerView addSubview:_processingHUD];
    }
    [self.processingHUD setHidden:NO];
}

- (void)hideProcessingHUD {
    _processingHUD.progress = 1;
    if (_processingHUD.superview) {
        [_processingHUD removeFromSuperview];
    }
    _processingHUD = nil;
}

- (void)updateProcessing:(CGFloat)process {
    _processingHUD.progress = process;
}

#pragma mark - 处理反转视频进度视图
- (MDBluredProgressView *)reverseProcessingHUD {
    if (!_reverseProcessingHUD) {
        NSString *tip = @"正在处理中";
        _reverseProcessingHUD = [[MDBluredProgressView alloc] initWithBlurView:self.containerView descText:tip needClose:YES];
        _reverseProcessingHUD.userInteractionEnabled = YES;
        _reverseProcessingHUD.progress = 0;
        
        __weak __typeof(self)weakSelf = self;
        [_reverseProcessingHUD setViewCloseHandler:^{
            //防止频繁点击
            [weakSelf handleReverseProgressCancel];
            
        }];
    }
    return _reverseProcessingHUD;
}

- (void)handleReverseProgressCancel
{
    [self.moduleAggregate cancelReverseOpertion];
}

- (void)showReverseProcessingHUD {
    self.reverseProcessingHUD.progress = 0;
    if (self.reverseProcessingHUD.superview) {
        [self.containerView bringSubviewToFront:self.reverseProcessingHUD];
    } else {
        [self.containerView addSubview:self.reverseProcessingHUD];
    }
    [self.reverseProcessingHUD setHidden:NO];
}

- (void)hideReverseProcessingHUD {
    _reverseProcessingHUD.progress = 1;
    if (_reverseProcessingHUD.superview) {
        [_reverseProcessingHUD removeFromSuperview];
    }
    _reverseProcessingHUD = nil;
}

- (void)updateReverseProcessing:(CGFloat)process {
    _reverseProcessingHUD.progress = process;
}

#pragma mark - 视频信息上传相关
- (MDVideoUploadHelper *)uploadHelper
{
    if (!_uploadHelper) {
        _uploadHelper = [[MDVideoUploadHelper alloc] init];
        _uploadHelper.videoInfo = self.settingItem.videoInfo;
    }
    
    return _uploadHelper;
}

- (void)configureMomentVideoInfo
{
    //数据打点
    self.uploadHelper.videoInfo.hasGraffiti = self.moduleAggregate.hasGraffiti;
    self.uploadHelper.videoInfo.dynamicStickerIds = [[NSMutableArray alloc] init];
    
    for (MDRecordBaseSticker *sticker in self.moduleAggregate.stickers) {
        if ([sticker.stickerId isNotEmpty]) {
            [self.uploadHelper.videoInfo.dynamicStickerIds addObjectSafe:sticker.stickerId];
        }
    }
    
    self.uploadHelper.videoInfo.decorateTexts = [NSMutableArray array];
    for (MDMomentTextSticker *sticker in self.moduleAggregate.textStickers) {
        [self.uploadHelper.videoInfo.decorateTexts addObjectSafe:sticker.text];
    }
    
    self.uploadHelper.videoInfo.musicId = self.moduleAggregate.musicId;
    self.uploadHelper.videoInfo.isLocalMusic = self.moduleAggregate.isLocalMusic;
    self.uploadHelper.videoInfo.isCutMusic = self.moduleAggregate.isMusicCut;
    
    self.uploadHelper.videoInfo.hasSpeedEffect = self.moduleAggregate.hasSpeedEffect;
    
    //特效滤镜
    NSArray *specialEffectsTypeArray = self.moduleAggregate.specialEffectsTypeArray;
    if (specialEffectsTypeArray.count) {
        self.uploadHelper.videoInfo.specialEffectsTypes = [specialEffectsTypeArray componentsJoinedByString:@","];
    }
    
    self.uploadHelper.videoInfo.videoCoverImage = self.uploadHelper.originVideoCover;
}

@end
