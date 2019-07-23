//
//  MDMusicActionItem.m
//  MDChat
//
//  Created by YZK on 2018/11/19.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicActionItem.h"
#import "MDMusicActionCell.h"
#import "MDRecordHeader.h"

@implementation MDMusicActionItem

+ (instancetype)uploadActionItem {
    MDMusicActionItem *item = [[self alloc] init];
    item.iconString = @"icon_music_local_upload";
    item.title = @"本地音乐";
    item.subTitle = @"上传本地音乐";
    item.type = MDMusicActionTypeUpload;
    return item;
}

+ (instancetype)recommendActionItem {
    MDMusicActionItem *item = [[self alloc] init];
    item.iconString = @"icon_music_recommend";
    item.title = @"点击推荐";
    item.subTitle = @"没找到合适的音乐";
    item.type = MDMusicActionTypeRecommend;
    return item;
}

- (Class)cellClass {
    return [MDMusicActionCell class];
}

- (CGSize)cellSize {
    CGFloat width = floor( (MDScreenWidth-20*2-17.5*2)/3.0 );
    return CGSizeMake(width, width*1.5);
}

@end
