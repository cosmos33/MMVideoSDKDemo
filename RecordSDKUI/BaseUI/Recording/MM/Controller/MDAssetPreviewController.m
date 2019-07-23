//
//  MDAssetPreviewController.m
//  MDChat
//
//  Created by Aaron on 16/6/27.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDAssetPreviewController.h"
#import "MDImageEditorViewController.h"
#import "MDAssetPreviewCell.h"
#import "MDAssetUtility.h"
#import "MDAlbumiCloudAssetHelper.h"

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+LargeImage.h"
#import "MDNormalButtonItem.h"
#import "MDRecordUtility.h"
#import "Toast/Toast.h"

@interface MDAssetPreviewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate>


@property (nonatomic, strong) MDNormalButtonItem    *rightItem; //右上角选中按钮
@property (nonatomic, strong) UILabel               *numLabel;  //右上角选中数量label
@property (nonatomic, strong) UICollectionView      *collectionView;
@property (nonatomic, strong) UIView                *bottomBackView; //下方视图
@property (nonatomic, strong) UILabel               *originLabel;    //原图label
@property (nonatomic, strong) UIButton              *originButton;   //原图按钮
@property (nonatomic, strong) UIButton              *sendButton;     //发送按钮
@property (nonatomic, strong) UIButton              *editButton;     //编辑按钮
@property (nonatomic, strong) UIScrollView          *miniPhotosView; //下发选中图片scrollView
@property (nonatomic, strong) UIView                *backView;       //选中图片选择框

@property (nonatomic, copy) NSString                *lengthStr;
@property (nonatomic, assign) BOOL                  fullScreen;            //是否全屏

@property (nonatomic, strong) NSMutableArray        *actualAssets;         //实际数据源
@property (nonatomic, strong) NSMutableArray        *actualAddressAssets;  //新地点和自拍数据源
@property (nonatomic, strong) NSIndexPath           *currentIndexPath;     //当前indexPath

@property (nonatomic, strong) NSMutableDictionary   *cachedImageDic;
@end


@implementation MDAssetPreviewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCurrentIndexPath:(NSIndexPath *)indexPath {
    self = [super init];
    if (self) {
        self.currentIndexPath = indexPath;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionWhenDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshSendButton];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:NO];
    _bottomBackView.hidden = NO;
    [self scrollEndAction];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setAutomaticallyAdjustsScrollViewInsets:NO];

    [self addBarItem];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomBackView];

    [self.collectionView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:self.collectionView afterDelay:0.5];
    
    [self updateMiniPhotosView];
    [self updateSpotLight];
    
    //添加手势
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickAllScreen:)];
    [self.collectionView addGestureRecognizer:tapGes];
}

