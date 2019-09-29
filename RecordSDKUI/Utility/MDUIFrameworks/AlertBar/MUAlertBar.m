//
//  MUAlertBar.m
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/12.
//  Copyright © 2016年 RecordSDK All rights reserved.
//

#import "MUAlertBar.h"

@implementation MUAlertBar

-(instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = RGBCOLOR(52, 155, 255);
        self.alpha = 0.94f;
    }
    return self;
}

@end
