//
//  MDAlbumVideoCoverFlowLayout.m
//  MomoChat
//
//  Created by Leery on 2018/9/13.
//  Copyright © 2018年 wemomo.com. All rights reserved.
//

#import "MDAlbumVideoCoverFlowLayout.h"
#import "UIConst.h"
#import "UIView+Utils.h"

#define ACTIVE_DISTANCE     (40.0)
#define kItemSizeWidth      (40.0)
#define kItemSizeHeight     (60.0)
#define ZOOM_FACTOR         (67.0 / kItemSizeHeight - 1)

@implementation MDAlbumVideoCoverFlowLayout

- (instancetype)init {
    if(self = [super init]) {
    }
    return self;
}

-(void)prepareLayout
{
    [super prepareLayout];
    self.itemSize = CGSizeMake(kItemSizeWidth, kItemSizeHeight);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = 0;
    self.sectionInset = UIEdgeInsetsMake(0, ceilf((MDScreenWidth-kItemSizeWidth)/2.0), 0, ceilf((MDScreenWidth-kItemSizeWidth)/2.0));
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.size;
    //取出默认cell的UICollectionViewLayoutAttributes
    
    NSArray *original = [super layoutAttributesForElementsInRect:rect];
    
    NSArray *tempArray = nil;
    if(original == nil) {
        tempArray = [NSArray array];
    }else{
        tempArray = original;
    }
    NSArray *array =  [[NSArray alloc] initWithArray:tempArray copyItems:YES];
    
    for (UICollectionViewLayoutAttributes* attributes in array) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
            
            distance = ABS(distance);
            
            if (distance <  self.itemSize.width) {
                CGFloat scale = 1 + ZOOM_FACTOR * (1 - distance / ACTIVE_DISTANCE);
                attributes.transform3D =  CATransform3DTranslate(CATransform3DMakeScale(scale, scale, 1.0), 0, 0, 1.0)   ;
            }
        }
    }
    
    return array;
}

//自动对齐到网格
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    //1.计算scrollview最后停留的范围
    CGRect lastRect ;
    lastRect.origin = proposedContentOffset;
    lastRect.size = self.collectionView.size;
    //2.取出这个范围内的所有属性
    NSArray *array = [self layoutAttributesForElementsInRect:lastRect];
    //计算屏幕最中间的x
    CGFloat centerX = proposedContentOffset.x + self.collectionView.width / 2 ;
    //3.遍历所有的属性
    CGFloat adjustOffsetX = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if(ABS(attrs.center.x - centerX) < ABS(adjustOffsetX)){//取出最小值
            adjustOffsetX = attrs.center.x - centerX;
        }
    }
    return CGPointMake(proposedContentOffset.x + adjustOffsetX, proposedContentOffset.y);
}

@end
