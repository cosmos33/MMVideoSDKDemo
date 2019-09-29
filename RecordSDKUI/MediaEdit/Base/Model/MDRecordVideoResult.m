//
//  MDRecordVideoResult.m
//  MDChat
//
//  Created by Jichuan on 15/10/27.
//  Copyright © 2015年 sdk.com. All rights reserved.
//

#import "MDRecordVideoResult.h"
@import CoreLocation;
#import "JSONKit.h"

@implementation MDRecordVideoResult

- (instancetype)init {
    self = [super init];
    if (self) {
        self.uuid = @"";
        self.borderID = @"";
        self.recordBorderID = @"";
        self.eventID = @"";
        self.address = @"";
        self.originFeedID = @"";
        self.creationDate = nil;
    }
    return self;
}

- (void)dealloc
{
    self.path = nil;
    self.uuid = nil;
    self.address = nil;
    self.borderID = nil;
    self.eventID = nil;
    self.recordBorderID = nil;
    self.originFeedID = nil;
    self.creationDate = nil;
    self.videoID = nil;
    self.themeID = nil;
    self.publishSource = nil;
    self.filterID = nil;
    self.stickerIds = nil;
    self.decorateTexts = nil;
    self.topicID = nil;
    self.faceID = nil;
    self.topicName = nil;
}

