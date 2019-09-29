//
//  MDMusicBaseCollectionCell.h
//  MDChat
//
//  Created by YZK on 2018/11/9.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDMusicBaseCollectionItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDMusicBaseCollectionCell : UICollectionViewCell

- (void)bindModel:(MDMusicBaseCollectionItem *)item;

+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
