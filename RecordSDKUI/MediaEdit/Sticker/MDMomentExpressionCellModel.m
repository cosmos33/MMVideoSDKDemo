//
//  MDMomentExpressionCellModel.m
//  MDChat
//
//  Created by lm on 2017/6/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMomentExpressionCellModel.h"

@implementation MDMomentExpressionCellModel

+ (NSDictionary *)eta_jsonKeyPathsByProperty {
    
    static NSDictionary *paths = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        paths = @{
                  @"resourceId"           :   @"id",
                  @"picUrl"               :   @"pic",
                  @"zipUrl"               :   @"zip"
                };
    });
    return paths;
}

@end
