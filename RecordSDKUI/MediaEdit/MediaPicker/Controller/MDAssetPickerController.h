//
//  MDAssetPickerController.h
//  MDChat
//
//  Created by YU LEI on 2017/6/2.
//  Copyright © 2017年 sdk.com. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MDUserFeedGuideModel.h"
#import "MDNavigationController.h"

@protocol MDAssetPickerControllerDelegate;

@interface MDAssetPickerController : MDNavigationController

@property (nonatomic, copy) NSArray                                 *selectedArr;
@property (nonatomic, assign) BOOL                                  isOrigin;
@property (nonatomic, readwrite) NSInteger                          selectionLimit;

- (id)initPreviewWithDelegate:(id <MDAssetPickerControllerDelegate>)delegate currentIndex:(NSInteger)idx;

- (void)commonConfigure;
@end


@protocol MDAssetPickerControllerDelegate <UINavigationControllerDelegate>

@optional
- (void)assetPickerController:(MDAssetPickerController *)sender didFinishPickingMediaWithAssets:(NSArray *)assets;

@end