+ (id)resultWithDictionary:(NSDictionary *)dic {
    MDRecordVideoResult *result = [[MDRecordVideoResult alloc] init];
    
    result.isFinished = [dic boolForKey:@"isFinished" defaultValue:NO];
    result.isBeautifySwitchOn = [dic boolForKey:@"isBeautifySwitchOn" defaultValue:NO];
    result.isFrontCamera = [dic boolForKey:@"isFrontCamera" defaultValue:NO];
    result.accessSource = [dic integerForKey:@"accessSource" defaultValue:MDVideoRecordAccessSource_Unkonwn];
    result.isAllowShared = [dic boolForKey:@"isAllowShared" defaultValue:NO];
    result.path = [dic stringForKey:@"path" defaultValue:nil];
    result.uuid = [dic stringForKey:@"uuid" defaultValue:nil];
    result.address = [dic stringForKey:@"address" defaultValue:nil];
    result.borderID = [dic stringForKey:@"borderID" defaultValue:@""];
    result.eventID = [dic stringForKey:@"eventID" defaultValue:@"default"];
    result.recordBorderID = [dic stringForKey:@"recordBorderID" defaultValue:@""];
    result.hasUploaded = [dic boolForKey:@"hasUploaded" defaultValue:NO];
    result.originFeedID = [dic stringForKey:@"originFeedID" defaultValue:nil];
    result.creationDate = [dic dateForKey:@"creationDate" defaultValue:nil];
    
    result.videoID = [dic stringForKey:@"videoID" defaultValue:nil];
    result.isFromShare = [dic boolForKey:@"isFromShare" defaultValue:NO];
    result.topicID = [dic stringForKey:@"topicID" defaultValue:nil];
    result.topicName = [dic stringForKey:@"topicName" defaultValue:nil];
    result.filterID = [dic stringForKey:@"advanced_filter_id" defaultValue:nil];
    result.faceID = [dic stringForKey:@"face_id" defaultValue:nil];
    result.delayCapture = [dic integerForKey:@"delay" defaultValue:0];
    result.hasChooseCover = [dic boolForKey:@"is_choose_cover" defaultValue:NO];
    result.hasVideoSegments = [dic boolForKey:@"is_resume" defaultValue:NO];
    NSString *texts = [dic stringForKey:@"decorator_texts" defaultValue:nil];
    if ([texts isNotEmpty]) {
        result.decorateTexts = [texts objectFromMDJSONString];
    }
    
    NSString *stickers = [dic stringForKey:@"tag_ids" defaultValue:nil];
    if ([stickers isNotEmpty]) {
        result.stickerIds = [stickers objectFromMDJSONString];
    }
    result.hasSpeedEffect = [dic boolForKey:@"variable_speed" defaultValue:NO];
    result.musicId = [dic stringForKey:@"music_id" defaultValue:nil];
    result.hasGraffiti = [dic boolForKey:@"is_graffiti" defaultValue:NO];
    result.isFromAlbum = [dic boolForKey:@"fromalbum" defaultValue:NO];
    result.videoCoverUuid = [dic stringForKey:@"videoCoverUuid" defaultValue:nil];
    result.recordOrientation = [dic boolForKey:@"recordOrientation" defaultValue:NO];
    result.videoRecordSource = [dic integerForKey:@"video_source" defaultValue:0];
    result.beautyFaceLevel = [dic integerForKey:@"beauty_face_level" defaultValue:0];
    result.bigEyeLevel = [dic integerForKey:@"bigeye_level" defaultValue:0];
    result.flashLightState = [dic integerForKey:@"flashlight" defaultValue:0];
    
    NSString *dynamicStickers = [dic stringForKey:@"dynamic_tag_id" defaultValue:nil];
    if ([dynamicStickers isNotEmpty]) {
        result.dynamicStickerIds = [dynamicStickers objectFromJSONString];
    }
    result.specialEffectsTypes = [dic stringForKey:@"special_filter" defaultValue:nil];
    
    result.hasCutVideo = [dic boolForKey:@"video_cut" defaultValue:NO];
    result.isNeedSameStyle = [dic boolForKey:@"is_follow_video" defaultValue:NO];
    result.isLocalMusic = [dic boolForKey:@"is_local_music" defaultValue:NO];
    result.followVideoId = [dic stringForKey:@"follow_video_id" defaultValue:nil];
    result.isCutMusic = [dic boolForKey:@"is_music_cut" defaultValue:NO];
    result.isAlbumVideo = [dic boolForKey:@"is_album_video" defaultValue:NO];
    result.albumVideoAnimateType = [dic integerForKey:@"live_photo_animate" defaultValue:0];
    result.albumVideoPhotoCount = [dic integerForKey:@"live_photo_count" defaultValue:0];

    result.originalFileSize = [dic longLongValueForKey:@"original_file_size" defaultValue:0];
    result.originalVideoNaturalWidth = [dic floatForKey:@"original_video_natural_width" defaultValue:0.0];
    result.originalVideoNaturalHeight = [dic floatForKey:@"original_video_natural_height" defaultValue:0.0];
    result.originalBitRate = [dic floatForKey:@"original_bit_rate" defaultValue:0.0];
    result.originalDuration = [dic floatForKey:@"original_duration" defaultValue:0.0];
    result.originalFrameRate = [dic floatForKey:@"original_frame_rate" defaultValue:0.0];
    result.isOriginalVideoCompress = [dic boolForKey:@"is_original_video_compress" defaultValue:NO];
    result.isOriginalVideoCut = [dic boolForKey:@"is_original_video_cut" defaultValue:NO];
    
    result.editVideoFileSize = [dic longLongValueForKey:@"edit_video_file_size" defaultValue:0];
    result.editVideoNaturalWidth = [dic floatForKey:@"edit_video_natural_width" defaultValue:0.0];
    result.editVideoNaturalHeight = [dic floatForKey:@"edit_video_natural_height" defaultValue:0.0];
    result.editVideoBitRate = [dic floatForKey:@"edit_video_bit" defaultValue:0.0];
    result.editVideoDuration = [dic floatForKey:@"edit_video_duration" defaultValue:0.0];
    result.editVideoFrameRate = [dic floatForKey:@"edit_video_frame_rate" defaultValue:0.0];

    result.videoBitRate = [dic floatForKey:@"video_bit_rate" defaultValue:0.0];
    result.videoFrameRate = [dic floatForKey:@"video_frame_rate" defaultValue:0.0];
    result.duration = [dic integerForKey:@"duration" defaultValue:0];
    result.videoNaturalHeight = [dic floatForKey:@"videoNaturalHeight" defaultValue:320.0];
    result.videoNaturalWidth = [dic floatForKey:@"videoNaturalWidth" defaultValue:320.0];
    result.fileSize = [dic longLongValueForKey:@"fileSize" defaultValue:0];

    return result;
}

