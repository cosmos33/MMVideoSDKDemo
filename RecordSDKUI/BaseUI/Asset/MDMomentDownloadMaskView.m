//
//  MDMomentDownloadMaskView.m
//  MDChat
//
//  Created by 符吉胜 on 2017/4/7.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMomentDownloadMaskView.h"
#import "UIImage+MDUtility.h"
#import "SDDownloadProgressView.h"
#import "UIImageEffects.h"
#import "MDRecordHeader.h"

static const CGFloat kContainerW = 110;
static const CGFloat kContainerH = kContainerW;

@interface MDMomentDownloadMaskView()

@property (nonatomic,strong) UIImageView            *containerView;
@property (nonatomic,strong) SDDownloadProgressView *progressView;
@property (nonatomic,strong) UILabel                *tipLabel;
@property (nonatomic,strong) UIImageView            *closeImageView;
@property (nonatomic,strong) UIView                 *blurView;

@property (nonatomic,copy) DismissDownloadMaskViewFinish finishBlock;
@property (nonatomic,assign,getter=isAnimating) BOOL     animating;
@property (nonatomic, copy) NSString                     *infoStr;

@end

@implementation MDMomentDownloadMaskView

#pragma mark - init
- (instancetype)initWithBlurView:(UIView *)blurView infoStr:(NSString *)str {
    if (self = [super initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)]) {
        _animating = NO;
        self.infoStr = str;
        [self configUI];
    }
    return self;
}

- (instancetype)initWithBlurView:(UIView *)blurView
{
    return  [self initWithBlurView:blurView infoStr:nil];
}

+ (instancetype)showDownloadMaskViewWithBlurView:(UIView *)blurView infoStr:(NSString *)str {
    MDMomentDownloadMaskView *maskView = [[MDMomentDownloadMaskView alloc] initWithBlurView:blurView infoStr:str];
    [[MDRecordContext appWindow] addSubview:maskView];
    
    maskView.blurView = blurView;
    maskView.containerView.image = [maskView blurImage];
    
    return maskView;
}

+ (instancetype)showDownloadMaskViewWithBlurView:(UIView *)blurView
{
    return [self showDownloadMaskViewWithBlurView:blurView infoStr:nil];
}

- (UIImage *)blurImage
{
    if (self.blurView == nil) {
        return nil;
    }
    
    CGRect rect = [MDRecordContext appWindow].bounds;
    CGRect clipRect = self.containerView.frame;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [self.blurView drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *blurImage = [UIImageEffects imageByApplyingBlurToImage:image withRadius:60 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.8 maskImage:nil];
    
    blurImage = [blurImage clipImageInRect:clipRect cornerRadius:6.0f];
    
    return blurImage;
}

#pragma mark - config UI
- (void)configUI
{
    self.backgroundColor = [UIColor clearColor];
    
    [self.containerView addSubview:self.progressView];
    [self.containerView addSubview:self.tipLabel];
    [self.containerView addSubview:self.closeImageView];
    
    [self addSubview:self.containerView];
    
    [self doEntranceAnimation];
}

- (UIImageView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kContainerW, kContainerH)];
        UIImage *backImg = [UIImage imageWithColor:RGBACOLOR(0, 0, 0, 0.45f) finalSize:_containerView.size cornerRadius:6.0f];
        _containerView.image = backImg;
        _containerView.userInteractionEnabled = YES;
        
        _containerView.center = self.center;
    }
    return _containerView;
}

- (SDDownloadProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[SDDownloadProgressView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        _progressView.lineWidth = 4.0f;
        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.centerX = kContainerW / 2.0f;
        _progressView.top = 30;
    }
    return _progressView;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.font = [UIFont systemFontOfSize:14.0f];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        
        _tipLabel.width = kContainerW;
        _tipLabel.height = [_tipLabel.font lineHeight];
        _tipLabel.left = 0;
        _tipLabel.bottom = kContainerH - 17.0f;
        
        _tipLabel.text = [self.infoStr isNotEmpty] ? self.infoStr : @"正在下载中";
    }
    return _tipLabel;
}

- (UIImageView *)closeImageView
{
    if (!_closeImageView) {
        UIImage *closeImage = [UIImage imageNamed:@"moment_play_download_close"];
        _closeImageView = [[UIImageView alloc] initWithImage:closeImage];
        _closeImageView.userInteractionEnabled = YES;
        _closeImageView.frame = CGRectMake(0, 0, closeImage.size.width, closeImage.size.height);
        _closeImageView.right = self.containerView.width - 10;
        _closeImageView.top = 10;
        
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCloseImageView)];
        [_closeImageView addGestureRecognizer:tapGesture];
    }
    return _closeImageView;
}

#pragma mark - 进出动画
- (void)doEntranceAnimation
{
    self.alpha = 0.0f;
    self.containerView.layer.transform = CATransform3DMakeScale(0.94, 0.94, 1);
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = 1.0;
                         self.containerView.alpha = 1.;
                         self.containerView.layer.transform = CATransform3DIdentity;
                         [self layoutIfNeeded];
                     } completion:nil];
}

- (void)doDismissAnimation
{
    self.animating = YES;
    self.containerView.layer.transform = CATransform3DIdentity;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = .0;
                         self.containerView.alpha = 0.;
                         self.containerView.layer.transform = CATransform3DMakeScale(0.94, 0.94, 1);
                         [self layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         
                         self.animating = NO;
                         
                         if (self.finishBlock) {
                             self.finishBlock();
                         }
                         
                         if (self.superview) {
                             [self removeFromSuperview];
                         }
                     }];
}

#pragma mark - 更新进度
- (void)setProgress:(CGFloat)progress
{
    self.progressView.progress = progress;
}

#pragma mark - action
- (void)tapCloseImageView
{
    [self dismissDownloadMaskView];
}

#pragma mark - dismiss
- (void)dismissDownloadMaskView
{
    [self doDismissAnimation];
    
    if ([self.delegate respondsToSelector:@selector(momentDownloadMaskView:didClickCloseView:)]) {
        [self.delegate momentDownloadMaskView:self didClickCloseView:self.closeImageView];
    }
}

- (void)dismissDownloadMaskViewCompletion:(DismissDownloadMaskViewFinish)finishBlock
{
    self.finishBlock = finishBlock;
    
    if (!self.isAnimating) {
        [self doDismissAnimation];
    }
}

@end
