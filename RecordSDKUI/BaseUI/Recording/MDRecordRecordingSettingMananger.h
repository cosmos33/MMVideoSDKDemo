//
//  MDRecordRecordingSettingMananger.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/5/31.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MDRecordScreenRatio) {
    RecordScreenRatioFullScreen,
    RecordScreenRatio9to16,
    RecordScreenRatio3to4,
    RecordScreenRatio1to1
};

typedef NS_ENUM(NSUInteger, MDRecordRecordingResolution) {
    RecordingResolution640x480,
    RecordingResolution960x540,
    RecordingResolution1280x720,
    RecordingResolution1920x1080
};

@interface MDRecordRecordingSettingMananger : NSObject

@property (nonatomic, assign, class) NSInteger frameRate;
@property (nonatomic, assign, class) NSInteger bitRate;
@property (nonatomic, assign, class) MDRecordScreenRatio ratio;
@property (nonatomic, assign, class) MDRecordRecordingResolution resolution;

@property (nonatomic, readonly, class) NSString *cameraPreset;
@property (nonatomic, readonly, class) CGSize exportResolution;

@end

NS_ASSUME_NONNULL_END
