//
//  MDMusicBottomEditView.m
//  MDChat
//
//  Created by YZK on 2018/11/14.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicBottomEditView.h"
#import "MDSMSelectIntervalProgressView.h"
#import "MDMusicResourceUtility.h"
#import "UIImage+MDUtility.h"


@interface MDMusicBottomEditView ()
@property (nonatomic, strong) UILabel                        *titleLabel;
@property (nonatomic, strong) UIImageView                    *iconView;
@property (nonatomic, strong) UILabel                        *timeLabel;
@property (nonatomic, strong) UILabel                        *subTitleLabel;
@property (nonatomic, strong) UIButton                       *useButton;
@property (nonatomic, strong) MDSMSelectIntervalProgressView *trimView;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIView        *loadBgView;
@property (nonatomic, strong) UIImageView   *loadingView;

@property (nonatomic, assign) CGFloat musicStartPercent;
@property (nonatomic, assign) CGFloat musicEndPercent;
@property (nonatomic, strong) MDMusicCollectionItem *item;
@end


@implementation MDMusicBottomEditView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBCOLOR(46, 46, 46);
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.iconView];
        [self addSubview:self.timeLabel];
        [self addSubview:self.subTitleLabel];
        [self addSubview:self.trimView];
        [self addSubview:self.useButton];
        
        [self.iconView addSubview:self.loadBgView];
        [self.loadBgView addSubview:self.loadingView];
        
        self.musicStartPercent = 0;
        self.musicEndPercent = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public

- (void)bindModel:(MDMusicCollectionItem *)item {
    self.item = item;
    
    self.titleLabel.text = item.displayTitle;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:item.musicVo.cover]];
    
    if (self.item.downLoading) {
        self.loadBgView.hidden = NO;
        self.displayLink.paused = NO;
    }else {
        self.loadBgView.hidden = YES;
        self.displayLink.paused = YES;
    }
    
    self.trimView.beginValue = 0;
    self.trimView.endValue = 1.0;
    self.trimView.currentValue = 0;
    
    AVAsset *asset = self.musicPlayer.currentItem.asset;
    [self setTitleLabelTextWithTime:CMTimeGetSeconds(asset.duration)];

    self.musicStartPercent = 0;
    self.musicEndPercent = 1;
}

- (void)periodicTimeCallback:(CMTime)time {
    NSTimeInterval current = CMTimeGetSeconds(time);
    NSTimeInterval duration = CMTimeGetSeconds(self.musicPlayer.currentItem.duration);
    if (duration > 0) {
        CGFloat progress = current / duration;
        progress = MAX(0, MIN(1, progress));
        self.trimView.currentValue = progress;
        
        if (self.musicEndPercent < 1) {
            NSTimeInterval end = self.musicEndPercent * duration;
            if ( current >= end && [self.delegate respondsToSelector:@selector(musicDidPlayEndWithTimeRange:)] ) {
                [self.delegate musicDidPlayEndWithTimeRange:self.currentTimeRange];
            }
        }
    }
}

- (CMTimeRange)currentTimeRange {
    CMTimeRange timeRange = [MDMusicResourceUtility timeRangeWithStartPercent:self.musicStartPercent endPercent:self.musicEndPercent duration:self.musicPlayer.currentItem.duration];
    return timeRange;
}

#pragma mark - event

- (void)playerItemDidPlayToEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    if (playerItem != self.musicPlayer.currentItem) {
        return;
    }
    [self.delegate musicDidPlayEndWithTimeRange:self.currentTimeRange];
}

- (void)setBeginPoint:(CGFloat)beginPoint {
    NSTimeInterval duration = CMTimeGetSeconds(self.musicPlayer.currentItem.duration);
    if (duration<=0) {
        return;
    }
    
    NSTimeInterval selectDuration = (self.musicEndPercent - beginPoint)*duration;
    if (selectDuration < kLeastMusicDuration) {
        beginPoint = self.musicEndPercent-kLeastMusicDuration/duration;
        self.trimView.beginValue = beginPoint;
    }
    self.musicStartPercent = beginPoint;
    
    [self setTitleLabelTextWithTime:(self.musicEndPercent-self.musicStartPercent)*duration];

    if ([self.delegate respondsToSelector:@selector(musicDidEditWithTimeRange:)]) {
        [self.delegate musicDidEditWithTimeRange:self.currentTimeRange];
    }
}

- (void)setEndPoint:(CGFloat)endPoint {
    NSTimeInterval duration = CMTimeGetSeconds(self.musicPlayer.currentItem.duration);
    if (duration<=0) {
        return;
    }
    
    NSTimeInterval selectDuration = (endPoint - self.musicStartPercent)*duration;
    if (selectDuration < kLeastMusicDuration) {
        endPoint = self.musicStartPercent+kLeastMusicDuration/duration;
        self.trimView.endValue = endPoint;
    }
    self.musicEndPercent = endPoint;
    [self setTitleLabelTextWithTime:(self.musicEndPercent-self.musicStartPercent)*duration];

    if ([self.delegate respondsToSelector:@selector(musicDidEditWithTimeRange:)]) {
        [self.delegate musicDidEditWithTimeRange:self.currentTimeRange];
    }
}

