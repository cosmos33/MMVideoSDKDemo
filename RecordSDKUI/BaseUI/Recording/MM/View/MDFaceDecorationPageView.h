//
//  MDMDFaceDecorationPageView.h
//
//  Created by 姜自佳 on 2017/5/12.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDFaceDecorationItem.h"

@class MDFaceDecorationPageView;
@protocol MDFaceDecorationPageViewDelegate <NSObject>

- (void)faceDecorationPageView:(MDFaceDecorationPageView *)pageView
                     indexPath:(NSIndexPath *)indexPath
                     withModel:(MDFaceDecorationItem *)cellModel;

- (void)faceDecorationPageViewDidEndDecelerating:(UIScrollView *)pageView
                                  currentSection:(NSInteger)currentSection
                                       pageCount:(NSInteger)pageCount
                                currentPageIndex:(NSInteger)currentPageIndex;

@end



@interface MDFaceDecorationPageView : UICollectionView

- (instancetype)initWithItemSize:(CGSize)size;

@property (nonatomic, weak) id<MDFaceDecorationPageViewDelegate> pageDelegate;
@property(nonatomic,strong)NSArray* dataArray;

@end

