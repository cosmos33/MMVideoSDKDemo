//
//  MDUnifiedRecordContainerView.h
//  MDChat
//
//  Created by 符吉胜 on 2017/6/2.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDUnifiedRecordViewDelegate.h"
#import "BBMediaEditorSlidingOverlayView.h"
#import "MDDurationArrayProgressView.h"
#import "MDUnifiedRecordBottomView.h"
#import "MDUnifiedRecordTopView.h"
#import "MDUnifiedRecordRightView.h"
#import "MDRecordHeader.h"

@interface MDUnifiedRecordContainerView : UIView

@property (nonatomic,strong,readonly) MDUnifiedRecordBottomView              *bottomView;
@property (nonatomic,strong,readonly) BBMediaEditorSlidingOverlayView        *slidingFilterView;
@property (nonatomic,strong,readonly) UIImageView                            *cameraFocusView;
@property (nonatomic,strong,readonly) MDUnifiedRecordTopView                 *currentTopView;
@property (nonatomic,strong,readonly) MDUnifiedRecordRightView               *currentRightView;
@property (nonatomic,strong, readonly) MDUnifiedRecordRightView               *rightViewForNormal;
@property (nonatomic,strong, readonly) MDUnifiedRecordRightView               *rightViewForHigh;

@property (nonatomic,strong,readonly) UILabel                                *loadingTipView;
//供视频渲染输出
@property (nonatomic,strong) UIView                            *contentView;
//视频录制进度条
@property (nonatomic,strong) MDDurationArrayProgressView       *progressView;

@property (nonatomic,  weak) id<MDUnifiedRecordViewDelegate>  delegate;

- (instancetype)initWithDelegate:(id<MDUnifiedRecordViewDelegate>)delegate levelType:(MDUnifiedRecordLevelType)levelType fromAlbum:(BOOL)fromAlbum;
- (instancetype)initWithDelegate:(id<MDUnifiedRecordViewDelegate>)delegate levelType:(MDUnifiedRecordLevelType)levelType;

- (void)showFaceDecorationTip:(NSString *)text;
- (void)showFilterNameTipAnimateWithText:(NSString *)text;

- (void)musicViewShow:(BOOL)isShow animated:(BOOL)animated;
- (void)highMiddleBottomViewShow:(BOOL)isShow animated:(BOOL)animated; //(包含变速条和提示框)
- (void)setHighRecordBtnTipViewTextWithDeleteSelected:(BOOL)deleteSelected;

- (void)setBottomViewAlpha:(CGFloat)alpha;
- (void)setRecordBtnEnable:(BOOL)enadble;
- (void)setRecordBtnProgress:(CGFloat)progress;
- (void)setDelayCloseViewHidden:(BOOL)hidden;
- (void)setCountDownViewWithImage:(UIImage *)image;

- (void)setDeleSegmentViewEnable:(BOOL)enable;
- (void)setDeleSegmentViewSelected:(BOOL)selected;
- (void)setDeleSegmentViewAlpha:(CGFloat)alpha;

- (void)setEditButtonEnable:(BOOL)enable;
- (void)setEditButtonEnableEvent:(BOOL)enableEvent;

- (void)setFlashViewImageWithFlashMode:(MDRecordCaptureFlashMode)flashMode;
- (void)switchFlashLightAfterRotateCamera;

- (void)updateForVideoRecording:(BOOL)isRecording animated:(BOOL)animated;
- (void)updateForCountDownAnimation:(BOOL)showAnimation;

- (void)setRecordDurationLabelAlpha:(CGFloat)alpha;
- (void)setRecordDurationLabelTextWithSecond:(int)second;

- (void)normalRecordBtnTipViewShow:(BOOL)isShow animated:(BOOL)animated;
- (void)loadingTipViewShow:(BOOL)isShow animated:(BOOL)animated;

- (void)syschronizaRightView;
- (void)showTopViewWithOffset:(CGFloat)offset;
- (void)setCurrentTopViewWithLevelType:(MDUnifiedRecordLevelType)currentLevelType animated:(BOOL)animated;
- (void)setRecordBtnType:(MDUnifiedRecordLevelType)recordLevelType;

- (void)topViewShow:(BOOL)show animated:(BOOL)animated;

//横屏旋转
- (void)handleViewRotate:(UIDeviceOrientation)orientation;

//引导动画
- (void)doGuideAnimationWithLevelType:(MDUnifiedRecordLevelType)levelType;


//宠物扫描相关
- (void)applyPetScannerMode;
//宠物拍摄分享
- (void)applyPetRecordMode;
- (void)setPetRecordButtonMode:(BOOL)isEnable;

- (BOOL)video3DTouchViewAcceptTouch;

- (void)setFromAlbum:(BOOL)fromAlbum;
//设置底部相册入口
- (void)setBottomAlbumButtonHidden:(BOOL)hidden;

@end
