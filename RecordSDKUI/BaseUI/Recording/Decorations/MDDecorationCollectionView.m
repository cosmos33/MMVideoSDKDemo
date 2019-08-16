//
//  MDDecorationCollectionView.m
//  MomoChat
//
//  Created by YZK on 2019/4/12.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "MDDecorationCollectionView.h"
#import "MDDecorationCollectionCell.h"
#import "UIView+Utils.h"

@interface MDDecorationCollectionView ()
<UICollectionViewDelegate,
UICollectionViewDataSource>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *collectionArray;
@property (nonatomic, strong) NSArray<NSArray<MDFaceDecorationItem*> *> *drawerDataArray;
@end

@implementation MDDecorationCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.bounces = NO;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.delegate = self;
        if (@available(iOS 11.0, *)) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:scrollView];
        self.scrollView = scrollView;
    }
    return self;
}

#pragma mark - public

- (void)configDrawerDataArray:(NSArray<NSArray<MDFaceDecorationItem*> *> *)drawerDataArray needLayout:(BOOL)needLayout
{
    self.drawerDataArray = drawerDataArray;
    if (needLayout) {
        [self layoutContentViewWithArray:drawerDataArray];
    }
}

- (void)scrollToSection:(NSInteger)section animated:(BOOL)animated
{
    [self.scrollView setContentOffset:CGPointMake(self.width*section, 0) animated:animated];
}

- (void)reloadData
{
    for (UICollectionView *view in self.collectionArray) {
        [view reloadData];
    }
}


#pragma mark - event

- (void)cellDidTapWithIndex:(NSInteger)index section:(NSInteger)section
{
    NSArray *array = self.drawerDataArray[section]; // [self.drawerDataArray objectAtIndex:section defaultValue:nil];
    MDFaceDecorationItem *item = array[index]; // [array objectAtIndex:index defaultValue:nil];
    if (self.selectedHandler) self.selectedHandler(section, index, item);
}

- (void)didScrollToSection:(NSInteger)section
{
    if (self.scrollEndHandler) self.scrollEndHandler(section);
}


#pragma mark - UI

- (void)layoutContentViewWithArray:(NSArray<NSArray<MDFaceDecorationItem*> *> *)drawerDataArray
{
    [self.scrollView removeAllSubviews];
    self.scrollView.contentSize = CGSizeMake(self.width*drawerDataArray.count, self.height);
    
    NSMutableArray *mArray = [NSMutableArray array];
    for (int i=0; i<self.drawerDataArray.count; i++) {
        UICollectionView *collectionView = [self createCollectionViewWithIndex:i];
        [mArray addObject:collectionView];
    }
    self.collectionArray = mArray;
}

- (UICollectionView *)createCollectionViewWithIndex:(NSInteger)index
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(45, 45);
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 27;
    layout.sectionInset = UIEdgeInsetsMake(10, 20, 90, 20);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectOffset(self.bounds, self.width*index, 0) collectionViewLayout:layout];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    if ([collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        collectionView.prefetchingEnabled = NO;
    }
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.tag = index;
    [self.scrollView addSubview:collectionView];
    
    [collectionView registerClass:[MDDecorationCollectionCell class] forCellWithReuseIdentifier:@"MDDecorationCollectionCell"];
    return collectionView;
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = self.drawerDataArray[collectionView.tag]; // [self.drawerDataArray objectAtIndex:collectionView.tag defaultValue:nil];
    return array ? array.count : 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = self.drawerDataArray[collectionView.tag]; // [self.drawerDataArray objectAtIndex:collectionView.tag defaultValue:nil];
    MDFaceDecorationItem *item = array[indexPath.item]; // [array objectAtIndex:indexPath.item defaultValue:nil];
    MDDecorationCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MDDecorationCollectionCell" forIndexPath:indexPath];
    [cell bindModel:item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self cellDidTapWithIndex:indexPath.item section:collectionView.tag];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        CGFloat index = self.scrollView.contentOffset.x / self.scrollView.width;
        [self didScrollToSection:round(index)];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.scrollView && !decelerate) {
        CGFloat index = self.scrollView.contentOffset.x / self.scrollView.width;
        [self didScrollToSection:round(index)];
    }
}

@end
