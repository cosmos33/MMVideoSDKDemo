//
//  MDAssetPreviewController.h
//  MDChat
//
//  Created by Aaron on 16/6/27.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDViewController.h"
#import "MDUnifiedRecordSettingItem.h"
#import "MDAssetSelectState.h"

@class MDAssetPreviewController;

@protocol MDAssetPreviewControllerDelegate <NSObject>
- (void)assetPreviewControllerDidFinish:(MDAssetPreviewController *)controller;
@end


@interface MDAssetPreviewController : MDViewController

- (instancetype)initWithCurrentIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) NSArray                               *fetchedAssets; //外界相册的数据源
@property (nonatomic, strong) NSArray                               *addressFetchedAssets;

@property (nonatomic, assign) BOOL                                  enableOrigin;
@property (nonatomic, weak) id<MDAssetPreviewControllerDelegate>    delegate;
@property (nonatomic, assign) BOOL                                  isOrigin;
@property (nonatomic, strong) MDUnifiedRecordSettingItem            *settingItem;
@property (nonatomic, strong) MDAssetSelectState                    *assetState;

@end
