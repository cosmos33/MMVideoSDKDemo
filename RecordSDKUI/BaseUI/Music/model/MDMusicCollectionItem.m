//
//  MDMusicCollectionItem.m
//  MDChat
//
//  Created by YZK on 2018/11/7.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicCollectionItem.h"
#import "MDMusicCollectionCell.h"
#import "MDMusicFavouriteManager.h"
//#import "MDMusicDownloadManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MDRecordHeader.h"
#import "MDPublicSwiftHeader.h"

@implementation MDMusicCollectionItem

- (instancetype)favouriteCopyItem {
    MDMusicCollectionItem *item = [self copy];
    item.musicVo.categoryID = kMusicMyFavouriteCategoryID;
    return item;
}

- (BOOL)resourceExist {
    if (self.isLocal) {
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:self.musicVo.musicID forProperty:MPMediaItemPropertyPersistentID];
        MPMediaQuery *songQuery = [[MPMediaQuery alloc] init];
        [songQuery addFilterPredicate: predicate];
        if (songQuery.items.count > 0) {
            return YES;
        }
    } else {
        if ([self.resourceUrl checkResourceIsReachableAndReturnError:nil]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)displayTitle {
    if ([self.musicVo.author isNotEmpty]) {
        return [NSString stringWithFormat:@"%@ - %@",self.musicVo.title,self.musicVo.author];
    }
    return self.musicVo.title;
}

- (void)setMusicVo:(MDMusicBVO *)musicVo {
    _musicVo = musicVo;
//    self.resourceUrl = [MDMusicDownloadManager getMusicResourceURLWithItem:musicVo];
    if (musicVo.remoteUrl) {
        self.resourceUrl = [MDNewMusicDownloadManager resoucePathFor:musicVo];
    }
}


+ (MDMusicCollectionItem *)converToMusicItemWithDictionary:(NSDictionary *)dic {
    if (dic == nil) {
        return nil;
    }
    MDMusicCollectionItem *item = [[self alloc] init];
    MDMusicBVO *vo = [MDMusicBVO converToMusicItemWithDictionary:dic];
    item.musicVo = vo;
    item.isLocal = [dic boolForKey:@"isLocal" defaultValue:NO];
    
    if (item.isLocal) {
        NSString *urlStirng = [dic stringForKey:@"resourceUrl" defaultValue:nil];
        item.resourceUrl = urlStirng ? [NSURL URLWithString:urlStirng] : nil;
    }

    return item;
}

+ (NSDictionary *)converToDictionaryWithMusicItem:(MDMusicCollectionItem *)item {
    if (item == nil) {
        return nil;
    }
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    NSDictionary *voDict = [MDMusicBVO converToDictionaryWithMusicItem:item.musicVo];
    
    [mDict addEntriesFromDictionary:voDict];
    [mDict setBool:item.isLocal forKey:@"isLocal"];
    [mDict setString:item.resourceUrl.absoluteString forKey:@"resourceUrl"];

    return [mDict copy];
}

- (Class)cellClass {
    return [MDMusicCollectionCell class];
}

- (CGSize)cellSize {
    CGFloat width = floor( (MDScreenWidth-20*2-17.5*2)/3.0 );
    return CGSizeMake(width, width*1.5);
}

- (id)copyWithZone:(nullable NSZone *)zone {
    MDMusicCollectionItem *item = [[[self class] allocWithZone:zone] init];
    item.musicVo = [self.musicVo copy];
    item.resourceUrl = [self.resourceUrl copy];
    item.isLocal = self.isLocal;
    return item;
}


@end
