//
//  MDRecordProgressView.m
//  MDChat
//
//  Created by 王璇 on 2017/4/13.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDRecordProgressView.h"
#import "MDRecordHeader.h"

@interface MDRecordProgressView ()

@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, strong) UIView *progressView;

@end

@implementation MDRecordProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)setupSubviews
{
    [self addSubview:self.trackView];
    [self addSubview:self.progressView];
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    _progressTintColor = progressTintColor;
    _progressView.backgroundColor = progressTintColor;
    
}

- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    _trackTintColor = trackTintColor;
    _trackView.backgroundColor = trackTintColor;
}

- (void)setProgress:(float)progress
{
    if (_progress == progress) {
        return;
    }
    
    progress = MAX(progress, 0);
    progress = MIN(progress, 1);
    
    _progress = progress;
    self.progressView.width = self.width *progress;
}

- (UIView *)trackView
{
    if (!_trackView) {
        _trackView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_trackView];
    }
    
    return _trackView;
}

- (UIView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.height)];
        [self addSubview:_progressView];
    }
    
    return _progressView;
}


@end
