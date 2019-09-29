//
//  MDMomentThumbSelectViewController.m
//  MDChat
//
//  Created by Leery on 16/12/28.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MDMomentThumbSelectViewController.h"
#import "MDNavigationTransitionExtra.h"
#import "MDMomentThumbFlowLayout.h"
#import "MDMomentThumbCell.h"
#import "MDRecordHeader.h"

#define kMomentThumbCell         @"kMomentThumbCell"
#define kBackButtonTag          100
#define kChooseButtonTag        101

#if !__has_feature(objc_arc)
#error MDMomentThumbSelectViewController must be built with ARC.
#endif

@interface MDMomentThumbSelectViewController ()<MDNavigationBarAppearanceDelegate,UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic ,strong) UIImageView           *largeCoverImageView;
@property (nonatomic ,strong) UIView                *bottomView;
@property (nonatomic ,strong) UILabel               *bottomTipLabel;
@property (nonatomic ,strong) UIImageView           *coverSelectBox;
@property (nonatomic ,strong) UICollectionView      *collectionView;
@property (nonatomic ,strong) AVPlayer              *player;
@property (nonatomic ,strong) AVPlayerLayer         *playerLayer;
@property (nonatomic, strong) NSIndexPath           *currentIndexPath;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation MDMomentThumbSelectViewController

#pragma mark - life

- (void)dealloc {
    //NSLog(@"MDMomentThumbSelectViewController - dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPreview];
    [self setupContentView];
    [self setupPreload];
}

- (void)setupPreview
{
    AVAsset *asset = nil;
    if (_deleagte && [_deleagte respondsToSelector:@selector(momentCoverSourceAsset)]) {
        asset = [_deleagte momentCoverSourceAsset];
    }
    
    if (asset) {
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        self.player = [[AVPlayer alloc] initWithPlayerItem:item];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.largeCoverImageView.bounds;
        [self.largeCoverImageView.layer addSublayer:self.playerLayer];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - UI
- (void)setupContentView {
    
    [self.view addSubview:self.largeCoverImageView];
    [self.largeCoverImageView addSubview:self.bottomView];
    [self setupCustomNavigationItem];
    [self.bottomView addSubview:self.coverSelectBox];
}

- (void)setupPreload {
    
    [self.collectionView reloadData];
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf scrollerToPreloadIndexItem];
    });
}

- (void)scrollerToPreloadIndexItem {
    
    if (self.preLoadIndex >= 0 && self.preLoadIndex < self.thumbDataArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.preLoadIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
        NSValue *timeValue = [self.thumbTimeArray objectAtIndex:self.preLoadIndex kindOfClass:[NSValue class]];
        [self resetLargeCoverImageViewWithTime:[timeValue CMTimeValue]];
        
        self.currentIndexPath = indexPath;
        
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf bringMomentCoverCellToFrontWithIndexPath:indexPath];
        });
    }
}

- (void)setupCustomNavigationItem {
    
//    UIImage *closeImage = [UIImage imageNamed:@"moment_return"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
//    backButton.frame = CGRectMake(5, 5, closeImage.size.width +20, closeImage.size.height +20);
    backButton.backgroundColor = [UIColor clearColor];
//    [backButton setImage:closeImage forState:UIControlStateNormal];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = kBackButtonTag;
    [self.view addSubview:backButton];
    
//    UIImage *chooseImage = [UIImage imageNamed:@"media_editor_compelete"];
    UIButton *chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    chooseButton.translatesAutoresizingMaskIntoConstraints = NO;
//    chooseButton.frame = CGRectMake(MDScreenWidth -chooseImage.size.width -15, 15 + HOME_INDICATOR_HEIGHT, chooseImage.size.width, chooseImage.size.height);
//    backButton.centerY = chooseButton.centerY;
//    chooseButton.right = MDScreenWidth - 15;
    chooseButton.backgroundColor = [UIColor clearColor];
    [chooseButton setTitle:@"确定" forState:UIControlStateNormal];
//    [chooseButton setImage:chooseImage forState:UIControlStateNormal];
    [chooseButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    chooseButton.tag = kChooseButtonTag;
    [self.view addSubview:chooseButton];
    
    [backButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:15].active = YES;
    [backButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15 + HOME_INDICATOR_HEIGHT].active = YES;
    
    [chooseButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-15].active = YES;
    [chooseButton.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor].active = YES;
}

#pragma mark - action
- (void)reloadCollectionView {
    [self.collectionView reloadData];
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf bringMomentCoverCellToFrontWithIndexPath:weakSelf.currentIndexPath];
    });
}

