//
//  MDNewAssetAlbumCell.h
//  MDChat
//
//  Created by YZK on 2018/10/26.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDAssetAlbumItem.h"

FOUNDATION_EXPORT const CGFloat kMDNewAssetAlbumCellHeight;

NS_ASSUME_NONNULL_BEGIN

@interface MDNewAssetAlbumCell : UITableViewCell

@property (nonatomic, strong) MDAssetAlbumItem *item;
- (void)bindModel:(MDAssetAlbumItem *)item;

@end

NS_ASSUME_NONNULL_END
