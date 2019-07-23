//
//  MDNewAssetContainerController.h
//  MDChat
//
//  Created by sdk on 2018/9/3.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDViewController.h"
#import <Photos/Photos.h>
#import "MDAssetCollectionViewController.h"
#import "MDUserFeedGuideModel.h"

@class MDNewAssetContainerController;
@protocol MDNewAssetContainerControllerDelegate <NSObject>

- (BOOL)assetContainerPickerControllerIsActive:(MDNewAssetContainerController *)sender;
//相册点击了打开拍摄
- (void)assetContainerPickerControllerDidTapTakePicture;
//由拍摄器打开的相册点击了返回
- (void)assetContainerPickerControllerDidTapBackByTransition;

@end

@interface MDNewAssetContainerController : MDViewController
@property (nonatomic, weak)     id<MDNewAssetContainerControllerDelegate>   delegate;
@property (nonatomic, assign)   BOOL                                    fromCamera;

@property (nonatomic, strong) MDUserFeedGuideShowModel *userFeedShowModel;

- (instancetype)initWithInitialItem:(MDUnifiedRecordSettingItem *)item couldShowTakePicture:(BOOL)enable;
- (void)anchorBySettingItem;

@end
