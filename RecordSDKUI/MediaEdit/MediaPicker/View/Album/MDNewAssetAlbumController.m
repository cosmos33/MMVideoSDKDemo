//
//  MDNewAssetAlbumController.m
//  MDChat
//
//  Created by YZK on 2018/10/26.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDNewAssetAlbumController.h"
#import "MDPhotoLibraryProvider.h"
#import "MDNewAssetAlbumCell.h"
#import "MDAssetUtility.h"

const static CGFloat kBackContentHeihgt = 450.0f;

@interface MDNewAssetAlbumController ()
<UITableViewDelegate,
UITableViewDataSource>
@property (nonatomic, strong) CAShapeLayer *backLayer;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *backContentView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation MDNewAssetAlbumController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:[self setupTopView]];
    [self.view addSubview:[self setupBottomView]];
    [self.view addSubview:[self setupBackContentView]];
    [self.backContentView.layer addSublayer:[self setupBackLayer]];
    [self.backContentView addSubview:[self setupTableView]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *albumArray = [[MDAssetUtility sharedInstance] fetchAlbumsWithMediaType:self.mediaType];
        [self handleImageAndCountWithAlbumArray:albumArray];
    });
}

- (void)handleImageAndCountWithAlbumArray:(NSArray *)albumArray {
    NSMutableArray *marr = [NSMutableArray array];
    for (int i=0; i<albumArray.count; i++) {
        PHAssetCollection *collection = albumArray[i];
        
        PHFetchResult *group = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        
        MDAssetAlbumItem *albumItem = [[MDAssetAlbumItem alloc] init];
        if (self.mediaType != MDAssetMediaTypeAll) {
            albumItem.count = [group countOfAssetsWithMediaType:[self mediaTypeWithMDType:self.mediaType]];
        }else {
            albumItem.count = group.count;
        }
        albumItem.name = collection.localizedTitle;
        albumItem.firstAsset = group.lastObject;
        albumItem.assetCollection = collection;
        [marr addObject:albumItem];
    }
    self.dataArray = marr;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (PHAssetMediaType)mediaTypeWithMDType:(MDAssetMediaType)type {
    switch (type) {
        case MDAssetMediaTypeAll:
            return PHAssetMediaTypeUnknown;
            break;
        case MDAssetMediaTypeOnlyPhoto:
            return PHAssetMediaTypeImage;
            break;
        case MDAssetMediaTypeOnlyVideo:
            return PHAssetMediaTypeVideo;
            break;
        default:
            return PHAssetMediaTypeUnknown;
            break;
    }
}

#pragma mark - event

- (void)backViewTap {
    if ([self.delegate respondsToSelector:@selector(didPickerAlbumCompleteWithItem:index:)]) {
        [self.delegate didPickerAlbumCompleteWithItem:nil index:NSNotFound];
    }
    [self hideWithAnimated:YES];
}


#pragma mark - animation

- (void)showWithAnimated:(BOOL)animated {
    self.backContentView.height = 0;
    self.bottomView.alpha = 0;
    [UIView animateWithDuration:animated ? 0.25 : 0.001 animations:^{
        self.backContentView.height = kBackContentHeihgt - self.topHeihgt;
        self.bottomView.alpha = 1;
    }];
}

- (void)hideWithAnimated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.25 : 0.001 animations:^{
        self.backContentView.height = 0;
        self.bottomView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self willMoveToParentViewController:nil];
        [self removeFromParentViewController];
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MDNewAssetAlbumCell";
    MDNewAssetAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MDNewAssetAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    MDAssetAlbumItem *item = [self.dataArray objectAtIndex:indexPath.row defaultValue:nil];
    [cell bindModel:item];
    
    if (!item.image) {
        [[MDAssetUtility sharedInstance] fetchSmallImageWithAsset:item.firstAsset targetSize:CGSizeMake(100, 100) complete:^(UIImage *image, NSString *identifer) {
            if ([cell.item.firstAsset.localIdentifier isEqualToString:identifer]) {
                cell.item.image = image;
                [cell bindModel:item];
            }
        }];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MDAssetAlbumItem *item = [self.dataArray objectAtIndex:indexPath.row defaultValue:nil];
    if ([self.delegate respondsToSelector:@selector(didPickerAlbumCompleteWithItem:index:)]) {
        [self.delegate didPickerAlbumCompleteWithItem:item index:indexPath.row];
    }
    [self hideWithAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kMDNewAssetAlbumCellHeight;
}


#pragma mark - UI

- (UIView *)setupTopView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, self.topHeihgt)];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTap)];
        [_topView addGestureRecognizer:tap];
    }
    return _topView;
}

- (UIView *)setupBottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topHeihgt, MDScreenWidth, MDScreenHeight-self.topHeihgt)];
        _bottomView.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTap)];
        [_bottomView addGestureRecognizer:tap];
    }
    return _bottomView;
}

- (UIView *)setupBackContentView {
    if (!_backContentView) {
        _backContentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topHeihgt, MDScreenWidth, kBackContentHeihgt-self.topHeihgt)];
        _backContentView.clipsToBounds = YES;
    }
    return _backContentView;
}

- (CAShapeLayer *)setupBackLayer {
    if (!_backLayer) {
        _backLayer = [CAShapeLayer layer];
        _backLayer.frame = self.backContentView.bounds;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:_backLayer.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
        _backLayer.path = path.CGPath;
        _backLayer.fillColor = [UIColor whiteColor].CGColor;
    }
    return _backLayer;
}

- (UITableView *)setupTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.backContentView.bounds];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(3, 0, 3, 0);
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

@end
