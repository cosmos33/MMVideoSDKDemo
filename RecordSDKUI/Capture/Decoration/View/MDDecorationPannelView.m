//
//  MDDecorationPannelView.m
//  MomoChat
//
//  Created by YZK on 2019/4/12.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "MDDecorationPannelView.h"
#import "MDFilterSegmentView.h"
#import "MDDecorationCategoryView.h"
#import "MDDecorationCollectionView.h"
#import "MDFaceDecorationDataHandle.h"
#import "MDFilterRecordView.h"
#import "UIView+Utils.h"

@interface MDDecorationPannelView ()
@property (nonatomic, strong) MDDecorationCategoryView *categoryView;
@property (nonatomic, strong) MDDecorationCollectionView *collectionView;
@property (nonatomic, strong) MDFilterRecordView *recordView;
@end

@implementation MDDecorationPannelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupVisualEffectView];
        [self setupTitleView];
        [self setupCategoryView];
        [self setupCollectionView];
        
        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        maskLayer.colors = @[(__bridge id)RGBACOLOR(0, 0, 0, 0).CGColor, (__bridge id)RGBACOLOR(0, 0, 0, 1).CGColor];
        maskLayer.startPoint = CGPointMake(0, 0);
        maskLayer.endPoint = CGPointMake(0, 1);
        maskLayer.frame = CGRectMake(0, self.height-109, self.width, 129);
        [self.layer addSublayer:maskLayer];
        
        MDFilterRecordView *recordView = [[MDFilterRecordView alloc] initWithFrame:CGRectMake(0, self.height-68, 40, 40)];
        recordView.centerX = self.center.x;
        [self addSubview:recordView];
        self.recordView = recordView;
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordViewDidTap)];
        [recordView addGestureRecognizer:tgr];
        
        //dataHandle刷新通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionData:) name:MDFaceDecorationDrawerUpdateNotiName object:nil];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public

- (void)setDataHandle:(MDFaceDecorationDataHandle *)dataHandle {
    _dataHandle = dataHandle;
    
}

- (void)setRecordLevelType:(MDUnifiedRecordLevelType)levelType {
    [self.recordView setRecordLevelType:levelType];
}

- (void)setSelectedClassWithIdentifier:(NSString *)identifer {
    [self.categoryView setCurrentCategoryWithIdentifer:identifer animated:NO];
}
- (void)setSelectedClassWithIndex:(NSInteger)index {
    [self.categoryView setCurrentCategoryWithIndex:index animated:NO];
}

- (BOOL)showAnimate
{
    if (self.isShowed || self.isAnimating) return NO;
    
    self.hidden = NO;
    self.show = YES;
    self.animating = YES;
    [self.recordView beginAniamtion];
    
    //变脸分类数据源
    NSArray *classArray = [self.dataHandle getDrawerClassDataArray];
    [self.categoryView setCategoryArray:classArray];
    //变脸item数据源
    NSArray *itemsArray = [self.dataHandle getDrawerDataArray];
    [self.collectionView configDrawerDataArray:itemsArray needLayout:YES];
    [self.collectionView reloadData];

    self.transform = CGAffineTransformMakeTranslation(0, self.height);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.animating = NO;
    }];
    
    return YES;
}

- (void)hideAnimateWithCompleteBlock:(void(^)())completeBlock
{
    if (!self.isShowed || self.isAnimating) return;
    
    self.hidden = NO;
    self.show = NO;
    self.animating = YES;
    [self.recordView endAnimation];

    self.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, self.height);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.animating = NO;
        if (completeBlock) completeBlock();
    }];
}


#pragma mark - notification event
- (void)reloadCollectionData:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    BOOL change = NO;
    if (userInfo) {
        change = [userInfo boolForKey:@"change" defaultValue:NO];
    }
    
    if (change) { //说明此时“我的”分类下数据源有变化，需要重新获取数据源刷新
        NSArray *itemsArray = [self.dataHandle getDrawerDataArray];
        [self.collectionView configDrawerDataArray:itemsArray needLayout:NO];
    }
    [self.collectionView reloadData];
}

#pragma mark - event

- (void)didSelectedClassWithItem:(MDFaceDecorationClassItem *)item section:(NSInteger)section animated:(BOOL)animated
{
    [self.collectionView scrollToSection:section animated:animated];
}

- (void)didScrollEndToSection:(NSInteger)section
{
    [self.categoryView setCurrentCategoryWithIndex:section animated:YES];
}

- (void)didTapDecorationWithIndex:(NSInteger)index section:(NSInteger)section item:(MDFaceDecorationItem *)item
{
    if (![item.identifier isNotEmpty] || item.isDownloading) {
        return;
    }
    //调用dataHandle处理item
    if (!item.isOverlap) {
        [self.dataHandle drawerDidSelectedItem:item];
    } else {
        [self.dataHandle drawerDidSelectedGift:item];
    }
}

- (void)cleanDecorationButtonTap
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认恢复默认效果吗？" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self.dataHandle drawerDidCleanAllItem];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    
    UIViewController *presentedVC = [UIUtility getUsablePresentedViewController:self.vc];
    [presentedVC presentViewController:alertController animated:YES completion:nil];
}

- (void)recordViewDidTap
{
    self.recordHandler ? self.recordHandler() : nil;
}

#pragma mark - UI

- (void)setupVisualEffectView
{
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    visualEffectView.frame = self.bounds;
    visualEffectView.height += 30;
    visualEffectView.backgroundColor = [UIColor clearColor];
    visualEffectView.layer.cornerRadius = 10.0f;
    visualEffectView.layer.masksToBounds = YES;
    [self addSubview:visualEffectView];
}

- (void)setupTitleView
{
    __weak typeof(self) weakSelf = self;
    MDFilterSegmentView *segmentView = [[MDFilterSegmentView alloc] initWithOrigin:CGPointMake(0, 0) title:@[@"道具"]];
    segmentView.resetButtonClicked = ^(NSInteger index) {
        [weakSelf cleanDecorationButtonTap];
    };
    [self addSubview:segmentView];
}

- (void)setupCategoryView
{
    __weak typeof(self) weakSelf = self;
    MDDecorationCategoryView *categoryView = [[MDDecorationCategoryView alloc] initWithFrame:CGRectMake(20, 70, MDScreenWidth-20*2, 25)];
    categoryView.selecteBlock = ^(MDFaceDecorationClassItem * _Nonnull model, NSInteger index, BOOL animated) {
        [weakSelf didSelectedClassWithItem:model section:index animated:animated];
    };
    [self addSubview:categoryView];
    self.categoryView = categoryView;
}

- (void)setupCollectionView
{
    __weak typeof(self) weakSelf = self;
    MDDecorationCollectionView *collectionView = [[MDDecorationCollectionView alloc] initWithFrame:CGRectMake(0, 106, MDScreenWidth, self.height-106)];
    collectionView.scrollEndHandler = ^(NSInteger index) {
        [weakSelf didScrollEndToSection:index];
    };
    collectionView.selectedHandler = ^(NSInteger section, NSInteger index, MDFaceDecorationItem * _Nonnull item) {
        [weakSelf didTapDecorationWithIndex:index section:section item:item];
    };
    [self addSubview:collectionView];
    self.collectionView = collectionView;
}

@end
