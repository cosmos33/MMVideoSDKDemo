//
//  MDMusicBaseCollectionCell.m
//  MDChat
//
//  Created by YZK on 2018/11/9.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicBaseCollectionCell.h"

@implementation MDMusicBaseCollectionCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

- (void)bindModel:(MDMusicBaseCollectionItem *)item {
}


@end
