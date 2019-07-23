//
//  MDMediaEditorContainerView.h
//  MDChat
//
//  Created by 符吉胜 on 2017/8/24.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDMediaEditorContainerViewDelegate.h"

#import "MDHitTestExpandView.h"
#import "BBMediaStickerAdjustmentView.h"
#import "MDMomentTextAdjustmentView.h"
#import "MDMomentTextOverlayEditorView.h"
//#import "MDMomentTopicSelectManager.h"
#import "MDMediaEditorBottomView.h"
#import "MDMediaEditorRightView.h"
#import "MDPublicSwiftHeader.h"

FOUNDATION_EXPORT const CGFloat kMediaEditorMoreBetweenMargin;
FOUNDATION_EXPORT const CGFloat kMediaEditorBottomToolButtonWidth;

FOUNDATION_EXPORT NSString * const kBtnTitleForSticker;
FOUNDATION_EXPORT NSString * const kBtnTitleForText;
FOUNDATION_EXPORT NSString * const kBtnTitleForMusic;
FOUNDATION_EXPORT NSString * const kBtnTitleForthumbSelect;
FOUNDATION_EXPORT NSString * const kBtnTitleForMoreAction;
FOUNDATION_EXPORT NSString * const kBtnTitleForSpeedVary;
FOUNDATION_EXPORT NSString * const kBtnTitleForPainter;

@interface MDMediaEditorContainerView : UIView

- (instancetype)initWithDelegate:(id<MDMediaEditorContainerViewDelegate>)delegate whRatio:(CGFloat)whRatio;

@property (nonatomic,  weak) id<MDMediaEditorContainerViewDelegate>  delegate;


// ************  UI  ***************
//文字涂鸦贴纸
@property (nonatomic, strong, readonly) MDHitTestExpandView    *costumContentView;  // 贴纸，涂鸦，文字的背景视图
@property (nonatomic, strong, readonly) BBMediaStickerAdjustmentView  *stickerAdjustView; //贴纸视图
@property (nonatomic, strong, readonly) UIImageView                   *graffitiCanvasView; //涂鸦视图
@property (nonatomic, strong, readonly) MDMomentTextAdjustmentView    *textAdjustView;  //文字视图
//顶部按钮
@property (nonatomic, strong, readonly) UIButton  *doneBtn; //完成按钮
@property (nonatomic, strong, readonly) UIButton  *reSendBtn; //重新拍摄按钮
//@property (nonatomic, strong, readonly) MDHitTestExpandView  *cancelBtn; //取消按钮
@property (nonatomic, strong, readonly) UIButton *cancelButton;

@property (nonatomic, strong, readonly) UILabel *timeLabel;

@property (nonatomic, strong, readonly) MDNewMediaEditorBottomView *buttonView;

@property (nonatomic, strong, readonly) UIButton  *stickerDeleteBtn; //删除贴纸按钮

@property (nonatomic, assign, readonly) CGFloat   edgeMargin;

//@property (nonatomic, strong) MMArpetResult  *qualityResult;
@property (nonatomic, strong, readonly) UIButton  *qualityBlockBtn;



- (UIImage *)renderOverlaySnapshot:(UIView *)view needWatermark:(BOOL)needWaterMark;
// 增加ArPet气泡
- (void)addArPetAlertPopView;

@end
