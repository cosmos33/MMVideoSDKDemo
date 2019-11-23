//
//  MDRecordRecordingSettingMananger.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/5/31.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordRecordingSettingMananger.h"
@import AVFoundation;

static NSInteger _frameRate = 0;
static NSInteger _bitRate = 0;
static CGFloat _upperExposureBias = 3.0;
static CGFloat _lowExposureBias = -3.0;
static MDRecordScreenRatio _ratio = RecordScreenRatioFullScreen;
static MDRecordRecordingResolution _resolution = RecordingResolution1280x720;

@implementation MDRecordRecordingSettingMananger

+ (void)setFrameRate:(NSInteger)frameRate {
    _frameRate = frameRate;
}

+ (NSInteger)frameRate {
    return _frameRate;
}

+ (void)setBitRate:(NSInteger)bitRate {
    _bitRate = bitRate;
}

+ (NSInteger)bitRate {
    return _bitRate;
}

+ (void)setRatio:(MDRecordScreenRatio)ratio {
    _ratio = ratio;
}

+ (MDRecordScreenRatio)ratio {
    return _ratio;
}

+ (CGFloat)upperExposureBias {
    return _upperExposureBias;
}

+ (void)setUpperExposureBias:(CGFloat)upperExposureBias {
    if (upperExposureBias >= 0 && upperExposureBias <= 3.0) {
        _upperExposureBias = upperExposureBias;
    } else {
        _upperExposureBias = 3.0;
    }
}

+ (CGFloat)lowExposureBias {
    return _lowExposureBias;
}

+ (void)setLowExposureBias:(CGFloat)lowExposureBias {
    if (lowExposureBias >= -3.0 && lowExposureBias <= 0) {
        _lowExposureBias = lowExposureBias;
    } else {
        _lowExposureBias = -3.0;
    }
}

+ (void)setResolution:(MDRecordRecordingResolution)resolution {
    _resolution = resolution;
}

+ (MDRecordRecordingResolution)resolution {
    return _resolution;
}

+ (MDRCaptureResolutionType)cameraPreset {
    switch (self.resolution) {
        case RecordingResolution640x480:
            return MDRCaptureResolutionType_480P;
            break;
            
        case RecordingResolution960x540:
            return MDRCaptureResolutionType_540P;
            break;
            
        case RecordingResolution1280x720:
            return MDRCaptureResolutionType_720P;
            break;
            
        case RecordingResolution1920x1080:
            return MDRCaptureResolutionType_1080P;
            break;
            
        default:
            return MDRCaptureResolutionType_720P;
            break;
    }
}

+ (NSInteger)widthForCurrentResolution {
    switch (self.resolution) {
        case RecordingResolution640x480:
            return 480;

        case RecordingResolution960x540:
            return 540;

        case RecordingResolution1280x720:
            return 720;

        case RecordingResolution1920x1080:
            return 1080;

        default:
            return 720;
    }
}

+ (CGSize)exportResolution {
    NSInteger width = [self widthForCurrentResolution];
    switch (self.ratio) {
        case RecordScreenRatioFullScreen:
            break;
            
        case RecordScreenRatio9to16:
            return CGSizeMake(width, width / 9 * 16 / 4 * 4);

        case RecordScreenRatio3to4:
            return CGSizeMake(width, width / 3 * 4 / 4 * 4);

        case RecordScreenRatio1to1:
            return CGSizeMake(width, width);
    }
    return CGSizeMake(720, 1280);
}

+ (MDRRatio)videoRatioValue {
    switch (self.ratio) {
        case RecordScreenRatio9to16: return MDRRatioMake(9, 16);
        case RecordScreenRatio3to4: return MDRRatioMake(3, 4);
        case RecordScreenRatio1to1: return MDRRatioMake(1, 1);
        default: return MDRRatioZero;
    }
}

@end
