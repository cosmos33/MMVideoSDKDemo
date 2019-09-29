//
//  MDMusicEditPalletController.m
//  MDChat
//
//  Created by YZK on 2018/11/19.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicEditPalletController.h"
#import "MDMusicEditPalletHandler.h"

#import "MDMusicResourceUtility.h"
#import "MDMusicFavouriteManager.h"
#import "ReactiveCocoa/ReactiveCocoa.h"

#import "MDBeautyMusicVolumeView.h"
#import "MDSMSelectIntervalProgressView.h"

#import "MDMusicEditCardItem.h"
#import "MDMusicEditActionItem.h"

#import <POP/POP.h>
#import "MUAt8AlertBar.h"
#import "MUAlertBarDispatcher.h"
#import "MDBackgroundMusicDownloader.h"
#import "MDRecordNewMusicTrimView.h"
#import "Toast/Toast.h"
#import "MPMediaLibrary+CustomMediaLibrary.h"

@import MediaPlayer;

static CGFloat const kMusicEditPalletHeight = 263.0f;
static CGFloat const kMusicContentCornerRadius = 30.0f;
static CGFloat const kMusicHeadViewHeight = 52.0f;

@interface MDMusicEditPalletController ()
<
    MDBeautyMusicVolumeViewDelegate,
    MDMusicEditPalletHandlerDelegate,
    MDBackgroundMusicDownloaderDelegate,
    MDRecordNewMusicTrimViewDelegate,
    MPMediaPickerControllerDelegate
>

/********************************** UI相关 **********************************/
@property (nonatomic, strong) UIView                  *contentView;
@property (nonatomic, strong) UIView                  *headBottomLineView;
@property (nonatomic, strong) NSArray<UIView*>        *headButtonArray;
@property (nonatomic, strong) UIView                  *bottomView;
//voiceView
@property (nonatomic ,strong) MDBeautyMusicVolumeView *musicAudioView;
@property (nonatomic ,strong) UICollectionView        *collectionView;
@property (nonatomic ,strong) MDMusicEditPalletHandler *handler;
//cutEditView
@property (nonatomic, strong) UIImageView             *iconView;
@property (nonatomic, strong) UILabel                 *titleLabel;
@property (nonatomic, strong) UILabel                 *timeLabel;
//@property (nonatomic, strong) MDSMSelectIntervalProgressView *trimView;
@property (nonatomic, strong) MDRecordNewMusicTrimView *trimMusicView;

/********************************** 音乐进度条相关 **********************************/
@property (nonatomic, assign) CGFloat musicStartPercent;
@property (nonatomic, assign) CGFloat musicEndPercent;
@property (nonatomic, assign) CGFloat defaultMusicVolume;

/********************************** 音乐点选相关 **********************************/
@property (nonatomic, strong) MDMusicCollectionItem *preMusicItem; //外部带入的item
@property (nonatomic, assign) CMTimeRange           preMusicItemTimeRange; //外部带入的item的timeRange
@property (nonatomic, strong) MDMusicCollectionItem *currentSelectMusicItem; //当前选择的item
@property (nonatomic, assign) CMTime                currentDuration; //当前时长
@property (nonatomic, strong) MDMusicCollectionItem *lastMusicItem; //鼠标最后点选的item
@property (nonatomic, strong) NSMutableDictionary   *musicDownloadMap;

/********************************** 动画相关 **********************************/
@property (nonatomic, assign) BOOL isShowed;
@property (nonatomic, assign) BOOL isAnimating;


@end

@implementation MDMusicEditPalletController

- (instancetype)init {
    self = [super init];
    if (self) {
        [MDMusicFavouriteManager getCurrentFavouriteManager];
        [MDMusicFavouriteManager strongSelf];
        self.musicDownloadMap = [NSMutableDictionary dictionary];
        self.handler = [[MDMusicEditPalletHandler alloc] init];
    }
    return self;
}

- (void)dealloc {
    [MDMusicFavouriteManager weakSelf];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMusicEditPalletView];
}

