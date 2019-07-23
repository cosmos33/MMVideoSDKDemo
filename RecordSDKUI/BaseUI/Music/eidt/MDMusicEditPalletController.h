//
//  MDMusicEditPalletController.h
//  MDChat
//
//  Created by YZK on 2018/11/19.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDRecordHeader.h"
#import "MDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class MDMusicEditPalletController,MDMusicCollectionItem;
@protocol MDMusicEditPalletControllerDelegate <NSObject>

@optional
- (void)musicEditPallet:(MDMusicEditPalletController *)musicEditPallet didPickMusicItems:(MDMusicCollectionItem *)musicItem timeRange:(CMTimeRange)timeRange;
- (void)musicEditPallet:(MDMusicEditPalletController *)musicEditPallet didEditOriginalVolume:(CGFloat)originalVolume musicVolume:(CGFloat)musicVolume;
- (void)musicEditPalletDidClearMusic:(MDMusicEditPalletController *)musicEditPallet;

@end


@interface MDMusicEditPalletController : MDViewController

@property (nonatomic, weak) id<MDMusicEditPalletControllerDelegate> delegate;
@property (nonatomic, strong, readonly) MDMusicCollectionItem *currentSelectMusicItem;
@property (nonatomic, assign, readonly) BOOL isShowed;

- (void)setOriginDefaultMusicVolume:(CGFloat)volume;
- (void)periodicTimeCallback:(CMTime)time;
- (void)updateMusicItem:(MDMusicCollectionItem *)musicItem timeRange:(CMTimeRange)timeRange; //更新当前带入的配乐(第3个位置的配乐)

- (void)showAnimateWithCompleteBlock:(nullable void (^)(void))completedBlock;
- (void)hideAnimationWithCompleteBlock:(nullable void (^)(void))completeBlock;

@end

NS_ASSUME_NONNULL_END
