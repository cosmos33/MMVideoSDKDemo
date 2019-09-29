//
//  MDNewAssetContainerController.m
//  MDChat
//
//  Created by sdk on 2018/9/3.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDNewAssetContainerController.h"
#import "MDNewAssetAlbumController.h"  //相册选择页

#import "MDTabSegmentView.h"
#import "SDDownloadProgressView.h"
#import "MDBluredProgressView.h"

//#import "MDAlbumVideoDynamicEffectModel.h"
#import "MDAlbumiCloudAssetHelper.h"

#import <KVOController/KVOController-umbrella.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "MDRecordImageResult.h"
#import "Toast/Toast.h"

@interface MDNewAssetContainerController ()
<UIScrollViewDelegate,
MDAssetCollectionViewControllerDelegate,
MDNewAssetAlbumControllerDelegate>

@property (nonatomic, strong) UIView           *headView;
@property (nonatomic, strong) UIView           *headContentView;
@property (nonatomic, strong) UIButton         *backButton;
@property (nonatomic, strong) UIButton         *finishButton;
@property (nonatomic, strong) MDTabSegmentView *segmentView;
@property (nonatomic, strong) UIScrollView     *pageView;

@property (nonatomic, strong) MDUnifiedRecordSettingItem *item;
@property (nonatomic, strong) NSArray                    *segmentArray;
@property (nonatomic, strong) NSArray                    *segmentTitleArray;

@property (nonatomic, strong          ) NSMutableArray                  *innerVCLArray;
@property (nonatomic, assign          ) NSInteger                       currentIndex;
@property (nonatomic, weak, readonly  ) MDAssetCollectionViewController *currentVCL;

@property (nonatomic, assign) BOOL couldShowTakePicture;
@property (nonatomic, assign) BOOL isLoadingPicture;
//@property (nonatomic, strong) MDAlbumVideoDynamicEffectModel *model;

@end

@implementation MDNewAssetContainerController

- (instancetype)initWithInitialItem:(MDUnifiedRecordSettingItem *)item couldShowTakePicture:(BOOL)enable {
    NSArray *segmentArray = nil;
    BOOL onlyPhoto = (item.assetMediaType == MDAssetMediaTypeOnlyPhoto);
    if((item.accessSource == MDVideoRecordAccessSource_AlbumVideo || item.accessSource == MDVideoRecordAccessSource_Feed) && !onlyPhoto){
        if (item.onlyVideoAlbum) {
            segmentArray = @[];
        }else {
            segmentArray = @[@(MDAssetCollectionViewTypeAll),@(MDAssetCollectionViewTypeVideo)];
        }
    }else if (item.accessSource == MDVideoRecordAccessSource_AlbumVideoChoosePicture){
        segmentArray = @[];
    }
    else if (item.accessSource == MDVideoRecordAccessSource_RegLogin && MDScreenHeight > 480){// 4s及以下 不支持使用
        segmentArray = @[@(MDAssetCollectionViewTypeSelfie),
                              @(MDAssetCollectionViewTypePortrait),
                              @(MDAssetCollectionViewTypeAll)];
    }
    else{
        segmentArray = @[@(MDAssetCollectionViewTypeAll)];
    }

    return [self initWithInitialItem:item segment:segmentArray couldShowTakePicture:enable];
}

- (instancetype)initWithInitialItem:(MDUnifiedRecordSettingItem *)item segment:(NSArray *)segment couldShowTakePicture:(BOOL)enable{
    self = [super init];
    if (self) {
        self.segmentArray = segment;
        self.item = item;
        self.couldShowTakePicture = enable;
        self.innerVCLArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.item.levelType = MDUnifiedRecordLevelTypeAsset;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configUI];
    [self configControllers];
}


- (void)configUI{
    [self.view addSubview:self.headView];
    [self.headView addSubview:self.headContentView];
    self.headContentView.bottom = self.headView.height;
    
    //顶部子视图
    [self.headContentView addSubview:self.backButton];
    [self.headContentView addSubview:self.segmentView];
    [self.headContentView addSubview:self.finishButton];
    self.finishButton.right = self.headContentView.width - 12;
    
    [self.view addSubview:self.pageView];
}

