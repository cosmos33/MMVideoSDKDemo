//
//  MDAlbumVideoDynamicEffectModel.h
//  MomoChat
//
//  Created by sunfei on 2018/9/12.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDMusicCollectionItem, MDDownLoaderModel;

@interface MDAlbumVideoDynamicEffectModel : NSObject

+ (instancetype)randomEffectModel;
- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon selectedIcon:(UIImage *)selectedIcon animationType:(NSString *)animationType;

@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) UIImage *selectedIcon;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *animationType;

// 绑定音频
@property (nonatomic , readonly) MDMusicCollectionItem     *musicItem;

// associated with downloading
@property (nonatomic, readonly) MDDownLoaderModel *downloaderModel;
@property (nonatomic, readonly) BOOL isNeedDownload;
@property (nonatomic, readonly) BOOL isDownloading;

@property (nonatomic, assign, getter=isSelected) BOOL selected;


- (void)startDownloadWithCompletion:(void(^)(MDAlbumVideoDynamicEffectModel *model, BOOL result))complete;
- (void)startDownloadWithProgress:(void(^)(float progress))progressBlock completion:(void(^)(MDAlbumVideoDynamicEffectModel *model, BOOL result))complete;
- (void)cancelDownload;

@end

// 从右向左
@interface MDAlbumVideoRTLDynamicEffectModel : MDAlbumVideoDynamicEffectModel

- (instancetype)init;

@end

// 从下向上
@interface MDAlbumVideoBTTDynamicEffectModel : MDAlbumVideoDynamicEffectModel

- (instancetype)init;

@end

// 四散
@interface MDAlbumVideoScatterDynamicEffectModel : MDAlbumVideoDynamicEffectModel

- (instancetype)init;

@end

// 秀动
@interface MDAlbumVideoShowDynamicEffectModel : MDAlbumVideoDynamicEffectModel

- (instancetype)init;

@property (nonatomic, readonly) NSString *loopupImage1Path;
@property (nonatomic, readonly) NSString *loopupImage2Path;
@property (nonatomic, readonly) NSString *loopupImage3Path;

@end

@interface MDAlbumVideoFastDynamicEffectModel : MDAlbumVideoDynamicEffectModel

@property (nonatomic, readonly) NSURL *decorationPath;
@property (nonatomic, readonly) NSString *momoID;
@property (nonatomic, readonly) NSString *nickname;

@end


@interface MDAlbumVideoSoftDynamicEffectModel : MDAlbumVideoDynamicEffectModel

@property (nonatomic, readonly) NSURL *decorationPath;
@property (nonatomic, readonly) NSURL *loopupImagePath;
@property (nonatomic, readonly) NSURL *curtainFallImagePath;

@end
