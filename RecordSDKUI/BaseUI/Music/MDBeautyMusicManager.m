//
//  MDBeautyMusicManager.m
//  MDChat
//
//  Created by sdk on 2018/5/11.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDBeautyMusicManager.h"
#import "MDMomentMusicListCell.h"
#import "MDRecordHeader.h"
//#import <EtaStorage/EtaStorage.h>
#import "MDVideoBackgroundMusicManager.h"
#import "Toast/Toast.h"

static const float      maxLocalMusicDuration = 60.0f * 7;
@implementation MDBeautyMusicManager

+ (MDBeautyMusic *)localMusic:(NSString *)m_musicID {
    if([m_musicID isKindOfClass:[NSString class]] && [m_musicID isNotEmpty]) {
//        return [[EtaContext shareInstance] modelWith:m_musicID andType:EtaModelTypeBeautyMusic];
    }
    return nil;
}

+ (void)setMusic:(MDBeautyMusic *)music {
//    [[EtaContext shareInstance] saveModel:music];
}
+ (void)setMusics:(NSArray *)array {
//    [[EtaContext shareInstance] saveModels:array];
}
/**
 * 获取一组music
 * @return:array 内容为MDBeautyMusic
 */
+ (NSArray *)getMusics:(NSArray *)m_musicIDs {
//    return [[EtaContext shareInstance] modelsWith:m_musicIDs andType:EtaModelTypeBeautyMusic];
    return nil;
}

+ (BOOL)checkAssetValid:(NSURL *)url sizeConstraint:(BOOL)needConstraint {
    if (!url) {
        return NO;
    }
    AVAsset *asset = [AVURLAsset assetWithURL:url];
    BOOL valid = asset.playable;
    if (!valid) {
        //[[MDContext sharedIndicate] showWarningInView:[MDContext sharedAppDelegate].window withText:@"资源异常" timeOut:1.5f];
    } else if (needConstraint) {
        valid = CMTimeGetSeconds(asset.duration) <= maxLocalMusicDuration;
        if (!valid) {
            [[MDRecordContext appWindow] makeToast:@"7分钟以上音乐暂时无法上传" duration:1.5f position:CSToastPositionCenter];
        }else {
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset
                                                                              presetName: AVAssetExportPresetAppleM4A];
            exporter.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
            //本地音乐文件的大小（不准确，仅用来限制音乐文件不要过大）
            valid = exporter.estimatedOutputFileLength <= 20 *1024 *1024;
            if (!valid) {
                [[MDRecordContext appWindow] makeToast:@"资源文件过大" duration:1.5f position:CSToastPositionCenter];
            }
        }
    }
    return valid;
}

+ (NSURL *)getMusicLocalPath:(MDBeautyMusic *)musicItem {
    NSURL *localUrl = nil;
    if(musicItem.m_isLocal && musicItem.m_localUrl) {
        localUrl = musicItem.m_localUrl;
    }else{
        NSString *urlString = [MDVideoBackgroundMusicManager getLocalMusicResourcePathWithItem:musicItem];
        localUrl = [urlString isNotEmpty] ? [NSURL fileURLWithPath:urlString] : nil;
    }
    return localUrl;
}

+ (MDMomentMusicListCellModel *)coverMusicItemToCellItem:(MDBeautyMusic *)musicItem {
    MDMomentMusicListCellModel *cellItem = [[MDMomentMusicListCellModel alloc] initWithMusicID:musicItem.m_musicID];
    NSURL *localUrl = [MDBeautyMusicManager getMusicLocalPath:musicItem];
    cellItem.localUrl = localUrl;
    cellItem.dataObj = musicItem;
    return cellItem;
}

//根据URL获取整段timerange
+ (CMTimeRange)getMusicTimeRangeWithURL:(NSURL *)localUrl {
    CMTimeRange timeRange = kCMTimeRangeZero;
    if (localUrl) {
        AVAsset *songAsset = [AVURLAsset assetWithURL:localUrl];
        timeRange = CMTimeRangeMake(kCMTimeZero, songAsset.duration);
    }
    return timeRange;
}

@end