- (void)useButtonClicked {
    if ([self.delegate respondsToSelector:@selector(musicDidSeletedMusicItem:timeRange:)]) {
        [self.delegate musicDidSeletedMusicItem:self.item timeRange:self.currentTimeRange];
    }
}

#pragma mark - 辅助方法

- (void)setTitleLabelTextWithTime:(NSTimeInterval)time {
    NSString *timeStirng = time>0 ? [MDRecordContext formatRemainSecondToStardardTime:time] : @"00:00";
    self.timeLabel.text = timeStirng;
}

#pragma mark - setup view

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 15, self.width-17*2, 15)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 40, 60, 60)];
        _iconView.backgroundColor = RGBCOLOR(73, 73, 73);
        _iconView.layer.cornerRadius = 10;
        _iconView.layer.masksToBounds = YES;
    }
    return _iconView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 40, 33, 15)];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:11];
        _timeLabel.backgroundColor = [UIColor clearColor];
    }
    return _timeLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeLabel.right, self.timeLabel.top, 120, 15)];
        _subTitleLabel.textColor = [UIColor whiteColor];
        _subTitleLabel.font = [UIFont systemFontOfSize:11];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.alpha = 0.4;
        _subTitleLabel.text = @"（滑动两端截取音乐）";
    }
    return _subTitleLabel;
}

- (MDSMSelectIntervalProgressView *)trimView {
    if (!_trimView) {
        _trimView = [[MDSMSelectIntervalProgressView alloc] initWithFrame:CGRectMake(86, 64, MDScreenWidth-86-88, 35)];
        _trimView.backgroundColor = [UIColor clearColor];
        _trimView.marginLineHightColor = [UIColor whiteColor];
        _trimView.marginLineColor = RGBCOLOR(92, 92, 92);
        _trimView.progressColor = RGBCOLOR(0, 156, 255);
        _trimView.trackColor = RGBCOLOR(0, 253, 211);
        _trimView.inactiveColor = RGBACOLOR(255, 255, 255, 0.2);
        _trimView.selectAreaBgColor = [UIColor clearColor];
        _trimView.beginValue = 0;
        _trimView.endValue = 1.0;
        _trimView.currentValue = 0;
        _trimView.leftMargin = 8;
        _trimView.rightMargin = 3;
        _trimView.linePadding = 11;
        _trimView.getLineHeightBlock = ^CGFloat(NSUInteger number) {
            number = number - 1;
            if(number % 6 == 0) return 20;
            if(number % 6 == 1) return 9;
            if(number % 6 == 2) return 13;
            if(number % 6 == 3) return 7;
            if(number % 6 == 4) return 13;
            if(number % 6 == 5) return 9;
            return 7;
        };
        
        __weak __typeof(self) weakSelf = self;
        [_trimView setValueHandleBlock:^(CGFloat vaule, ChangeValueType valueType, TouchStatus status) {
            if(status != TouchStatusMove) {
                if(valueType == ChangeValueTypeBegin) {
                    [weakSelf setBeginPoint:vaule];
                }else{
                    [weakSelf setEndPoint:vaule];
                }
            }
        }];
    }
    return _trimView;
}

- (UIButton *)useButton {
    if (!_useButton) {
        _useButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _useButton.frame = CGRectMake(MDScreenWidth-72, 54, 52, 32);
        _useButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_useButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_useButton setTitle:@"使用" forState:UIControlStateNormal];
        UIImage *image = [UIImage imageWithColor:RGBCOLOR(0, 192, 255) finalSize:_useButton.size cornerRadius:_useButton.height/2.0];
        [_useButton setBackgroundImage:image forState:UIControlStateNormal];
        [_useButton addTarget:self action:@selector(useButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _useButton;
}

- (UIView *)loadBgView {
    if (!_loadBgView) {
        _loadBgView = [[UIView alloc] initWithFrame:self.iconView.bounds];
        _loadBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _loadBgView.hidden = YES;
    }
    return _loadBgView;
}

- (UIImageView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 19)];
        _loadingView.image = [UIImage imageNamed:@"moment_play_bar_loading"];
        _loadingView.center = CGPointMake(self.loadBgView.width/2, self.loadBgView.height/2);
    }
    return _loadingView;
}

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        MDWeakProxy *weakProxy = [MDWeakProxy weakProxyForObject:self];
        _displayLink = [CADisplayLink displayLinkWithTarget:weakProxy selector:@selector(displayDidRefresh:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
    }
    return _displayLink;
}

- (void)displayDidRefresh:(CADisplayLink *)displayLink {
    CGAffineTransform transform = self.loadingView.transform;
    NSTimeInterval duration = 1;
    CGFloat rotationAnglePerRefresh = (2*M_PI)/(duration*60.0);
    self.loadingView.transform = CGAffineTransformRotate(transform, rotationAnglePerRefresh);
}

@end