// 更新底部选中图片scrollView
- (void)updateMiniPhotosView {
    [self.miniPhotosView removeAllSubviews];
    [self.miniPhotosView addSubview:self.backView];
    
    NSArray *assetArray = self.assetState.selectedArray;
    for (int i = 0; i < assetArray.count; i++) {
        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.frame = CGRectMake(i*45+10, 10, 35, 35);
        [imageButton addTarget:self action:@selector(miniPhotosAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageButton.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 3.0;
        imageView.clipsToBounds = YES;
        [imageButton addSubview:imageView];
        
        MDAssetStateModel *model = assetArray[i];
        NSIndexPath *fetchAssetIndexPath = model.indexPath;

        NSInteger index = 0;
        NSInteger section = fetchAssetIndexPath.section;
        if ([self judgeShowTwoSection] && fetchAssetIndexPath.section == 0) {
            index = [self.actualAddressAssets indexOfObject:model.assetItem];
        } else {
            index = [self.actualAssets indexOfObject:model.assetItem];
        }
        
        imageButton.tag = section<<20 | index;
        
        if (model.assetItem.editedImage) {
            imageView.image = model.assetItem.editedImage;
            UIImageView *editIcon = [[UIImageView alloc] initWithFrame:CGRectMake(4, 23, 9, 9)];
            editIcon.image = [UIImage imageNamed:@"icon_album_edit"];
            [imageButton addSubview:editIcon];
        } else {
            [[MDAssetUtility sharedInstance] fetchLowQualityImageWithPhotoItem:model.assetItem complete:^(UIImage *image, NSString *identifer) {
                imageView.image = image;
            }];
        }
        [self.miniPhotosView addSubview:imageButton];
        self.miniPhotosView.contentSize = CGSizeMake(imageButton.right+20, self.miniPhotosView.height);
    }
}

// 更新底部选中图片的选中框
- (void)updateSpotLight {
    MDPhotoItem *item = [self getActualPhotoItemWithActualIndexPath:self.currentIndexPath];
    NSInteger index = [self.assetState indexOfSelectAssetItem:item];
    if (index == NSNotFound) {
        self.backView.hidden = YES;
        return;
    }
    self.backView.hidden = NO;
    self.backView.left = index*45+9;
    if (self.backView.right - self.miniPhotosView.contentOffset.x > MDScreenWidth) {
        //如果框右侧超出当前显示范围，右移scrollView
        [self.miniPhotosView setContentOffset:CGPointMake(self.backView.right-MDScreenWidth, 0) animated:YES];
    } else if (self.backView.left < self.miniPhotosView.contentOffset.x) {
        //如果框左侧超出当前显示范围，左移scrollView
        [self.miniPhotosView setContentOffset:CGPointMake(self.backView.left, 0) animated:YES];
    }
}


#pragma mark - public

- (void)setFetchedAssets:(NSArray *)fetchedAssets {
    _fetchedAssets = fetchedAssets;
    [self.actualAssets removeAllObjects];
    for (MDPhotoItem *item in fetchedAssets) {
        if ([item isKindOfClass:[MDPhotoItem class]]) {
            if (item.type == MDPhotoItemTypeImage) {
                [self.actualAssets addObjectSafe:item];
            }
        }
    }
}
- (void)setAddressFetchedAssets:(NSArray *)addressFetchedAssets{
    _addressFetchedAssets = addressFetchedAssets;
    [self.actualAddressAssets removeAllObjects];
    for (MDPhotoItem *item in addressFetchedAssets) {
        if ([item isKindOfClass:[MDPhotoItem class]]) {
            if (item.type == MDPhotoItemTypeImage) {
                [self.actualAddressAssets addObjectSafe:item];
            }
        }
    }
}

#pragma mark - event

- (void)actionWhenDidBecomeActive {
    [self scrollEndAction];
}

- (void)back {
    if (self.navigationController.viewControllers.firstObject == self) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didClickAllScreen:(UITapGestureRecognizer *)tap {
    _fullScreen = !_fullScreen;
    _bottomBackView.hidden = _fullScreen;
    [self.navigationController setNavigationBarHidden:_fullScreen animated:NO];
}

- (void)didClickSelectButton:(id)sender {
    [self selectCurrentImage];
}

- (void)didClickSelectOriginButton:(UIButton *)button {
    MDPhotoItem *item = [self getActualPhotoItemWithActualIndexPath:self.currentIndexPath];
    NSInteger index = [self.assetState indexOfSelectAssetItem:item];
    if (index != NSNotFound) {//若当前图片已被选中，原图逻辑无限制
        button.selected = !button.selected;
        self.isOrigin = !self.isOrigin;
    } else { //若当前图片未选中
        if (self.assetState.selectedCount >= self.assetState.selectionLimit) {//已选满，原图按钮无效
            NSString *errMsg = [NSString stringWithFormat:@"最多选择%d张图片", (int)self.assetState.selectionLimit?:6];
            [self.view makeToast:errMsg duration:1.5f position:CSToastPositionCenter];
        } else {//未满，点原图的同时图片被选中
            button.selected = !button.selected;
            self.isOrigin = !self.isOrigin;
            [self selectCurrentImage];
        }
    }
    if (button.selected) {
        self.originLabel.text = self.lengthStr;
    } else {
        self.originLabel.text = @"原图";
    }
}

- (void)didClickEditButton {
    MDAssetPreviewCell *cell = (MDAssetPreviewCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    MDPhotoItem *item = [self getActualPhotoItemWithActualIndexPath:self.currentIndexPath];
    
    //相册预览页面进入编辑页
    UIImage *image = [MDRecordUtility checkOrScaleImage:cell.previewImageView.image ignoreLongPic:YES];
    if (!image) {
        return;
    }

    @weakify(self);
    MDImageEditorViewController *vc = [[MDImageEditorViewController alloc]initWithImage:image completeBlock:^(UIImage *image, BOOL isEdited) {
        @strongify(self);
        
        cell.previewImageView.image = image;
        item.edited = YES;
        item.editedImage = image;
        NSData *imageData = UIImageJPEGRepresentation(item.editedImage, 1.0);
        item.originLength = imageData.length;
        self.lengthStr = [[self class] stringWithOriginPictureLength:item.originLength];
        
        //未被选中, 且小于6张
        if (!item.selected && self.assetState.selectedCount < self.assetState.selectionLimit) {
            [self selectCurrentImage];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        [self updateMiniPhotosView];
    }];
    
    __weak MDImageEditorViewController *weakImageEditorVC = vc;
    vc.cancelBlock = ^(BOOL isEdit) {
        [weakImageEditorVC.navigationController popViewControllerAnimated:YES];
    };
    vc.imageUploadParamModel = item.imageUploadParamModel;
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

+ (NSString *)stringWithOriginPictureLength:(NSInteger)length
{
    float lenM = length * 1.0 / (1024 * 1024);
    if (lenM >= 1.) {
        return [NSString stringWithFormat:@"原图(%.2fM)", lenM];
    } else {
        return [NSString stringWithFormat:@"原图(%dK)", (int)(lenM * 1024)];
    }
}

- (void)didClickSendButton:(id)sender {
    for (MDAssetStateModel *model in self.assetState.selectedArray) {
        MDPhotoItem *item = model.assetItem;
        if ([item isKindOfClass:[MDPhotoItem class]]) {
            item.isOrigin = self.isOrigin;
        }
    }
    
    if (self.assetState.selectedCount == 0) {
        //选中当前预览图片
        [self selectCurrentImage];
    }
    
    if ([self.delegate respondsToSelector:@selector(assetPreviewControllerDidFinish:)]) {
        [self.delegate assetPreviewControllerDidFinish:self];
    }
}


- (void)miniPhotosAction:(UIButton *)sender {
    NSInteger idx = sender.tag;
    if (idx >= 0) {
        NSInteger section = idx >> 20;
        NSInteger row = idx & 0xFFFFF;
        self.currentIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self.collectionView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        [self updateSpotLight];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollEndAction];
        });
    }
}

#pragma mark - private

- (void)refreshSendButton {
    NSString *str = [self.settingItem.doneBtnText isNotEmpty] ? self.settingItem.doneBtnText : @"发送";
    if (self.assetState.selectedCount > 0) {
        NSString *title = nil;
        title = [NSString stringWithFormat:@"%@ (%lu)",str, (unsigned long)self.assetState.selectedCount];
        [self.sendButton setTitle:title forState:UIControlStateNormal];
    } else {
        [self.sendButton setTitle:str forState:UIControlStateNormal];
    }
}

- (NSIndexPath *)getActualIndexPathWithContentOffsetX:(CGFloat)contentOffsetX {
    NSInteger index = roundf(contentOffsetX / MDScreenWidth);
    if ([self judgeShowTwoSection]) {
        NSInteger section = 0;
        if (index >= self.addressFetchedAssets.count) {
            section = 1;
            index -= self.addressFetchedAssets.count;
        }
        return [NSIndexPath indexPathForRow:index inSection:section];
    }
    return [NSIndexPath indexPathForRow:index inSection:0];
}

// 将collectionView的实际indexPath 转换为传入的fetchAsset的indexPath (注意actualAssets和fetchedAssets的区别，fetchAsset并没有过滤图片，所以indexPath和实际indexPath不一样)
- (NSIndexPath *)getFetchAssetIndexPathFromActualIndexPath:(NSIndexPath *)actualIndexPath {
    MDPhotoItem *item = [self getActualPhotoItemWithActualIndexPath:actualIndexPath];
    if (!item) {
        return nil;
    }
    NSInteger row;
    if ([self judgeShowTwoSection] && actualIndexPath.section == 0) {
        row = [self.addressFetchedAssets indexOfObject:item];
    } else{
        row = [self.fetchedAssets indexOfObject:item];
    }
    return [NSIndexPath indexPathForRow:row inSection:actualIndexPath.section];
}


- (MDPhotoItem *)getActualPhotoItemWithActualIndexPath:(NSIndexPath*)indexPath{
    if ([self judgeShowTwoSection] && indexPath.section == 0) {
        return [self.actualAddressAssets objectAtIndex:indexPath.row defaultValue:nil];
    }
    return [self.actualAssets objectAtIndex:indexPath.row defaultValue:nil];
}

- (BOOL)judgeShowTwoSection{
    if (self.addressFetchedAssets.count == 0) {
        return NO;
    }
    return YES;
}

- (void)selectCurrentImage {
    MDPhotoItem *item = [self getActualPhotoItemWithActualIndexPath:self.currentIndexPath];
    NSIndexPath *actualIndexPath = [self getFetchAssetIndexPathFromActualIndexPath:self.currentIndexPath];
    
    if (self.assetState.selectedCount >= self.assetState.selectionLimit && !item.selected) {//已选满，且当前图未选中，按钮无效
        NSString *errMsg = [NSString stringWithFormat:@"最多选择%d张图片", (int)self.assetState.selectionLimit?:6];
        [self.view makeToast:errMsg duration:1.5f position:CSToastPositionCenter];
    } else {//按钮有效
        if (item) {
            item.selected = !item.selected;
            [self.rightItem setImage:(item.selected ? [UIImage imageNamed:@"icon_album_selected"] : [UIImage imageNamed:@"icon_album_unselected"]) forState:UIControlStateNormal];
            if (item.selected && self.isOrigin) {
                self.originButton.selected = YES;
                self.originLabel.text = self.lengthStr;
            }
        }
        [self.assetState changeSelectState:item.selected forAsset:item indexPath:actualIndexPath];
        [self refreshSendButton];

        if (item.selected) {
            [self updateCellPhotoNumber];
        } else {
            self.numLabel.text = @"";
        }

        [self updateMiniPhotosView];
        [self updateSpotLight];
    }
}

- (void)updateCellPhotoNumber {
    NSIndexPath *actualIndexPath = [self getFetchAssetIndexPathFromActualIndexPath:self.currentIndexPath];
    NSArray *indexPathArray = [self.assetState updateAssetSelectIndex];
    NSInteger index = [indexPathArray indexOfObject:actualIndexPath];
    if (index != NSNotFound) {
        self.numLabel.text = [NSString stringWithFormat:@"%d", (int)index+1];
    }
}


#pragma mark - collection view delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([self judgeShowTwoSection]) {
        return 2;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self judgeShowTwoSection] && section == 0) {
        return self.actualAddressAssets.count;
    }
    return self.actualAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MDAssetPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MDAssetPreviewCell" forIndexPath:indexPath];
    
    UIImage *image = [self.cachedImageDic objectForKey:indexPath];
    MDPhotoItem *item = [self getActualPhotoItemWithActualIndexPath:indexPath];
    if (item.editedImage) {
        cell.previewImageView.image = item.editedImage;
    } else if (image) {
        cell.previewImageView.image = image;
    } else {
        cell.previewImageView.image = nil;
        if (item) {
            __weak typeof(self) weakSelf = self;
            [[MDAlbumiCloudAssetHelper sharedInstance] getDegradedImageFromPhotoItem:item targetSize:CGSizeMake(MDScreenWidth*2, MDScreenHeight*2) completeBlock:^(UIImage *result, MDPhotoItem *resultItem, BOOL isDegraded) {
                if (resultItem == item) {
                    cell.previewImageView.image = result;
                    if (!isDegraded) {
                        [weakSelf.cachedImageDic setObjectSafe:result forKey:indexPath];
                    }
                }
            }];
        }
    }
    return cell;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView { //该方法正常滑动结束不会调用
    [self scrollEndAction];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollEndAction];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollEndAction];
    }
}

