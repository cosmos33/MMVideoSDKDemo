//
//  MDMusicBVO.m
//  MDChat
//
//  Created by YZK on 2018/11/8.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicBVO.h"
#import "MDRecordHeader.h"

@implementation MDMusicBVO

+ (MDMusicBVO *)converToMusicItemWithDictionary:(NSDictionary *)dic {
    if (dic == nil) {
        return nil;
    }
    MDMusicBVO *item = [[self alloc] init];
    item.musicID = [dic stringForKey:@"music_id" defaultValue:@""];
    item.title = [dic stringForKey:@"title" defaultValue:@""];
    item.remoteUrl = [dic stringForKey:@"url" defaultValue:@""];
    item.cover = [dic stringForKey:@"cover" defaultValue:@""];
    item.type = [dic stringForKey:@"type" defaultValue:@""];
    item.categoryID = [dic stringForKey:@"category_id" defaultValue:@""];
    item.author = [dic stringForKey:@"author" defaultValue:@""];
    item.opid = [dic stringForKey:@"opid" defaultValue:@""];
    item.duration = [dic doubleForKey:@"duration" defaultValue:0];
        
    return item;
}

+ (NSDictionary *)converToDictionaryWithMusicItem:(MDMusicBVO *)item {
    if (item == nil) {
        return nil;
    }
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict setString:item.musicID forKey:@"music_id"];
    [mDict setString:item.title forKey:@"title"];
    [mDict setString:item.remoteUrl forKey:@"url"];
    [mDict setString:item.cover forKey:@"cover"];
    [mDict setString:item.type forKey:@"type"];
    [mDict setString:item.categoryID forKey:@"category_id"];
    [mDict setString:item.author forKey:@"author"];
    [mDict setString:item.opid forKey:@"opid"];
    [mDict setDouble:item.duration forKey:@"duration"];
    
    return [mDict copy];
}


- (id)copyWithZone:(nullable NSZone *)zone {
    MDMusicBVO *bvo = [[[self class] allocWithZone:zone] init];
    bvo.musicID = [self.musicID copy];
    bvo.title = [self.title copy];
    bvo.remoteUrl = [self.remoteUrl copy];
    bvo.cover = [self.cover copy];
    bvo.type = [self.type copy];
    bvo.categoryID = [self.categoryID copy];
    bvo.author = [self.author copy];
    bvo.opid = [self.opid copy];
    bvo.duration = self.duration;
    return bvo;
}

@end
