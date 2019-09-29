//
//  MDAlbumVideoImageSortingView.m
//  MDAlbumVideo
//
//  Created by sunfei on 2018/9/6.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "MDAlbumVideoImageSortingView.h"
#import "MDAlbumVideoImageSortingViewCollectionViewCell.h"
#import "MDAlbumVideoSwitchButtonView.h"
#import "MDUnifiedRecordSettingItem.h"
#import "MDCameraContainerViewController.h"
#import "MDRecordVideoResult.h"
#import "MDRecordImageResult.h"
#import "UINavigationController+AnimatedTransition.h"
#import "MDPhotoLibraryProvider.h"

#define kAlbumVideoMaxImageCount   10
static NSString * const kMDAlbumVideoSelectViewCellIdentifier = @"kMDAlbumVideoSelectViewCellIdentifier";

@interface MDAlbumVideoImageSortingView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *snapshotCell;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@property (nonatomic, strong) NSArray<MDPhotoItem *> *images;

@property (nonatomic, assign) BOOL photoAssetShow;

@end

@implementation MDAlbumVideoImageSortingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColor.blackColor;

        [self addSubview:self.collectionView];

        [self.collectionView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.collectionView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.collectionView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 0.3;
        [self.collectionView addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self.collectionView addGestureRecognizer:tap];
    }
    return self;
}

- (void)updateImages:(NSArray<MDPhotoItem *> *)images {
    self.images = images;
    
    [self.collectionView reloadData];
}

- (void)updateImagesOnly:(NSArray<MDPhotoItem *> *)images {
    _images = images;
    [self.collectionView reloadData];
}

- (void)setImages:(NSArray<MDPhotoItem *> *)images {
    _images = images;
    
    self.sorted ? self.sorted(images) : nil;
}

- (void)swapImageFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.images];
    MDPhotoItem *image = self.images[fromIndex];
    [mutableArray removeObjectAtIndex:fromIndex];
    [mutableArray insertObject:image atIndex:toIndex];
    self.images = mutableArray;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(60, 115);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 28, 0, 28);
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.clipsToBounds = NO;
        
        [_collectionView registerClass:[MDAlbumVideoImageSortingViewCollectionViewCell class] forCellWithReuseIdentifier:kMDAlbumVideoSelectViewCellIdentifier];
    }
    return _collectionView;
}

#pragma mark - long press methods

- (void)longPress:(UILongPressGestureRecognizer *)longPress {

    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint pos = [longPress locationInView:self.collectionView];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pos];
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
        }
            break;
        case UIGestureRecognizerStateChanged:
            [self.collectionView updateInteractiveMovementTargetPosition:[longPress locationInView:self.collectionView]];
            break;
        case UIGestureRecognizerStateEnded:
            [self.collectionView endInteractiveMovement];
            break;
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

//- (void)goToAsset {
//    //已经最大个数 不应该大于10
//    if(self.images.count >= kAlbumVideoMaxImageCount){
//        //提示的文案有待产品提供
//        [[MDContext sharedIndicate] showTipInView:[MDContext sharedAppDelegate].window withText:@"影集最多支持10张照片" timeOut:2.0];
//        return;
//    }
//    if ([[[MDContext currentUser] videoChatManager] checkConflictWithBizType:MomoMediaBizType_VideoRecord showTip:YES]) {
//        return;
//    }
//
//    if (![MDCameraContainerViewController checkDevicePermission]) {
//        return;
//    }
//
//    MDCameraContainerViewController *containerVC = [[MDCameraContainerViewController alloc] init];
//    __weak typeof(containerVC) weakContainerVC = containerVC;
//    MDUnifiedRecordSettingItem *settingItem = [MDUnifiedRecordSettingItem defaultConfigForSendFeed];
//    settingItem.levelType = MDUnifiedRecordLevelTypeAsset;
//    settingItem.accessSource = MDVideoRecordAccessSource_AlbumVideoChoosePicture;
//    settingItem.assetLevelType = MDAssetAlbumLevelTypeAlbumVideo;
//    settingItem.totalLimit = kAlbumVideoMaxImageCount;
//    NSInteger currentImageCount = self.images.count;
//    settingItem.selectionLimit = kAlbumVideoMaxImageCount - currentImageCount;
//    settingItem.completeHandler = ^(id result) {
//
//        if ([result isKindOfClass:[MDRecordImageResult class]]) {
//            NSArray<MDPhotoItem *> *photoItemArray = ((MDRecordImageResult *)result).photoItems;
//            NSMutableArray *currentImages = [NSMutableArray arrayWithArray:self.images];
//            [currentImages addObjectsFromArray:photoItemArray];
//            [self updateImages:currentImages];
//        }
//
//        [weakContainerVC dismissViewControllerAnimated:YES completion:nil];
//        self.photoAssetShow = NO;
//    };
//
//    containerVC.recordSetting = settingItem;
//
//    MDNavigationController *nav = [MDNavigationController md_NavigationControllerWithRootViewController:containerVC];
//    [MomoUtility goToViewController:nav animated:YES transtionStyle:MDViewControllerTransitionStylePresented];
//}