- (void)btnAction:(UIButton *)btn {
    
    if(self.deleagte && [self.deleagte respondsToSelector:@selector(momentCoverImage:atThumbIndex:)]) {
        
        UIImage *largeCoverImage = [self getLargeCoverImageWithTime:self.player.currentTime];
        
        if(largeCoverImage && btn.tag == kChooseButtonTag) {
            [self.deleagte momentCoverImage:largeCoverImage atThumbIndex:self.currentIndexPath.row];
        }else{
            [self.deleagte momentCoverImage:nil atThumbIndex:NSNotFound];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIImage *)getLargeCoverImageWithTime:(CMTime)time
{
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.player.currentItem.asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    _maxThumbSize = (_maxThumbSize == 0.0f) ? 640 : _maxThumbSize;
    imageGenerator.maximumSize = CGSizeMake(_maxThumbSize, _maxThumbSize);
    
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:2.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return image;
}

- (void)resetLargeCoverImageViewWithTime:(CMTime)time
{
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)bringMomentCoverCellToFrontWithIndexPath:(NSIndexPath *)indexPath {
    MDMomentThumbCell *cell = (MDMomentThumbCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self.collectionView bringSubviewToFront:cell];
}

#pragma mark - 懒加载
- (UIImageView *)largeCoverImageView {
    
    if(!_largeCoverImageView) {
        _largeCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)];
        _largeCoverImageView.backgroundColor = [UIColor blackColor];
        _largeCoverImageView.userInteractionEnabled = YES;
    }
    return _largeCoverImageView;
}

- (UIView *)bottomView {
    
    if(!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MDScreenHeight - 160 - HOME_INDICATOR_HEIGHT, MDScreenWidth, 160 + HOME_INDICATOR_HEIGHT)];
        _bottomView.backgroundColor = RGBACOLOR(0, 0, 0, 0.8);
        _bottomView.layer.cornerRadius = 10;
        
        CGFloat bottomTipLabelH = 14+16+HOME_INDICATOR_HEIGHT;
        _bottomTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _bottomView.height-bottomTipLabelH, MDScreenWidth-20, bottomTipLabelH)];
        _bottomTipLabel.textAlignment = NSTextAlignmentCenter;
        _bottomTipLabel.textColor = RGBACOLOR(255, 255, 255, 0.3);
        _bottomTipLabel.numberOfLines = 1;
        _bottomTipLabel.font = [UIFont systemFontOfSize:12];
        _bottomTipLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _bottomTipLabel.text = @"滑动可选择一张封面";
        [_bottomView addSubview:_bottomTipLabel];
        
        [_bottomView addSubview:self.titleLabel];
        [self.titleLabel.leftAnchor constraintEqualToAnchor:self.bottomView.leftAnchor constant:27].active = YES;
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.bottomView.topAnchor constant:20].active = YES;
        
        [_bottomView addSubview:self.collectionView];
    }
    return _bottomView;
}

- (UIImageView *)coverSelectBox {
    
    if(!_coverSelectBox) {
        _coverSelectBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iocn_moment_coverSelectBox"]];
        _coverSelectBox.backgroundColor = [UIColor clearColor];
        _coverSelectBox.centerX = self.collectionView.centerX;
        _coverSelectBox.centerY = self.collectionView.centerY;
    }
    return _coverSelectBox;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        MDMomentThumbFlowLayout *layout = [[MDMomentThumbFlowLayout alloc] init];
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 55, MDScreenWidth, 77) collectionViewLayout:layout];
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

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.text = @"封面";
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImage *thumbImage = [self.thumbDataArray objectAtIndex:indexPath.row kindOfClass:[UIImage class]];
    MDMomentThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMomentThumbCell forIndexPath:indexPath];
    [cell updateCoverNailImageWithImage:thumbImage];

    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint pointInView = [self.bottomView convertPoint:self.collectionView.center toView:self.collectionView];
    NSIndexPath *indexPathNow = [self.collectionView indexPathForItemAtPoint:pointInView];
    
    [self bringMomentCoverCellToFrontWithIndexPath:indexPathNow];
    
    if (indexPathNow.row != self.currentIndexPath.row) {
        NSValue *valueTime = [self.thumbTimeArray objectAtIndex:indexPathNow.row kindOfClass:[NSValue class]];
        [self resetLargeCoverImageViewWithTime:[valueTime CMTimeValue]];
        
        self.currentIndexPath = indexPathNow;
    }
}

#pragma mark - MDNavigationBarAppearanceDelegate
- (UINavigationBar *)md_CustomNavigationBar
{
    return nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
