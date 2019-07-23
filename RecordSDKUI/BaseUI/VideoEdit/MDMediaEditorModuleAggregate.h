//
//  MDMediaEditorModuleAggregate.h
//  MDChat
//
//  Created by 符吉胜 on 2017/8/24.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class MDDynamicSticker;
@class MDMomentTextSticker;
@class MDBaseSticker;
@class MDMomentTextSticker;
@class MDMusicCollectionItem;

@protocol MDMediaEditorModuleAggregateDelegate <NSObject>

//滤镜相关
- (void)willShowFilterDrawer;
- (void)didHideFilterDrawer;
- (void)didSelectedBeautySetting:(NSDictionary *)beautySettingDict;

//贴纸相关
- (void)willShowStickerChooseView;
- (void)didHidestickerChooseViewWithSticker:(MDDynamicSticker *)aSticker
                                     center:(CGPoint)center
                                   errorMsg:(NSString *)errorMsg;

//文字编辑相关
- (void)willShowTextEditingView;
- (void)didEndEditingWithTextSticker:(MDMomentTextSticker *)aTextSticker errorMsg:(NSString *)errorMsg;

//配乐相关
- (void)willShowMusicPicker;
- (void)didCloseMusicPickerViewWithSelectedMusicTitle:(NSString *)title;

//封面选取相关
- (void)willShowThumbPicker;
- (void)didPickAThumbImage:(BOOL)isPick;

//涂鸦相关
- (void)willShowGraffitiEditor;
- (void)didShowGraffitiEditor;
- (void)willHideGraffitiEditor;
- (void)graffitiEditorUpdateWithCanvasImage:(UIImage *)canvasImage mosaicCanvasImage:(UIImage *)mosaicCanvasImage;

//特效滤镜相关
- (void)willBeginReverseVideoOpertion;
- (void)reverseVideoWithProgress:(CGFloat)progress;
- (void)didEndReverseVideoOpertion;

//变速相关
- (void)willShowSpeedVaryVC;
- (void)didHideSpeedVaryVC;

//话题相关
- (void)willShowTopicSeletedTable;
- (void)topicSelectedManagerDidFinishSelectWithTopicID:(NSString *)aTopicID topicName:(NSString *)aTopicName;
- (void)topicSelectedManagerDidClose;
- (void)topicListDidRefresh;

//导出相关: isSaveMode yes为保存 no为导出
- (void)willBeginExportForSaveMode:(BOOL)isSaveMode;
- (void)exportingWithProgress:(CGFloat)progress;
- (void)willExportFinishWithVideoURL:(NSURL *)videoURL error:(NSError *)error;
- (void)didExportFinishWithVideoURL:(NSURL *)videoURL
                   originVideoCover:(UIImage *)originVideoCover
              originVideoCoverIndex:(NSInteger)originVideoCoverIndex;

- (void)didCutVideoFinish; //裁剪视频完成

//下载相关
- (void)didSaveVideoFinishWithVideoURL:(NSURL *)videoURL completeBlock:(void(^)())completBlock;

@end


@protocol MDMediaEditorModuleControllerDelegate <NSObject>

//最大上传时长
- (CGFloat)maxUploadDuration;
//话题view的位置
- (CGPoint)topicLayoutOrigin;
//需要往视频里合成的图片,saveMode:是否是保存操作
- (UIImage *)rendenOverlayImageForSaveMode:(BOOL)saveMode;
//是否需要添加水印
- (BOOL)isNeedWaterMarkWithSaveMode:(BOOL)saveMode;
//截图的封面最大尺寸
- (CGFloat)maxThumbImageSize;
//进入编辑页时带入的配乐URL
- (NSURL *)originMisicUrl;
//是否从相册选取
- (BOOL)isFromAlbum;
//是否可以使用高清晰度策略(即视频不压缩策略)
- (BOOL)supportHighResolutionStrategy;

@end

@interface MDMediaEditorModuleAggregate : NSObject

@property (nonatomic,weak) id<MDMediaEditorModuleAggregateDelegate>     delegate;

@property (nonatomic,assign,readonly) CGRect                            videoRenderFrame;
@property (nonatomic,assign,readonly) CGSize                            videoSize;

@property (nonatomic,strong,readonly) NSMutableArray                    *stickers;
@property (nonatomic,strong,readonly) NSMutableArray                    *textStickers;
@property (nonatomic,assign,readonly) BOOL                              hasGraffiti;
@property (nonatomic,assign,readonly) BOOL                              hasSpeedEffect;
@property (nonatomic,copy  ,readonly) NSString                          *musicId;
@property (nonatomic,assign,readonly) BOOL                              isLocalMusic;
@property (nonatomic,assign,readonly) BOOL                              isMusicCut;

- (instancetype)initWithController:(UIViewController<MDMediaEditorModuleControllerDelegate> *)viewController;
- (void)configDocumentWithVideoAsset:(AVAsset *)videoAsset
                      videoTimeRange:(CMTimeRange)videoTimeRange
                            musicURL:(NSURL *)musicURL
                      musicTimeRange:(CMTimeRange)musicTimeRange
                           musicItem:(MDMusicCollectionItem *)musicItem;

//播放相关
- (void)activatePlayer;
- (void)applySoudPitchFunction:(NSURL *)soundPitchURL; //应用变声功能
- (void)play;
- (void)pause;

//滤镜相关(瘦身)
- (void)activateFilterDrawer2;
- (void)activateFilterDrawer;
- (void)hideFilterDrawer;

//贴纸相关
- (void)activateSticker;
- (void)removeASticker:(MDBaseSticker *)aSticker;

//文字编辑相关
- (void)activateTextEdit;
- (void)removeATextSticker:(MDMomentTextSticker *)aTextSticker;
- (void)configTextEditViewDefaultText:(NSString *)defaultText colorIndex:(NSInteger)colorIndex;

//配乐相关
- (void)activateMusicPicker;
- (void)hideMusicPicker;

//封面选取相关
- (void)activateThumbPicker;
- (void)preloadThumbs;
- (UIImage *)defaultLargeCoverImage;

//涂鸦相关
- (void)activateGraffitiEditor;

//变速相关
- (void)activateSpeedVaryVc;

//特效滤镜相关
- (void)preloadSpecialImage;
- (void)activateSpecialEffectsVc;
- (void)cancelReverseOpertion;
- (NSArray *)specialEffectsTypeArray;

//导出相关
- (void)exportVideo;
- (void)cancelExport;

//下载相关
- (void)saveVideo;

//辅助方法
- (BOOL)isDoingExportOperation;
- (BOOL)checkHasEditedVideo;
//返回是否在编辑页修改过
- (BOOL)checkHasChangeVideo;

@end
