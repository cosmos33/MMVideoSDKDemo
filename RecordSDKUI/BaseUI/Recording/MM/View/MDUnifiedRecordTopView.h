//
//  MDUnifiedRecordTopView.h
//  MDChat
//
//  Created by 符吉胜 on 2017/7/26.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDRecordGuideTipsManager;

@protocol MDUnifiedRecordTopViewDelegate <NSObject>

@optional
- (void)didTapSwitchCameraView:(UIImageView *)view;
- (void)didTapFlashLightView:(UIImageView *)view;
- (void)didTapCountDownView:(UIImageView *)view;
@end

@interface MDUnifiedRecordTopView : UIView

@property (nonatomic,strong,readonly) UIImageView    *flashLightView;
//@property (nonatomic,strong,readonly) UIImageView    *countDownView;
@property (nonatomic,strong,readonly) UIImageView    *switchCameraView;

@property (nonatomic,weak) id<MDUnifiedRecordTopViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andGuideTipsManager:(MDRecordGuideTipsManager *)guideManager;

- (void)handleRotateWithTransform:(CGAffineTransform)transform;

@end
