//
//  MDMusicCategoryItem.m
//  MDChat
//
//  Created by YZK on 2018/11/7.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicCategoryItem.h"
#import "MDRecordHeader.h"

@implementation MDMusicCategoryItem


+ (MDMusicCategoryItem *)dictToMusicCategoryItem:(NSDictionary *)dic {
    if (dic == nil) return nil;
    
    MDMusicCategoryItem *item = [[self alloc] init];
    item.categoryId = [dic stringForKey:@"category_id" defaultValue:@""];
    item.categoryName = [dic stringForKey:@"name" defaultValue:@""];
    item.selected = [dic boolForKey:@"selected" defaultValue:NO];

    return item;
}

@end