- (void)configControllers{
    [self.innerVCLArray removeAllObjects];
    NSInteger i = 0;
    
    __weak typeof(self) weakSelf = self;
    for (NSNumber *num in self.segmentArray) {
        MDAssetCollectionViewType pageType = [num integerValue];
        MDAssetCollectionViewController *assetCollectionVCL = [self createAssetCollectionVCLWithPageTpe:pageType];
        [assetCollectionVCL setSelectLimit:self.item.selectionLimit];
        if (pageType == MDAssetCollectionViewTypeAll) {
            assetCollectionVCL.userFeedShowModel = self.userFeedShowModel;
        } else if (pageType == MDAssetCollectionViewTypeVideoAlbum && self.item.accessSource != MDVideoRecordAccessSource_AlbumVideoChoosePicture) {
            [assetCollectionVCL setSelectLimit:kAlbumVideoPictureMaxCount];
        }
        assetCollectionVCL.viewDidLoadCallback = ^(MDAssetCollectionViewController *viewController, UIView *view) {
            view.frame = CGRectMake(weakSelf.pageView.width * i, 0, weakSelf.pageView.width, weakSelf.pageView.height);
            [weakSelf.pageView addSubview:view];
        };
        [self.innerVCLArray addObjectSafe:assetCollectionVCL];
        i++;
        
        //延时1秒触发其他controller的viewDidLoad
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [assetCollectionVCL view];
        });
    }
    [self anchorBySettingItem];
}

- (void)anchorBySettingItem{
    NSInteger index = 0;
    switch (self.item.assetLevelType) {
        case MDAssetAlbumLevelTypeAlbumVideo:
            index = [self.segmentArray indexOfObject:@(MDAssetCollectionViewTypeVideoAlbum)];
            break;
        case MDAssetAlbumLevelTypeAll:
            index = [self.segmentArray indexOfObject:@(MDAssetCollectionViewTypeAll)];
            break;
        case MDAssetAlbumLevelTypeVideo:
            index = [self.segmentArray indexOfObject:@(MDAssetCollectionViewTypeVideo)];
            break;
        case MDAssetAlbumLevelTypePortrait:
            index = [self.segmentArray indexOfObject:@(MDAssetCollectionViewTypePortrait)];
            break;
        case MDAssetAlbumLevelTypeSelfie:
        {
            index = [self defaultIndexOfTypeSelfie];
        }
            break;
        default:
            index = [self.segmentArray indexOfObject:@(MDAssetCollectionViewTypeAll)];
            break;
    }
    
    if(index < 0 || index >= self.segmentArray.count){
        index = 0;
    }
    
    self.currentIndex = -1;
    [self exchangeCurrentControllerWithIndex:index];
    
    MDAssetCollectionViewController *assetCollectionVCL = [self.innerVCLArray objectAtIndex:index defaultValue:nil];
    [assetCollectionVCL view];
    
    [self.segmentView setCurrentLabelIndex:self.currentIndex animated:NO];
    [self.pageView setContentOffset:CGPointMake(self.pageView.width * self.currentIndex, 0) animated:NO];
}

- (NSInteger)defaultIndexOfTypeSelfie
{
    NSInteger index = 0;
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits options:nil];
    PHAssetCollection *assetCollection = smartAlbums.firstObject;
    if (smartAlbums.count > 0) {
        PHFetchResult *group = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        if (group.count > 0) {
            index = [self.segmentArray indexOfObject:@(MDAssetCollectionViewTypeSelfie)];
        }else {
            index = [self.segmentArray indexOfObject:@(MDAssetCollectionViewTypeAll)];
        }
    }else {
        index = [self.segmentArray indexOfObject:@(MDAssetCollectionViewTypeAll)];
    }
    return index;
}




#pragma mark - MDAssetCollectionViewControllerDelegate

- (void)selectedCountDidChange:(NSInteger)count{
    UIColor *titleColor = count > 0 ? RGBCOLOR(59, 179, 250) : RGBCOLOR(170, 170, 170);
    NSString *title = count > 0 ? [NSString stringWithFormat:@"完成(%ld)",(long)count] : @"完成";
    
    [self.finishButton setTitleColor:titleColor forState:UIControlStateNormal];
    [self.finishButton setTitle:title forState:UIControlStateNormal];
}

