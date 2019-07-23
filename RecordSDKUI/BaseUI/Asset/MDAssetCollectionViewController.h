//
//  MDAssetCollectionViewController.h
//  MDChat
//
//  Created by YU LEI on 2017/6/2.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "MDAssetPreviewController.h"
#import "MDUserFeedGuideModel.h"
#import "MDAssetAlbumItem.h"

typedef NS_ENUM(NSInteger,MDAssetCollectionViewType){
    MDAssetCollectionViewTypeVideoAlbum = 1,//影集 仅有照片
    MDAssetCollectionViewTypeAll,//相册 照片和视频
    MDAssetCollectionViewTypeVideo,//视频 仅视频
    MDAssetCollectionViewTypePortrait, //人像
    MDAssetCollectionViewTypeSelfie,   //自拍
};

@class MDAssetCollectionViewController;

@protocol MDAssetCollectionViewControllerDelegate <NSObject>

- (void)selectedCountDidChange:(NSInteger)count; //选中数量变化
- (void)didClickTakePictureAction; //点击拍摄按钮
- (void)didFinishSelectedToAlbumVideo; //影集选择完成
// 获取当前页面是否展示在屏幕上，下载iCloud图片结束后，如果不在屏幕上，就不推出编辑页面
- (BOOL)currentVCLIsActive:(MDAssetCollectionViewController *)target;

@end

@interface MDAssetCollectionViewController : MDViewController

@property (nonatomic, weak  ) id<MDAssetCollectionViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL                                    fromCamera;
@property (nonatomic, copy) void(^viewDidLoadCallback)(MDAssetCollectionViewController *viewController, UIView *view);
@property (nonatomic, strong) MDUserFeedGuideShowModel                *userFeedShowModel;

@property (nonatomic, assign, readonly) MDAssetMediaType          assetMediaType;
@property (nonatomic, assign, readonly) MDAssetCollectionViewType pageType;
@property (nonatomic, strong, readonly) MDAssetSelectState        *assetState;

- (instancetype)initWithInitialItem:(MDUnifiedRecordSettingItem *)item pageType:(MDAssetCollectionViewType)pageType couldTakePicture:(BOOL)enable;
- (void)setSelectLimit:(NSInteger)selectLimit;

- (void)clearState;
- (void)viewControllerDidShow;
- (void)didPickerAlbumCompleteWithItem:(MDAssetAlbumItem *)item index:(NSInteger)index;
- (void)clearOriginImage;

@end
