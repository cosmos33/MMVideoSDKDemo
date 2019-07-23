//
//  MDUnifiedRecordTopView.m
//  MDChat
//
//  Created by 符吉胜 on 2017/7/26.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordTopView.h"
#import "MDRecordGuideTipsManager.h"
#import "UIImage+MDUtility.h"
#import "MDRecordHeader.h"

static const CGFloat kViewH = 30;
static const CGFloat kIconW = kViewH;
static const CGFloat kIconH = kIconW;

static const CGFloat kRightEdge = 15.0;
static const NSUInteger kIconCount = 4;

@interface MDUnifiedRecordTopView()

@property (nonatomic,strong) UIImageView    *flashLightView;
//@property (nonatomic,strong) UIImageView    *countDownView;
@property (nonatomic,strong) UIImageView    *switchCameraView;

@property (nonatomic,assign) CGFloat        margin;

@property (nonatomic,strong) MDRecordGuideTipsManager   *tipsManager;

@end

@implementation MDUnifiedRecordTopView

- (instancetype)initWithFrame:(CGRect)frame andGuideTipsManager:(MDRecordGuideTipsManager *)guideManager
{
    if (self = [super initWithFrame:frame]) {
        _tipsManager = guideManager;
        _margin = ((MDScreenWidth - kRightEdge*2) - kIconCount * kIconW) / (kIconCount - 1);
        [self configUI];
    }
    return self;
}

- (void)configUI
{
//    self.countDownView = [self imageViewWithImageName:@"count_down_off"
//                                                index:0
//                                               selStr:@"didTapCountDownView"];

    self.flashLightView = [self imageViewWithImageName:@"btn_moment_flashLight_off"
                                                 index:1
                                                selStr:@"didTapFlashLightView"];
    
    self.switchCameraView = [self imageViewWithImageName:@"btn_moment_camera_switch"
                                                   index:2
                                                  selStr:@"didTapSwitchCameraView"];
    
//    [self addSubview:self.countDownView];
    [self addSubview:self.flashLightView];
    [self addSubview:self.switchCameraView];
    
    self.left = kIconW + _margin + kRightEdge;
    self.size = CGSizeMake(self.switchCameraView.right, kViewH);
    
    //前置摄像头，隐藏闪光灯
    AVCaptureDevicePosition position =  AVCaptureDevicePositionFront; //[[[MDContext currentUser] dbStateHoldProvider] momentCameraPosition];
    position = position == AVCaptureDevicePositionUnspecified ? AVCaptureDevicePositionFront : position;
    if (position == AVCaptureDevicePositionFront) {
        self.flashLightView.alpha = 0.0f;
    }
}

- (UIImageView *)imageViewWithImageName:(NSString *)imageName
                                  index:(NSInteger)index
                                 selStr:(NSString *)selStr
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    
    CGFloat left = (kIconW + _margin) * index;
    imageView.frame = CGRectMake(left, 0, kIconW, kIconH);
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:NSSelectorFromString(selStr)];
    [imageView addGestureRecognizer:tapGesture];
    
    return imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.flashLightView.right = self.switchCameraView.left - 28.5;
}

#pragma mark - 交互事件
- (void)didTapFlashLightView
{
    if ([self.delegate respondsToSelector:@selector(didTapFlashLightView:)]) {
        [self.delegate didTapFlashLightView:self.flashLightView];
    }
}

- (void)didTapCountDownView
{
//    if ([self.delegate respondsToSelector:@selector(didTapCountDownView:)]) {
//        [self.delegate didTapCountDownView:self.countDownView];
//    }
}

- (void)didTapSwitchCameraView
{
    if ([self.delegate respondsToSelector:@selector(didTapSwitchCameraView:)]) {
        [self.delegate didTapSwitchCameraView:self.switchCameraView];
    }
}

#pragma mark - public function

- (void)handleRotateWithTransform:(CGAffineTransform)transform
{
    self.flashLightView.transform = transform;
//    self.countDownView.transform = transform;
    self.switchCameraView.transform = transform;
}


@end
