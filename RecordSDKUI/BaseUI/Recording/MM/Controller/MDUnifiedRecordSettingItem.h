//
//  MDUnifiedRecordSettingItem.h
//  MDChat
//
//  Created by 符吉胜 on 2017/6/12.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDMusicCollectionItem.h"
#import "MDRecordHeader.h"

@class MDQuestionInfo;

typedef enum
{
    MDAssetPickerTypeFeed,
    MDAssetPickerTypeChat,
    MDAssetPickerTypePreview//直接进预览页
}MDAssetPickerType;

typedef enum
{
    MDAssetMediaTypeAll,
    MDAssetMediaTypeOnlyPhoto,
    MDAssetMediaTypeOnlyVideo
}MDAssetMediaType;

@interface MDUnifiedRecordSettingItem : NSObject

#pragma mark -  相册参数
@property (nonatomic, readwrite) NSInteger                  selectionLimit;
@property (nonatomic, assign) NSInteger                     totalLimit;
@property (nonatomic, assign) MDAssetPickerType             type;
@property (nonatomic, assign) MDAssetMediaType              assetMediaType;

#pragma mark -  视频参数

//拍摄来源
@property (nonatomic, assign) MDVideoRecordAccessSource     accessSource;
//拍摄类型
@property (nonatomic, assign) MDUnifiedRecordLevelType      levelType;
//相册页面需要定位到的帧(需要保证有这个帧)
@property (nonatomic, assign) MDAssetAlbumLevelType         assetLevelType;
//只有影集帧
@property (nonatomic, assign) BOOL                          onlyVideoAlbum;
//完成回调
@property (nonatomic,   copy) MDVideoRecordCompleteBlock    completeHandler;
//选择图片途径回调,打点用
@property (nonatomic,   copy) MDPhotoTypeSelectedCompleteBlock photoTypeSelectedCompleted;

//禁止录制的alert
@property (nonatomic,   copy) NSString                      *alertForForbidRecord;
//禁止拍照的alert
@property (nonatomic,   copy) NSString                      *alertForForbidPicture;
//宽高比不符合的alert
@property (nonatomic,   copy) NSString                      *alertForRatioNotSuitable;
//视频宽高比最大限制(不包含）
@property (nonatomic, assign) CGFloat                       maxWHRatioForVideoSize;
//视频宽高比最小限制(不包含）
@property (nonatomic, assign) CGFloat                       minWHRatioForVideoSize;
//视屏时长小于最短限制时长的alert
@property (nonatomic,   copy) NSString                      *alertForDurationTooShort;
//是否禁止横屏拍摄
@property (nonatomic, assign) BOOL                          forbidHorizontalRecord;
//是否需要加水印
@property (nonatomic, assign) BOOL                          needWaterMark;
//裁剪的图片宽高比
@property (nonatomic, assign) CGFloat                       imageClipScale;

//配乐id
@property (nonatomic, strong) MDMusicCollectionItem         *musicItem;
//活动id
@property (nonatomic,   copy) NSString                      *themeId;
//话题
@property (nonatomic,   copy) NSString                      *topicId;
//变脸id
@property (nonatomic,   copy) NSString                      *faceId;
//变脸分类id
@property (nonatomic,   copy) NSString                      *faceClassId;
//变脸资源路径
@property (nonatomic,   copy) NSString                      *faceZipUrlStr;

//具体某个场景下允许上传的最短时长
@property (nonatomic, assign) NSTimeInterval                minUploadDurationOfScene;
//具体某个场景下允许上传的最大时长 （视频裁剪也使用这个限制）
@property (nonatomic, assign) NSTimeInterval                maxUploadDurationOfScene;
//随goto定义的可配置普通最大录制时长s
@property (nonatomic, assign) NSTimeInterval                costumMaxDurationOfNormal;
//随goto定义的可配置高级最大录制时长s
@property (nonatomic, assign) NSTimeInterval                costumMaxDurationOfHigh;
//话题是否可更改
@property (nonatomic, assign) BOOL                          lockTopic;
//隐藏话题入口
@property (nonatomic, assign) BOOL                          hideTopicEntrance;

//完成按钮文案
@property (nonatomic, copy) NSString                *doneBtnText;

//是否允许拍同款逻辑
@property (nonatomic, assign) BOOL                          isAllowedSameStyle;
//从哪个视频进入拍摄器
@property (nonatomic, copy) NSString                        *followVideoId;
//8.9.5相册页面是否能展示长腿瘦身的提示
@property (nonatomic, assign) BOOL                          disableShowTip;

+ (instancetype)defaultConfigForSoulMatch;
+ (instancetype)defaultConfigForQuickMatch;
+ (instancetype)defaultConfigForProfileEdit;
+ (instancetype)defaultConfigForChat;
+ (instancetype)defaultConfigForSendFeed;
+ (instancetype)defaultConfigForSendFeedOnlyPhoto;
+ (instancetype)defaultConfigForSendFeedOnlyVideo;
+ (instancetype)defaultConfigForSendGroupFeed;
+ (instancetype)defaultConfigForShopChat;
+ (instancetype)defaultConfigForQuickVideoProfileEdit;
+ (instancetype)defaultConfigForMK;
+ (instancetype)defaultConfigForVChatBackground;
+ (instancetype)defaultConfigForVChatSuperRoomCover;

@end
