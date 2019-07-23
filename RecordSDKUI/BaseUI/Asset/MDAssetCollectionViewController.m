//
//  MDAssetCollectionViewController.m
//  MDChat
//
//  Created by YU LEI on 2017/6/2.
//  Copyright © 2017年 sdk.com. All rights reserved.
//


#import "MDAssetCollectionViewController.h"

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "MDRecordVideoResult.h"
#import "MDPhotoLibraryProvider.h"
#import "MDAlbumiCloudAssetHelper.h"
#import "MDRegLoginPortraitManager.h"
#import "MDAssetUtility.h"
#import "MDAssetSelectState.h"

#import "MDBluredProgressView.h"
#import "MDAssetTakePictureCollectionViewCell.h"
#import "MDAssetImageCollectionCell.h"
#import "MDAssetVideoCollectionCell.h"
#import "MDAssetCollectionHeaderReusableView.h"
// 大图预览
#import "MDPreviewPageViewController.h"
// 图片编辑相关
#import "ImageFixOrientationHelper.h"
#import "MDImageEditorViewController.h"
#import "MDImageClipAndScaleViewController.h"
// 视频相关
#import "MDMomentVideoTrimViewController.h"
#import "MDAssetCompressHandler.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MDMediaEditorSettingItem.h"
#import "MDNewMediaEditorViewController.h"
#import "MDRecordImageResult.h"
#import "Toast/Toast.h"
#import "MBProgressHUD/MBProgressHUD.h"

#define KNAVHEADERhEIGHT  44


#define KASSETTIPTEXT @"有新模板更新，快来试试吧~"

@interface MDAssetCollectionViewController ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    MDAssetImageCollectionCellDelegate,
    MDAssetVideoCollectionCellDelegate,
    MDImageClipAndScaleViewControllerDelegate,
    MDAssetPreviewControllerDelegate
>

@property (nonatomic, strong) UICollectionView              *collectionView;
@property (nonatomic, assign) BOOL                          disableVideo;
@property (nonatomic, assign) BOOL                          disableFaceDetector;

@property (nonatomic, strong) MDRecordVideoResult           *videoResult;
@property (nonatomic, strong) MDUnifiedRecordSettingItem    *item;
@property (nonatomic, strong) NSMutableArray                *fetchedAssets;

@property (nonatomic, strong) MDAssetCompressHandler        *compressorHandler;
@property (nonatomic, strong) MDAssetSelectState            *assetState;
@property (nonatomic, assign) MDAssetMediaType              assetMediaType;
@property (nonatomic, assign) MDAssetCollectionViewType     pageType;

@property (nonatomic, assign) BOOL                          isProcessingVideo;
@property (nonatomic, assign) BOOL                          isProcessingPhoto;
@property (nonatomic, assign) PHImageRequestID              iCloudVideoRequestID;
@property (nonatomic, assign) BOOL                          scrollEndYetTouch;
@property (nonatomic, assign) BOOL                          couldShowTakePicture;

@end


@implementation MDAssetCollectionViewController

#pragma mark - View Lifecycle

#define TABLEVIEW_INSETS UIEdgeInsetsMake(2, 0, 2, 0);

