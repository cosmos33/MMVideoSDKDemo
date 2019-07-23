//
//  MDRecordTipItem.m
//  MDChat
//
//  Created by nanjibingshuang on 2017/6/23.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDRecordTipItem.h"

@implementation MDRecordTipItem
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self){
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.tipText = [aDecoder decodeObjectForKey:@"tipText"];
        self.serverUpdateTimestamp = [aDecoder decodeDoubleForKey:@"serverUpdateTime"];
        self.showTip = [aDecoder decodeBoolForKey:@"showTip"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.tipText forKey:@"tipText"];
    [aCoder encodeDouble:self.serverUpdateTimestamp forKey:@"serverUpdateTime"];
    [aCoder encodeBool:self.showTip forKey:@"showTip"];
}
@end