-(void)scrollEndAction {
    NSIndexPath *actualIndexPath = [self getActualIndexPathWithContentOffsetX:self.collectionView.contentOffset.x];
    self.currentIndexPath = actualIndexPath;
    MDPhotoItem *item = [self getActualPhotoItemWithActualIndexPath:actualIndexPath];
    
    if (item) {
        [self.rightItem setImage:(item.selected ? [UIImage imageNamed:@"icon_album_selected"] : [UIImage imageNamed:@"icon_album_unselected"]) forState:UIControlStateNormal];
        self.originButton.selected = (self.isOrigin && item.selected);
    }
    if (item.selected) {
        [self updateCellPhotoNumber];
    } else {
        self.numLabel.text = @"";
    }
    
    MDAssetPreviewCell *cell = (MDAssetPreviewCell *)[self.collectionView cellForItemAtIndexPath:actualIndexPath];
    
    if (item) {
        if (item.editedImage) {
            cell.previewImageView.image = item.editedImage;
            
            self.lengthStr = [[self class] stringWithOriginPictureLength:item.originLength];
            if (self.originButton.selected) {
                self.originLabel.text = self.lengthStr;
            } else {
                self.originLabel.text = @"原图";
            }
        } else {
            @weakify(self);
            [[MDAlbumiCloudAssetHelper sharedInstance].imageManager requestImageDataForAsset:item.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                @strongify(self);
                if ([actualIndexPath isEqual:self.currentIndexPath]) {
                    if (imageData) {
                        cell.previewImageView.image = [[UIImage imageWithData:imageData] downsize];
                        item.originLength = imageData.length;
                    }
                    self.lengthStr = [[self class] stringWithOriginPictureLength:imageData.length];
                    if (self.originButton.selected) {
                        self.originLabel.text = self.lengthStr;
                    } else {
                        self.originLabel.text = @"原图";
                    }
                }
            }];
        }
    }
    [self updateSpotLight];
}

