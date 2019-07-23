//
//  BBMediaStickerAdjustmentView.h
//  BiBi
//
//  Created by YuAo on 12/11/15.
//  Copyright © 2015 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RecordSDK/MDRecordDynamicSticker.h>

@class BBMediaStickerAdjustmentView;

@protocol BBMediaStickerAdjustmentViewDelegate <NSObject>

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerWillBeginChange:(MDRecordBaseSticker *)sticker frame:(CGRect)frame;

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidMove:(MDRecordBaseSticker *)sticker frame:(CGRect)frame touchPoint:(CGPoint)point;

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidEndChange:(MDRecordBaseSticker *)sticker frame:(CGRect)frame;

@optional
- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidPinch:(MDRecordBaseSticker *)sticker frame:(CGRect)frame;

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidRotate:(MDRecordBaseSticker *)sticker angle:(CGFloat)angle;

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidAfterAdjust:(MDRecordBaseSticker *)sticker frame:(CGRect)frame;

@end

@interface BBMediaStickerAdjustmentView : UIView

- (void)addSticker:(MDRecordBaseSticker *)sticker center:(CGPoint)center;
- (void)removeSticker:(MDRecordBaseSticker *)sticker;

@property (nonatomic,weak) id<BBMediaStickerAdjustmentViewDelegate> delegate;

@end