-(void)dealloc {
    if (self.iCloudVideoRequestID > 0) {
        [[MDAssetUtility sharedInstance] cancelVideoRequest:self.iCloudVideoRequestID];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)initWithInitialItem:(MDUnifiedRecordSettingItem *)item pageType:(MDAssetCollectionViewType)pageType couldTakePicture:(BOOL)enable{
    self = [super init];
    if (self) {
        self.pageType = pageType;
        switch (pageType) {
            case MDAssetCollectionViewTypeAll:
                self.assetMediaType = MDAssetMediaTypeAll;
                if (item.assetMediaType == MDAssetMediaTypeOnlyPhoto) {
                    self.assetMediaType = MDAssetMediaTypeOnlyPhoto;
                }else if (item.assetMediaType == MDAssetMediaTypeOnlyVideo) {
                    self.assetMediaType = MDAssetMediaTypeOnlyVideo;
                }
                break;
            case MDAssetCollectionViewTypeVideo:
                self.assetMediaType = MDAssetMediaTypeOnlyVideo;
                break;
            case MDAssetCollectionViewTypeVideoAlbum:
                self.assetMediaType = MDAssetMediaTypeOnlyPhoto;
                break;
            case MDAssetCollectionViewTypeSelfie:
            case MDAssetCollectionViewTypePortrait:
                self.assetMediaType = MDAssetMediaTypeOnlyPhoto;
                break;
            default:
                self.assetMediaType = MDAssetMediaTypeAll;
                break;
        }
        self.item = item;
        self.couldShowTakePicture = enable;
        self.assetState = [[MDAssetSelectState alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isProcessingVideo = NO;
    self.isProcessingPhoto = NO;
    self.disableFaceDetector = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.disableFaceDetector = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doDataInitEvent];
    });

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    if (self.viewDidLoadCallback) {
        self.viewDidLoadCallback(self, self.view);
    }
}

- (void)doDataInitEvent {
    [self.view addSubview:[self createCollectionView]];
//    [self addTipViewIfNeed]; //头部提示语
    
    __weak typeof(self) weakSelf = self;
    [ALAssetsLibrary checkAlbumAuthorizationStatus:^(ALAuthorizationStatus status) {
        if (status == ALAuthorizationStatusAuthorized) {
            if (weakSelf.pageType == MDAssetCollectionViewTypeSelfie) {
                [[MDAssetUtility sharedInstance] fetchSelfieAssetsWithMediaType:weakSelf.assetMediaType completeBlock:^(NSArray<MDPhotoItem *> *itemArray) {
                    weakSelf.fetchedAssets = [itemArray mutableCopy];
                    [weakSelf assetsUpdate];
                }];
            }
            else if(weakSelf.pageType == MDAssetCollectionViewTypePortrait) {
                [[MDAssetUtility sharedInstance] fetchAllAssetsWithMediaType:weakSelf.assetMediaType maxCount:200 completeBlock:^(NSArray<MDPhotoItem *> *itemArray) {
                    weakSelf.fetchedAssets = [itemArray mutableCopy];
                    [weakSelf assetsAsyncFaceDetectorWithCompletion:^{
                        [weakSelf assetsUpdate];
                    }];
                }];
            }
            else {
                [[MDAssetUtility sharedInstance] fetchAllAssetsWithMediaType:weakSelf.assetMediaType completeBlock:^(NSArray<MDPhotoItem *> *itemArray) {
                    //这里需要整理数据,数组分为两组
                    weakSelf.fetchedAssets = [weakSelf removeNewestPhotoWithPhotoArray:itemArray];
                    [weakSelf assetsUpdate];
                }];
            }
        }
    }];
}

//- (void)addTipViewIfNeed
//{
//    if (self.item.disableShowTip || self.pageType != MDAssetCollectionViewTypeVideoAlbum) {
//        return;
//    }
////    DBStateHoldProvider * dbProvider = [MDContext currentUser].dbStateHoldProvider;
////    NSInteger count = [dbProvider assetViewShowCount];
//    NSInteger count = [MDRecordContext assetViewShowCount];
//    if(count < 1){
//        MUButton *button = [MUButtonDispatcher buttonWithType:MUButtonTypeB14];
//        [button setTitle:KASSETTIPTEXT forState:UIControlStateNormal];
//        button.mj_y =  0;
//        
//        UIEdgeInsets insets = self.collectionView.contentInset;
//        insets.top += button.height-5;
//        self.collectionView.contentInset = insets;
//        
//        [self.view addSubview:button];
//    }
//}

- (void)applicationWillResignActive:(id)sender {
    [self.compressorHandler applicationWillResignActive];
    self.isProcessingVideo = NO;
}

#pragma mark - public

// 选择相册
- (void)didPickerAlbumCompleteWithItem:(MDAssetAlbumItem *)item index:(NSInteger)index {
    if (self.assetState.albumIndex != index) {
        self.assetState.albumIndex = index;

        @weakify(self);
        [[MDAssetUtility sharedInstance] fetchAssetsWithAssetCollection:item.assetCollection options:nil mediaType:self.assetMediaType completeBlock:^(NSArray<MDPhotoItem *> *itemArray) {
            @strongify(self);
            [self clearState];
            self.fetchedAssets = [self removeNewestPhotoWithPhotoArray:itemArray];
            [self assetsUpdate];
        }];
    }
}

// 设置选择最大数量
- (void)setSelectLimit:(NSInteger)selectLimit {
    self.assetState.selectionLimit = selectLimit;
}

// 清除图片缓存
- (void)clearOriginImage {
    for (MDPhotoItem *item in self.fetchedAssets) {
        if ([item isKindOfClass:[MDPhotoItem class]]) {
            item.originImage = nil;
            item.editedImage = nil;
            item.nailImage = nil;
        }
    }
}

// 切换进入当前controller
- (void)viewControllerDidShow {
    if (self.pageType == MDAssetCollectionViewTypeVideoAlbum) {
        if (self.item.disableShowTip) {
            return;
        }
//        DBStateHoldProvider * dbProvider = [MDContext currentUser].dbStateHoldProvider;
//        NSInteger count = [dbProvider assetViewShowCount];
        NSInteger count = [MDRecordContext assetViewShowCount];
        if (count<1) {
//            [dbProvider setAssetViewShowCount:count+1];
            [MDRecordContext setAssetViewShowCount:count +1];
        }
//        [MDActionManager handleLocaRecord:[NSString stringWithFormat:@"live_photo_show_%@",self.item.recordLog.logString]];
    }else if (self.pageType == MDAssetCollectionViewTypeAll) {
//        [MDActionManager handleLocaRecord:[NSString stringWithFormat:@"album_show_%@",self.item.recordLog.logString]];
    }else if (self.pageType == MDAssetCollectionViewTypeVideo) {
//        [MDActionManager handleLocaRecord:[NSString stringWithFormat:@"video_show_%@",self.item.recordLog.logString]];
    }
}


#pragma mark - 处理数据源

- (void)assetsUpdate
{
    //是否要展示拍摄入口
    if (self.couldShowTakePicture && !self.fromCamera && self.pageType != MDAssetCollectionViewTypeVideoAlbum && self.pageType != MDAssetCollectionViewTypeVideo) {
        MDAssetTakePictureItem *item = [MDAssetTakePictureItem new];
        [self.fetchedAssets insertObject:item atIndex:0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.assetState updateAssetSelectIndex];
        [self.collectionView reloadData];
        [self.collectionView layoutIfNeeded];
        [self loadTargetSizeThumbnailImageForVisibleCells];
    });
}


- (void)assetsAsyncFaceDetectorWithCompletion:(void(^)(void))completion {
    MDRegLoginPortraitManager *manger = [[MDRegLoginPortraitManager alloc] init];
    NSMutableArray<MDPhotoItem*> *newArray = [NSMutableArray array];
    NSMutableArray<MDPhotoItem*> *oldArray = self.fetchedAssets;
    CGSize scanSize = [manger currentDeviceScanSize];
    
//    MBProgressHUD *hud = [[MDRecordContext sharedIndicate] showHUDAddedTo:self.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [oldArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MDPhotoItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.disableFaceDetector) { // 停止识别
                *stop = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.fetchedAssets = newArray;
                    [MBProgressHUD hideHUDForView:hud animated:YES];
                    if (completion) completion();
                });
                return;
            }

            [[MDAssetUtility sharedInstance] synFetchSmallImageWithAsset:obj.asset targetSize:scanSize complete:^(UIImage *image, NSString *identifer) {
                if ([manger faceFeatureWithImage:image]) {
                    [newArray addObjectSafe:obj];
                }
            }];
            
            if (idx == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.fetchedAssets = newArray;
                    [MBProgressHUD hideHUDForView:hud animated:YES];
                    if (newArray.count > 0) {
                        [MDRegLoginPortraitManager showBottomMessage:@"筛选了相册中近期的人像" toView:self.view timeOut:2.5];
                    }
                    if (completion) completion();
                });
            }
        }];
    });
}