#pragma mark -- lazy

- (NSMutableDictionary *)cachedImageDic {
    if (!_cachedImageDic) {
        _cachedImageDic = [[NSMutableDictionary alloc]init];
    }
    return _cachedImageDic;
}

- (NSMutableArray *)actualAddressAssets {
    if (!_actualAddressAssets) {
        _actualAddressAssets = [NSMutableArray array];
    }
    return _actualAddressAssets;
}

- (NSMutableArray *)actualAssets {
    if (!_actualAssets) {
        _actualAssets = [NSMutableArray array];
    }
    return _actualAssets;
}


- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(9, 9, 37, 37)];
        _backView.layer.cornerRadius = 3.0;
        _backView.backgroundColor = RGBCOLOR(0, 192, 255);
        _backView.clipsToBounds = YES;
        _backView.hidden = YES;
    }
    return _backView;
}

- (void)addBarItem {
    MDNormalButtonItem *leftItem = [[MDNormalButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_tag_goback"]];
    [leftItem setTitleHighLight:YES];
    [leftItem addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarItem:leftItem];
    
    self.rightItem = [[MDNormalButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_album_unselected"]];
    [self.rightItem.navButton addSubview:self.numLabel];
    [self.rightItem addTarget:self action:@selector(didClickSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBarItem:self.rightItem];
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc]initWithFrame:self.rightItem.navButton.bounds];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _numLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0.;
        layout.itemSize = CGSizeMake(MDScreenWidth, MDScreenHeight);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight) collectionViewLayout:layout];
        if ([_collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            [_collectionView setPrefetchingEnabled:NO];
        }
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor blackColor];
        [_collectionView registerClass:[MDAssetPreviewCell class] forCellWithReuseIdentifier:@"MDAssetPreviewCell"];
    }
    return _collectionView;
}

