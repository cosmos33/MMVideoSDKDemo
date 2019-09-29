//
//  MDMusicEditActionItem.m
//  MDChat
//
//  Created by YZK on 2018/11/20.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicEditActionItem.h"
#import "MDMusicEditActionCell.h"
#import "MDRecordHeader.h"

@implementation MDMusicEditActionItem

+ (instancetype)libraryEditActionItem {
    MDMusicEditActionItem *item = [[MDMusicEditActionItem alloc] init];
    item.iconString = @"recordsdk-page1";
    item.bgColor = RGBCOLOR(0, 192, 255);
    item.title = @"音乐库";
    item.type = MDMusicEditActionTypeLibrary;
    return item;
}

+ (instancetype)localMusicActionItem {
    MDMusicEditActionItem *item = [[MDMusicEditActionItem alloc] init];
    item.iconString = @"recordsdk-page1";
    item.bgColor = RGBCOLOR(0, 192, 255);
    item.title = @"本地音乐";
    item.type = MDMusicEditActionTypeLocal;
    return item;
}

+ (instancetype)clearEditActionItem {
    MDMusicEditActionItem *item = [[MDMusicEditActionItem alloc] init];
    item.iconString = @"recordsdk-group12";
    item.bgColor = RGBCOLOR(40, 40, 40);
    item.title = @"无音乐";
    item.type = MDMusicEditActionTypeClear;
    return item;
}

- (Class)cellClass {
    return [MDMusicEditActionCell class];
}

- (CGSize)cellSize {
    return CGSizeMake(60, 90);
}

@end