- (void)setupMusicEditPalletView {
    self.view.frame = CGRectMake(0, MDScreenHeight-kMusicEditPalletHeight-HOME_INDICATOR_HEIGHT, MDScreenWidth, kMusicEditPalletHeight+HOME_INDICATOR_HEIGHT +kMusicContentCornerRadius);
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:[self createContentView]];
    
    [self setupHeadViewAndBottomView];
    [self setupVoiceBgView];
    [self setupCutEditBgView];
    
    [self.handler bindCollectionView:self.collectionView delagate:self];
}

#pragma mark - public

- (void)updateMusicItem:(MDMusicCollectionItem *)musicItem timeRange:(CMTimeRange)timeRange {
    if (musicItem && ![musicItem isKindOfClass:[MDMusicEditCardItem class]]) {
        musicItem = [MDMusicEditCardItem itemWithCollectionItem:musicItem];
    }
    self.preMusicItem = musicItem;
    self.preMusicItemTimeRange = timeRange;
    if (musicItem && ![musicItem resourceExist]) {
        [self downloadPreAutoMusicItem:musicItem];
    }
}

- (void)periodicTimeCallback:(CMTime)time {
    CMTimeRange timeRange = [MDMusicResourceUtility timeRangeWithStartPercent:self.musicStartPercent endPercent:self.musicEndPercent duration:self.currentDuration];
    NSTimeInterval offsetTime = fmodf(CMTimeGetSeconds(time), CMTimeGetSeconds(timeRange.duration));
    if (CMTIMERANGE_IS_INVALID(timeRange)) {
        return;
    }
    
    NSTimeInterval current = MAX(0, CMTimeGetSeconds(timeRange.start) + offsetTime);
    NSTimeInterval duration = CMTimeGetSeconds(self.currentDuration);
    if (duration > 0) {
        CGFloat progress = current / duration;
        progress = MAX(0, MIN(1, progress));
//        self.trimView.currentValue = progress;
        self.trimMusicView.currentValue = progress;
    }
}

//设置上边音量条的音量
- (void)setOriginDefaultMusicVolume:(CGFloat)volume {
    self.defaultMusicVolume = volume;
    [self.musicAudioView updateVolumeProgress:volume];
}


- (void)showAnimateWithCompleteBlock:(void (^)(void))completedBlock {
    if (self.isShowed || self.isAnimating) {
        return;
    }
    self.isShowed = YES;
    self.isAnimating = YES;
    
    if (self.preMusicItem) {
        if ([self.preMusicItem resourceExist]) {
            [self _selectedMusicCollectionItem:self.preMusicItem];
            [self _updateEditCutViewWithTimeRange:self.preMusicItemTimeRange];
        }
        [self.handler updateCurrentMusicItem:self.preMusicItem];
        self.preMusicItem = nil;
        self.preMusicItemTimeRange = kCMTimeRangeZero;
    }
    
    self.contentView.top = self.view.height;
    [self.contentView pop_removeAllAnimations];
    __weak __typeof(self) weakSelf = self;
    POPSpringAnimation *animationUpward = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    animationUpward.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, MDScreenWidth, self.contentView.height)];
    animationUpward.springBounciness = 7;
    animationUpward.springSpeed = 7;
    animationUpward.completionBlock = ^(POPAnimation *animation,BOOL finish) {
        if (finish) {
            weakSelf.isAnimating = NO;
            
            NSInteger count = 0; // [[MDContext currentUser] dbStateHoldProvider].showMusicPalletVolumeTipsCount;
            if (count == 0) {
//                CGRect frame = [self.musicAudioView convertRect:self.trimView.bounds toView:[MDRecordContext appWindow]];

//                MUAt8AlertBarModel *model = [MUAt8AlertBarModel new];
//                model.maskFrame = [UIApplication sharedApplication].delegate.window.frame;
//                model.title = @"滑动调节音量";
//                model.anchorPoint = CGPointMake(CGRectGetMidX(frame), frame.origin.y-5);
//                model.anchorType = MUAt8AnchorTypeBottom;
//                model.textColor = RGBCOLOR(50, 51, 51);
//                model.backgroundColor = [UIColor whiteColor];
//                model.anchorOffset = 0;
//                MUAlertBar *guideBar = [MUAlertBarDispatcher alertBarWithModel:model];
//                [[MDRecordContext appWindow] addSubview:guideBar];
            }
            if (completedBlock) {
                completedBlock();
            }
        }
    };
    [self.contentView pop_addAnimation:animationUpward forKey:@"animationUpward"];
}