#pragma mark - tap methods

- (void)tapAction:(UITapGestureRecognizer *)tap {
    // prevent from poping up asset twice
    if (self.photoAssetShow) {
        return;
    }
    CGPoint pos = [tap locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pos];
    if (indexPath.row == self.images.count) {
        // 弹出相册
        self.photoAssetShow = YES;
//        [self goToAsset];
    }
}

#pragma mark - UICollectionViewDelegate Methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row != self.images.count;
}

- (void)collectionView:(UICollectionView *)collectionView
   moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath
           toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self swapImageFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (NSIndexPath *)collectionView:(UICollectionView *)collectionView
targetIndexPathForMoveFromItemAtIndexPath:(NSIndexPath *)originalIndexPath
            toProposedIndexPath:(NSIndexPath *)proposedIndexPath {
    if (proposedIndexPath.row == self.images.count) {
        return [NSIndexPath indexPathForRow:proposedIndexPath.row - 1 inSection:proposedIndexPath.section];
    }
    return proposedIndexPath;
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    if (self.images.count >= kAlbumVideoMaxImageCount) {
        return self.images.count;
//    }
//    return self.images.count + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MDAlbumVideoImageSortingViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMDAlbumVideoSelectViewCellIdentifier
                                                                                                     forIndexPath:indexPath];
    if (indexPath.row == self.images.count) {
        cell.image = [UIImage imageNamed:@"AddImageButton"];
        cell.closeButtonHidden = YES;
    } else {
        MDPhotoItem *item = self.images[indexPath.row];
        UIImage *image = nil;
        if (item.editedImage) {
            image = item.editedImage;
        } else if (item.nailImage) {
            image = item.nailImage;
        } else {
            image = item.originImage;
        }
        cell.image = image;
        cell.closeButtonHidden = self.images.count <= 2;
    }
    if (!cell.closeButtonTapped) {
        __weak typeof(self) weakself = self;
        cell.closeButtonTapped = ^(MDAlbumVideoImageSortingViewCollectionViewCell *cell) {
            __strong typeof(self) strongself = weakself;
            // 预防一下删除到两个以下
            if (strongself.images.count <= 2) {
                return;
            }
            NSIndexPath *indexPath = [strongself.collectionView indexPathForCell:cell];
            NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:strongself.images];
            MDPhotoItem *item = [mutableArray objectAtIndex:indexPath.row kindOfClass:[MDPhotoItem class]];
            strongself.deleteItem ? strongself.deleteItem(item) : nil;
            item.originImage = nil;
            [mutableArray removeObjectAtIndex:indexPath.row];
            strongself.images = mutableArray;

            if (strongself.images.count == kAlbumVideoMaxImageCount - 1) {
                [strongself.collectionView reloadData];
            } else {
                void(^deleteAction)(void) = ^{
                    [strongself.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                };
                
                if (strongself.images.count == 2) {
                    // 直接调用delete方法不会重新reload cell，那么closebutton不能准确隐藏
                    [weakself.collectionView performBatchUpdates:deleteAction completion:^(BOOL finished) {
                        [weakself.collectionView reloadItemsAtIndexPaths:[weakself.collectionView indexPathsForVisibleItems]];
                    }];
                } else {
                    deleteAction();
                }
            }
        };
    }
    return cell;
}

@end
