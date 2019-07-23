//
//  MDMusicEditCardItem.m
//  MDChat
//
//  Created by YZK on 2018/11/20.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicEditCardItem.h"
#import "MDMusicEditCardCell.h"

@implementation MDMusicEditCardItem

+ (instancetype)itemWithCollectionItem:(MDMusicCollectionItem *)musicItem {
    MDMusicEditCardItem *item = [[self alloc] init];
    item.musicVo = [musicItem.musicVo copy];
    item.isLocal = musicItem.isLocal;
    item.resourceUrl = [musicItem.resourceUrl copy];
    item.selected = musicItem.selected;
    item.downLoading = musicItem.downLoading;
    return item;
}

+ (MDMusicCollectionItem *)collectionItemWithItem:(MDMusicEditCardItem *)item {
    MDMusicCollectionItem *musicItem = [[MDMusicCollectionItem alloc] init];
    musicItem.musicVo = [item.musicVo copy];
    musicItem.isLocal = item.isLocal;
    musicItem.resourceUrl = [item.resourceUrl copy];
    musicItem.selected = item.selected;
    musicItem.downLoading = item.downLoading;
    return musicItem;
}

- (Class)cellClass {
    return [MDMusicEditCardCell class];
}

- (CGSize)cellSize {
    return CGSizeMake(60, 90);
}

@end