+ (NSDictionary *)dictionaryWithResult:(MDRecordVideoResult *)result {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setBool:result.isFinished forKey:@"isFinished"];
    [dic setBool:result.isBeautifySwitchOn forKey:@"isBeautifySwitchOn"];
    [dic setBool:result.isFrontCamera forKey:@"isFrontCamera"];
    [dic setInteger:result.accessSource forKey:@"accessSource"];
    [dic setBool:result.isAllowShared forKey:@"isAllowShared"];
    [dic setString:result.path forKey:@"path"];
    [dic setString:result.uuid forKey:@"uuid"];
    [dic setString:result.address forKey:@"address"];
    [dic setString:result.borderID forKey:@"borderID"];
    [dic setString:result.eventID forKey:@"eventID"];
    [dic setString:result.recordBorderID forKey:@"recordBorderID"];
    [dic setBool:result.hasUploaded forKey:@"hasUploaded"];
    [dic setString:result.originFeedID forKey:@"originFeedID"];
    [dic setObjectSafe:result.creationDate forKey:@"creationDate"];
    
    [dic setString:result.videoID forKey:@"videoID"];
    [dic setBool:result.isFromShare forKey:@"isFromShare"];
    [dic setString:result.topicID forKey:@"topicID"];
    [dic setString:result.topicName forKey:@"topicName"];
    [dic setString:result.filterID forKey:@"advanced_filter_id"];
    [dic setObjectSafe:result.faceID forKey:@"face_id"];
    [dic setInteger:result.delayCapture forKey:@"delay"];
    [dic setBool:result.hasChooseCover forKey:@"is_choose_cover"];
    [dic setBool:result.hasVideoSegments forKey:@"is_resume"];
    
    [dic setString:[result.decorateTexts MDJSONString] forKey:@"decorator_texts"];
    [dic setString:[result.stickerIds MDJSONString] forKey:@"tag_ids"];
    [dic setBool:result.hasSpeedEffect forKey:@"variable_speed"];
    [dic setString:result.musicId forKey:@"music_id"];
    [dic setBool:result.hasGraffiti forKey:@"is_graffiti"];
    [dic setBool:result.isFromAlbum forKey:@"fromalbum"];
    [dic setString:result.videoCoverUuid forKey:@"videoCoverUuid"];
    [dic setBool:result.recordOrientation forKey:@"recordOrientation"];
    [dic setInteger:result.videoRecordSource forKey:@"video_source"];
    [dic setInteger:result.beautyFaceLevel forKey:@"beauty_face_level"];
    [dic setInteger:result.bigEyeLevel forKey:@"bigeye_level"];
    [dic setInteger:result.flashLightState forKey:@"flashlight"];
    [dic setString:[result.dynamicStickerIds MDJSONString] forKey:@"dynamic_tag_id"];
    [dic setBool:result.hasCutVideo forKey:@"video_cut"];
    [dic setBool:result.isNeedSameStyle forKey:@"is_follow_video"];
    [dic setBool:result.isLocalMusic forKey:@"is_local_music"];
    [dic setString:result.followVideoId forKey:@"follow_video_id"];
    [dic setBool:result.isCutMusic forKey:@"is_music_cut"];
    [dic setString:result.specialEffectsTypes forKey:@"special_filter"];
    [dic setBool:result.isAlbumVideo forKey:@"is_album_video"];
    [dic setInteger:result.albumVideoAnimateType forKey:@"live_photo_animate"];
    [dic setInteger:result.albumVideoPhotoCount forKey:@"live_photo_count"];

    [dic setLongLongValue:result.originalFileSize forKey:@"original_file_size"];
    [dic setFloat:result.originalVideoNaturalWidth forKey:@"original_video_natural_width"];
    [dic setFloat:result.originalVideoNaturalHeight forKey:@"original_video_natural_height"];
    [dic setFloat:result.originalBitRate forKey:@"original_bit_rate"];
    [dic setFloat:result.originalDuration forKey:@"original_duration"];
    [dic setFloat:result.originalFrameRate forKey:@"original_frame_rate"];
    [dic setBool:result.isOriginalVideoCompress forKey:@"is_original_video_compress"];
    [dic setBool:result.isOriginalVideoCut forKey:@"is_original_video_cut"];
    
    [dic setLongLongValue:result.editVideoFileSize forKey:@"edit_video_file_size"];
    [dic setFloat:result.editVideoNaturalWidth forKey:@"edit_video_natural_width"];
    [dic setFloat:result.editVideoNaturalHeight forKey:@"edit_video_natural_height"];
    [dic setFloat:result.editVideoBitRate forKey:@"edit_video_bit"];
    [dic setFloat:result.editVideoDuration forKey:@"edit_video_duration"];
    [dic setFloat:result.editVideoFrameRate forKey:@"edit_video_frame_rate"];
    
    [dic setFloat:result.videoBitRate forKey:@"video_bit_rate"];
    [dic setFloat:result.videoFrameRate forKey:@"video_frame_rate"];
    [dic setInteger:result.duration forKey:@"duration"];
    [dic setFloat:result.videoNaturalWidth forKey:@"videoNaturalWidth"];
    [dic setFloat:result.videoNaturalHeight forKey:@"videoNaturalHeight"];
    [dic setLongLongValue:result.fileSize forKey:@"fileSize"];

    return dic;
}