- (NSMutableArray *)removeNewestPhotoWithPhotoArray:(NSArray *)photosArray{
    NSMutableArray *dataSource = [[NSMutableArray alloc]initWithArray:photosArray];
    if (![self judgeShowCollectionSectionHeader]) {
        return dataSource;
    }
    if (photosArray.count == 0) {
        return dataSource;
    }
    
    MDPhotoItem *lastItem = self.userFeedShowModel.photoArr.lastObject;
    for (MDPhotoItem *item in photosArray) {
        //读取最后一张, 如果相册中的照片比最后一张时间老, 就不在往下读取
        if ([item.asset.creationDate compare:lastItem.asset.creationDate] == NSOrderedAscending) {
            break;
        }
        for (MDPhotoItem *localItem in self.userFeedShowModel.photoArr) {
            if ([item.asset.localIdentifier isEqualToString: localItem.asset.localIdentifier]) {
                [dataSource removeObject:item];
            }
        }
    }
    return dataSource;
}

- (void)setDisableVideo:(BOOL)disableVideo {
    //如果是视频帧 这个不生效 为了支持相册帧选了照片 到了视频帧 能不屏蔽视频 直接发布视频
    if (self.pageType == MDAssetCollectionViewTypeVideo) {
        return;
    }
    if (_disableVideo != disableVideo) {
        _disableVideo = disableVideo;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}

- (void)clearState{
    [self.assetState cleanAll];
    [self setDisableVideo:NO];
    //选中状态清空
    for (id obj in self.fetchedAssets) {
        if ([obj isKindOfClass:[MDPhotoItem class]]) {
            MDPhotoItem *item = (MDPhotoItem *)obj;
            item.selected = NO;
        }
    }
    if ([self judgeShowCollectionSectionHeader]) {
        for (id obj in self.userFeedShowModel.photoArr) {
            if ([obj isKindOfClass:[MDPhotoItem class]]) {
                MDPhotoItem *item = (MDPhotoItem *)obj;
                item.selected = NO;
            }
        }
    }
    
    [self.collectionView reloadData];
    [self loadTargetSizeThumbnailImageForVisibleCells];
    [self refreshSendButton];
}

- (void)refreshSendButton {
    if ([self.delegate respondsToSelector:@selector(selectedCountDidChange:)]) {
        [self.delegate selectedCountDidChange:self.assetState.selectedCount];
    }
}


#pragma mark - 辅助方法

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *previewSource = nil;
    if ([self judgeShowCollectionSectionHeader] && indexPath.section == 0) {
        previewSource = self.userFeedShowModel.photoArr;
    } else{
        previewSource = self.fetchedAssets;
    }
    id obj = [previewSource objectAtIndex:indexPath.row defaultValue:nil];
    return obj;
}

- (BOOL)judgeShowCollectionSectionHeader{
    if (self.userFeedShowModel.photoArr.count != 0 && self.assetState.albumIndex == 0) {
        return YES;
    }
    return NO;
}

#pragma mark - MDAssetImageCollectionCellDelegate & MDAssetVideoCollectionCellDelegate

- (BOOL)assetImageCellCanSelect:(MDAssetImageCollectionCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    id obj = [self objectAtIndexPath:indexPath];
    
    if (![obj isKindOfClass:[MDPhotoItem class]]) {
        return NO;
    }
    MDPhotoItem *item = (MDPhotoItem *)obj;
    
    //个人资料页面, 先进入裁剪页面  合拍也先进裁剪页面
    if (self.item.accessSource == MDVideoRecordAccessSource_Profile ||
        self.item.accessSource == MDVideoRecordAccessSource_QVProfile ||
        self.item.accessSource == MDVideoRecordAccessSource_SoulMatch ||
        self.item.accessSource == MDVideoRecordAccessSource_RegLogin) {
        [self goToImageCutViewWithItem:item];
        return NO;
    }
    
    //点点直接进入图片编辑页
    if (self.item.accessSource == MDVideoRecordAccessSource_QuickMatch) {
        [self gotoImageEditControllerWithItem:item];
        return NO;
    }
    
    BOOL shouldSelectAsset = (self.assetState.selectedCount < self.assetState.selectionLimit);

    if (!shouldSelectAsset && !item.selected) {
        NSString *errMsg = [NSString stringWithFormat:@"最多选择%d张图片", (int)self.assetState.selectionLimit?:6];
        [self.view makeToast:errMsg duration:1.5f position:CSToastPositionCenter];
        return NO;
    }
    
    return YES;
}

- (void)assetImageCell:(MDAssetImageCollectionCell *)cell didClickImageWithSelected:(BOOL)selected {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    id obj = [self objectAtIndexPath:indexPath];

    if (![obj isKindOfClass:[MDPhotoItem class]]) {
        return;
    }
    [self.assetState changeSelectState:selected forAsset:(MDPhotoItem *)obj indexPath:indexPath];
    NSArray<NSIndexPath*> *indexArray = [self.assetState updateAssetSelectIndex];
    [self setDisableVideo:(self.assetState.selectedCount>0)];
    
    if (self.assetState.selectionLimit) {
        [self refreshSendButton];
    }
    
    for (NSIndexPath *indexPath in indexArray) {
        if (indexPath.section<0 || indexPath.row<0) {
            continue;
        }
        MDAssetImageCollectionCell *cell = (MDAssetImageCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell refreshSelectedNumber];
    }
}

