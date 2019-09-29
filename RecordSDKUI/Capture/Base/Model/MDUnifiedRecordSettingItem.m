//
//  MDUnifiedRecordSettingItem.m
//  MDChat
//
//  Created by 符吉胜 on 2017/6/12.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordSettingItem.h"
#define kLimitFeedNumber  9

@interface MDUnifiedRecordSettingItem()


@end

@implementation MDUnifiedRecordSettingItem

- (instancetype)init
{
    if (self = [super init]) {
        _minUploadDurationOfScene = 2.0f;
        _maxWHRatioForVideoSize = MAXFLOAT;
        _minWHRatioForVideoSize = 0;
        _needWaterMark = NO; //[[[MDContext currentUser] dbStateHoldProvider] needAddWaterMark];
        _imageClipScale = 1.0;
    }
    return self;
}

+ (instancetype)defaultConfigForSoulMatch
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_SoulMatch;
    settingItem.hideTopicEntrance = YES;
    settingItem.alertForForbidRecord = @"合拍头像暂不支持视频头像";
    settingItem.doneBtnText = @"";
    
    settingItem.selectionLimit = 1;
    settingItem.totalLimit = 1;
    settingItem.type = MDAssetPickerTypeFeed;
    settingItem.assetMediaType = MDAssetMediaTypeOnlyPhoto;
    
    return settingItem;
}

+ (instancetype)defaultConfigForQuickMatch
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_QuickMatch;
    settingItem.hideTopicEntrance = YES;
    settingItem.alertForForbidRecord = @"点点封面暂不支持视频头像";
    settingItem.doneBtnText = @"";
    
    settingItem.selectionLimit = 1;
    settingItem.totalLimit = 1;
    settingItem.type = MDAssetPickerTypeFeed;
    settingItem.assetMediaType = MDAssetMediaTypeOnlyPhoto;
    
    return settingItem;
}

+ (instancetype)defaultConfigForProfileEdit
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_Profile;
    settingItem.hideTopicEntrance = YES;
    settingItem.maxUploadDurationOfScene = kMaxUploadDurationForProfileEdit;
    settingItem.costumMaxDurationOfNormal = kMaxUploadDurationForProfileEdit;
    settingItem.costumMaxDurationOfHigh  = kMaxUploadDurationForProfileEdit;
    settingItem.doneBtnText = @"完成";
    
    settingItem.selectionLimit = 1;
    settingItem.totalLimit = 1;
    settingItem.type = MDAssetPickerTypeFeed;
    settingItem.assetMediaType = MDAssetMediaTypeAll;
    
    return settingItem;
}

+ (instancetype)defaultConfigForQuickVideoProfileEdit
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_QVProfile;
    settingItem.hideTopicEntrance = YES;
    settingItem.maxUploadDurationOfScene = kMaxUploadDurationForGeneralScene;
    settingItem.costumMaxDurationOfNormal = kMaxUploadDurationForGeneralScene;
    settingItem.needWaterMark = NO;
    settingItem.costumMaxDurationOfHigh  = kMaxUploadDurationForGeneralScene;
    settingItem.alertForDurationTooShort = @"视频时长最短需要5s";
    settingItem.alertForRatioNotSuitable = @"视频介绍仅支持竖屏9:16视频";
    settingItem.minUploadDurationOfScene = 5.0;
    settingItem.minWHRatioForVideoSize = 0.46;
    settingItem.maxWHRatioForVideoSize = 0.57;
    settingItem.doneBtnText = @"";
    
    settingItem.selectionLimit = 1;
    settingItem.totalLimit = 1;
    settingItem.type = MDAssetPickerTypeFeed;
    return settingItem;
}

+ (instancetype)defaultConfigForChat
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_Chat;
    settingItem.hideTopicEntrance = YES;
    settingItem.maxUploadDurationOfScene = kMaxUploadDurationForGeneralScene;
    settingItem.doneBtnText = @"发送";
    settingItem.needWaterMark = NO;
    
    settingItem.selectionLimit = 9;
    settingItem.totalLimit = 9;
    settingItem.type = MDAssetPickerTypeChat;
    settingItem.assetMediaType = MDAssetMediaTypeAll;
    
    return settingItem;
}

