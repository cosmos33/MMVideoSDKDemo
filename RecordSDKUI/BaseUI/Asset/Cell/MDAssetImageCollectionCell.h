//
//  MDAssetImageCollectionCell.h
//  MDChat
//
//  Created by YZK on 2018/12/12.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDAssetBaseCollectionCell.h"

@class MDAssetImageCollectionCell;

@protocol MDAssetImageCollectionCellDelegate <NSObject>

- (BOOL)assetImageCellCanSelect:(MDAssetImageCollectionCell *)cell;
- (void)assetImageCell:(MDAssetImageCollectionCell *)cell didClickImageWithSelected:(BOOL)selected;
- (void)assetImageCellClickPreview:(MDAssetImageCollectionCell *)cell;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetImageCollectionCell : MDAssetBaseCollectionCell

@property (nonatomic, weak) id<MDAssetImageCollectionCellDelegate> cellDelegate;
- (void)setEnableSelect:(BOOL)enable;
- (void)refreshSelectedNumber;

@end

NS_ASSUME_NONNULL_END
