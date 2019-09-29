//
//  MDDecorationCollectionCell.h
//  MomoChat
//
//  Created by YZK on 2019/4/13.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDFaceDecorationItem;

NS_ASSUME_NONNULL_BEGIN

@interface MDDecorationCollectionCell : UICollectionViewCell

- (void)bindModel:(MDFaceDecorationItem *)model;
- (void)setCellSelected:(BOOL)isSelected;
- (void)startDownLoadAnimate:(MDFaceDecorationItem *)item;

@end

NS_ASSUME_NONNULL_END
