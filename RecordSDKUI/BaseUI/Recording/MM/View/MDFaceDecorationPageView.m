//
//  MDMDFaceDecorationPageView.m
//
//  Created by 姜自佳 on 2017/5/12.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDFaceDecorationPageView.h"
#import "MDFaceDecorationItem.h"
#import "MDFaceDecorationItemCell.h"
#import "MDDecorationHorizontalLayout.h"
#import "MDDecorationTool.h"
#import "MDRecordHeader.h"

@interface MDFaceDecorationPageView()
<UICollectionViewDelegate,
UICollectionViewDataSource>

@end


@implementation MDFaceDecorationPageView

- (instancetype)initWithItemSize:(CGSize)size {
    
    MDDecorationHorizontalLayout* flow = [MDDecorationHorizontalLayout new];
    flow.columnCount = kDecorationsColCount;
    flow.rowCount = kDecorationsRowCount;
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumLineSpacing = 0;
    flow.minimumInteritemSpacing = 0;
    flow.itemSize = size;

    self = [super initWithFrame:CGRectZero collectionViewLayout:flow];
    if (self) {
        
        [self registerClass:[MDFaceDecorationItemCell class] forCellWithReuseIdentifier:NSStringFromClass([MDFaceDecorationItemCell class])];
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = YES;
        self.dataSource = self;
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        if ([self respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            [self setPrefetchingEnabled:NO];
        }
        
    }
    return self;
}




- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
//    NSArray *sortedIndexPaths = [self.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [obj1 compare:obj2];
//    }];
    
    CGPoint firstPoint = CGPointMake(scrollView.contentOffset.x+10, scrollView.contentOffset.y+10);
    NSIndexPath* indexPath = [self indexPathForItemAtPoint:firstPoint];
    if (!indexPath) {
        return;
    }
    NSInteger section = indexPath.section;

    NSArray* sectionArray = [self.dataArray objectAtIndex:section kindOfClass:[NSArray class]];
    NSInteger count = sectionArray.count/kMaxDecorationCount;

    if (self.pageDelegate && [self.pageDelegate respondsToSelector:@selector(faceDecorationPageViewDidEndDecelerating:currentSection:pageCount:currentPageIndex:)]) {
        [self.pageDelegate faceDecorationPageViewDidEndDecelerating:self currentSection:section pageCount:count currentPageIndex:indexPath.item/kMaxDecorationCount];
    }
}




#pragma mark - UICollectionViewDataSource UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.dataArray.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSArray* arr = [self.dataArray arrayAtIndex:section defaultValue:nil];
    return arr.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    MDFaceDecorationItem* item = [self itemOfRow:indexPath];
    MDFaceDecorationItemCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MDFaceDecorationItemCell class]) forIndexPath:indexPath];
    [cell updateWithModel:item];
    return cell;
}

- (MDFaceDecorationItem*)itemOfRow:(NSIndexPath*)indexPath{
    NSArray* arr = [self.dataArray arrayAtIndex:indexPath.section defaultValue:nil];
    MDFaceDecorationItem* item = [arr objectAtIndex:indexPath.row kindOfClass:[MDFaceDecorationItem class]];
    return item;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MDFaceDecorationItem* itemModel = [self itemOfRow:indexPath];
    if([self.pageDelegate respondsToSelector:@selector(faceDecorationPageView:indexPath:withModel:)]){
        [self.pageDelegate faceDecorationPageView:self indexPath:indexPath withModel:itemModel];
    }
}

@end