- (void)assetImageCellClickPreview:(MDAssetImageCollectionCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    id obj = [self objectAtIndexPath:indexPath];
    
    if (![obj isKindOfClass:[MDPhotoItem class]]) {
        return;
    }
    MDPhotoItem *item = (MDPhotoItem *)obj;

    //个人资料页面, 先进入裁剪页面
    if (self.item.accessSource == MDVideoRecordAccessSource_Profile||
        self.item.accessSource == MDVideoRecordAccessSource_QVProfile ||
        self.item.accessSource == MDVideoRecordAccessSource_SoulMatch ||
        self.item.accessSource == MDVideoRecordAccessSource_RegLogin) {
        [self goToImageCutViewWithItem:item];
        return;
    }
    //点点直接进入图片编辑页
    if (self.item.accessSource == MDVideoRecordAccessSource_QuickMatch) {
        [self gotoImageEditControllerWithItem:item];
        return;
    }
    
    NSInteger count = 0;
    NSInteger section = indexPath.section;
    for (int i = 0; i < indexPath.row; i++) {
        id obj = [self objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
        if (![obj isKindOfClass:[MDPhotoItem class]]) {
            continue;
        }
        if (((MDPhotoItem *)obj).type == MDPhotoItemTypeImage) {
            count++;
        }
    }
    
    MDAssetPreviewController *previewController = [[MDAssetPreviewController alloc] initWithCurrentIndexPath:[NSIndexPath indexPathForRow:count inSection:section]];
    previewController.settingItem = self.item;
    previewController.assetState = self.assetState;
    previewController.fetchedAssets = self.fetchedAssets;
    previewController.addressFetchedAssets = self.userFeedShowModel.photoArr;
    previewController.enableOrigin = (self.item.type == MDAssetPickerTypeChat);
    previewController.delegate = self;
    [self.navigationController pushViewController:previewController animated:YES];
}

- (void)assetVideoCellClickVideo:(MDAssetVideoCollectionCell *)cell {
    //直接跳视频处理逻辑
    [self gotoVideoEditWithItem:cell.item];
    return;
}

#pragma mark - MDAssetPreviewControllerDelegate

- (void)assetPreviewControllerDidFinish:(MDAssetPreviewController *)controller {
    if ((self.pageType == MDAssetCollectionViewTypeVideoAlbum) && self.item.accessSource != MDVideoRecordAccessSource_AlbumVideoChoosePicture) {
        if (self.assetState.selectedCount < 2) {
            [[MDRecordContext appWindow] makeToast:@"影集至少需要选择2张图片" duration:1.5f position:CSToastPositionCenter];
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(didFinishSelectedToAlbumVideo)]) {
            [self.delegate didFinishSelectedToAlbumVideo];
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[MDAlbumiCloudAssetHelper sharedInstance] loadOriginImageFromPhotoItemArray:self.assetState.selectedItemArray cancelBlock:nil completeBlock:^(NSArray<MDPhotoItem *> * _Nonnull resultArray) {
        MDRecordImageResult *result = [[MDRecordImageResult alloc] init];
        result.photoItems = weakSelf.assetState.selectedItemArray;
//        result.recordLog = weakSelf.item.recordLog;
        result.fromAlbum = YES;
        if (weakSelf.item.completeHandler) {
            weakSelf.item.completeHandler(result);
        };
    }];
}


#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if ([self judgeShowCollectionSectionHeader]) {
        return 2;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self judgeShowCollectionSectionHeader] && section == 0) {
        return self.userFeedShowModel.photoArr.count;
    }
    return self.fetchedAssets.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self objectAtIndexPath:indexPath];
    if ([obj isKindOfClass:[MDAssetTakePictureItem class]]) {
        MDAssetTakePictureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MDAssetTakePictureCollectionViewCell" forIndexPath:indexPath];
        return cell;
    } else {
        MDPhotoItem *item = (MDPhotoItem *)obj;
        return [self getAssetCollectionViewCellWithIndexPath:indexPath photoItem:item];
    }
}

- (UICollectionViewCell *)getAssetCollectionViewCellWithIndexPath:(NSIndexPath *)indexPath photoItem:(MDPhotoItem *)item{
    MDAssetBaseCollectionCell *cell = nil;
    if (item.type == MDPhotoItemTypeVideo) {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[MDAssetVideoCollectionCell reuseIdentifier] forIndexPath:indexPath];
        [(MDAssetVideoCollectionCell *)cell setEnableSelect:!self.disableVideo];
        [(MDAssetVideoCollectionCell *)cell setCellDelegate:self];
    }else {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[MDAssetImageCollectionCell reuseIdentifier] forIndexPath:indexPath];
        
        BOOL hideSelect = (self.item.accessSource == MDVideoRecordAccessSource_Profile ||
                           self.item.accessSource == MDVideoRecordAccessSource_QuickMatch ||
                           self.item.accessSource == MDVideoRecordAccessSource_QVProfile ||
                           self.item.accessSource == MDVideoRecordAccessSource_SoulMatch ||
                           self.item.accessSource == MDVideoRecordAccessSource_RegLogin);
        [(MDAssetImageCollectionCell *)cell setEnableSelect:!hideSelect];
        [(MDAssetImageCollectionCell *)cell setCellDelegate:self];
    }
    [cell bindModel:item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([self judgeShowCollectionSectionHeader]) {
        UICollectionReusableView *supplementaryView = nil;
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            MDAssetCollectionHeaderReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                           withReuseIdentifier:@"MDAssetCollectionHeaderReusableView"
                                                                                                  forIndexPath:indexPath];
            if (indexPath.section == 0) {
                [view configTitle:self.userFeedShowModel.toastStr];
            } else if (indexPath.section == 1){
                [view configTitle:@"全部照片"];
            }
            supplementaryView = view;
        }
        return supplementaryView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if ([self judgeShowCollectionSectionHeader]) {
        return CGSizeMake(self.collectionView.width, 41);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.disableFaceDetector = YES;
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if([cell isKindOfClass:[MDAssetTakePictureCollectionViewCell class]]){
        //点击了拍摄按钮
        if([self.delegate respondsToSelector:@selector(didClickTakePictureAction)]){
            [self.delegate didClickTakePictureAction];
        }
    }
}