- (NSDictionary *)paramsForUploadVideo
{
    // 统计所需参数,key值应该用服务器约定的值
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:self.uuid forKey:@"uuid"];
    [params setObjectSafe:self.borderID forKey:@"frame"];
    [params setObjectSafe:self.eventID forKey:@"eventid"];
    [params setObjectSafe:@((self.isAllowShared ? 1:0)) forKey:@"permission"];
    [params setObjectSafe:self.address forKey:@"city"];
    
    
    if (self.videoNaturalHeight > 0.0) {
        [params setObjectSafe:@(self.videoNaturalWidth/self.videoNaturalHeight) forKey:@"screenratio"];
    }
    
    //统计参数
    [params setObjectSafe:self.recordBorderID forKey:@"first_frame"];
    [params setObjectSafe:@((self.isBeautifySwitchOn ? 1:0)) forKey:@"uselandscape"];
    [params setObjectSafe:@((self.isFrontCamera ? 1:0)) forKey:@"front_camera"];
    [params setObjectSafe:self.topicID forKey:@"topic_id"];
    [params setObjectSafe:self.filterID forKey:@"advanced_filter_id"];
    [params setObjectSafe:self.faceID forKey:@"face_id"];
    [params setObjectSafe:@(self.delayCapture) forKey:@"delay"];
    [params setObjectSafe:@(self.hasChooseCover ? 1 : 0) forKey:@"is_choose_cover"];
    [params setObjectSafe:@(self.hasVideoSegments ? 1 : 0) forKey:@"is_resume"];

    [params setObjectSafe:[self.decorateTexts MDJSONString] forKey:@"decorator_texts"];
    [params setObjectSafe:[self.stickerIds componentsJoinedByString:@","] forKey:@"tag_ids"];
    [params setObjectSafe:@((self.hasSpeedEffect||self.hasPerSpeedEffect ? 1 : 0)) forKey:@"variable_speed"];
    [params setObjectSafe:self.musicId forKey:@"music_id"];
    [params setObjectSafe:@(self.hasGraffiti ? 1: 0) forKey:@"is_graffiti"];
