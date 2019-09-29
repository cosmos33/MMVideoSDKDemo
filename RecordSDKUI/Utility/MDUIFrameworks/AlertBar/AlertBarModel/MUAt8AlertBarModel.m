//
//  MUAt8AlertBarModel.m
//  RecordSDK
//
//  Created by Aaron on 16/7/28.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAt8AlertBarModel.h"

@implementation MUAt8AlertBarModel

-(instancetype)init{
    self = [super init];
    if (self) {
        self.type = MUAlertBarTypeAt8;
    }
    return self;
}

@end
