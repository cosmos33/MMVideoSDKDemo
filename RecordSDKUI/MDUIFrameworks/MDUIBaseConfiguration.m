//
//  MDUIBaseConfiguration.m
//  Pods
//
//  Created by RecordSDK on 2016/10/9.
//
//

#import "MDUIBaseConfiguration.h"

static MDUIBaseConfiguration *configure = nil;
@implementation MDUIBaseConfiguration

+ (MDUIBaseConfiguration *)uibaseConfiguration
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configure = [[MDUIBaseConfiguration alloc] init];
    });
    return configure;
}

@end
