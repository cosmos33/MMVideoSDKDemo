//
//  MDDecorationHorizontalLayout.m
//  DEMo
//
//  Created by 姜自佳 on 2017/5/20.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDDecorationHorizontalLayout.h"
#import "MDRecordHeader.h"

@interface   MDDecorationHorizontalLayout()<UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableDictionary *layoutAttributesDict;
@end

@implementation MDDecorationHorizontalLayout

- (void)prepareLayout{

    [super prepareLayout];
    
    self.layoutAttributesDict = [NSMutableDictionary dictionary];
    
    NSInteger sections = [self.collectionView numberOfSections];
    for (int i = 0; i < sections; i++)
    {
        NSUInteger count = [self.collectionView numberOfItemsInSection:i];
        for (NSUInteger j = 0; j<count; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self setLayoutAttributes:attr forIndexPath:indexPath];
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger item = indexPath.item;
    NSUInteger x = 0;
    NSUInteger y = 0;
    [self targetPositionWithItem:item resultX:&x resultY:&y];
    NSUInteger newItem = [self originItemAtX:x y:y];
  
    NSIndexPath *theNewIndexPath = [NSIndexPath indexPathForItem:newItem inSection:indexPath.section];
    
    UICollectionViewLayoutAttributes *theNewAttr = [super layoutAttributesForItemAtIndexPath:theNewIndexPath];
    theNewAttr.indexPath = indexPath;
    return theNewAttr;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *marr = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attr in array) {
        [marr addObjectSafe:[self layoutAttributesForIndexPath:attr.indexPath]];
    }
    return marr;
}


- (void)targetPositionWithItem:(NSUInteger)item
                       resultX:(NSUInteger *)x
                       resultY:(NSUInteger *)y{
    
    if (!self.columnCount || !self.rowCount) {
        return;
    }
    
    NSUInteger page = item/(self.columnCount*self.rowCount);
    
    NSUInteger theX = item % self.columnCount + page * self.columnCount;
    NSUInteger theY = item / self.columnCount - page * self.rowCount;
    if (x != NULL) {
        *x = theX;
    }
    if (y != NULL) {
        *y = theY;
    }
}

- (NSUInteger)originItemAtX:(NSUInteger)x
                          y:(NSUInteger)y
{
    NSUInteger item = x * self.rowCount + y;
    return item;
}


- (void)setLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
               forIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    NSInteger section = indexPath.section;
    NSString *key = [NSString stringWithFormat:@"%@-%@",@(section),@(item)];
    [self.layoutAttributesDict setObjectSafe:layoutAttributes forKey:key];
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    NSInteger section = indexPath.section;
    NSString *key = [NSString stringWithFormat:@"%@-%@",@(section),@(item)];
    return [self.layoutAttributesDict objectForKey:key defaultValue:nil];
}


@end
