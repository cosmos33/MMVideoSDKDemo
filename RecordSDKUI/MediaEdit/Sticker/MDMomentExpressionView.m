//
//  MDMomentExpressionView.m
//  MDChat
//
//  Created by Leery on 16/7/25.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDMomentExpressionView.h"
#import "MDMomentExpressionCell.h"
#import "MDCollectionHelper.h"
#import "MDDownLoadManager.h"
#import "MDEffectImageView.h"
#import <Masonry/Masonry.h>
#import <MMFoundation/MMFoundation.h>
#import "UIView+Utils.h"
#import "MDRecordMacro.h"

#define MDScreenWidth     CGRectGetWidth([[UIScreen mainScreen] bounds])
#define MDScreenHeight    CGRectGetHeight([[[UIApplication sharedApplication].delegate window] bounds])

#if !__has_feature(objc_arc)
#error MDMomentExpressionView must be built with ARC.
#endif

#define kMomentExpressionCell   @"MDMomentExpressionCell"
#define kCellMargin             12
#define kCellSpace              17

@interface MDMomentExpressionView ()<MDCollectionHelperDelegate>
@property (nonatomic ,strong) UIVisualEffectView                *backGroundView;//背景图片
@property (nonatomic ,strong) UIView                            *topContentView;
@property (nonatomic ,strong) UIButton                          *closeButton;
@property (nonatomic ,strong) UIView                            *bottomContentView;
@property (nonatomic ,strong) UICollectionView                  *collectionView;
@property (nonatomic ,strong) MDCollectionHelper                *collectionHelper;
@property (nonatomic ,strong) NSMutableArray                    *picDateArray;
@property (nonatomic ,weak) id<MDMomentExpressionViewDelegate>  delegate;
@end

@implementation MDMomentExpressionView

#pragma mark - init
- (instancetype)initWithDelegate:(id<MDMomentExpressionViewDelegate>)aDelegate{
    if(self = [super init]){
        self.frame = CGRectMake(0, 0, MDScreenWidth, MDScreenHeight);
        self.delegate = aDelegate;
        [self setupAllContents];
    }
    return self;
}

#pragma mark - setupUI
- (void)setupAllContents {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backGroundView];
    [self.topContentView addSubview:self.closeButton];
    [self.backGroundView.contentView addSubview:self.bottomContentView];
    [self.bottomContentView addSubview:self.collectionView];
    [self.backGroundView.contentView addSubview:self.topContentView];

    self.collectionHelper = [MDCollectionHelper bindingForCollectionView:self.collectionView sourceList:self.picDateArray templateClassNameList:[self classNameCellArray] delegate:self sourceSignal:RACObserve(self, self.picDateArray)];
    
    [self updateAllFrames];
}

#pragma mark - updateFrames
- (void)updateAllFrames {
    self.topContentView.frame = CGRectMake(0, 0, MDScreenWidth, 80);
    
    __weak __typeof(self) weakSelf = self;
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *maker) {
        maker.left.mas_equalTo(weakSelf.topContentView.left).offset(12);
        maker.width.height.mas_equalTo(@30);
        maker.top.mas_equalTo(@(15 + HOME_INDICATOR_HEIGHT));
    }];
    
    self.bottomContentView.frame = CGRectMake(kCellMargin, self.topContentView.bottom, MDScreenWidth-2*kCellMargin, MDScreenHeight - self.topContentView.height);
    self.collectionView.frame = CGRectMake(0, 0, self.bottomContentView.width, self.bottomContentView.height);
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, kCellMargin, 0)];
}

#pragma mark - 接口
- (void)setBackGroundViewWithImage:(UIImage *)image {
//    if(image) {
//        [self.backGroundView setImage:image];
//        self.backGroundView.backgroundColor = [UIColor clearColor];
//    }else {
//        self.backGroundView.image = nil;
//        self.backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
//    }
}

- (void)setPicDatesArrayWithArray:(NSMutableArray *)array{
    self.picDateArray = array;
    [self.collectionView reloadData];
}

- (void)refreshView {
    [self.collectionView reloadData];
}

#pragma mark - collectView delegate
     
- (NSArray *)classNameCellArray {
    return @[kMomentExpressionCell];
}

- (NSString *)collectionCellIdentifier:(MDMomentExpressionCellModel *)item
{
    NSString *identifer = @"";
    if (item) {
        identifer = kMomentExpressionCell;
    }
    return identifer;
}

- (NSString *)cellReuseIdentifer:(NSInteger)index
{
    NSString *identifer = @"";
    if ([self.picDateArray count] && index < [self.picDateArray count]) {
        MDMomentExpressionCellModel *model = [self.picDateArray objectAtIndex:index defaultValue:nil];
        identifer = [self collectionCellIdentifier:model];
    }
    return identifer;
}

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(self.picDateArray.count && indexPath.row < self.picDateArray.count){
        if(self.delegate && [self.delegate respondsToSelector:@selector(collectionViewDidSelectDateArrayAtIndexUrlDictionary:)]){
            
            MDMomentExpressionCell *cell = (MDMomentExpressionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            CGPoint center = [cell convertPoint:[cell cellContentView].center toView:self];
            
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
            [dictionary setObjectSafe:[NSValue valueWithCGPoint:center] forKey:@"center"];
            MDMomentExpressionCellModel *model = [self.picDateArray objectAtIndex:indexPath.row defaultValue:nil];
            [dictionary setObjectSafe:model forKey:@"data"];
            
            [self.delegate collectionViewDidSelectDateArrayAtIndexUrlDictionary:dictionary];
        }
    }
    
}

#pragma mark - action事件
- (void)closeAction {
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeEventAction)]){
        [self.delegate closeEventAction];
    }
}

#pragma mark - 懒加载UI
- (UIVisualEffectView *)backGroundView {
    if(!_backGroundView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _backGroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _backGroundView.frame = self.bounds;
        _backGroundView.userInteractionEnabled = YES;
    }
    return _backGroundView;
}

- (UIView *)topContentView {
    if(!_topContentView) {
        _topContentView = [[UIView alloc] init];
        _topContentView.backgroundColor = [UIColor clearColor];
    }
    return _topContentView;
}

- (UIView *)bottomContentView {
    if(!_bottomContentView) {
        _bottomContentView = [[UIView alloc] init];
        _bottomContentView.backgroundColor = [UIColor clearColor];
    }
    return _bottomContentView;
}

- (UIButton *)closeButton {
    if(!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = [UIColor clearColor];
        [_closeButton setImage:[UIImage imageNamed:@"btn_moment_record_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UICollectionView *)collectionView {
    if(!_collectionView) {
        
        CGFloat cellHeight = floorf((MDScreenWidth - 2*kCellMargin - 3*kCellSpace)/4);
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(cellHeight, cellHeight);
        flowLayout.minimumInteritemSpacing = kCellSpace;
        flowLayout.minimumLineSpacing = 20;
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        if ([_collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            [_collectionView setPrefetchingEnabled:NO];
        }
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];

    }
    return _collectionView;
}

@end





