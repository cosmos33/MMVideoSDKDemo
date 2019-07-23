//
//  MDAssetVideoCollectionCell.h
//  MDChat
//
//  Created by YZK on 2018/12/12.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDAssetBaseCollectionCell.h"

@class MDAssetVideoCollectionCell;
@protocol MDAssetVideoCollectionCellDelegate <NSObject>
- (void)assetVideoCellClickVideo:(MDAssetVideoCollectionCell *)cell;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetVideoCollectionCell : MDAssetBaseCollectionCell

@property (nonatomic, weak) id<MDAssetVideoCollectionCellDelegate> cellDelegate;
- (void)setEnableSelect:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