- (void)hideAnimationWithCompleteBlock:(void(^)(void))completeBlock {
    if (!self.isShowed || self.isAnimating) {
        return;
    }
    self.isShowed = NO;
    self.isAnimating = YES;
    
    __weak __typeof(self) weakSelf = self;
    [self.contentView pop_removeAllAnimations];
    POPBasicAnimation *animationDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    animationDown.toValue = [NSValue valueWithCGRect:CGRectMake(0, self.view.height, MDScreenWidth, self.contentView.height)];
    animationDown.duration = 0.2f;
    animationDown.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        weakSelf.isAnimating = NO;
        [weakSelf.view removeFromSuperview];
        if (completeBlock) {
            completeBlock();
        }
    };
    [self.contentView pop_addAnimation:animationDown forKey:@"animationDown"];
}

- (void)downloadPreAutoMusicItem:(MDMusicCollectionItem *)musicItem {
    musicItem.downLoading = YES;
    
    [[MDBackgroundMusicDownloader shared] downloadItem:musicItem.musicVo completion:^(MDMusicBVO * _Nonnull bvo, NSURL * _Nonnull fileUrl, BOOL success) {
        musicItem.downLoading = NO;
        if (success && !self.currentSelectMusicItem) {
            [self _playWithCheckAssetValid:musicItem];
            [[MDMusicFavouriteManager getCurrentFavouriteManager] insertMusicItemToFavourite:musicItem];
        }
        [self.collectionView reloadData];
    }];
}

#pragma mark - event

- (void)headButtonClicked:(UIButton *)btn {
    [self _transitionWithIndex:btn.tag-1];
}

- (void)_transitionWithIndex:(NSInteger)index {
    UIView *btn = [self.headButtonArray objectAtIndex:index defaultValue:nil];
    
    CGRect bounds = self.bottomView.bounds;
    bounds.origin.x = MDScreenWidth*index;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.headBottomLineView.centerX = btn.centerX;
        self.bottomView.bounds = bounds;
    } completion:^(BOOL finished) {
        
        if (index == 1) {
            NSInteger count = 0;//[[MDContext currentUser] dbStateHoldProvider].showMusicPalletCutEditTipsCount;
            if (count == 0) {
//                CGRect frame = [self.trimView convertRect:self.trimView.bounds toView:[MDRecordContext appWindow]];
                CGRect frame = [self.trimMusicView convertRect:self.trimMusicView.bounds toView:[MDRecordContext appWindow]];
                
                MUAt8AlertBarModel *model = [MUAt8AlertBarModel new];
                model.maskFrame = [MDRecordContext appWindow].frame;
                model.title = @"滑动两端截取音乐";
                model.anchorPoint = CGPointMake(CGRectGetMidX(frame), frame.origin.y-8);
                model.anchorType = MUAt8AnchorTypeBottom;
                model.textColor = RGBCOLOR(50, 51, 51);
                model.backgroundColor = [UIColor whiteColor];
                model.anchorOffset = 0;
                MUAlertBar *guideBar = [MUAlertBarDispatcher alertBarWithModel:model];
                [[MDRecordContext appWindow] addSubview:guideBar];
            }
        }
    }];
}

- (void)handleMusicWithStartPercent:(CGFloat)startPercent endPercent:(CGFloat)endPercent {
    if ([self.delegate respondsToSelector:@selector(musicEditPallet:didPickMusicItems:timeRange:)]) {
        CMTimeRange timeRange = [MDMusicResourceUtility timeRangeWithStartPercent:startPercent endPercent:endPercent duration:self.currentDuration];
        [self _setTimeLabelTextWithTime:CMTimeGetSeconds(timeRange.duration)];
        [self.delegate musicEditPallet:self didPickMusicItems:self.currentSelectMusicItem timeRange:timeRange];
    }
}

#pragma mark MDBeautyMusicVolumeViewDelegate

