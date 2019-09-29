//
//  MDMediaEditorSettingItem.h
//  MDChat
//
//  Created by 符吉胜 on 2017/8/28.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDMusicCollectionItem.h"
#import "MDRecordVideoResult.h"

typedef void(^MDVideoEditorCompleteBlock)(id videoInfo);
@interface MDMediaEditorSettingItem : NSObject

@property (nonatomic,   copy) MDVideoEditorCompleteBlock    completeBlock;
@property (nonatomic, strong) MDRecordVideoResult           *videoInfo;

//视频相关信息
@property (nonatomic, strong) AVAsset                       *videoAsset;
@property (nonatomic, assign) CMTimeRange                   videoTimeRange;

//配乐相关信息
@property (nonatomic, strong) MDMusicCollectionItem         *backgroundMusicItem;
@property (nonatomic, strong) NSURL                         *backgroundMusicURL;
@property (nonatomic, assign) CMTimeRange                   backgroundMusicTimeRange;

//不同场景有不同文案
@property (nonatomic,   copy) NSString                      *doneButtonTitle;
//话题是否可更改
@property (nonatomic, assign) BOOL                          lockTopic;
//隐藏话题入口
@property (nonatomic, assign) BOOL                          hideTopicEntrance;
//视频是否被裁剪过
@property (nonatomic, assign) BOOL                          hasCutVideo;
//变声过后的音频URL，用以替代原声音频
@property (nonatomic, strong) NSURL                         *soundPitchURL;
//允许上传的最大时长
@property (nonatomic, assign) NSTimeInterval                maxUploadDuration;
//是否需要加水印
@property (nonatomic, assign) BOOL                          needWaterMark;
//封面的最大尺寸
@property (nonatomic, assign) CGFloat                       maxThumbImageSize;
//录制过程中是否检测到人脸
@property (nonatomic, assign) BOOL                          isFaceCaptured;
//录制过程中是否检测到光膀子
@property (nonatomic, assign) BOOL                          isDetectorBareness;
//视频是否是支持多段录制合成的
@property (nonatomic, assign) BOOL                          supportMultiSegmentsRecord;
// AR宠物需要再编辑页面增添气泡提示
//@property (nonatomic, strong) MMArpetResult              *qualityResult;

@property (nonatomic, assign) BOOL                          fromAlbum;

@end
