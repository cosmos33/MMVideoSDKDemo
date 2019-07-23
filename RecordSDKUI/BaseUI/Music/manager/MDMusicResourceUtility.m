//
//  MDMusicResourceUtility.m
//  MDChat
//
//  Created by YZK on 2018/11/9.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicResourceUtility.h"
#import "MDMusicBVO.h"
#import "MDRecordContext.h"
#import "Toast/Toast.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

static const float maxLocalMusicDuration = 60.0f * 7;

@implementation MDMusicResourceUtility

+ (BOOL)checkAssetValidWithURL:(NSURL *)url sizeConstraint:(BOOL)needConstraint {
    if (!url) {
        return NO;
    }
    AVAsset *asset = [AVAsset assetWithURL:url];
    BOOL valid = asset.playable;
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if (!valid) {
        [window makeToast:@"资源异常" duration:1.5f position:CSToastPositionCenter];
    } else if (needConstraint) {
        valid = CMTimeGetSeconds(asset.duration) <= maxLocalMusicDuration;
        if (!valid) {
            [window makeToast:@"7分钟以上音乐暂时无法上传" duration:1.5f position:CSToastPositionCenter];
        }else {
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset
                                                                              presetName: AVAssetExportPresetAppleM4A];
            exporter.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
            //本地音乐文件的大小（不准确，仅用来限制音乐文件不要过大）
            valid = exporter.estimatedOutputFileLength <= 20 *1024 *1024;
            if (!valid) {
                [window makeToast:@"资源文件过大" duration:1.5f position:CSToastPositionCenter];
            }
        }
    }
    return valid;
}

+ (CMTimeRange)timeRangeWithStartPercent:(CGFloat)startPercent endPercent:(CGFloat)endPercent duration:(CMTime)duration {
    CFTimeInterval durationTime = CMTimeGetSeconds(duration);
    
    CFTimeInterval start = floor(durationTime * startPercent * duration.timescale);
    CMTime startTime = CMTimeMake(start, duration.timescale);
    
    CFTimeInterval end = floor(durationTime * endPercent * duration.timescale);
    CMTime endTime = CMTimeMake(end, duration.timescale);
    
    return CMTimeRangeFromTimeToTime(startTime, endTime);
}

+ (NSString *)keyWithMusicBVO:(MDMusicBVO *)bvo {
    return [NSString stringWithFormat:@"%@_%@",bvo.categoryID,bvo.musicID];
}


@end
