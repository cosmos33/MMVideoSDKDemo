//
//  MDMomentTextAdjustmentView.h
//  MDChat
//
//  Created by wangxuan on 17/2/6.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDMomentTextSticker : NSObject

@property (nonatomic, copy,readonly) UIImage       *image;
@property (nonatomic, strong)        NSString      *text;
@property (nonatomic, strong)        UILabel       *label;
@property (nonatomic, assign)        NSInteger     colorIndex;
@property (nonatomic, assign)        CGPoint       center;
@property (nonatomic, assign)        CGAffineTransform transform;

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithLabel:(UILabel *)label;

@end

@class MDMomentTextAdjustmentView;

@protocol MDMomentTextAdjustmentViewDelegate <NSObject>

@optional
- (void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerWillBeginChange:(MDMomentTextSticker *)sticker frame:(CGRect)frame;

- (void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerDidMove:(MDMomentTextSticker *)sticker frame:(CGRect)frame touchPoint:(CGPoint)point;

- (void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerDidEndChange:(MDMomentTextSticker *)sticker frame:(CGRect)frame;

- (void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerDidTap:(MDMomentTextSticker *)sticker frame:(CGRect)frame;
@end

@interface MDMomentTextAdjustmentView : UIView

- (void)addSticker:(MDMomentTextSticker *)sticker center:(CGPoint)center transform:(CGAffineTransform)transform;
- (void)removeSticker:(MDMomentTextSticker *)sticker;

@property (nonatomic,weak) id<MDMomentTextAdjustmentViewDelegate> delegate;

@end