- (void)progressDidChange:(CGFloat)progress {
    //progress是配乐的音量
    if ([self.delegate respondsToSelector:@selector(musicEditPallet:didEditOriginalVolume:musicVolume:)]) {
        [self.delegate musicEditPallet:self didEditOriginalVolume:(1-progress) musicVolume:progress];
    }
}

#pragma mark - MDMusicEditPalletHandlerDelegate

- (void)collectionViewDidSelectItem:(MDMusicBaseCollectionItem *)baseItem indexPath:(NSIndexPath *)indexPath {
    if ([baseItem isKindOfClass:[MDMusicEditCardItem class]]) {
        [self _handleSelectedMusicCollectionItem:(MDMusicEditCardItem *)baseItem indexPath:indexPath];
    }else if ([baseItem isKindOfClass:[MDMusicEditActionItem class]]) {
        [self _handleSelectedActionItem:(MDMusicEditActionItem *)baseItem indexPath:indexPath];
    }
}

- (void)_handleSelectedMusicCollectionItem:(MDMusicCollectionItem *)item indexPath:(NSIndexPath *)indexPath {
    self.lastMusicItem = item;
    if ([item resourceExist]) {
        if([[MDMusicResourceUtility keyWithMusicBVO:self.lastMusicItem.musicVo] isEqualToString:[MDMusicResourceUtility keyWithMusicBVO:self.currentSelectMusicItem.musicVo]]) {
            [self _transitionWithIndex:1];
        }else {
            [self _playWithCheckAssetValid:item];
        }
    }else if (!item.downLoading){
        if (![item.musicVo.remoteUrl isNotEmpty] || ![item.musicVo.musicID isNotEmpty]) {
            [[MDRecordContext appWindow] makeToast:@"远程资源异常" duration:1.5f position:CSToastPositionCenter];
            return;
        }
        item.downLoading = YES;
        [self.collectionView reloadData];

        //去下载
        @weakify(self);
        void (^completion)(NSURL *fileURL, BOOL success) = ^(NSURL *fileURL, BOOL success){
            @strongify(self);
            item.downLoading = NO;

            if (!success) {
                [self.view makeToast:@"请检查网络设置" duration:1.5f position:CSToastPositionCenter];
            } else {
                if([[MDMusicResourceUtility keyWithMusicBVO:self.lastMusicItem.musicVo] isEqualToString:[MDMusicResourceUtility keyWithMusicBVO:item.musicVo]]) {//若果是当前选中的
                    [self _playWithCheckAssetValid:item];
                }
            }
            [self.collectionView reloadData];
        };

        [self.musicDownloadMap setObjectSafe:[completion copy] forKey:[MDMusicResourceUtility keyWithMusicBVO:item.musicVo]];
        [[MDBackgroundMusicDownloader shared] downloadItem:item.musicVo bind:self];
    }
}

- (void)startDownloadWithItem:(MDMusicBVO *)item {
    
}

- (void)finishDownloadWithItem:(MDMusicBVO *)bvo fileUrl:(NSURL *)fileUrl success:(BOOL)success {
    //下载完成
    void (^completion)(NSURL *fileURL, BOOL success) = [self.musicDownloadMap objectForKey:[MDMusicResourceUtility keyWithMusicBVO:bvo] defaultValue:nil];
    if (completion) completion(fileUrl, success);
    [self.musicDownloadMap removeObjectForKey:[MDMusicResourceUtility keyWithMusicBVO:bvo]];
}


- (BOOL)_playWithCheckAssetValid:(MDMusicCollectionItem *)item {
    BOOL isValid = YES;
    if (![MDMusicResourceUtility checkAssetValidWithURL:item.resourceUrl sizeConstraint:NO]) {
        isValid = NO;
    } else {
        [self _selectedMusicCollectionItem:item];
        if ([self.delegate respondsToSelector:@selector(musicEditPallet:didPickMusicItems:timeRange:)]) {
            [self.delegate musicEditPallet:self didPickMusicItems:item timeRange:CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity)];
        }
    }
    return isValid;
}

