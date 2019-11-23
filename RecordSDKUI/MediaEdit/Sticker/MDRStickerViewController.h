//
//  MDRStickerViewController.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/7/1.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "MDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class MDRStickerViewController, MDRecordDynamicSticker, MDVideoEditorAdapter;

@protocol MDRStickerViewControllerDelegate <NSObject>

- (void)didCompleteEditSticker:(MDRStickerViewController *)controller;
- (void)cancelEditSticker:(MDRStickerViewController *)controller;

- (void)didSelecedSticker:(MDRStickerViewController *)controller
                  sticker:(MDRecordDynamicSticker * _Nullable)sticker
                   center:(CGPoint)center;

@end

@interface MDRStickerViewController : MDViewController

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAdapter:(MDVideoEditorAdapter *)adapter asset:(AVAsset *)asset;

@property (nonatomic, weak, nullable) id<MDRStickerViewControllerDelegate> delegate;
@property (nonatomic, assign) NSUInteger maxStickerCount;

@property (nonatomic, readonly) NSArray<MDRecordDynamicSticker *> *stickerArray;

- (void)showWithAnimated:(BOOL)animated;
- (void)showWithAnimated:(BOOL)animated completion:(void(^ _Nullable)(void))completion;
- (void)dissmissWithAnimated:(BOOL)animated;
- (void)dissmissWithAnimated:(BOOL)animated completion:(void(^ _Nullable)(void))completion;

- (void)removeSticker:(MDRecordDynamicSticker *)sticker;
- (void)selectSticker:(MDRecordDynamicSticker *)sticker;

@end

NS_ASSUME_NONNULL_END
