//
//  MDCollectionHelper.h
//  MDChat
//
//  Created by 杜林 on 15/7/20.
//  Copyright (c) 2015年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


@protocol MDCollectionHelperCellDelegate <NSObject>

- (void)bindModel:(id)model;
@optional
- (void)bindDelegate:(id)target;
@end


@protocol MDCollectionHelperDelegate <NSObject>

- (NSString *)cellReuseIdentifer:(NSInteger)index;

@optional
- (void)cell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)headerReuseIdentifer:(NSInteger)index;
- (UICollectionReusableView *)sectionHeaderAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)footerReuseIdentifer:(NSInteger)index;
- (UICollectionReusableView *)sectionFooterAtIndexPath:(NSIndexPath *)indexPath;

- (void)willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSInteger)index;
- (void)didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSInteger)index;

- (void)collectionViewDidScroll:(UIScrollView *)scrollView;
- (void)collectionViewsWillBeginDragging:(UIScrollView *)scrollView;
- (void)collectionViewsDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollDidEndScrollingAnimation:(UIScrollView *)scrollView;
- (void)collectionViewDidScrollToTop:(UIScrollView *)scrollView;
- (BOOL)collectionViewShouldScrollToTop:(UIScrollView *)scrollView;
@end


@interface MDCollectionHelper : NSObject
<UICollectionViewDelegate,
UICollectionViewDataSource>

@property (nonatomic, assign, readonly) BOOL reloadDataComplete;

+ (MDCollectionHelper *)bindingForCollectionView:(UICollectionView *)collectionView sourceList:(NSMutableArray *)datas templateClassNameList:(NSArray<NSString *> *)classNameList delegate:(id<MDCollectionHelperDelegate>)adelegate;

+ (MDCollectionHelper *)bindingForCollectionView:(UICollectionView *)collectionView sourceList:(NSMutableArray *)datas templateClassNameList:(NSArray<NSString *> *)classNameList delegate:(id<MDCollectionHelperDelegate>)adelegate sourceSignal:(RACSignal *)sourceSignal;

- (void)registerSectionHeader:(NSString *)viewClassString;
- (void)registerSectionFooter:(NSString *)viewClassString;

/// 外界更新内部数据源，不会触发reloadData
- (void)updateDataSource:(NSArray *(^)(NSArray *data))dataSourceBlock;

@end
