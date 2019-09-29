//
//  MDDecorationCategoryView.m
//  MomoChat
//
//  Created by YZK on 2019/4/12.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "MDDecorationCategoryView.h"
#import "MDDecorationCategoryCell.h"
#import "UIView+Utils.h"

@interface MDDecorationCategoryView ()
<UICollectionViewDelegate,
UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *categoryView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation MDDecorationCategoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentIndex = -1;
        [self setupCategoryView];
    }
    return self;
}

- (void)setupCategoryView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 6;//11
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.categoryView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, 25) collectionViewLayout:layout];
    self.categoryView.showsVerticalScrollIndicator = NO;
    self.categoryView.showsHorizontalScrollIndicator = NO;
    
    if ([self.categoryView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        if (@available(iOS 10.0, *)) {
            self.categoryView.prefetchingEnabled = NO;
        } else {
            // Fallback on earlier versions
        }
    }
    self.categoryView.backgroundColor = [UIColor clearColor];
    self.categoryView.delegate = self;
    self.categoryView.dataSource = self;
    [self addSubview:self.categoryView];
    
    [self.categoryView registerClass:[MDDecorationCategoryCell class] forCellWithReuseIdentifier:@"MDDecorationCategoryCell"];
}

- (void)setCategoryArray:(NSArray<MDFaceDecorationClassItem*> *)array
{
    NSMutableArray *mArray = [NSMutableArray array];
    for (MDFaceDecorationClassItem *classItem in array) {
        MDDecorationCategoryItem *item = [[MDDecorationCategoryItem alloc] init];
        item.classItem = classItem;
        item.selected = NO;
        CGFloat width = [classItem.name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 25) options:0 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.width;
        item.itemSize = CGSizeMake(ceil(width)+22, 25);
        [mArray addObject:item];
    }
    self.dataSource = mArray;
}

- (void)setCurrentCategoryWithIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index>=0 && index<self.dataSource.count) {
        MDDecorationCategoryItem *oldItem = self.currentIndex >= 0 && self.currentIndex < self.dataSource.count ? self.dataSource[self.currentIndex] : nil;// [self.dataSource objectAtIndex:self.currentIndex defaultValue:nil];
        oldItem.selected = NO;
        MDDecorationCategoryItem *item = self.dataSource[index]; // [self.dataSource objectAtIndex:index defaultValue:nil];
        item.selected = YES;
        self.currentIndex = index;
        [self.categoryView reloadData];
        [self.categoryView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:animated];
        self.selecteBlock ? self.selecteBlock(item.classItem, index, animated) : nil;
    }
}

- (void)setCurrentCategoryWithIdentifer:(NSString *)identifer animated:(BOOL)animated
{
    for (int i=0; i<self.dataSource.count; i++) {
        MDDecorationCategoryItem *item = self.dataSource[i]; // [self.dataSource objectAtIndex:i defaultValue:nil];
        if ([item.classItem.identifier isEqualToString:identifer]) {
            [self setCurrentCategoryWithIndex:i animated:animated];
            return;
        }
    }
}


#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MDDecorationCategoryItem *item = self.dataSource[indexPath.item]; // [self.dataSource objectAtIndex:indexPath.item defaultValue:nil];
    return item.itemSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource ? self.dataSource.count : 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MDDecorationCategoryItem *item = self.dataSource[indexPath.item]; // [self.dataSource objectAtIndex:indexPath.item defaultValue:nil];
    MDDecorationCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MDDecorationCategoryCell" forIndexPath:indexPath];
    [cell bindModel:item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.currentIndex) {
        return;
    }
    [self setCurrentCategoryWithIndex:indexPath.item animated:YES];
}


@end
