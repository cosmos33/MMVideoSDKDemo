//
//  MDDownLoaderModel.m
//  MDChat
//
//  Created by lm on 2017/6/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDDownLoaderModel.h"
@import RecordSDK;

@implementation MDDownLoaderModel

-(BOOL)isEqual:(id)object {
    
    if (![object isKindOfClass:[MDDownLoaderModel class]]) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    MDDownLoaderModel *model = object;
    if ([self.url isEqualToString:model.url]) {
        return YES;
    }
    
    return NO;
}

-(NSUInteger)hash {
    
    return [self.url md_MD5];
}
@end