- (void)_selectedMusicCollectionItem:(MDMusicCollectionItem *)item {
    MDMusicCollectionItem *oldItem = self.currentSelectMusicItem;
    oldItem.selected = NO;
    
    self.currentSelectMusicItem = item;
    self.currentSelectMusicItem.selected = YES;
    
    if ([item resourceExist]) {
        AVAsset *asset = [AVURLAsset URLAssetWithURL:item.resourceUrl options:nil];
        self.currentDuration = asset.duration;

        if (self.musicAudioView.progress == 0) {
            [self setOriginDefaultMusicVolume:0.5];
            [self progressDidChange:0.5];
        }
    }else {
        self.currentDuration = kCMTimeZero;
    }
    
    self.trimMusicView.duration = CMTimeGetSeconds(self.currentDuration);
    
    [self.collectionView reloadData];
    [self _updateEditCutViewWithMusicItem:item];
    
    //如果本次选中的音乐不是在我的收藏里的选中的，加入我的收藏中顶置
    if(item && ![item.musicVo.categoryID isEqualToString:kMusicMyFavouriteCategoryID]) {
        [[MDMusicFavouriteManager getCurrentFavouriteManager] insertMusicItemToFavourite:[item favouriteCopyItem]];
    }
}

- (void)_handleSelectedActionItem:(MDMusicEditActionItem *)item indexPath:(NSIndexPath *)indexPath {
    switch (item.type) {
        case MDMusicEditActionTypeLibrary:
        {
            
        }
            break;
        case MDMusicEditActionTypeClear:
        {
            [self _clearMusic];
        }
            break;
        case MDMusicEditActionTypeLocal:
            [self showLocalMusics];
            break;
    }
}

- (void)_clearMusic {
    [self _selectedMusicCollectionItem:nil];

    if ([self.delegate respondsToSelector:@selector(musicEditPalletDidClearMusic:)]) {
        [self.delegate musicEditPalletDidClearMusic:self];
    }
}

- (void)showLocalMusics {
    [MPMediaLibrary checkMediaPickerWithAuthorizedHandler:^{
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
        mediaPicker.delegate = self;
        [self presentViewController:mediaPicker animated:YES completion:nil];
    } unAuthorizedHandler:nil];
}

#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    __weak __typeof(self) weakSelf = self;
    /***** 先关闭页面 *****/
    [self dismissViewControllerAnimated:YES completion:^{
        __strong __typeof(self) self = weakSelf;
        MPMediaItem *item = mediaItemCollection.items.firstObject;
        
        if (!item.assetURL) {
            // 版权保护
            return;
        }
        
        AVAsset *asset = [AVAsset assetWithURL:item.assetURL];
        BOOL valid = asset.playable;
        
        if (!valid) {
            return;
        }
        
        valid = CMTimeGetSeconds(asset.duration) <= 60.0f * 7;
        
        if (!valid) {
            return;
        }
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
        exporter.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        valid = exporter.estimatedOutputFileLength <= 20 * 1024 * 1024;
        if (!valid) {
            return;
        }
        
        NSString *musicID = [@(item.persistentID) stringValue];
        MDMusicBVO *bvo = [[MDMusicBVO alloc] init];
        bvo.musicID = musicID;
        bvo.title = item.title;
        bvo.author = item.artist;
        bvo.categoryID = @"kMusicMyFavouriteCategoryID";
        bvo.cover = @"https://s.momocdn.com/w/u/others/2018/11/23/1542942303189-icon_music_local_cover@2x.png";
        
        MDMusicCollectionItem *musicItem = [[MDMusicCollectionItem alloc] init];
        musicItem.musicVo = bvo;
        musicItem.isLocal = YES;
        musicItem.resourceUrl = item.assetURL;
        
        musicItem = [MDMusicEditCardItem itemWithCollectionItem:musicItem];
        [self _selectedMusicCollectionItem:musicItem];
        [self.handler updateCurrentMusicItem:musicItem];
        [self _updateEditCutViewWithTimeRange:exporter.timeRange];
        
        if ([self.delegate respondsToSelector:@selector(musicEditPallet:didPickMusicItems:timeRange:)]) {
            [self.delegate musicEditPallet:self didPickMusicItems:musicItem timeRange:exporter.timeRange];
        }
    }];
}


- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private

- (void)_updateMusicTitle:(NSString *)title {
    self.titleLabel.text = title;
    CGFloat width = [self.titleLabel sizeThatFits:self.titleLabel.bounds.size].width;
    width = MIN(MDScreenWidth-60, width);
    self.titleLabel.width = width;
    CGFloat left = (MDScreenWidth-self.titleLabel.width)/2.0;
    self.titleLabel.left = left+7.5;
    self.iconView.left = left-7.5;
}

- (void)_updateEditCutViewWithMusicItem:(MDMusicCollectionItem *)musicItem {
    if (musicItem) {
        [self _updateMusicTitle:musicItem.displayTitle];
//        self.trimView.disable = NO;
        self.trimMusicView.disable = NO;
    }else {
        [self _updateMusicTitle:@"无音乐"];
//        self.trimView.disable = YES;
        self.trimMusicView.disable = YES;
    }
    [self.musicAudioView setMusicNameText:musicItem.displayTitle];
    [self _setTimeLabelTextWithTime:CMTimeGetSeconds(self.currentDuration)];

    self.trimMusicView.beginTime = 0;
//    self.trimView.beginValue = 0;
//    self.trimView.endValue = 1.0;
//    self.trimView.currentValue = 0;
    
    self.musicStartPercent = 0.0;
    self.musicEndPercent = 1.0;
}

- (void)_updateEditCutViewWithTimeRange:(CMTimeRange)timeRange {
    if ( CMTimeCompare(self.currentDuration, kCMTimeZero) > 0 && !CMTIMERANGE_IS_EMPTY(timeRange)) {
        CMTime beginTime = timeRange.start;
        CMTime endTime = CMTimeRangeGetEnd(timeRange);
        
        CGFloat beginValue = CMTimeGetSeconds(beginTime) / CMTimeGetSeconds(self.currentDuration);
        CGFloat endValue = CMTimeGetSeconds(endTime) / CMTimeGetSeconds(self.currentDuration);
        
        if (beginValue<0 || beginValue>1 || endValue<0 || endValue>1 || beginValue>=endValue) {
            return;
        }
        
//        self.trimView.beginValue = beginValue;
//        self.trimView.endValue = endValue;
//        self.trimView.currentValue = beginValue;
        self.trimMusicView.beginTime = CMTimeGetSeconds(beginTime);
        
        self.musicStartPercent = beginValue;
        self.musicEndPercent = endValue;
        [self _setTimeLabelTextWithTime:CMTimeGetSeconds(timeRange.duration)];
    }
}

- (void)_resetEditCutView {
    [self _updateMusicTitle:@"无音乐"];
    [self _setTimeLabelTextWithTime:0];
    self.trimMusicView.disable = YES;
//    self.trimView.disable = YES;
//    self.trimView.beginValue = 0;
//    self.trimView.endValue = 1.0;
//    self.trimView.currentValue = 0;
    
    self.musicStartPercent = 0.0;
    self.musicEndPercent = 1.0;
}

- (void)_setTimeLabelTextWithTime:(NSTimeInterval)time {
    NSString *timeStirng = time>0 ? [MDRecordContext formatRemainSecondToStardardTime:time] : @"00:00";
    self.timeLabel.text = timeStirng;
}

#pragma mark - setup UI

- (UIView *)createContentView {
    if(!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.layer.cornerRadius = 10.0;
        _contentView.layer.masksToBounds = YES;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *bgView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        bgView.frame = _contentView.bounds;
        [_contentView addSubview:bgView];
    }
    return _contentView;
}

