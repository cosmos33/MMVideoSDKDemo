//
//  MDBluredProgressView.m
//  MDChat
//
//  Created by 王璇 on 2017/4/13.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "MDBluredProgressView.h"
#import "SDDownloadProgressView.h"
#import "UIImageEffects.h"
#import "UIImage+MDUtility.h"
#import "MDRecordHeader.h"

static const CGFloat kContainerW = 110;
static const CGFloat kContainerH = kContainerW;

@interface MDBluredProgressView ()

@property (nonatomic,strong) UIImageView            *containerView;
@property (nonatomic,strong) SDDownloadProgressView *progressView;
@property (nonatomic,strong) UILabel                *tipLabel;
@property (nonatomic,strong) UIImageView            *closeImageView;

@property (nonatomic,strong) UIView                 *blurView;

@end


@implementation MDBluredProgressView

- (instancetype)initWithBlurView:(UIView *)blurView descText:(NSString *)desc needClose:(BOOL)need
{
    if (self = [super initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)]) {
        [self configUI];
        
//        self.blurView = blurView;
//        self.containerView.image = [self blurImage];
        self.tipLabel.text = desc;
        self.closeImageView.hidden = !need;
    }
    return self;
}

- (UIImage *)blurImage
{
    if (self.blurView == nil) {
        return nil;
    }
    
    CGRect rect = [UIApplication sharedApplication].delegate.window.bounds;
    CGRect clipRect = self.containerView.frame;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [self.blurView drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *blurImage = [UIImageEffects imageByApplyingBlurToImage:image withRadius:60 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.8 maskImage:nil];
    
    blurImage = [blurImage clipImageInRect:clipRect cornerRadius:6.0f];
    
    return blurImage;
}

- (void)configUI
{
    self.backgroundColor = [UIColor clearColor];
    
    [self.containerView addSubview:self.tipLabel];
    [self.containerView addSubview:self.closeImageView];
    
    [self addSubview:self.containerView];
}

- (UIImageView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kContainerW, kContainerH)];
        UIImage *backImg = [UIImage imageWithColor:RGBACOLOR(0, 0, 0, 0.5f) finalSize:_containerView.size cornerRadius:6.0f];
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
        _progressView.progress = .0f;
        [self.containerView addSubview:_progressView];
    }
    return _progressView;
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
        
        _tipLabel.text = @"正在下载中";
    }
    return _tipLabel;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    if (_progress >= 1.0f) {
        [_progressView removeFromSuperview];
        _progressView = nil;

        if (self.superview) {
            [self removeFromSuperview];
        }
    } else {
        self.progressView.progress = progress;
    }
}

#pragma mark - action
- (void)tapCloseImageView
{
    if (self.superview) {
        [self removeFromSuperview];
    }
    if (self.viewCloseHandler) {
        self.viewCloseHandler();
    }
}

@end
