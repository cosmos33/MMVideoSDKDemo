//
//  MDRecordFilterListView.m
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/4.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDRecordFilterListView.h"
#import "MDRecordFilterCell.h"
#import "MDRecordFilterModel.h"
#import "UIConst.h"
#import <MMFoundation/MMFoundation.h>

@interface MDRecordFilterListView()<UICollectionViewDelegate,UICollectionViewDataSource>

@end
@implementation MDRecordFilterListView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    UICollectionViewFlowLayout* flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 20;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    flowLayout.itemSize = CGSizeMake(60, 100);
    
    if(self = [super initWithFrame:frame collectionViewLayout:flowLayout]){
        [self registerClass:[MDRecordFilterCell class] forCellWithReuseIdentifier:NSStringFromClass([MDRecordFilterCell class])];
        self.delegate   = self;
        self.dataSource = self;
        self.bounces = NO;
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.05);
        if([self respondsToSelector:@selector(setPrefetchingEnabled:)]){
            self.prefetchingEnabled = NO;
        }

    }
    return self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MDRecordFilterCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MDRecordFilterCell class]) forIndexPath:indexPath];
    cell.selectedColor = self.selectedColor ? self.selectedColor : RGBCOLOR(0, 192, 255);
    MDRecordFilterModel* model = [self.dataArray objectAtIndex:indexPath.row defaultValue:nil];
    
    [cell refreshCellWithFilterModel:model];
    return cell;
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.shouldHandleSelectedBlock && !self.shouldHandleSelectedBlock()) {
        return;
    }
    
    [self refreshSelectedStateWithIndex:indexPath isSelected:YES needCallBack:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.shouldHandleSelectedBlock && !self.shouldHandleSelectedBlock()) {
        return;
    }

    [self refreshSelectedStateWithIndex:indexPath isSelected:NO needCallBack:NO];
}


-(void)refreshSelectedStateWithIndex:(NSIndexPath*)indexPath isSelected:(BOOL)isSelected needCallBack:(BOOL)need {

    [self clearAllModelSelectStatus];
    MDRecordFilterModel* model = [self.dataArray objectAtIndex:indexPath.row defaultValue:nil];
    MDRecordFilterCell* cell = (MDRecordFilterCell*)[self cellForItemAtIndexPath:indexPath];
    
    if(!isSelected){
        @try {
            [self.dataArray setObjectSafe:@(NO) forKey:@"isSelected"];
        } @catch (NSException *exception) {} @finally {}
        
    }else{
        
        model.isSelected = YES;
    }

    [UIView performWithoutAnimation:^{
        [cell refreshCellWithFilterModel:model];
    }];
    
    if(self.setselectedItemBlock && need){
        self.setselectedItemBlock(indexPath.item);
    }
}

- (void)clearAllModelSelectStatus {
    for (MDRecordFilterModel* model in self.dataArray) {
        model.isSelected = NO;
    }
    [self reloadData];
}

- (void)selectedAndReloadCollectionView:(NSUInteger)row  {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
    [self refreshSelectedStateWithIndex:indexPath isSelected:YES needCallBack:NO];
}


@end
