//
//  MDMusicCollectionCell.h
//  MDChat
//
//  Created by YZK on 2018/11/7.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicBaseCollectionCell.h"
#import "MDMusicCollectionItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDMusicCollectionCell : MDMusicBaseCollectionCell

@property (nonatomic, strong, readonly) MDMusicCollectionItem *item;

@end

NS_ASSUME_NONNULL_END