#pragma mark - 加载图片

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (velocity.y < 0.001 && !self.scrollEndYetTouch) {
        [self loadTargetSizeThumbnailImageForVisibleCells];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadTargetSizeThumbnailImageForVisibleCells];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.scrollEndYetTouch = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrolling:) object:scrollView];
    [self performSelector:@selector(scrollViewDidEndScrolling:) withObject:scrollView afterDelay:0.1 inModes:@[NSRunLoopCommonModes]];
}

- (void)scrollViewDidEndScrolling:(UIScrollView *)scrollView {
    self.scrollEndYetTouch = (scrollView.isTracking && scrollView.isDragging);
    if (self.scrollEndYetTouch) {
        [self loadTargetSizeThumbnailImageForVisibleCells];
    }
}

- (void)loadTargetSizeThumbnailImageForVisibleCells {
    NSArray<UICollectionViewCell *> *visibleCells = [self.collectionView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[MDAssetTakePictureCollectionViewCell class]]){
            //拍照的cell
        }else if ([obj isKindOfClass:[MDAssetBaseCollectionCell class]]) {
            [(MDAssetBaseCollectionCell*)obj displayTargetSizeImageWithBindedItem];
        }
    }];
}

#pragma mark - 进入视频编辑页

-(void)gotoVideoEditWithItem:(MDPhotoItem *)item {
    if (self.isProcessingVideo) {
        return;
    }
    self.isProcessingVideo = YES;
    
    if ([self.item.alertForForbidRecord isNotEmpty]) {
        [[MDRecordContext appWindow] makeToast:self.item.alertForForbidRecord duration:1.5f position:CSToastPositionCenter];
        self.isProcessingVideo = NO;
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    /***** 读取视频信息 *****/
    [[MDAssetUtility sharedInstance] fetchAVAssetFromPHAsset:item.asset completeBlock:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        //block回调非主线程
        id isICloud = [info objectForKey:PHImageResultIsInCloudKey];
        if (isICloud && [isICloud boolValue] && !asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf _handleFetchICloudAVAsset:item.asset fetchFinishHandleBlock:^(AVAsset *cloudAsset, AVAudioMix *cloudAudioMix, NSDictionary *infoDict) {
                    [weakSelf handleWithPHAsset:item.asset AVAsset:cloudAsset audioMix:cloudAudioMix info:infoDict];
                }];
            });
        } else {
            [weakSelf handleWithPHAsset:item.asset AVAsset:asset audioMix:audioMix info:info];
        }
    }];
}

- (void)_handleFetchICloudAVAsset:(PHAsset *)asset fetchFinishHandleBlock:(void (^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *infoDict))handleBlock {
    MDBluredProgressView *processingHUD = [[MDBluredProgressView alloc] initWithBlurView:[MDRecordContext appWindow] descText:@"下载iCloud视频" needClose:YES];
    processingHUD.userInteractionEnabled = YES;
    processingHUD.progress = 0;
    __weak __typeof(self) weakSelf = self;
    [processingHUD setViewCloseHandler:^{
        [[MDAssetUtility sharedInstance] cancelVideoRequest:weakSelf.iCloudVideoRequestID];
        weakSelf.iCloudVideoRequestID = 0;
        weakSelf.isProcessingVideo = NO;
    }];
    [[MDRecordContext appWindow] addSubview:processingHUD];
    
    self.iCloudVideoRequestID = [[MDAssetUtility sharedInstance] fetchAvassetFromICloudWithPHAsset:asset progressBlock:^(double progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            processingHUD.progress = progress;
        });
    } completeBlock:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [processingHUD removeFromSuperview];
        });
        if (handleBlock) {
            handleBlock(asset, audioMix, info);
        }
    }];
}

