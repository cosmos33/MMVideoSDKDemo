//
//  MDRecordVideoResult.h
//  MDChat
//
//  Created by Jichuan on 15/10/27.
//  Copyright © 2015年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MDRecordHeader.h"
/*
 * 录制返回结果
 */
@interface MDRecordVideoResult : NSObject


/* 是否完成录制 */
@property (nonatomic, assign) BOOL isFinished;

/* 是否开启了一键美化 */
@property (nonatomic, assign) BOOL isBeautifySwitchOn;

/* 是否使用了前置摄像头 */
@property (nonatomic, assign) BOOL isFrontCamera;

/* 视频地理位置 */
@property (nonatomic, copy) NSString *address;

/* 导出使用视频边框ID. */
@property (nonatomic, copy) NSString *borderID;

/* 导出使用边框所在的活动ID */
@property (nonatomic, copy) NSString *eventID;

/* 拍摄时使用的视频边框ID */
@property (nonatomic, copy) NSString *recordBorderID;

/* 来源动态的ID */
@property (nonatomic, copy) NSString *originFeedID;

@property (nonatomic, assign) BOOL  isFromDraft;


/*
 新增字段
 */
//视频信息
/* 视频id */
@property (nonatomic, copy) NSString *videoID;

/* 视频uuid */
@property (nonatomic, copy) NSString *uuid;

/* 视频路径 */
@property (nonatomic, copy) NSString *path;

/* 文件大小 */
@property (nonatomic, assign) MDVideoFileSize fileSize;

/* 视频文件创建时间 */
@property (nonatomic, retain) NSDate *creationDate;

/* 视频时长 */
@property (nonatomic, assign) float duration;

/* 视频宽高 */
@property (nonatomic, assign) CGFloat videoNaturalWidth;
@property (nonatomic, assign) CGFloat videoNaturalHeight;

/* 视频码率 */
@property (nonatomic, assign) CGFloat videoBitRate;
/* 视频帧率 */
@property (nonatomic, assign) CGFloat videoFrameRate;

/* 下发封面 */
@property (nonatomic, strong) NSString *videoCoverUrl;
/* 封面uuid 下载的时候必须通过uuid取路径 */
@property (nonatomic, strong) NSString *videoCoverUuid;

//业务相关
/* 是否允许被分享 */
@property (nonatomic, assign) BOOL isAllowShared;

/* 录制来源 */
@property (nonatomic, assign) MDVideoRecordAccessSource accessSource;

/* 是否已经上传 */
@property (nonatomic, assign) BOOL hasUploaded;

@property (nonatomic, assign) BOOL  isFromAlbum;

//统计信息
//主题id（goto传递）
@property (nonatomic, strong) NSString      *themeID;

//是否有涂鸦
@property (nonatomic, assign) BOOL          hasGraffiti;

//贴纸id数组
@property (nonatomic, strong) NSMutableArray *stickerIds;

//文字贴纸
@property (nonatomic, strong) NSMutableArray *decorateTexts;

//变脸素材id
@property (nonatomic, strong) NSString      *faceID;

//话题id
@property (nonatomic, strong) NSString      *topicID;

//话题名字
@property (nonatomic, strong) NSString      *topicName;

//发布来源
@property (nonatomic, strong) NSString *publishSource;

//是否选择封面
@property (nonatomic, assign) BOOL     hasChooseCover;

@property (nonatomic, assign) UIImage * videoCoverImage;

//是否断点续传
@property (nonatomic, assign) BOOL     hasVideoSegments;

//延时拍摄
@property (nonatomic, assign) NSInteger delayCapture;

//音乐id
@property (nonatomic, copy) NSString    *musicId;

//是否变速
@property (nonatomic, assign) BOOL      hasSpeedEffect;
@property (nonatomic, assign) BOOL      hasPerSpeedEffect; //是否前置变速

//是否是转发
@property (nonatomic, assign) BOOL      isFromShare;
//横屏录制
@property (nonatomic, assign) BOOL      recordOrientation;
@property (nonatomic, assign) BOOL      longVideoRecord;

#pragma mark - 8.0新增统计字段
//滤镜id
@property (nonatomic, strong) NSString  *filterID;
//高级拍摄为10
@property (nonatomic, assign) NSInteger videoRecordSource;
//瘦身等级
@property (nonatomic, assign) NSInteger thinBodayLevel;
//长腿等级
@property (nonatomic, assign) NSInteger longLegLevel;
//美白磨皮等级
@property (nonatomic, assign) NSInteger beautyFaceLevel;
//大眼瘦脸等级
@property (nonatomic, assign) NSInteger bigEyeLevel;
//闪光灯状态
@property (nonatomic, assign) NSInteger flashLightState;
//动态贴纸id
@property (nonatomic, strong) NSMutableArray        *dynamicStickerIds;
//视频是否被裁剪过
@property (nonatomic, assign) BOOL                  hasCutVideo;

//标志是否是重新发布的视频
@property (nonatomic, assign) BOOL                  isRetrySend;

//是否需要拍同款
@property (nonatomic, assign) BOOL                  isNeedSameStyle;
//是否是本地音乐
@property (nonatomic, assign) BOOL                  isLocalMusic;
//从哪个视频进入拍摄器
@property (nonatomic, copy) NSString                *followVideoId;
//音乐是否被裁剪
@property (nonatomic, assign) BOOL                  isCutMusic;
//特效滤镜type
@property (nonatomic, copy) NSString                *specialEffectsTypes;


/********************** 影集相关 **********************/
//是否是影集
@property (nonatomic, assign) BOOL                  isAlbumVideo;
//影集动效类型
@property (nonatomic, assign) NSInteger             albumVideoAnimateType;
//影集照片张数
@property (nonatomic, assign) NSInteger             albumVideoPhotoCount;

/********************** 相册本地上传 **********************/
//相册源视频大小
@property (nonatomic, assign) MDVideoFileSize originalFileSize;
//相册源视频宽高
@property (nonatomic, assign) CGFloat originalVideoNaturalWidth;
@property (nonatomic, assign) CGFloat originalVideoNaturalHeight;
//相册源视频码率
@property (nonatomic, assign) CGFloat originalBitRate;
//相册源视频时长
@property (nonatomic, assign) CGFloat originalDuration;
//相册源视频帧率
@property (nonatomic, assign) CGFloat originalFrameRate;
//相册源视频是否压缩
@property (nonatomic, assign) BOOL isOriginalVideoCompress;
//相册源视频是否裁切
@property (nonatomic, assign) BOOL isOriginalVideoCut;

/********************** 进入编辑页 **********************/
//进入编辑页视频分辨率
@property (nonatomic, assign) CGFloat editVideoNaturalWidth;
@property (nonatomic, assign) CGFloat editVideoNaturalHeight;
//进入编辑页视频码率
@property (nonatomic, assign) CGFloat editVideoBitRate;
//进入编辑页视频时长
@property (nonatomic, assign) CGFloat editVideoDuration;
//进入编辑页视频帧率
@property (nonatomic, assign) CGFloat editVideoFrameRate;
//进入编辑页视频大小
@property (nonatomic, assign) MDVideoFileSize editVideoFileSize;



+ (id)resultWithDictionary:(NSDictionary *)dic;
+ (NSDictionary *)dictionaryWithResult:(MDRecordVideoResult *)result;

//上传视频时需要上传的参数
- (NSDictionary *)paramsForUploadVideo;

@end

