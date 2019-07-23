//
//  MUAt1AlertBarModel.m
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/12.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAt5AlertBarModel.h"

@implementation MUAt5AlertBarModel

-(instancetype)init{
    self = [super init];
    if (self) {
        self.type = MUAlertBarTypeAt5;
    }
    return self;
}

@end