+ (instancetype)defaultConfigForSendFeed
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_Feed;
    settingItem.hideTopicEntrance = NO;
    settingItem.maxUploadDurationOfScene = kMaxUploadDurationForGeneralScene;
    settingItem.doneBtnText = @"完成";
    
    settingItem.selectionLimit = kLimitFeedNumber;
    settingItem.totalLimit = kLimitFeedNumber;
    settingItem.type = MDAssetPickerTypeFeed;
    settingItem.assetMediaType = MDAssetMediaTypeAll;
    
    return settingItem;
}

+ (instancetype)defaultConfigForSendFeedOnlyPhoto
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_Feed_photo;
    settingItem.hideTopicEntrance = NO;
    settingItem.alertForForbidRecord = @"不支持视频录制";
    settingItem.doneBtnText = @"完成";
    
    settingItem.selectionLimit = kLimitFeedNumber;
    settingItem.totalLimit = kLimitFeedNumber;
    settingItem.type = MDAssetPickerTypeFeed;
    settingItem.assetMediaType = MDAssetMediaTypeOnlyPhoto;
    
    return settingItem;
}

+ (instancetype)defaultConfigForSendFeedOnlyVideo
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_Feed_video;
    settingItem.hideTopicEntrance = NO;
    settingItem.maxUploadDurationOfScene = kMaxUploadDurationForGeneralScene;
    settingItem.alertForForbidPicture = @"不支持拍照";
    settingItem.doneBtnText = @"完成";
    
    settingItem.selectionLimit = kLimitFeedNumber;
    settingItem.totalLimit = kLimitFeedNumber;
    settingItem.type = MDAssetPickerTypeFeed;
    settingItem.assetMediaType = MDAssetMediaTypeOnlyVideo;
    
    return settingItem;
}

+ (instancetype)defaultConfigForSendGroupFeed
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_GroupFeed;
    settingItem.hideTopicEntrance = YES;
    settingItem.doneBtnText = @"完成";
    settingItem.alertForForbidRecord = @"不支持上传视频";
    
    settingItem.selectionLimit = kLimitFeedNumber;
    settingItem.totalLimit = kLimitFeedNumber;
    settingItem.type = MDAssetPickerTypeFeed;
    settingItem.assetMediaType = MDAssetMediaTypeOnlyPhoto;
    
    return settingItem;
}

+ (instancetype)defaultConfigForShopChat
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_Chat;
    settingItem.hideTopicEntrance = YES;
    settingItem.doneBtnText = @"完成";
    settingItem.alertForForbidRecord = @"不支持上传视频";
    
    settingItem.selectionLimit = 9;
    settingItem.totalLimit = 9;
    settingItem.type = MDAssetPickerTypeChat;
    settingItem.assetMediaType = MDAssetMediaTypeOnlyPhoto;
    
    return settingItem;
}

+ (instancetype)defaultConfigForMK
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    settingItem.accessSource = MDVideoRecordAccessSource_MK;
    settingItem.selectionLimit = 1;
    settingItem.totalLimit = 1;
    settingItem.doneBtnText = @"完成";
    settingItem.alertForDurationTooShort = @"视频过短";
    
    return settingItem;
}

+ (instancetype)defaultConfigForVChatBackground
{
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_BackGround;
    settingItem.hideTopicEntrance = YES;
    settingItem.doneBtnText = @"完成";
    settingItem.alertForForbidRecord = @"不支持上传视频";
    
    settingItem.selectionLimit = 1;
    settingItem.totalLimit = 1;
    settingItem.type = MDAssetPickerTypeChat;
    settingItem.assetMediaType = MDAssetMediaTypeOnlyPhoto;
    
    return settingItem;
}

+ (instancetype)defaultConfigForVChatSuperRoomCover {
    MDUnifiedRecordSettingItem *settingItem = [[MDUnifiedRecordSettingItem alloc] init];
    
    settingItem.accessSource = MDVideoRecordAccessSource_Profile;
    settingItem.hideTopicEntrance = YES;
    settingItem.doneBtnText = @"完成";
    settingItem.alertForForbidRecord = @"不支持上传视频";
    
    settingItem.selectionLimit = 1;
    settingItem.totalLimit = 1;
    settingItem.type = MDAssetPickerTypeChat;
    settingItem.assetMediaType = MDAssetMediaTypeOnlyPhoto;
    
    return settingItem;
}

@end

