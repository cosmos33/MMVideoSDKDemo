//
//  MDFaceTipItem.m
//  MDChat
//
//  Created by sdk on 2017/6/22.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDFaceTipItem.h"

@implementation MDFaceTipItem

+ (NSDictionary *)eta_jsonKeyPathsByProperty
{
    return @{
             @"content":@"content",
             @"shouldFaceTrack":@"isFaceTrack",
             @"faceTrackContent":@"triggerTip.content"
             };
}

@end
