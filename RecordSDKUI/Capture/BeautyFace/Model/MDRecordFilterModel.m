//
//  MDRecordModel.m
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/3.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDRecordFilterModel.h"
#import <MMFoundation/MMFoundation.h>

@implementation MDRecordFilterModel

+ (instancetype)filterModelWithDicionary:(NSDictionary*)dictionary{
    
    MDRecordFilterModel *filterModel = [MDRecordFilterModel new];
    
    filterModel.identifier      = [dictionary stringForKey:@"id" defaultValue:nil];
    filterModel.title           = [dictionary stringForKey:@"title" defaultValue:nil];
    filterModel.tag             = [dictionary stringForKey:@"tag" defaultValue:nil];
    filterModel.iconUrlString   = [dictionary stringForKey:@"img_url" defaultValue:nil];
    filterModel.zipUrlString    = [dictionary stringForKey:@"zip_url" defaultValue:nil];

    return filterModel;
}

@end


@implementation MDRecordMakeUpModel

@end

