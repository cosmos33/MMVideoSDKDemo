//
//  MDUnifiedRecordBottomView.h
//  MDChat
//
//  Created by 符吉胜 on 2017/6/2.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDUnifiedRecordButton.h"
#import "MDRecordHeader.h"

@protocol MDUnifiedRecordBottomViewDelegate <NSObject>

@optional
- (void)didTapDelayCloseView:(UIImageView *)view;
- (void)didTapDeleSegmentView:(UIImageView *)view isSelected:(BOOL)isSelected;
- (void)didTapGotoEditView:(UIImageView *)view;
- (void)didTapAlbumButton:(BOOL)hadShowAlert;
- (BOOL)currentRecordDurationSmallerThanMinSegmentDuration;
- (BOOL)couldShowAlbumVideoAlert;
- (void)didTapFaceDecorationButton:(UIImageView *)imageView;
@end

@interface MDUnifiedRecordBottomView : UIView

@property (nonatomic,strong,readonly) MDUnifiedRecordButton         *recordButton;
@property (nonatomic,strong,readonly) UIImageView                   *delayCloseView;
@property (nonatomic,strong,readonly) UIImageView                   *deleSegmentView;
@property (nonatomic,strong,readonly) UIImageView                   *gotoEditView;


@property (nonatomic,weak) id<MDUnifiedRecordBottomViewDelegate,MDUnifiedRecordButtonDelegate> delegate;

- (instancetype)initWithDelegate:(id<MDUnifiedRecordBottomViewDelegate,MDUnifiedRecordButtonDelegate>)delegate andLevelType:(MDUnifiedRecordLevelType)levelType;

- (void)setRecordBtnEnable:(BOOL)enadble;
- (void)setRecordBtnActive:(BOOL)active;
- (void)setOffsetPercentage:(CGFloat)percentage withTargetLevelType:(MDUnifiedRecordLevelType)recordLevelType;
- (void)setRecordBtnProgress:(CGFloat)progress;
- (void)setRecordBtnType:(MDUnifiedRecordLevelType)recordLevelType;
- (void)setRecordButtonAlpha:(CGFloat)alpha;
/**
 *setAlbumButtonHidden 内部有特殊情况下 直接会设置为隐藏
 **/
- (void)setAlbumButtonHidden:(BOOL)hidden;

- (void)setDelayCloseViewHidden:(BOOL)hidden;
- (void)setDelayClosViewWithImage:(UIImage *)delayImage;

- (void)setDeleSegmentViewSelected:(BOOL)selected;

- (CGRect)absoluteFrameOfRecordButton;

- (void)handleRotateWithTransform:(CGAffineTransform)transform;
- (void)setDisableAlbumEntrance:(BOOL)disableAlbumEntrance;
@end


@interface UIImageView (userEnableEvent)
@property (nonatomic, assign) BOOL md_enableEvent;
@end
