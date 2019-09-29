//
//  MDSpecialEffectsSelectView.m
//  BlockTest
//
//  Created by litianpeng on 2018/8/7.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import "MDSpecialEffectsSelectView.h"
#import "MDSpecialEffectsSelectViewCollectionViewCell.h"
#import "MDRecordSpecialEffectsManager.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "MDRecordHeader.h"

@interface MDSpecialEffectsSelectView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, assign) MDRecordSpecialType type;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation MDSpecialEffectsSelectView

- (id)initWithFrame:(CGRect)frame type:(MDRecordSpecialType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        [self configSubViews];
    }
    return self;
}
- (void)configSubViews{
    [self addSubview:self.collectionView];
    
    if (self.type == MDRecordSpecialTypeFilter) {
        self.dataSource = [MDRecordSpecialEffectsManager getSpecialEffectsFilterModelArray];
    }else {
        self.dataSource = [MDRecordSpecialEffectsManager getSpecialEffectsTimeModelArray];
    }
    
    [self.collectionView reloadData];
}

- (void)resetSelectEffect{
    if (self.type == MDRecordSpecialTypeFilter) {

    }else {
        self.dataSource = [MDRecordSpecialEffectsManager getSpecialEffectsTimeModelArray];
    }
    [self.collectionView reloadData];

}
#pragma mark -- UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MDSpecialEffectsSelectViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MDSpecialEffectsSelectViewCollectionViewCell" forIndexPath:indexPath];
    [cell updateCellWithModel:[self.dataSource objectAtIndex:indexPath.row defaultValue:nil]];
    @weakify(self);
    [cell setPreviewPress:self.specialEffectsLongBlock];
    [cell setPreviewTap:^(MDSpecialEffectsModel *model) {
        @strongify(self);
        if (self.specialEffectsTapBlock) {
            self.specialEffectsTapBlock(model);
        }
        if (self.type == MDRecordSpecialTypeTime) {
            for (MDSpecialEffectsModel *model in self.dataSource) {
                model.isSelect = NO;
            }
            model.isSelect = YES;
            [self.collectionView reloadData];
        }
    }];
    
    return cell;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 5;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(55, 112);
        layout.minimumLineSpacing = 20;
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 25, 0, 0);
        _collectionView.showsVerticalScrollIndicator = NO;

        [_collectionView registerClass:[MDSpecialEffectsSelectViewCollectionViewCell class] forCellWithReuseIdentifier:@"MDSpecialEffectsSelectViewCollectionViewCell"];
    }
    return _collectionView;
}

@end
