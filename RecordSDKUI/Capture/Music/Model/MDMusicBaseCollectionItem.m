//
//  MDMusicBaseCollectionItem.m
//  MDChat
//
//  Created by YZK on 2018/11/9.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicBaseCollectionItem.h"
#import "MDMusicBaseCollectionCell.h"

@implementation MDMusicBaseCollectionItem

- (Class)cellClass {
    return [MDMusicBaseCollectionCell class];
}

- (CGSize)cellSize {
    return CGSizeZero;
}

@end
