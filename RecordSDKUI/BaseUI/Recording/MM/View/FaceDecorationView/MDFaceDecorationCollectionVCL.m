//
//  MDFaceDecorationCollectionVCL.m
//  MDChat
//
//  Created by YZK on 2017/7/26.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDFaceDecorationCollectionVCL.h"
#import "MDFaceDecorationCollectionLayout.h"
#import "MDFaceDecorationScrollCell.h"
#import "MDFaceDecorationDataHandle.h"

@interface MDFaceDecorationCollectionVCL ()
<UICollectionViewDelegate,
UICollectionViewDataSource>

@property (nonatomic, assign) MDUnifiedRecordLevelType levelType;
@property (nonatomic, strong) NSArray *dataArray;

@end


@implementation MDFaceDecorationCollectionVCL

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionDataAndScroll:) name:MDFaceDecorationRecommendUpdateNotiName object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 切换type

- (void)setOffsetPercentage:(CGFloat)percentage withTargetLevelType:(MDUnifiedRecordLevelType)levelType {
    if (self.levelType == levelType) {
        return;
    }
    
    percentage = MIN(1.0, MAX(0.0, percentage));
    self.view.hidden = NO;

    if (levelType == MDUnifiedRecordLevelTypeNormal) {
        CGFloat alpha = 0;
        if (percentage > 0.9) {
            alpha = (percentage-0.9)/0.1;
        }
        self.view.alpha = alpha;
    }else if (levelType == MDUnifiedRecordLevelTypeHigh) {
        CGFloat alpha = 0;
        if (percentage < 0.1) {
            alpha = 1 - percentage/0.1;
        }
        self.view.alpha = alpha;
    }
}
- (void)setCurrentLevelType:(MDUnifiedRecordLevelType)levelType
{
    self.levelType = levelType;
    
    if (self.levelType == MDUnifiedRecordLevelTypeNormal) {
        self.view.hidden = NO;
        [UIView animateWithDuration:0.1 animations:^{
            self.view.alpha = 1;
        }];
        
    } else if (self.levelType == MDUnifiedRecordLevelTypeHigh) {
        [UIView animateWithDuration:0.1 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            self.view.hidden = YES;
        }];
    }
}

- (void)setActive:(BOOL)active {
    _active = active;
    if (self.active) {
        [UIView animateWithDuration:0.1 animations:^{
            self.view.alpha = 0;
        }];
    }else {
        [UIView animateWithDuration:0.1 animations:^{
            self.view.alpha = 1;
        }];
    }
}


#pragma mark - notification event

- (void)reloadCollectionDataAndScroll:(NSNotification *)noti {
    self.dataArray = self.dataHandle.recommendDataArray;
    [self.view reloadData];
    
    NSDictionary *userInfo = noti.userInfo;
    if (userInfo) {
        NSInteger selectIndex = [userInfo integerForKey:@"selectIndex" defaultValue:NSNotFound];
        BOOL needSelected = [userInfo boolForKey:@"needSelected" defaultValue:NO];
        if (selectIndex>=0 && selectIndex<self.dataArray.count) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectIndex inSection:0];
            //滚动indexPath到中央
            [self scrollItemToCenterWithIndexPath:indexPath];
            //记录当前选中的变脸item
            MDFaceDecorationItem *item = [self itemOfRow:indexPath];
            [self setCurrentSelectItem:item];
            
            if (needSelected) {
                [self selectItemAtIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MDFaceDecorationScrollCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MDFaceDecorationScrollCell identifier] forIndexPath:indexPath];
    
    [cell updateWithModel:[self itemOfRow:indexPath]];
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectItemAtIndexPath:indexPath];
    //滚动到中间
    self.view.panGestureRecognizer.enabled = NO;
    [self scrollItemToCenterWithIndexPath:indexPath];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.view.panGestureRecognizer.enabled = YES;
    if (scrollView == self.view) {
        [self selectCenterItem];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.view.panGestureRecognizer.enabled = YES;
    if (scrollView == self.view && !decelerate) {
        [self selectCenterItem];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.view.panGestureRecognizer.enabled = YES;
}

- (void)selectCenterItem {
    CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    NSIndexPath *indexPath = [self.view indexPathForItemAtPoint:center];
    if (indexPath) {
        [self selectItemAtIndexPath:indexPath];
    }
}


#pragma mark - private method

- (void)setCurrentSelectItem:(MDFaceDecorationItem *)item {
    //记录当前选中的变脸item，
    self.dataHandle.currentSelectItem = item;
}
- (MDFaceDecorationItem *)currentSelectItem {
    return self.dataHandle.currentSelectItem;
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath {
    MDFaceDecorationItem *item = [self itemOfRow:indexPath];
    
    //记录当前选中的变脸item，
    [self setCurrentSelectItem:item];
    
    //调用dataHandle处理item
    [self.dataHandle recommendDidSelectedItem:item];
}

- (MDFaceDecorationItem*)itemOfRow:(NSIndexPath *)indexPath{
    MDFaceDecorationItem* item = [self.dataArray objectAtIndex:indexPath.item kindOfClass:[MDFaceDecorationItem class]];
    return item;
}

//滚动对应index的cell到中间
- (void)scrollItemToCenterWithIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = [self.view layoutAttributesForItemAtIndexPath:indexPath];
    CGFloat x = attribute.center.x - self.view.width/2;
    [self.view setContentOffset:CGPointMake(x, 0) animated:YES];
}

#pragma mark - lazy
- (UICollectionView *)view {
    if (!_view) {
        MDFaceDecorationCollectionLayout *layout = [[MDFaceDecorationCollectionLayout alloc] init];
        layout.itemSize = CGSizeMake(44, 44);
        layout.sectionInset = UIEdgeInsetsMake(0, (MDScreenWidth - 44) / 2.0,
                                               0, (MDScreenWidth - 44) / 2.0);
        
        _view = [[UICollectionView alloc] initWithFrame:CGRectZero
                                   collectionViewLayout:layout];
        _view.backgroundColor = [UIColor clearColor];
        _view.delegate = self;
        _view.dataSource = self;
        _view.showsHorizontalScrollIndicator = NO;
        _view.showsVerticalScrollIndicator = NO;
        if ([_view respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            [_view setPrefetchingEnabled:NO];
        }
        
        [_view registerClass:[MDFaceDecorationScrollCell class] forCellWithReuseIdentifier:[MDFaceDecorationScrollCell identifier]];
    }
    return _view;
}

- (void)setDataHandle:(MDFaceDecorationDataHandle *)dataHandle {
    _dataHandle = dataHandle;
    self.dataArray = dataHandle.recommendDataArray;
    [self reloadCollectionDataAndScroll:nil];
}


@end
