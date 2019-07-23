//
//  MDMusicEditCardItem.h
//  MDChat
//
//  Created by YZK on 2018/11/20.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicCollectionItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDMusicEditCardItem : MDMusicCollectionItem

+ (instancetype)itemWithCollectionItem:(MDMusicCollectionItem *)item;
+ (MDMusicCollectionItem *)collectionItemWithItem:(MDMusicEditCardItem *)item;

@end

NS_ASSUME_NONNULL_END