- (void)didClickTakePictureAction{
    if ([self.delegate respondsToSelector:@selector(assetContainerPickerControllerDidTapTakePicture)]) {
        [self.delegate assetContainerPickerControllerDidTapTakePicture];
    }
}

- (void)didFinishSelectedToAlbumVideo{
//    [self loadResourceAndGotoAlbumVC];
}

- (BOOL)currentVCLIsActive:(MDAssetCollectionViewController *)target{
    BOOL superActive = NO;
    if ([self.delegate respondsToSelector:@selector(assetContainerPickerControllerIsActive:)]) {
        superActive = [self.delegate assetContainerPickerControllerIsActive:self];
    }
    if(superActive && self.currentVCL == target){
        return YES;
    }
    return NO;
}

#pragma mark - Action

- (void)goBackAction {
    //返回
    if(self.fromCamera){
        if ([self.delegate respondsToSelector:@selector(assetContainerPickerControllerDidTapBackByTransition)]) {
            [self.delegate assetContainerPickerControllerDidTapBackByTransition];
        }
    }else if (self.item.completeHandler) {
        self.item.completeHandler(nil);
        
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)finishSelected {
    //完成选择
    if (self.isLoadingPicture) {
        return;
    }
    
    if (self.currentVCL.pageType == MDAssetCollectionViewTypeVideoAlbum) {
        if (self.item.accessSource == MDVideoRecordAccessSource_AlbumVideoChoosePicture) {
            if (self.currentVCL.assetState.selectedCount <= 0) {
                return;
            }
            __weak typeof(self) weakSelf = self;
            [self loadSelectedPicturesWithCompletion:^(NSArray *items) {
                if (weakSelf.item.completeHandler) {
                    MDRecordImageResult *imageResult = [[MDRecordImageResult alloc] init];
                    imageResult.photoItems = weakSelf.currentVCL.assetState.selectedItemArray;
//                    imageResult.recordLog = self.item.recordLog;
                    imageResult.fromAlbum = YES;
                    weakSelf.item.completeHandler(imageResult);
                }
            }];
        } else {
            if (self.currentVCL.assetState.selectedCount < kAlbumVideoPictureMinCount) {
                [[MDRecordContext appWindow] makeToast:[NSString stringWithFormat:@"影集至少需要选择%d张图片",kAlbumVideoPictureMinCount] duration:1.5f position:CSToastPositionCenter];
                return;
            }
//            [self loadResourceAndGotoAlbumVC];
        }
        return;
    }
    
    if (self.currentVCL.assetState.selectedCount > 0) {
        self.isLoadingPicture = YES;
        __weak typeof(self) weakSelf = self;
        [[MDAlbumiCloudAssetHelper sharedInstance] loadOriginImageFromPhotoItemArray:self.currentVCL.assetState.selectedItemArray cancelBlock:^{
            weakSelf.isLoadingPicture = NO;
        } completeBlock:^(NSArray<MDPhotoItem *> * _Nonnull resultArray) {
            if (weakSelf.item.completeHandler) {
                MDRecordImageResult *imageResult = [[MDRecordImageResult alloc] init];
                imageResult.photoItems = resultArray;
//                imageResult.recordLog = self.item.recordLog;
                imageResult.fromAlbum = YES;
                weakSelf.item.completeHandler(imageResult);
            }
        }];
//        [MDActionManager handleLocaRecord:[NSString stringWithFormat:@"album_finish_click_%@",self.item.recordLog.logString]];

        //8.2添加打点
//        if (self.item.accessSource == MDVideoRecordAccessSource_Chat) {
//            [MDActionManager handleLocaRecord:[NSString stringWithFormat:@"chatsendimagecount:%@", @([self.currentVCL.assetState selectedCount])]];
//        }
    }
}


#pragma mark - 打开影集

//- (void)loadResourceAndGotoAlbumVC {
//    if (self.isLoadingPicture) {
//        return;
//    }
//    self.isLoadingPicture = YES;
//    [MDActionManager handleLocaRecord:[NSString stringWithFormat:@"live_photo_finish_click_%@",self.item.recordLog.logString]];
//
//    @weakify(self);
//    [[MDAlbumiCloudAssetHelper sharedInstance] loadLivePhotoImageFromPhotoItemArray:self.currentVCL.assetState.selectedItemArray cancelBlock:^{
//        @strongify(self);
//        self.isLoadingPicture = NO;
//    } completeBlock:^(NSArray<MDPhotoItem *> * _Nonnull resultArray) {
//        @strongify(self);
//
//        MDAlbumVideoDynamicEffectModel *model = [MDAlbumVideoDynamicEffectModel randomEffectModel];
//        BOOL modelLoadFinish = ![model isNeedDownload];
//        if (!modelLoadFinish) {
//            self.model = model;
//
//            MDBluredProgressView *processingHUD = [[MDBluredProgressView alloc] initWithBlurView:self.view descText:@"正在加载资源" needClose:YES];
//            processingHUD.userInteractionEnabled = YES;
//            processingHUD.progress = 0;
//
//            __weak __typeof(self)weakSelf = self;
//            [processingHUD setViewCloseHandler:^{
//                [weakSelf.model cancelDownload];
//            }];
//            [[MDContext appWindow] addSubview:processingHUD];
//
//            [model startDownloadWithProgress:^(float progress) {
//                processingHUD.progress = progress;
//            } completion:^(MDAlbumVideoDynamicEffectModel *model, BOOL result) {
//                [processingHUD removeFromSuperview];
//                weakSelf.isLoadingPicture = NO;
//                if (!result) {
//                    [[MDContext sharedIndicate] showWarningInView:weakSelf.view withText:@"资源下载失败" timeOut:1.5];
//                    return;
//                }
//                [weakSelf openAlbumVCL:resultArray effectModel:model];
//            }];
//        }else {
//            self.isLoadingPicture = NO;
//            [self openAlbumVCL:resultArray effectModel:model];
//        }
//    }];
//}

- (void)loadSelectedPicturesWithCompletion:(void(^)(NSArray *items))completion {
    self.isLoadingPicture = YES;
    
    @weakify(self);
    [[MDAlbumiCloudAssetHelper sharedInstance] loadLivePhotoImageFromPhotoItemArray:self.currentVCL.assetState.selectedItemArray cancelBlock:^{
        @strongify(self);
        self.isLoadingPicture = NO;
    } completeBlock:^(NSArray<MDPhotoItem *> * _Nonnull resultArray) {
        self.isLoadingPicture = NO;
        if (completion) completion(resultArray);
    }];
}

//- (void)openAlbumVCL:(NSArray *)items effectModel:(MDAlbumVideoDynamicEffectModel *)model {
//    MDAlbumVideoEditItem *item = [[MDAlbumVideoEditItem alloc] init];
//    item.albumArray = items;
//    item.effectModel = model;
//    item.backgroundMusicItem = model.musicItem;
//
//    item.lockTopic = self.item.lockTopic;
//    item.hideTopicEntrance = self.item.hideTopicEntrance;
//    item.maxUploadCount = kAlbumVideoPictureMaxCount;
//    item.minUploadCount = kAlbumVideoPictureMinCount;
//    item.needWaterMark = self.item.needWaterMark;
//
//    item.videoInfo = [[MDRecordVideoResult alloc] init];
//    item.videoInfo.recordLog = self.item.recordLog;
//    item.videoInfo.topicID = self.item.topicId;
//    item.videoInfo.themeID = self.item.themeId;
//    item.videoInfo.accessSource = self.item.accessSource;
//
//    item.completeBlock = self.item.completeHandler;

//    MDAlbumVideoEditController *vc = [[MDAlbumVideoEditController alloc] initWithSettingItem:item];

//    for(MDAssetCollectionViewController *vcl in self.innerVCLArray){
//        [vcl clearOriginImage];
//    }
//}

#pragma mark - MDNewAssetAlbumController(相册分类controller) && Delegate

- (void)showAssetAlbumController {
    MDNewAssetAlbumController *controller = [[MDNewAssetAlbumController alloc] init];
    controller.delegate = self;
    controller.topHeihgt = self.headView.bottom;
    controller.mediaType = self.currentVCL.assetMediaType;
    
    controller.view.frame = self.view.bounds;
    [self.view addSubview:controller.view];
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    
    [controller showWithAnimated:YES];
}

- (void)didPickerAlbumCompleteWithItem:(MDAssetAlbumItem *)item index:(NSInteger)index {
    if (item) {
        [self.currentVCL didPickerAlbumCompleteWithItem:item index:index];
        
        NSString *originName = [self.segmentTitleArray objectAtIndex:self.currentIndex defaultValue:nil];
        [self.segmentView setTapTitle:index == 0 ? originName : item.name atIndex:self.currentIndex];
    }
    [self.segmentView resumeCurrentLabelArrowWithAnimated:YES];
}



#pragma mark - setter

- (void)setFromCamera:(BOOL)fromCamera{
    _fromCamera = fromCamera;
    if (fromCamera) {
        [_backButton setImage:[UIImage imageNamed:@"UIBundle.bundle/nav_back_bg1"] forState:UIControlStateNormal];
    }else{
        [_backButton setImage:[UIImage imageNamed:@"icon_hp_entrance_close"] forState:UIControlStateNormal];
    }
}

- (void)exchangeCurrentControllerWithIndex:(NSInteger)index {
    
    if (_currentIndex == index) {
        return;
    }
    NSInteger oldIndex = _currentIndex;
    [self handleSelectedIndex:index oldIndex:oldIndex];
    self.currentIndex = index;
}

- (void)handleSelectedIndex:(NSInteger)index oldIndex:(NSInteger)oldIndex {
    MDAssetCollectionViewController *fromVCL = [self.innerVCLArray objectAtIndex:oldIndex defaultValue:nil];
    MDAssetCollectionViewController *toVCL = [self.innerVCLArray objectAtIndex:index defaultValue:nil];
    
    self.finishButton.hidden = (toVCL.pageType == MDAssetCollectionViewTypeVideo || self.item.accessSource == MDVideoRecordAccessSource_RegLogin);

    if (toVCL.pageType == MDAssetCollectionViewTypeVideoAlbum && self.item.accessSource != MDVideoRecordAccessSource_AlbumVideoChoosePicture) {
        [self.segmentView setRedDotHidden:YES adIndex:index];
//        [[[MDContext currentUser] dbStateHoldProvider] setHadAnchorToAlbumVideo:YES];
    }
    [toVCL viewControllerDidShow];
    
    //离开或者进入影集帧 全员clearState
    if (fromVCL.pageType == MDAssetCollectionViewTypeVideoAlbum || toVCL.pageType == MDAssetCollectionViewTypeVideoAlbum) {
        for(MDAssetCollectionViewController *vcl in self.innerVCLArray){
            [vcl clearState];
        }
    }
}


- (MDAssetCollectionViewController *)createAssetCollectionVCLWithPageTpe:(MDAssetCollectionViewType)pageType {
    MDAssetCollectionViewController *assetCollectionVCL = [[MDAssetCollectionViewController alloc] initWithInitialItem:self.item pageType:pageType couldTakePicture:self.couldShowTakePicture];
    assetCollectionVCL.delegate = self;
    assetCollectionVCL.fromCamera = self.fromCamera;
    
    [self addChildViewController:assetCollectionVCL];
    [assetCollectionVCL didMoveToParentViewController:self];
    return assetCollectionVCL;
}

- (MDAssetCollectionViewController *)currentVCL{
    return [self.innerVCLArray objectAtIndex:self.currentIndex defaultValue:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.segmentView.scrollHandler scrollViewDidScroll:scrollView];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.segmentView.scrollHandler scrollViewWillBeginDragging:scrollView];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.segmentView.scrollHandler scrollViewDidEndDecelerating:scrollView];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self.segmentView.scrollHandler scrollViewDidEndScrollingAnimation:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.segmentView.scrollHandler scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