- (UIView *)bottomBackView {
    if (!_bottomBackView) {
        CGFloat height = 99 + HOME_INDICATOR_HEIGHT;
        _bottomBackView = [[UIView alloc]initWithFrame:CGRectMake(0, MDScreenHeight-height, MDScreenWidth, height)];
        _bottomBackView.backgroundColor = RGBACOLOR(30, 30, 30, 0.9);
        [_bottomBackView addSubview:self.miniPhotosView];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(7.5, 54.5, MDScreenWidth-15, 0.5)];
        lineView.backgroundColor = RGBACOLOR(0, 0, 0, 0.2);
        [_bottomBackView addSubview:lineView];

        if (self.enableOrigin) {
            [_bottomBackView addSubview:self.originButton];
            [_bottomBackView addSubview:self.originLabel];
        }
        [_bottomBackView addSubview:self.sendButton];
        [_bottomBackView addSubview:self.editButton];
    }
    return _bottomBackView;
}

- (UILabel *)originLabel {
    if (!_originLabel) {
        _originLabel = [[UILabel alloc]initWithFrame:CGRectMake(MDScreenWidth/2.0, 55, 50, 44)];
        _originLabel.textColor = RGBCOLOR(170, 170, 170);
        _originLabel.font = [UIFont systemFontOfSize:14.0];
        _originLabel.text = @"原图";
    }
    return _originLabel;
}

