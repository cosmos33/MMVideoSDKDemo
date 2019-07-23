//
//  MDUserFeedGuideModel.m
//  MDChat
//
//  Created by litianpeng on 2018/10/10.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDUserFeedGuideModel.h"
#import "MDRecordHeader.h"

@implementation MDUserFeedGuideModel
+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    NSDictionary *infoDic = [dict objectForKey:@"info"];
    if (infoDic) {
        MDUserFeedGuideModel *model = [[MDUserFeedGuideModel alloc] init];
        model.title = [infoDic stringForKey:@"title" defaultValue:nil];
        model.icon = [infoDic stringForKey:@"icon" defaultValue:nil];
        model.desc = [infoDic stringForKey:@"description" defaultValue:nil];
        model.gotoString = [infoDic stringForKey:@"goto" defaultValue:nil];
        model.statKey = [infoDic stringForKey:@"stat_key" defaultValue:nil];
        model.type = 1;
        model.modelType = 3;
        return model;
    }
    return nil;
}
@end


@implementation MDUserFeedGuideShowModel



@end