- (void)handleWithPHAsset:(PHAsset *)phAsset AVAsset:(AVAsset *)asset audioMix:(AVAudioMix *)audioMix info:(NSDictionary *)info {
    //非主线程调用
    
    NSURL *mediaURL = nil;
    if ([asset isKindOfClass:[AVComposition class]]) {
        NSString *sandboxExtensionTokenKey = info[@"PHImageFileSandboxExtensionTokenKey"];
        NSArray *arr = [sandboxExtensionTokenKey componentsSeparatedByString:@";"];
        NSString *string = [arr stringAtIndex:arr.count-1 defaultValue:nil];
        NSString *filePath = @"";
        if (string.length > 8) {
            filePath = [string substringFromIndex:8];
        }
        mediaURL = [NSURL URLWithString:[@"file://" stringByAppendingString:filePath]];
    }
    else if ([asset isKindOfClass:[AVURLAsset class]]) {
        mediaURL = ((AVURLAsset *)asset).URL;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.view) {
                [self.view makeToast:@"资源异常" duration:1.5f position:CSToastPositionCenter];
                self.isProcessingVideo = NO;
            }
        });
        return;
    }
    
    
    if ([self.delegate respondsToSelector:@selector(currentVCLIsActive:)]) {
        BOOL isActive = [self.delegate currentVCLIsActive:self];
        if (!isActive) {
            self.isProcessingVideo = NO;
            return;
        }
    }
    if (![self checkVideoAssetValid:asset]) return;
    
    //打点记录原视频相关信息
    [self _handleResultInfoWithOriginalURL:mediaURL asset:asset];
    
    __weak typeof(self) weakSelf = self;
    [self _handleCutAsset:asset completion:^(AVAsset *asset, CMTimeRange timeRange, BOOL hasCutVideo) {
        //主线程回调
        [weakSelf handleExportAsset:asset phAsset:phAsset mediaURL:mediaURL timeRange:timeRange hasCutVideo:hasCutVideo completion:^(NSURL *outputURL) {
            if (outputURL) {
                AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:outputURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)}];
                [weakSelf _handleResultInfoWithEditAsset:urlAsset hasCutVideo:hasCutVideo];
                [weakSelf pushToEditingVCWithAsset:urlAsset];
            }else {
                weakSelf.isProcessingVideo = NO;
                [[MDRecordContext appWindow] makeToast:@"视频处理有问题" duration:1.5f position:CSToastPositionCenter];
            }
        }];
    }];
}



- (void)_handleResultInfoWithOriginalURL:(NSURL *)mediaURL asset:(AVAsset *)asset {
    NSDictionary *resourceValues = [mediaURL resourceValuesForKeys:@[NSURLFileSizeKey,NSURLTotalFileSizeKey] error:nil];
    
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize presentationSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    presentationSize.width = ABS(presentationSize.width);
    presentationSize.height = ABS(presentationSize.height);
    
    self.videoResult.originalFileSize = [resourceValues longLongValueForKey:NSURLFileSizeKey defaultValue:0] ?: [resourceValues longLongValueForKey:NSURLTotalFileSizeKey defaultValue:0];
    self.videoResult.originalDuration = CMTimeGetSeconds(asset.duration);
    self.videoResult.originalVideoNaturalWidth = presentationSize.width;
    self.videoResult.originalVideoNaturalHeight = presentationSize.height;
    self.videoResult.originalBitRate = [track estimatedDataRate];
    self.videoResult.originalFrameRate = [track nominalFrameRate];
    
    self.videoResult.isOriginalVideoCompress = [self.compressorHandler needCompressWithAsset:asset mediaURL:mediaURL];
}

- (void)_handleResultInfoWithEditAsset:(AVAsset *)asset hasCutVideo:(BOOL)hasCutVideo {
    self.videoResult.isFromAlbum = YES;
    self.videoResult.isOriginalVideoCut = hasCutVideo;
    
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize presentationSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    presentationSize.width = ABS(presentationSize.width);
    presentationSize.height = ABS(presentationSize.height);
    
    self.videoResult.editVideoDuration = CMTimeGetSeconds(asset.duration);
    self.videoResult.editVideoNaturalWidth = presentationSize.width;
    self.videoResult.editVideoNaturalHeight = presentationSize.height;
    self.videoResult.editVideoBitRate = [track estimatedDataRate];
    self.videoResult.editVideoFrameRate = [track nominalFrameRate];
    
    if ([asset isKindOfClass:[AVURLAsset class]]) {
        NSURL *mediaURL = ((AVURLAsset *)asset).URL;
        NSDictionary *resourceValues = [mediaURL resourceValuesForKeys:@[NSURLFileSizeKey,NSURLTotalFileSizeKey] error:nil];
        self.videoResult.editVideoFileSize = [resourceValues longLongValueForKey:NSURLFileSizeKey defaultValue:0] ?: [resourceValues longLongValueForKey:NSURLTotalFileSizeKey defaultValue:0];
    }
}


#pragma mark - 压缩本地视频

- (void)_handleCutAsset:(AVAsset *)videoAsset completion:(void (^)(AVAsset *asset, CMTimeRange timeRange, BOOL hasCutVideo))completion {
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //判断时长时fix一下，不要用最精确的时长限制
        if (CMTimeGetSeconds(videoAsset.duration) > self.item.maxUploadDurationOfScene + 2) {
            MDMomentVideoTrimViewController *trimVC = [[MDMomentVideoTrimViewController alloc] initWithMaxDuration:self.item.maxUploadDurationOfScene CloseHandler:^(UIViewController *controller, AVAsset *asset,CMTimeRange timeRange) {
                
                BOOL animated = asset ? NO : YES;
                [controller.navigationController popViewControllerAnimated:animated];
                
                if (!CMTimeRangeEqual(timeRange, kCMTimeRangeInvalid)) {
                    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
                    timeRange = CMTimeRangeMake(timeRange.start, CMTimeMake(CMTimeGetSeconds(timeRange.duration) * videoTrack.timeRange.duration.timescale, videoTrack.timeRange.duration.timescale));
                    
                    if (completion) completion(asset, timeRange, YES);
                }
            }];
            
            trimVC.asset = videoAsset;
            [self.navigationController pushViewController:trimVC animated:YES];
            
        } else if (CMTimeGetSeconds(videoAsset.duration) < 2) {
            [self.view makeToast:@"视频时长过短，暂不支持2秒以下视频" duration:1.5f position:CSToastPositionCenter];
            self.isProcessingVideo = NO;
            
        } else {
            AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            if (completion) completion(videoAsset, videoTrack.timeRange, NO);
        }
    });
}