- (UIButton *)originButton {
    if (!_originButton) {
        _originButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originButton.frame = CGRectMake(MDScreenWidth/2.0-25, 57, 60, 40);
        [_originButton setImage:[UIImage imageNamed:@"icon_asset_origin_n"] forState:UIControlStateNormal];
        [_originButton setImage:[UIImage imageNamed:@"icon_asset_origin"] forState:UIControlStateSelected];
        [_originButton addTarget:self action:@selector(didClickSelectOriginButton:) forControlEvents:UIControlEventTouchUpInside];
        _originButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40);
    }
    return _originButton;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(5, 67, 40, 20);
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_editButton setTitleColor:RGBCOLOR(170, 170, 170) forState:UIControlStateNormal];
        _editButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_editButton addTarget:self action:@selector(didClickEditButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.frame = CGRectMake(MDScreenWidth-75, 67, 70, 20);
        _sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_sendButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        
        NSString *title = [self.settingItem.doneBtnText isNotEmpty] ? self.settingItem.doneBtnText : @"发送";
        [_sendButton setTitle:title forState:UIControlStateNormal] ;
        
        [_sendButton setTitleColor:RGBCOLOR(0, 192, 255) forState:UIControlStateNormal];
        [_sendButton setTitleColor:RGBCOLOR(170, 170, 170) forState:UIControlStateDisabled];
        _sendButton.titleLabel.font =  [UIFont systemFontOfSize:15.0];
        [_sendButton addTarget:self action:@selector(didClickSendButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (UIScrollView *)miniPhotosView {
    if (!_miniPhotosView) {
        _miniPhotosView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, MDScreenWidth, 55)];
        _miniPhotosView.backgroundColor = [UIColor clearColor];
    }
    return _miniPhotosView;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
