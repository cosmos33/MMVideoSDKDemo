//
//  MDCollectionHelper.m
//  MDChat
//
//  Created by 杜林 on 15/7/20.
//  Copyright (c) 2015年 sdk.com. All rights reserved.
//

#import "MDCollectionHelper.h"

#define kIdentfierHeader                    @"header"
#define kIdentfierFooter                    @"footer"

@interface MDCollectionHelper ()

@property (nonatomic, strong) UICollectionView                          *collectionView;
@property (nonatomic, strong) NSArray                                   *datas;
@property (nonatomic, weak) id<MDCollectionHelperDelegate>              delegate;
@property (nonatomic, assign) BOOL                                      reloadDataComplete;

@end

@implementation MDCollectionHelper

+ (MDCollectionHelper *)bindingForCollectionView:(UICollectionView *)collectionView sourceList:(NSMutableArray *)datas templateClassNameList:(NSArray *)classNameList delegate:(id<MDCollectionHelperDelegate>)adelegate
{
    return [[self alloc] initWithCollectionView:collectionView sourceList:datas templateClassNameList:classNameList delegate:adelegate];
}

+ (MDCollectionHelper *)bindingForCollectionView:(UICollectionView *)collectionView sourceList:(NSMutableArray *)datas templateClassNameList:(NSArray *)classNameList delegate:(id<MDCollectionHelperDelegate>)adelegate sourceSignal:(RACSignal *)sourceSignal
{
    return [[self alloc] initWithCollectionView:collectionView sourceList:datas templateClassNameList:classNameList delegate:adelegate sourceSignal:sourceSignal];
}

#pragma mark - init

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView sourceList:(NSMutableArray *)datas delegate:(id<MDCollectionHelperDelegate>)adelegate
{
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
        self.datas = datas;
        self.delegate = adelegate;
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}


- (instancetype)initWithCollectionView:(UICollectionView *)collectionView sourceList:(NSMutableArray *)datas templateClassNameList:(NSArray *)classNameList delegate:(id<MDCollectionHelperDelegate>)adelegate
{
    self = [self initWithCollectionView:collectionView sourceList:datas delegate:adelegate];
    if (self) {
        [classNameList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.collectionView registerClass:NSClassFromString((NSString *)obj) forCellWithReuseIdentifier:(NSString *)obj];
        }];
    }
    return self;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView sourceList:(NSMutableArray *)datas templateClassNameList:(NSArray *)classNameList delegate:(id<MDCollectionHelperDelegate>)adelegate sourceSignal:(RACSignal *)sourceSignal
{
    self = [self initWithCollectionView:collectionView sourceList:datas templateClassNameList:classNameList delegate:adelegate];
    if (self) {
        @weakify(self);
        [[sourceSignal deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self);
            self.datas = x;
            [self.collectionView reloadData];
            self.reloadDataComplete = YES;
        }];
    }
    return self;
}

#pragma mark - 
/*
 *
 * 该helper只支持1个section的collectionview,所以header和footer的标示可以直接写死
 *
 */
- (void)registerSectionHeader:(NSString *)viewClassString
{
    [self.collectionView registerClass:NSClassFromString((NSString *)viewClassString)
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kIdentfierHeader];
}

- (void)registerSectionFooter:(NSString *)viewClassString
{
    [self.collectionView registerClass:NSClassFromString((NSString *)viewClassString)
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kIdentfierFooter];
}

#pragma mark -

- (void)updateDataSource:(NSArray *(^)(NSArray *data))dataSourceBlock {
    if (!dataSourceBlock) return;
    
    NSArray *dataArray = dataSourceBlock(self.datas);
    self.datas = dataArray;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell<MDCollectionHelperCellDelegate> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self.delegate cellReuseIdentifer:indexPath.row] forIndexPath:indexPath];

    
    if([cell respondsToSelector:@selector(bindModel:)] && self.datas.count > indexPath.item)
    {
        id modle = [self.datas objectAtIndex:indexPath.item];
        [cell bindModel:modle];
    }
    
    if ([cell respondsToSelector:@selector(bindDelegate:)]) {
        [cell bindDelegate:self.delegate];
    }
    
    if ([self.delegate respondsToSelector:@selector(cell:atIndexPath:)]) {
        [self.delegate cell:cell atIndexPath:indexPath];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectItemAtIndexPath:)]) {
        [self.delegate didSelectItemAtIndexPath:indexPath];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if([kind isEqual:UICollectionElementKindSectionHeader])
    {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kIdentfierHeader forIndexPath:indexPath];
        return headerView;
    }
    else if([kind isEqual:UICollectionElementKindSectionFooter])
    {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kIdentfierFooter forIndexPath:indexPath];
        return footerView;

    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(willDisplayCell:forItemAtIndexPath:)]) {
        [self.delegate willDisplayCell:cell forItemAtIndexPath:indexPath.row];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEndDisplayingCell:forItemAtIndexPath:)]) {
        [self.delegate didEndDisplayingCell:cell forItemAtIndexPath:indexPath.row];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewDidScroll:)]) {
        [self.delegate collectionViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(self.delegate && [self.delegate respondsToSelector:@selector(collectionViewsWillBeginDragging:)]) {
        [self.delegate collectionViewsWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(self.delegate && [self.delegate respondsToSelector:@selector(collectionViewsDidEndDecelerating:)]) {
        [self.delegate collectionViewsDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollDidEndScrollingAnimation:)]) {
        [self.delegate scrollDidEndScrollingAnimation:scrollView];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(collectionViewDidScrollToTop:)]) {
        [self.delegate collectionViewDidScrollToTop:scrollView];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(collectionViewShouldScrollToTop:)]) {
        return [self.delegate collectionViewShouldScrollToTop:scrollView];
    }
    
    return YES;
}


@end