#pragma mark - UI

- (UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, SCREEN_TOP_INSET)];
        _headView.backgroundColor = [UIColor whiteColor];
    }
    
    return _headView;
}

- (UIView *)headContentView{
    if(!_headContentView){
        _headContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, NAV_BAR_HEIGHT)];
    }
    
    return _headContentView;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 54, NAV_BAR_HEIGHT);
        if (self.fromCamera) {
            [_backButton setImage:[UIImage imageNamed:@"UIBundle.bundle/nav_back_bg1"] forState:UIControlStateNormal];
        }else{
            [_backButton setImage:[UIImage imageNamed:@"icon_hp_entrance_close"] forState:UIControlStateNormal];
        }
        _backButton.adjustsImageWhenHighlighted = NO;
        
        [_backButton addTarget:self action:@selector(goBackAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (MDTabSegmentView *)segmentView{
    if (!_segmentView) {
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *actionIndexArray = [NSMutableArray array];
        BOOL hasVideoAlbum = NO;
        for (NSNumber *num in self.segmentArray) {
            NSInteger type = [num integerValue];
            switch (type) {
                case MDAssetCollectionViewTypeVideoAlbum:
                    [actionIndexArray addObjectSafe:@(array.count)];
                    [array addObjectSafe:@"影集"];
                    hasVideoAlbum = YES;
                    break;
                case MDAssetCollectionViewTypeAll:
                    [actionIndexArray addObjectSafe:@(array.count)];
                    [array addObjectSafe:@"相册"];
                    break;
                case MDAssetCollectionViewTypeVideo:
                    [array addObjectSafe:@"视频"];
                    break;
                case MDAssetCollectionViewTypeSelfie:
                    [array addObjectSafe:@"自拍"];
                    break;
                case MDAssetCollectionViewTypePortrait:
                    [array addObjectSafe:@"人像"];
                    break;

                default:
                    break;
            }
        }
        self.segmentTitleArray = array;
        
        MDTabSegmentViewConfiguration *config = [MDTabSegmentViewConfiguration defaultConfiguration];
        config.leftPadding = 0;
        config.itemPadding = 27;
        
        __weak typeof(self) weakSelf = self;
        _segmentView = [[MDTabSegmentView alloc] initWithFrame:CGRectMake(54, 0, MDScreenWidth - 54 - 70 - 12 - 5, NAV_BAR_HEIGHT) segmentTitles:array configuration:config tapBlock:^(MDTabSegmentView *tapView, NSInteger index) {
            [weakSelf.pageView setContentOffset:CGPointMake(CGRectGetWidth(weakSelf.view.bounds) * index, 0) animated:YES];
            [weakSelf exchangeCurrentControllerWithIndex:index];
        } scrollEndBlock:^(MDTabSegmentView *tapView, NSInteger index) {
            [weakSelf exchangeCurrentControllerWithIndex:index];
        }];
        
        [_segmentView setShowArrowActionWithBlock:^(NSInteger index) {
            [weakSelf showAssetAlbumController];
        } atIndexs:actionIndexArray];
        
        BOOL hadAnchorToAlbumVideo = NO; // [[[MDContext currentUser] dbStateHoldProvider] hadAnchorToAlbumVideo];
        if (hasVideoAlbum && !hadAnchorToAlbumVideo) {
            [_segmentView setRedDotHidden:NO adIndex:0];
        }
    }
    
    return _segmentView;
}

- (UIButton *)finishButton{
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishButton.frame = CGRectMake(0, 0, 70, NAV_BAR_HEIGHT);
        _finishButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [_finishButton setTitleColor:RGBCOLOR(170, 170, 170) forState:UIControlStateNormal];
        _finishButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        [_finishButton addTarget:self action:@selector(finishSelected) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _finishButton;
}

- (UIScrollView *)pageView{
    if (!_pageView) {
        _pageView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.headView.bottom, MDScreenWidth, MDScreenHeight - self.headView.bottom - SAFEAREA_BOTTOM_MARGIN)];
        _pageView.delegate = self;
        _pageView.pagingEnabled = YES;
        _pageView.bounces = NO;
        _pageView.showsHorizontalScrollIndicator = NO;
        _pageView.contentSize = CGSizeMake(_pageView.width * self.segmentArray.count, _pageView.height);
        if (@available(iOS 11.0, *)) {
            _pageView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
    return _pageView;
}

@end