- (void)handleExportAsset:(AVAsset *)asset
                  phAsset:(PHAsset *)phAsset
                 mediaURL:(NSURL *)mediaURL
                timeRange:(CMTimeRange)timeRange
              hasCutVideo:(BOOL)hasCutVideo
               completion:(void (^) (NSURL *))completion {
    __weak typeof(self) weakSelf = self;
    [self.compressorHandler compressorVideoWithPHAsset:phAsset
                                                 asset:asset
                                              mediaURL:mediaURL
                                             timeRange:timeRange
                                           hasCutVideo:hasCutVideo
                                     progressSuperView:self.view
                                     completionHandler:completion
                                         cancelHandler:^{
                                             weakSelf.isProcessingVideo = NO;
                                         }];
}



//本地视频
- (void)pushToEditingVCWithAsset:(AVAsset *)asset
{
//    self.videoResult.recordLog = self.item.recordLog;
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    MDMediaEditorSettingItem *settingItem = [[MDMediaEditorSettingItem alloc] init];
    settingItem.videoAsset = asset;
    settingItem.videoTimeRange = videoTrack.timeRange;
    settingItem.backgroundMusicURL = nil;
    settingItem.backgroundMusicTimeRange = kCMTimeRangeInvalid;
    settingItem.backgroundMusicItem = nil;
    settingItem.supportMultiSegmentsRecord = NO;
    settingItem.completeBlock = ^ (id videoInfo) {
        if (self.item.completeHandler) {
            self.item.completeHandler(videoInfo);
        }
    };
    settingItem.videoInfo = self.videoResult;
    settingItem.hideTopicEntrance = self.item.hideTopicEntrance;
    settingItem.lockTopic = self.item.lockTopic;
    settingItem.maxUploadDuration = self.item.maxUploadDurationOfScene;
    settingItem.doneButtonTitle = self.item.doneBtnText;
    settingItem.hasCutVideo = self.videoResult.isOriginalVideoCut;
    settingItem.needWaterMark = self.item.needWaterMark;
    settingItem.maxThumbImageSize = (self.item.accessSource == MDVideoRecordAccessSource_QVProfile ? 1280 : 640);
    settingItem.fromAlbum = YES;
    MDNewMediaEditorViewController *vc = [[MDNewMediaEditorViewController alloc] initWithSettingItem:settingItem];
    [self.navigationController pushViewController:vc animated:YES];
    
//    [MDActionManager handleLocaRecord:[NSString stringWithFormat:@"video_finish_click_%@",self.item.recordLog.logString]];
}

- (BOOL)checkVideoAssetValid:(AVAsset *)asset
{
    //资源合法性检查
    BOOL valid = asset.isPlayable;
    if (!valid) {
//        NSString *logStr = [NSString stringWithFormat:@"error:playable-%d,exportable-%d,Composable-%d,readable-%d",valid,asset.isExportable,asset.isComposable,asset.isReadable];
//        [MDClientLog logWithKey:@"ios_videoLocalError_log" content:logStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:@"资源异常" duration:1.5f position:CSToastPositionCenter];
            self.isProcessingVideo = NO;
        });
    } else {
        valid = CMTimeGetSeconds(asset.duration) <= kMaxPickerLocalVideoDuration;
        if (!valid) {
            NSString *text = [NSString stringWithFormat:@"%.0f分钟以上视频暂时无法上传", kMaxPickerLocalVideoDuration / 60];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:text duration:1.5f position:CSToastPositionCenter];
                self.isProcessingVideo = NO;
            });
        }
    }
    
    //针对快聊资料页的入口，判断宽高比是否ok、时长是否ok
    if (self.item.accessSource == MDVideoRecordAccessSource_QVProfile || self.item.accessSource == MDVideoRecordAccessSource_MK) {
        
        if ([self.item.alertForDurationTooShort isNotEmpty] &&
            CMTimeGetSeconds(asset.duration) < self.item.minUploadDurationOfScene) {
            
            valid = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:self.item.alertForDurationTooShort duration:1.5f position:CSToastPositionCenter];
                self.isProcessingVideo = NO;
            });
            
        }
        else if ([self.item.alertForRatioNotSuitable isNotEmpty]) {
            AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            CGSize presentationSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
            presentationSize.width = ABS(presentationSize.width);
            presentationSize.height = ABS(presentationSize.height);
            
            CGFloat ratio = presentationSize.width / presentationSize.height;
            if (ratio > self.item.maxWHRatioForVideoSize || ratio < self.item.minWHRatioForVideoSize) {
                
                valid = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:self.item.alertForRatioNotSuitable duration:1.5f position:CSToastPositionCenter];
                    self.isProcessingVideo = NO;
                });
                
            }
            
        }
    }
    
    return valid;
}


#pragma mark - 裁剪页和编辑页

- (void)goToImageCutViewWithItem:(MDPhotoItem*)item {
    if (self.isProcessingPhoto) {
        return;
    }
    self.isProcessingPhoto = YES;

    @weakify(self);
    [[MDAlbumiCloudAssetHelper sharedInstance] loadBigImageFromPhotoItem:item isNeedThumb:YES cancelBlock:^{
        @strongify(self);
        self.isProcessingPhoto = NO;
    } completeBlock:^(UIImage *image) {
        @strongify(self);
        if (image) {
            MDImageClipAndScaleViewController *imageCutController = [[MDImageClipAndScaleViewController alloc] initWithImage:image];
            imageCutController.delegate = (id<MDImageClipAndScaleViewControllerDelegate>)self;
            imageCutController.imageClipScale = self.item.imageClipScale;
            [self.navigationController pushViewController:imageCutController animated:YES];
            
            if(self.item.photoTypeSelectedCompleted) {
                switch (self.pageType) {
                    case MDAssetCollectionViewTypeAll:
                        self.item.photoTypeSelectedCompleted(MDRegLoginSelectImageTypePickerAllAlbum);
                        break;
                    case MDAssetCollectionViewTypeSelfie:
                        self.item.photoTypeSelectedCompleted(MDRegLoginSelectImageTypePickerSelfie);
                        break;
                    case MDAssetCollectionViewTypePortrait:
                        self.item.photoTypeSelectedCompleted(MDRegLoginSelectImageTypePickerPortraits);
                        break;
                    default:
                        break;
                }
            }
        }
        self.isProcessingPhoto = NO;
    }];
}