//    NSInteger isWifi = ([[[MDContext sharedReachManager] reachability] currentNetworkStatus] == MDNetworkStatusType_Wifi) ? 1: 0;
//    [params setObjectSafe:@(isWifi) forKey:@"is_wifi"];

    NSInteger videoSourceType = 0;
    if (self.isFromAlbum) {
        videoSourceType = 2;
    } else if (self.isFromDraft) {
        videoSourceType = 1;
    } else {
        videoSourceType = self.videoRecordSource;
    }
    
    self.videoRecordSource = videoSourceType;
    
    [params setObjectSafe:@(self.videoRecordSource) forKey:@"video_source"];
    [params setObjectSafe:@((self.isFromAlbum ? 1:0)) forKey:@"fromalbum"];
    
    [params setObjectSafe:self.themeID forKey:@"activityid"];
    [params setObjectSafe:@(self.recordOrientation ? 1: 0) forKey:@"is_across_screen"];

    [params setObjectSafe:@(self.beautyFaceLevel) forKey:@"beauty_face_level"];
    [params setObjectSafe:@(self.bigEyeLevel) forKey:@"bigeye_level"];
    [params setObjectSafe:@(self.flashLightState) forKey:@"flashlight"];
    [params setObjectSafe:[self.dynamicStickerIds componentsJoinedByString:@","] forKey:@"dynamic_tag_id"];
    [params setObjectSafe:@(self.hasCutVideo) forKey:@"video_cut"];
    [params setObjectSafe:@(self.isNeedSameStyle) forKey:@"is_follow_video"];
    [params setObjectSafe:self.isLocalMusic?@(1):@(0) forKey:@"is_local_music"];
    [params setObjectSafe:@(self.thinBodayLevel) forKey:@"thin_body_level"];
    [params setObjectSafe:@(self.longLegLevel) forKey:@"long_leg_level"];
    [params setString:self.specialEffectsTypes forKey:@"special_filter"];
    [params setObjectSafe:@(self.isAlbumVideo ? 1:0) forKey:@"is_album_video"];

    //相册本地上传
    [params setLongLongValue:self.originalFileSize forKey:@"original_file_size"];
    [params setFloat:self.originalVideoNaturalWidth forKey:@"original_video_natural_width"];
    [params setFloat:self.originalVideoNaturalHeight forKey:@"original_video_natural_height"];
    [params setFloat:(self.originalBitRate/1024/1024) forKey:@"original_bit_rate"]; //单位:Mbps/s
    [params setFloat:self.originalDuration forKey:@"original_duration"];
    [params setFloat:self.originalFrameRate forKey:@"original_frame_rate"];
    [params setBool:self.isOriginalVideoCompress forKey:@"is_original_video_compress"];
    [params setBool:self.isOriginalVideoCut forKey:@"is_original_video_cut"];
    
    //进编辑页
    [params setLongLongValue:self.editVideoFileSize forKey:@"edit_video_file_size"];
    [params setFloat:self.editVideoNaturalWidth forKey:@"edit_video_natural_width"];
    [params setFloat:self.editVideoNaturalHeight forKey:@"edit_video_natural_height"];
    [params setFloat:(self.editVideoBitRate/1024/1024) forKey:@"edit_video_bit"]; //单位:Mbps/s
    [params setFloat:self.editVideoDuration forKey:@"edit_video_duration"];
    [params setFloat:self.editVideoFrameRate forKey:@"edit_video_frame_rate"];
    
    //导出视频
    [params setFloat:(self.videoBitRate/1024/1024) forKey:@"video_bit_rate"]; //单位:Mbps/s
    [params setFloat:self.videoFrameRate forKey:@"video_frame_rate"];
    [params setObjectSafe:@(self.duration) forKey:@"duration"];
    [params setObjectSafe:@(self.videoNaturalWidth) forKey:@"width"];
    [params setObjectSafe:@(self.videoNaturalHeight) forKey:@"height"];
    [params setLongLongValue:self.fileSize forKey:@"file_size"];

    return params;
}

@end

