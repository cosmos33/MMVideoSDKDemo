//
//  MDRecordVideoSettingManager.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/5/31.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordVideoSettingManager.h"

static NSInteger _exportFrameRate = 0;
static NSInteger _exportBitRate = 0;
static BOOL _enableBgBlur = NO;

@implementation MDRecordVideoSettingManager

+ (void)setExportFrameRate:(NSInteger)exportFrameRate {
    _exportFrameRate = exportFrameRate;
}

+ (NSInteger)exportFrameRate {
    return _exportFrameRate;
}

+ (void)setExportBitRate:(NSInteger)exportBitRate {
    _exportBitRate = exportBitRate;
}

+ (NSInteger)exportBitRate {
    return _exportBitRate;
}

+ (void)setEnableBlur:(BOOL)enableBlur {
    _enableBgBlur = enableBlur;
}

+ (BOOL)enableBlur {
    return _enableBgBlur;
}

@end
