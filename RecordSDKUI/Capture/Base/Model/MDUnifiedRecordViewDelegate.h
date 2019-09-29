//
//  MDUnifiedRecordViewDelegate.h
//  MDChat
//
//  Created by 符吉胜 on 2017/6/3.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDRecordHeader.h"
#import <RecordSDK/MDRecordCameraAdapter.h>

@protocol MDUnifiedRecordViewDelegate <NSObject>

@required
- (BOOL)currentRecordDurationBiggerThanMinDuration; //是否大于拍摄最低时长
- (BOOL)currentRecordDurationSmallerThanMinSegmentDuration; //是否已经开拍，YES表示没有开拍，NO开拍
- (BOOL)isRecording;
- (BOOL)shouldShowNormalBtnTipView;
- (NSString *)normalBtnTip;
//moduleView : 滤镜、变脸、配乐抽屉
- (BOOL)isModuleViewShowed;
- (BOOL)hasModuleViewShowed;
- (MDRecordCaptureFlashMode)currentFlashMode;
- (BOOL)canUseRecordFunction;
//运营携带的音乐id
- (NSString *)musicIDFromOperation;

@optional
- (void)didClickCancelBtn:(UIView *)cancelBtn;

- (void)filterViewTapped:(UITapGestureRecognizer *)tapGesture;
- (void)didDoubleTapCamera;

- (void)filterViewPinched:(UIPinchGestureRecognizer *)pinchGesture;

//变速条
- (void)speedControlViewDidChangeWithFactor:(CGFloat)factor;

- (void)exposureBias:(CGFloat)bias;

//right view
- (void)didTapSwitchCameraView:(UIImageView *)view;
- (void)didTapFlashLightView:(UIImageView *)view;
- (void)didTapCountDownView:(UIImageView *)view;
- (void)didTapMusicView:(UIImageView *)view;
- (void)didTapThinView:(UIImageView *)view;
- (void)didTapDeleSegmentView:(UIImageView *)view isSelected:(BOOL)isSelected;
- (void)didTapSpeedView:(UIImageView *)view;
- (void)didTapMakeUpView:(UIImageView *)view;

//bottom view
- (void)didTapFaceDecorationView:(UIImageView *)view;
- (void)didTapFilterView:(UIImageView *)view;
- (void)didTapDelayCloseView:(UIImageView *)view;
- (void)didTapGotoEditView:(UIImageView *)view;
- (void)didTapAlbumButton:(BOOL)hadShowAlert;
- (BOOL)couldShowAlbumVideoAlert;

//recordBtn
- (void)didTapRecordButton;
- (void)didLongPressBegan;
- (void)didLongPressEnded:(BOOL)pointInside;

- (MDVideoRecordAccessSource)videoRecordAccessSource;

@end
