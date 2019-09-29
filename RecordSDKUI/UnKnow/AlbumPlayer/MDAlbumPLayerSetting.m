//
//  MDAlbumPLayerSetting.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/7/3.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDAlbumPLayerSetting.h"

static MDAlbumPlayerAnimationKey _animationType = nil;

@implementation MDAlbumPLayerSetting

+ (void)setAnimationType:(MDAlbumPlayerAnimationKey)animationType {
    _animationType = animationType.copy;
}

+ (MDAlbumPlayerAnimationKey)animationType {
    return _animationType ?: kAlbumPlayerAnimationTypeNone;
}

@end
