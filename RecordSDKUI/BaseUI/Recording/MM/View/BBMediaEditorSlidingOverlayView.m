//
//  BBMediaEditorSlidingOverlayView.m
//  BiBi
//
//  Created by YuAo on 12/10/15.
//  Copyright © 2015 sdk.com. All rights reserved.
//

#import "BBMediaEditorSlidingOverlayView.h"
#import "MDRecordFilterModel.h"
#import "MDRecordHeader.h"
@import RecordSDK;

NSInteger const BBMediaEditorPageClonesCount = 50;

@interface BBMediaEditorSlidingOverlayView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic,weak) UICollectionView *collectionView;

@property (nonatomic,copy) NSArray<MDRecordFilter *> *filters;

@property (nonatomic) NSInteger scrollStartIndex;

@property (nonatomic) BOOL didAppear;

@property (nonatomic, assign) NSInteger currentFilterIndex;

@property (nonatomic,assign) BBMediaEditorSlidingOverlayViewType        slidingOverlayViewType;
@property (nonatomic,assign) BBMediaEditorSlidingOverlayViewSceneType   slidingOverlayViewSceneType;


@end

@implementation BBMediaEditorSlidingOverlayView

- (instancetype)initWithSlidingOverlayViewType:(BBMediaEditorSlidingOverlayViewType)slidingOverlayViewType sceneType:(BBMediaEditorSlidingOverlayViewSceneType)sceneType frame:(CGRect)frame
{
    if (self = [self initWithFrame:frame]) {
        _slidingOverlayViewType = slidingOverlayViewType;
        _slidingOverlayViewSceneType = sceneType;
        [self setupMediaEditorSlidingOverlayView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupMediaEditorSlidingOverlayView];
    }
    return self;
}

- (void)dealloc
{
    _filters = nil;
    _collectionView.delegate = nil;
}

- (void)setupMediaEditorSlidingOverlayView {
    _scrollEnabled = YES;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = [self scrollDirection];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    if ([_collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        [_collectionView setPrefetchingEnabled:NO];
    }
    if ([_collectionView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            [_collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        } else {
            // Fallback on earlier versions
        }
    }
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.bounces = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.scrollEnabled = _scrollEnabled;
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
}

- (UICollectionViewScrollDirection)scrollDirection
{
    return self.slidingOverlayViewType == BBMediaEditorSlidingOverlayViewTypeHorizontal ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
}

- (void)didMoveToWindow {
    if (self.window) {
        if (!self.didAppear) {
            self.didAppear = YES;
            [self scrollViewDidScroll:self.collectionView];
        }
    }
}

- (void)setFilters:(NSArray<MDRecordFilter *> *)filters
{
    _filters = filters;
    [self.collectionView reloadData];
}

- (MDRecordFilter *)filterAtPageIndex:(NSInteger)pageIndex {
    return [self.filters objectAtIndex:(pageIndex%self.filters.count) defaultValue:nil];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return [self.delegate mediaEditorSlidingOverlayView:self shouldHandleTouchAtPoint:point withEvent:event defaultValue:[super pointInside:point withEvent:event]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count * BBMediaEditorPageClonesCount;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.filters.count <= 0) return;
    
    double filterOffset = [self filterOffsetWithContentOffset:scrollView.contentOffset];
    NSInteger filterAIndex = floor(filterOffset);
    NSInteger filterBIndex = ceil(filterOffset);
    id filterA = [self filterAtPageIndex:filterAIndex];
    id filterB = [self filterAtPageIndex:filterBIndex];
    double offset = ceil(filterOffset) - filterOffset;
    [self.delegate mediaEditorSlidingOverlayView:self filterOffsetDidChange:offset ? :1 filterA:filterA filterB:filterB];
}

- (double)filterOffsetWithContentOffset:(CGPoint)contentOffset
{
    double result = 0.f;
    
    result = (contentOffset.x/CGRectGetWidth(self.collectionView.frame));
    
    if (self.slidingOverlayViewType == BBMediaEditorSlidingOverlayViewTypeVertical) {
        result = (contentOffset.y/CGRectGetHeight(self.collectionView.frame));
    }
    
    return result;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.scrollStartIndex = self.currentPageIndex;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self.delegate mediaEditorSlidingOverlayViewDidEndDecelerating:self fromPageIndex:self.scrollStartIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.delegate mediaEditorSlidingOverlayViewDidEndDecelerating:self fromPageIndex:self.scrollStartIndex];
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    [self.collectionView performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        NSInteger pageIndex = (currentPageIndex % self.filters.count) + BBMediaEditorPageClonesCount/2 * self.filters.count;
        self.collectionView.contentOffset = [self contentOffsetWithPageIndex:pageIndex];
    }];
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex animated:(BOOL)animated
{
    [self.collectionView performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        NSInteger pageIndex = (currentPageIndex % self.filters.count) + BBMediaEditorPageClonesCount/2 * self.filters.count;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:pageIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }];
}

- (CGPoint)contentOffsetWithPageIndex:(NSInteger)pageIndex
{
    CGPoint result = CGPointMake(CGRectGetWidth(self.collectionView.bounds) * pageIndex, 0);
    
    if (self.slidingOverlayViewType == BBMediaEditorSlidingOverlayViewTypeVertical) {
        result = CGPointMake(0,CGRectGetHeight(self.collectionView.bounds) * pageIndex);
    }
    
    return result;
}

- (NSInteger)currentPageIndex {
    NSInteger pageIndex = floor(self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.bounds));
    
    if (self.slidingOverlayViewType == BBMediaEditorSlidingOverlayViewTypeVertical) {
        pageIndex = floor(self.collectionView.contentOffset.y / CGRectGetHeight(self.collectionView.bounds));
    }
    
    return pageIndex;
}

- (NSInteger)currentFilterIndex
{
    return self.currentPageIndex % self.filters.count;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    if (_scrollEnabled == scrollEnabled) {
        return;
    }
    
    _scrollEnabled = scrollEnabled;
    _collectionView.scrollEnabled = scrollEnabled;
}

-(void)scrollToNextPage
{
    NSArray *visibleItems = [self.collectionView indexPathsForVisibleItems];
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    //越界保护
    NSInteger itemRow = currentItem.item < self.filters.count * BBMediaEditorPageClonesCount - 1 ? currentItem.item +1 : 0;
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:itemRow inSection:currentItem.section];
    [self.collectionView scrollToItemAtIndexPath:nextItem atScrollPosition:[self scrollPosition] animated:YES];
}

- (UICollectionViewScrollPosition)scrollPosition
{
    return self.slidingOverlayViewType == BBMediaEditorSlidingOverlayViewTypeHorizontal ?  UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
}


@end