-(void)clipControllerDidCancel:(MDImageClipAndScaleViewController *)controller {
    [controller.navigationController popViewControllerAnimated:YES];
}

-(void)clipController:(MDImageClipAndScaleViewController *)controller didClipImage:(UIImage *)image {
    [self gotoImageEditControllerWithImage:image];
}

- (void)gotoImageEditControllerWithItem:(MDPhotoItem *)item {
    if (self.isProcessingPhoto) {
        return;
    }
    self.isProcessingPhoto = YES;

    __weak typeof(self) weakSelf = self;
    [[MDAlbumiCloudAssetHelper sharedInstance] loadBigImageFromPhotoItem:item isNeedThumb:YES cancelBlock:^{
        weakSelf.isProcessingPhoto = NO;
    } completeBlock:^(UIImage *image) {
        if (image) {
            [weakSelf gotoImageEditControllerWithImage:image];
        }
        weakSelf.isProcessingPhoto = NO;
    }];
}

- (void)gotoImageEditControllerWithImage:(UIImage *)image {
    
    UIImage *orientationFixedImage = [ImageFixOrientationHelper fixOrientation:image];
    
    //相册裁剪页面进入编辑页面
    MDImageUploadParamModel *imageUploadParamModel = [[MDImageUploadParamModel alloc] init];
    __weak typeof(self) weakSelf = self;
    MDImageEditorViewController *imageEditVC = [[MDImageEditorViewController alloc]initWithImage:orientationFixedImage completeBlock:^(UIImage *image, BOOL isEdited) {
        
        MDPhotoItem *photoItem = [MDPhotoItem new];
        photoItem.imageUploadParamModel = imageUploadParamModel;
        photoItem.nailImage = image;
        MDRecordImageResult *result = [[MDRecordImageResult alloc]init];
        result.photoItems = @[photoItem];
//        result.recordLog = weakSelf.item.recordLog;
        result.fromAlbum = YES;

        if (weakSelf.item.completeHandler) {
            weakSelf.item.completeHandler(result);
        }
    }];
    imageEditVC.imageUploadParamModel = imageUploadParamModel;
    
    __weak MDImageEditorViewController *weakImageEditorVC = imageEditVC;
    imageEditVC.cancelBlock = ^(BOOL isEdit) {
        //弹alert
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"要放弃该图片吗?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIViewController *targetController = nil;
            NSArray *controllers = [weakImageEditorVC.navigationController viewControllers];
            if (controllers.count > 2) {
                targetController = controllers[controllers.count-3];
                [weakImageEditorVC.navigationController popToViewController:targetController animated:YES];
            }else {
                [weakImageEditorVC.navigationController popViewControllerAnimated:YES];
            }
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    };
    
    //压入编辑视图
    [self.navigationController pushViewController:imageEditVC animated:YES];
}


#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    for (MDPhotoItem *item in self.fetchedAssets) {
        if ([item isKindOfClass:[MDPhotoItem class]]) {
            item.nailImage = nil;
            item.originImage = nil;
        }
    }
    for (MDPhotoItem *item in self.userFeedShowModel.photoArr) {
        if ([item isKindOfClass:[MDPhotoItem class]]) {
            item.nailImage = nil;
            item.originImage = nil;
        }
    }
    
#if DEBUG
    static NSUInteger warningCount = 1;
    NSLog(@"%@收到第%zd次内存警告⚠️⚠️⚠️", NSStringFromClass([self class]), warningCount++);
#endif
}


- (UICollectionView *)createCollectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellSize = floor((MDScreenWidth-30.0)/3.0);
        layout.itemSize = CGSizeMake(cellSize, cellSize);
        layout.sectionInset = UIEdgeInsetsMake(3.0f, 3.0f, 3.0f, 3.0f);
        layout.minimumLineSpacing = 3.0f;
        layout.minimumInteritemSpacing = 3.0f;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight - SAFEAREA_TOP_MARGIN - SAFEAREA_BOTTOM_MARGIN) collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 9, 15, 9);
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[MDAssetVideoCollectionCell class] forCellWithReuseIdentifier:[MDAssetVideoCollectionCell reuseIdentifier]];
        [_collectionView registerClass:[MDAssetImageCollectionCell class] forCellWithReuseIdentifier:[MDAssetImageCollectionCell reuseIdentifier]];
        [_collectionView registerClass:[MDAssetTakePictureCollectionViewCell class] forCellWithReuseIdentifier:@"MDAssetTakePictureCollectionViewCell"];
        [_collectionView registerClass:[MDAssetCollectionHeaderReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"MDAssetCollectionHeaderReusableView"];
    }
    return _collectionView;
}

- (MDRecordVideoResult *)videoResult
{
    if (!_videoResult) {
        _videoResult = [[MDRecordVideoResult alloc] init];
        _videoResult.accessSource = self.item.accessSource;
        _videoResult.themeID = self.item.themeId;
        _videoResult.topicID = self.item.topicId;
    }
    return  _videoResult;
}

- (NSMutableArray *)fetchedAssets{
    if (!_fetchedAssets) {
        _fetchedAssets = [NSMutableArray array];
    }
    return _fetchedAssets;
}

- (MDAssetCompressHandler *)compressorHandler {
    if (!_compressorHandler) {
        _compressorHandler = [[MDAssetCompressHandler alloc] init];
    }
    return _compressorHandler;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
