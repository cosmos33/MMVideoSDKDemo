//
//  MDAlbumVideoCoverContentView.m
//  MomoChat
//
//  Created by Leery on 2018/9/13.
//  Copyright © 2018年 wemomo.com. All rights reserved.
//

#import "MDAlbumVideoCoverContentView.h"
#import "MDAlbumVideoCoverFlowLayout.h"
#import "MDMomentThumbCell.h"
//#import <UIImage+MDUtility.h>
#import "MDPhotoLibraryProvider.h"
#import "UIConst.h"
#import "UIView+Utils.h"

#define kMomentThumbCell        @"kMomentThumbCell"

@interface MDAlbumVideoCoverContentView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic ,strong) UIImageView                   *coverSelectBox;
@property (nonatomic ,strong) UICollectionView              *collectionView;
@property (nonatomic ,strong) NSArray                       *photoItemsArray;
@property (nonatomic ,strong) MDPhotoItem                   *currentPhotoItem;
@property (nonatomic ,strong) MDPhotoItem                   *prePhotoItem;
@property (nonatomic ,copy) AlbumVideoCoverSelectedBlock    selectedBlock;

@end

@implementation MDAlbumVideoCoverContentView

#pragma mark - life
- (instancetype)initWithPhotoItems:(NSArray *)array {
    if(self = [super init]) {
        self.width = MDScreenWidth;
        self.height = kAlbumVideoCoverContentViewHeight;
        self.photoItemsArray = array;
//        self.currentPhotoItem = [array objectAtIndex:0 kindOfClass:[MDPhotoItem class]];
        self.currentPhotoItem = (MDPhotoItem *)array.firstObject;
        [self setupAlbumVideoCoverContentView];
    }
    return self;
}

#pragma mark - setupUI
- (void)setupAlbumVideoCoverContentView {
    [self addSubview:self.collectionView];
    [self addSubview:self.coverSelectBox];
    [self reloadCollectionView];
}

#pragma mark - public
- (void)albumVideoCoverSelectedItem:(AlbumVideoCoverSelectedBlock)block {
    self.selectedBlock = block;
}

- (void)updateAlbumVideoCoverContentViewWithArray:(NSArray *)array selectedItem:(MDPhotoItem *)photoItem {
    self.photoItemsArray = array;
    if(photoItem && [array containsObject:photoItem]) {
        _currentPhotoItem = photoItem;
    }else{
//        _currentPhotoItem = [array objectAtIndex:0 kindOfClass:[MDPhotoItem class]];
        _currentPhotoItem = (MDPhotoItem *)array.firstObject;
        if(self.selectedBlock) {
            self.selectedBlock(nil);
        }
    }
    [self setupPreload];
}

#pragma mark - private
- (void)bringMomentCoverCellToFrontWithItem:(MDPhotoItem *)photoItem {
    if([self.photoItemsArray containsObject:photoItem]) {
        NSInteger row = [self.photoItemsArray indexOfObject:photoItem];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        MDMomentThumbCell *cell = (MDMomentThumbCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self.collectionView bringSubviewToFront:cell];
    }
}

- (void)reloadCollectionView {
    [self.collectionView reloadData];
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf bringMomentCoverCellToFrontWithItem:weakSelf.currentPhotoItem];
    });
}

- (void)setupPreload {
    [self.collectionView reloadData];
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf scrollerToPreloadIndexItem];
    });
}

- (void)scrollerToPreloadIndexItem {
    if([self.photoItemsArray containsObject:self.currentPhotoItem]) {
        NSInteger index = [self.photoItemsArray indexOfObject:self.currentPhotoItem];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf bringMomentCoverCellToFrontWithItem:self.currentPhotoItem];
        });
    }
}

- (void)setCurrentPhotoItem:(MDPhotoItem *)currentPhotoItem {
    if(![_currentPhotoItem isEqual:currentPhotoItem]) {
        _currentPhotoItem = currentPhotoItem;
        [self bringMomentCoverCellToFrontWithItem:_currentPhotoItem];
        if(self.selectedBlock) {
            self.selectedBlock(_currentPhotoItem);
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoItemsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MDPhotoItem *photoItem = (MDPhotoItem *)self.photoItemsArray[indexPath.row];
    UIImage *thumbeImage = nil;
    if(photoItem.editedImage) {
        thumbeImage = photoItem.editedImage;
    } else if(photoItem.nailImage) {
        thumbeImage = photoItem.nailImage;
    } else if(photoItem.originImage) {
        thumbeImage = photoItem.originImage;
    }
    MDMomentThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMomentThumbCell forIndexPath:indexPath];
    [cell updateCoverNailImageWithImage:thumbeImage];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint pointInView = [self convertPoint:self.collectionView.center toView:self.collectionView];
    NSIndexPath *indexPathNow = [self.collectionView indexPathForItemAtPoint:pointInView];
    MDPhotoItem *photoItem = indexPathNow.row >= self.photoItemsArray.count ? nil : self.photoItemsArray[indexPathNow.row];
    if (photoItem != self.currentPhotoItem) {
        self.currentPhotoItem = photoItem;
    }
}

#pragma mark - lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        MDAlbumVideoCoverFlowLayout *layout = [[MDAlbumVideoCoverFlowLayout alloc] init];
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, MDScreenWidth, kAlbumVideoCoverContentViewHeight) collectionViewLayout:layout];
        if ([_collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            [_collectionView setPrefetchingEnabled:NO];
        }
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.scrollsToTop = NO;
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[MDMomentThumbCell class] forCellWithReuseIdentifier:kMomentThumbCell];
        _collectionView.alwaysBounceHorizontal = YES;
    }
    return _collectionView;
}

- (UIImageView *)coverSelectBox {
    if(!_coverSelectBox) {
        UIImage *image = [[UIImage imageNamed:@"icon_albumCover_rectangle"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
        _coverSelectBox = [[UIImageView alloc] initWithImage:image];
        _coverSelectBox.size = CGSizeMake(51, 73);
        _coverSelectBox.backgroundColor = [UIColor clearColor];
        _coverSelectBox.centerX = self.collectionView.centerX;
        _coverSelectBox.centerY = self.collectionView.centerY;
    }
    return _coverSelectBox;
}

@end
