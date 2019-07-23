//
//  MDAssetBaseCollectionCell.h
//  MDChat
//
//  Created by YZK on 2018/12/12.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDAssetUtility.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetBaseCollectionCell : UICollectionViewCell

//@property (nonatomic, assign) BOOL masked;

@property (nonatomic, strong) UIImageView     *imageView;
@property (nonatomic, strong) MDPhotoItem     *item;

+ (NSString *)reuseIdentifier;
- (void)bindModel:(MDPhotoItem *)item;
- (void)displayTargetSizeImageWithBindedItem;

@end

NS_ASSUME_NONNULL_END
