//
//  MDFaceDecorationCollectionLayout.m
//  MDChat
//
//  Created by YZK on 2017/7/25.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDFaceDecorationCollectionLayout.h"

@implementation MDFaceDecorationCollectionLayout

-(id)init{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;//设置为水平显示
        self.minimumLineSpacing = 10.0;//cell的最小间隔
        self.minimumInteritemSpacing = 70;
        
        self.activeDistance = 35;
        self.scaleFactor = 0.3;
        self.translationDistance = 15;
    }
    return self;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    //proposedContentOffset是没有设置对齐时本应该停下的位置（collectionView落在屏幕左上角的点坐标）
    CGFloat offsetAdjustment = MAXFLOAT;//初始化调整距离为无限大
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);//collectionView落在屏幕中点的x坐标
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);//collectionView落在屏幕的大小
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];//获得落在屏幕的所有cell的属性
    
    //对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    //调整
    return CGPointMake(round(proposedContentOffset.x + offsetAdjustment), proposedContentOffset.y);
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *originalArray = [super layoutAttributesForElementsInRect:rect];
    NSArray *array = [[NSArray alloc] initWithArray:originalArray copyItems:YES];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    //遍历所有布局属性
    for (UICollectionViewLayoutAttributes* attributes in array) {
        //如果cell在屏幕上则进行缩放
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;//距离中点的距离
            CGFloat normalizedDistance = distance / self.activeDistance;
            
            //对距离内的进行缩放
            CATransform3D transform3D = CATransform3DIdentity;
            if (ABS(distance) < self.activeDistance) {
                CGFloat zoom = 1 + self.scaleFactor*(1 - ABS(normalizedDistance));
                transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
                attributes.zIndex = 1;
            }
            
            //调整左右间距
            normalizedDistance = MAX(-1, MIN(normalizedDistance, 1));
            attributes.transform3D = CATransform3DTranslate(transform3D, -1*normalizedDistance*self.translationDistance, 0, 0);
        }
    }
    
    return array;
}

/**
 *  只要显示的边界发生改变就重新布局:
 内部会重新调用prepareLayout和layoutAttributesForElementsInRect方法获得所有cell的布局属性
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
