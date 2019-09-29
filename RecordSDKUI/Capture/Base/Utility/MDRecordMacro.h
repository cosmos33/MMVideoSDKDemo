//
//  MDRecordMacro.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/1/31.
//  Copyright © 2019 sunfei. All rights reserved.
//

#ifndef MDRecordMacro_h
#define MDRecordMacro_h

#import "MDRecordHeader.h"
#import "MDRecordContext.h"

#define IS_IPHONE_X [UIUtility isIPhoneX]
#define HOME_INDICATOR_HEIGHT [MDRecordContext homeIndicatorHeight]
#define STATUS_BAR_HEIGHT [MDRecordContext statusBarHeight]
#define NAV_BAR_HEIGHT 44.f
#define SCREEN_TOP_INSET (STATUS_BAR_HEIGHT + NAV_BAR_HEIGHT)
#define SAFEAREA_TOP_MARGIN      SCREEN_TOP_INSET               ///< 安全区域上方高度

#define kVideoBackgroundMusicPath    [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/VideoBackgroundMusic/"]
//变脸资源总路径
#define kFaceDecorationPath         [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/Face_Decoration"]

#ifdef DEBUG
#define MMLOG(...) NSLog(__VA_ARGS__)
#else
#define MMLOG(...)
#endif

typedef NS_ENUM(NSInteger,MDVideoRecordAccessSource) {
    MDVideoRecordAccessSource_Unkonwn,
    MDVideoRecordAccessSource_Chat,
    MDVideoRecordAccessSource_Profile,
    MDVideoRecordAccessSource_Feed,             //图片 & 视频
    MDVideoRecordAccessSource_Feed_photo,       //只能发视频
    MDVideoRecordAccessSource_Feed_video,       //只能发图片
    MDVideoRecordAccessSource_GroupFeed,
    MDVideoRecordAccessSource_QuickMatch,       //点点
    
    MDVideoRecordAccessSource_FeedDraft,
    MDVideoRecordAccessSource_ChatDraft,
    MDVideoRecordAccessSource_QVProfile,
    MDVideoRecordAccessSource_MK,               //从MK调起
    
    MDVideoRecordAccessSource_ARPet,
    
    MDVideoRecordAccessSource_AlbumVideo,       //影集
    MDVideoRecordAccessSource_AlbumVideoChoosePicture, //影集选照片
    MDVideoRecordAccessSource_BackGround,        //背景
    
    MDVideoRecordAccessSource_SoulMatch,      //合拍
    MDVideoRecordAccessSource_RegLogin,      // 注册头像用户增长新增。没有高级拍摄
    
};

typedef NS_ENUM(NSUInteger, MDUnifiedRecordLevelType) {
    MDUnifiedRecordLevelTypeAsset   = 0,                                //相册
    MDUnifiedRecordLevelTypeNormal  = 1,                                //普通拍摄
    MDUnifiedRecordLevelTypeHigh    = 2,                                //高级拍摄
    MDUnifiedRecordLevelTypeDefault = MDUnifiedRecordLevelTypeNormal
};

typedef NS_ENUM(NSUInteger, MDAssetAlbumLevelType){
    MDAssetAlbumLevelTypeAll = 0,           //相册帧
    MDAssetAlbumLevelTypeVideo = 1,         //视频帧
    MDAssetAlbumLevelTypeAlbumVideo = 2,    //影集帧
    MDAssetAlbumLevelTypePortrait = 3,      //人像帧
    MDAssetAlbumLevelTypeSelfie = 4,        //自拍帧
};

typedef NS_ENUM(NSInteger,MDVideoRecordCountDownType) {
    MDVideoRecordCountDownType_None = 0,
    MDVideoRecordCountDownType_3    = 3,
    MDVideoRecordCountDownType_10   = 10,
};

// 相片的来源
typedef NS_ENUM(NSInteger, MDRegLoginSelectImageType) {
    MDRegLoginSelectImageTypeTakeNone = 0,
    MDRegLoginSelectImageTypeTakePhoto , // 拍摄器
    MDRegLoginSelectImageTypePickerSelfie, // 自拍
    MDRegLoginSelectImageTypePickerPortraits, // 人像
    MDRegLoginSelectImageTypePickerAllAlbum, //所有相册
};


typedef unsigned long long MDVideoFileSize;

#define ALL_VIEW_BACKGROUND_COLOR                       RGBCOLOR(244,243,242)

#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
//除资料以外其他场景允许上传的最大时长
static const NSTimeInterval kMaxUploadDurationForGeneralScene = 60.0f;

#define NAV_BAR_HEIGHT 44.f

#define kRecordTipOfFace                @"face"
#define kRecordTipOfMusic               @"music"
#define kRecordTipOfStaticStiker        @"static_sticker"
#define kRecordTipOfDynamicStiker       @"dynamic_sticker"
#define kRecordTipOfFilter              @"filter"
#define kRecordTipOfCover               @"cover"


#define kRecordTipOfThin                @"thin"
#define kRecordTipOfVideoEditThin       @"videoEditThin"
#define kRecordTipOfImageEditThin       @"imageEditThin"

#define kRecordTipOfSpecialEffects      @"specialEffects"


#define kFaceClassIndentifierOfMy @"RecordSDK_MY_FACE_CLASS"

#define NTF_MUSIC_HIDE_GLOBAL_COVER @"NTF_MUSIC_HIDE_GLOBAL_COVER"
#define NTF_MUSIC_SHOW_GLOBAL_COVER @"NTF_MUSIC_SHOW_GLOBAL_COVER"

#define kCancelCaptureTipTop (MDScreenHeight - 200 - SAFEAREA_BOTTOM_MARGIN)
#define SAFEAREA_BOTTOM_MARGIN   HOME_INDICATOR_HEIGHT          ///< 安全区域下方高度

//默认的录制最短时长（只有大于才可编辑）
static const NSTimeInterval kDefaultRecordMinDuration = 2.0f;
static CGFloat kLeastMusicDuration  =  kDefaultRecordMinDuration;

//资料页允许上传的最大时长
static const NSTimeInterval kMaxUploadDurationForProfileEdit = 10.0f;

//普通拍摄最大时长
static const NSTimeInterval kMaxVideoDurationForNormalLevel = 20.0f;

//高级拍摄最大时长
static const NSTimeInterval kMaxVideoDurationForHighLevel = 60.0f;

//每段可录的最短时长
static const NSTimeInterval kRecordSegmentMinDuration = 1.0f;

//本地可选取视频时的最大时长
static const NSTimeInterval kMaxPickerLocalVideoDuration = 60.0f *5;

#define kAlbumVideoPictureMaxCount           10
#define kAlbumVideoPictureMinCount           2

typedef void(^MDVideoRecordCompleteBlock)(id result);
typedef void(^MDPhotoTypeSelectedCompleteBlock)(MDRegLoginSelectImageType type);

#endif /* MDRecordMacro_h */
