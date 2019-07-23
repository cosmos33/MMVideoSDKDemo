//
//  MUAt7AlertBarModel.m
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/15.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAt7AlertBarModel.h"

@implementation MUAt7AlertBarModel

-(instancetype)init{
    self = [super init];
    if (self) {
        self.type = MUAlertBarTypeAt7;
    }
    return self;
}

@end
