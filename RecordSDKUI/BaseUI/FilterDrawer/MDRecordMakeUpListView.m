//
//  MDRecordChangeFaceListView.m
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/4.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDRecordMakeUpListView.h"
#import "MDRecordFaceMakeUpCell.h"
#import "MDRecordFilterModel.h"
#import <MMFoundation/MMFoundation.h>
#import "UIConst.h"

#define cellWidth  (MDScreenWidth - 15*5 - 18*2)/6.0

@interface MDRecordMakeUpListView()<UICollectionViewDelegate,
                                    UICollectionViewDataSource>

@end
@implementation MDRecordMakeUpListView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    UICollectionViewFlowLayout* flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = 15;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.itemSize = CGSizeMake(cellWidth, 100);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 18, 0, 18);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    if(self = [super initWithFrame:frame collectionViewLayout:flowLayout]){
        [self registerClass:[MDRecordFaceMakeUpCell class] forCellWithReuseIdentifier:NSStringFromClass([MDRecordFaceMakeUpCell class])];
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.05);
        self.delegate   = self;
        self.bounces = NO;
        self.dataSource = self;
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
    
    MDRecordFaceMakeUpCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MDRecordFaceMakeUpCell class]) forIndexPath:indexPath];
    MDRecordMakeUpModel* model = [self.dataArray objectAtIndex:indexPath.row defaultValue:nil];
    
    [cell refreshCellWithMakeUpModel:model];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self refreshSelectedStateWithIndex:indexPath isSelected:YES needCallBack:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self refreshSelectedStateWithIndex:indexPath isSelected:NO needCallBack:YES];
}


-(void)refreshSelectedStateWithIndex:(NSIndexPath*)indexPath isSelected:(BOOL)isSelected needCallBack:(BOOL)need {
    
    [self clearAllModelSelectStatus];
    MDRecordMakeUpModel* model = [self.dataArray objectAtIndex:indexPath.row defaultValue:nil];
    MDRecordFaceMakeUpCell* cell = (MDRecordFaceMakeUpCell*)[self cellForItemAtIndexPath:indexPath];
    
    if(!isSelected){
        @try {
            [self.dataArray setObjectSafe:@(NO) forKey:@"isSelected"];
        } @catch (NSException *exception) {} @finally {}
        
    }else{
        
        model.isSelected = YES;
    }
   
 
    [UIView performWithoutAnimation:^{
        [cell refreshCellWithMakeUpModel:model];
    }];
    
    NSInteger makeUpId = model.makeUpId.integerValue;
    
    if (self.selectedIndexBlock && isSelected && need) {
        self.selectedIndexBlock(makeUpId);
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