- (void)setupHeadViewAndBottomView {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, kMusicHeadViewHeight)];
    [self.contentView addSubview:headView];

    UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceButton.frame = CGRectMake(22, 15, 40, 30);
    voiceButton.tag = 1;
    voiceButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [voiceButton setTitle:@"音量" forState:UIControlStateNormal];
    [voiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [voiceButton setTitleColor:RGBACOLOR(255, 255, 255, 0.3) forState:UIControlStateSelected];
    [voiceButton addTarget:self action:@selector(headButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:voiceButton];
    
    UIButton *cutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cutButton.frame = CGRectMake(78, 15, 40, 30);
    cutButton.tag = 2;
    cutButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [cutButton setTitle:@"截取" forState:UIControlStateNormal];
    [cutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cutButton setTitleColor:RGBACOLOR(255, 255, 255, 0.3) forState:UIControlStateSelected];
    [cutButton addTarget:self action:@selector(headButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:cutButton];
    
    self.headButtonArray = @[voiceButton,cutButton];
    
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, headView.height-2.5, 10, 2)];
    lineView.centerX = voiceButton.centerX;
    lineView.layer.cornerRadius = 0.5;
    lineView.layer.masksToBounds = YES;
    lineView.backgroundColor = [UIColor whiteColor];
    [headView addSubview:lineView];
    self.headBottomLineView = lineView;
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(28, headView.height-0.5, headView.width-28*2, 0.5);
    lineLayer.backgroundColor = RGBACOLOR(255, 255, 255, 0.1).CGColor;
    [headView.layer addSublayer:lineLayer];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kMusicHeadViewHeight, MDScreenWidth, self.contentView.height-kMusicHeadViewHeight)];
    [self.contentView addSubview:self.bottomView];
}

- (void)setupVoiceBgView {
    CGRect frame = {.origin=CGPointZero, .size=self.bottomView.bounds.size};
    UIView *voiceBgView = [[UIView alloc] initWithFrame:frame];
    [self.bottomView addSubview:voiceBgView];
    
    self.musicAudioView = [[MDBeautyMusicVolumeView alloc] initWithFrame:CGRectMake(13, 0, voiceBgView.width-13*2, kMusicVolumeViewHeight)];
    self.musicAudioView.delegate = self;
    [self.musicAudioView updateVolumeProgress:self.defaultMusicVolume];
    [voiceBgView addSubview:self.musicAudioView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60, 90);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 12;
    layout.sectionInset = UIEdgeInsetsMake(0, 13.5, 0, 13.5);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 89, voiceBgView.width, 90) collectionViewLayout:layout];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    if ([self.collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        if (@available(iOS 10.0, *)) {
            self.collectionView.prefetchingEnabled = NO;
        }
    }
    self.collectionView.backgroundColor = [UIColor clearColor];
    [voiceBgView addSubview:self.collectionView];
}

- (void)setupCutEditBgView {
    CGRect frame = {.origin=CGPointZero, .size=self.bottomView.bounds.size};
    UIView *cutEditBgView = [[UIView alloc] initWithFrame:frame];
    cutEditBgView.left = MDScreenWidth;
    [self.bottomView addSubview:cutEditBgView];

    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 32.5, 11, 11)];
    [self.iconView setImage:[UIImage imageNamed:@"recordSDK-icon_music_edit_play"]];
    [cutEditBgView addSubview:self.iconView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 10, 16)];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColor = [UIColor whiteColor];
    [cutEditBgView addSubview:self.titleLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 30, 13)];
    self.timeLabel.centerX = cutEditBgView.width/2.0;
    self.timeLabel.font = [UIFont systemFontOfSize:9];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.alpha = 0.43;
    self.timeLabel.text = @"00:00";
    [cutEditBgView addSubview:self.timeLabel];
    
    _trimMusicView = [[MDRecordNewMusicTrimView alloc] initWithFrame:CGRectMake(7, 76, MDScreenWidth - 14, 70)];
    [cutEditBgView addSubview:_trimMusicView];
    _trimMusicView.delegate = self;

    [self _resetEditCutView];
}

#pragma mark - trimMusicView delegate

- (void)valueChanged:(MDRecordNewMusicTrimView *)view startPercent:(CGFloat)startPercent endPercent:(CGFloat)endPercent {
    NSTimeInterval duration = CMTimeGetSeconds(self.currentDuration);
    if (duration == 0) {
        return;
    }
    
    self.musicStartPercent = startPercent;
    self.musicEndPercent = endPercent;
    [self handleMusicWithStartPercent:self.musicStartPercent endPercent:self.musicEndPercent];
}

@end
