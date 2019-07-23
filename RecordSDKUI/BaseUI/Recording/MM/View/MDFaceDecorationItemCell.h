//
//  ItemCell.h
//  MDChat
//
//  Created by 姜自佳 on 2017/5/16.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDMomentFaceDecorationItem.h"
@interface MDFaceDecorationItemCell : UICollectionViewCell

- (void)setIsSelected:(BOOL)isSelected;
- (MDFaceDecorationItem *)item;
- (void)updateWithModel:(MDFaceDecorationItem*)itemModel;

- (void)startDownLoadAnimate:(MDFaceDecorationItem *)item;
- (void)showResourceSelectedAnimate;
@end
