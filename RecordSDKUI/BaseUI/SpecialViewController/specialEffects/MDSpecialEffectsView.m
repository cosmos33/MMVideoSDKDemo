//
//  MDSpecialEffectsView.m
//  BlockTest
//
//  Created by litianpeng on 2018/8/7.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import "MDSpecialEffectsView.h"
#import "MDSpecialEffectsSelectView.h"
#import "MDSpecialEffectsTitleView.h"
#import "MDSpecialEffectsProgressView.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "MDRecordSpecialImageDataManager.h"
#import "MDEffectsTimeManager.h"
#import "MDSpecialEffectsManager.h"
#import "MDRecordHeader.h"
#import "Toast/Toast.h"

@interface MDSpecialEffectsView()<MDRecordSpecialImageDataManagerDelegate>
@property (nonatomic, strong) MDSpecialEffectsSelectView *pictureView;///<画面特效
@property (nonatomic, strong) MDSpecialEffectsSelectView *timeView;///<时间特效
@property (nonatomic, strong) MDSpecialEffectsTitleView *titleView;///<中间的标题
@property (nonatomic, strong) MDSpecialEffectsProgressView *pictureProgressView;///<画面特效进度
@property (nonatomic, strong) MDSpecialEffectsProgressView *timeProgressView;///< 时间特效进度
@property (nonatomic, strong) UILabel *reminderLabel;///<画面特效
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, assign) CMTime currentTime;///<当前播放进度
@property (nonatomic, strong) id            timeObserver;
@property (nonatomic, assign) BOOL isBackground;///<是否进入后台
@property (nonatomic, assign) BOOL isLongPress;///<是否在长按
@property (nonatomic, assign) BOOL isTimeEffect;///<是否是选择时间特效

@property (nonatomic, strong) MDEffectsTimeManager *effectTimeManager;///<存储时间

@property (nonatomic, assign) BOOL isUserPlayer;///<手动播放, 自动循环播放
@end

@implementation MDSpecialEffectsView
- (void)dealloc{
    [self removeTimerObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)removeTimerObserver{
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}
- (id)initWithFrame:(CGRect)frame assetDuration:(CMTime)duration
{
    self = [super initWithFrame:frame];
    if (self) {
        self.assetDuration = duration;
        self.isLongPress = NO;
        self.isUserPlayer = NO;
        [self configDefaultValue];
        [self addNotifiations];
        [self configSubViews];
        [self specialEffectsPause];

    }
    return self;
}
- (void)configDefaultValue{
    self.isTimeEffect = NO;
    self.isBackground = NO;
    self.isLongPress = NO;
    self.currentTime = kCMTimeZero;
    [self.effectTimeManager configDefaultValue:self.assetDuration];
}
- (void)configSubViews{
    
    [self addSubview:self.reminderLabel];
    
    [self addSubview:self.pictureProgressView];
    [self addSubview:self.timeProgressView];
    
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.titleView];
    [self.bottomView addSubview:self.pictureView];
    [self.bottomView addSubview:self.timeView];
}

#pragma mark - notifiations
- (void)addNotifiations
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    self.isBackground = YES;
    [self specialEffectsPause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    self.isBackground = NO;
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
    if (self.isLongPress) {
        //长按过程中
    }
    else if (self.isTimeEffect){
        //时间特效播放结束
        [self specialEffectsPause];
        [self.timeProgressView updateTimeSpecialSliderState:YES];
    }
    else if(self.isUserPlayer){
        // 如果是手动点击屏幕播放, 循环播放
        [self specialEffectsSeekToTime:kCMTimeZero];
        [self updateProgressViewWithCurrentTime:kCMTimeZero];
        [self specialEffectsPlay];
    }
}
#pragma mark -- Public
- (void)setPlayer:(AVPlayer *)player{
    if (_player != player) {
        [self removeTimerObserver];
        _player = player;
        @weakify(self);
        self.timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0/60.0, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
            //设置滑块的当前进度
            @strongify(self);
            if (self.player.rate != 0) {
                if (CMTimeCompare(time, self.currentTime) >=0) {
                    self.currentTime = time;
                    [self updateProgressViewWithCurrentTime:time];
                }
            }
        }];
    }
}
- (void)setAssetDuration:(CMTime)assetDuration{
    _assetDuration = assetDuration;
    [self.effectTimeManager setAssetDuration:assetDuration];
    self.pictureProgressView.allTime = assetDuration;
    self.timeProgressView.allTime = assetDuration;
}
- (void)seekToTime:(CMTime)time{
    [self updateProgressViewWithCurrentTime:time];
    [self specialEffectsSeekToTime:time];
}

- (void)updateImageWithDataSource:(NSArray *)imageArray {
    [self.pictureProgressView updateImageWithDataSource:imageArray];
    [self.timeProgressView updateImageWithDataSource:imageArray];
}
- (void)play
{
    if (self.timeProgressView.hidden == NO) {
        [self.timeProgressView updateTimeSpecialSliderState:NO];
        self.isTimeEffect = NO;
    }
    self.isUserPlayer = YES;
    [self specialEffectsPlay];
}

- (void)pause
{
    if (self.timeProgressView.hidden == NO) {
        [self.timeProgressView updateTimeSpecialSliderState:YES];
        self.isTimeEffect = NO;
    }
    self.isUserPlayer = NO;
    [self specialEffectsPause];
}
- (void)resetAllSpecialEffects{
    [self specialEffectsSeekToTime:kCMTimeZero];
    [self.pictureProgressView resetAllEffects];
    [self.timeProgressView resetAllEffects];
    [self.effectTimeManager resetDefultTime];
    [self.timeView resetSelectEffect];
    [self.titleView resetSelectTitleView];
    [self.titleView setRevocationBtnState:[self.pictureProgressView existSpecialModel]];
}

- (void)updateProgressViewWithCurrentTime:(CMTime)time{
    if (self.pictureProgressView.hidden == YES) {
        [self.timeProgressView updateCurrentTime:time];
    }
    else{
        [self.pictureProgressView updateCurrentTime:time];
    }
}

- (void)specialEffectsSeekToTime:(CMTime)time{
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    self.currentTime = time;
}
- (void)specialEffectsPlay{
    if (self.isBackground || ![self isViewVisible]) {
        return;
    }
    self.playButton.hidden = YES;
    [self.player play];
}

- (void)specialEffectsPause{

    self.playButton.hidden = NO;
    [self.player pause];

}
- (BOOL)isViewVisible
{
    return self.window;
}
//在选择动效的时候, 其他按钮都不能使用
- (void)changeEffectOtherViewStatus:(BOOL)isStatus{
    self.pictureProgressView.userInteractionEnabled = isStatus;
    self.titleView.userInteractionEnabled = isStatus;
    self.pictureView.userInteractionEnabled = isStatus;
    self.playerControlView.userInteractionEnabled = isStatus;
}

- (void)changeProgressState:(BOOL)state{
    self.pictureProgressView.hidden = state;
    self.pictureView.hidden = state;
    
    self.timeView.hidden = !state;
    self.timeProgressView.hidden = !state;

    self.isTimeEffect = state;
}

- (void)setIsLongPress:(BOOL)isLongPress {
    _isLongPress = isLongPress;
    [[self class] setCellLongPressShouldBegin:!isLongPress];
}

static BOOL _cellLongPressShouldBegin = YES;
+ (void)setCellLongPressShouldBegin:(BOOL)shouldBegin {
    _cellLongPressShouldBegin = shouldBegin;
}
+ (BOOL)cellLongPressShouldBegin {
    return _cellLongPressShouldBegin;
}

#pragma mark -- Lazy

- (MDSpecialEffectsSelectView *)pictureView{
    if (!_pictureView) {
        _pictureView = [[MDSpecialEffectsSelectView alloc]initWithFrame:CGRectMake(0, self.titleView.bottom, self.width, 112) type:MDRecordSpecialTypeFilter];
        @weakify(self);
        [_pictureView setSpecialEffectsLongBlock:^(BOOL status,MDSpecialEffectsModel *model) {
            @strongify(self);
            if (status) {
                self.isLongPress = YES;
                [self changeEffectOtherViewStatus:NO];
                //先暂停
                [self specialEffectsPause];
                [self.pictureProgressView startPressStateWithCurrentTime:self.currentTime currentModel:model];
                if (self.sendSelectSpecialModel) {
                    self.sendSelectSpecialModel(model,self.currentTime,YES);
                }
                //开始播放
                [self specialEffectsPlay];
            }
            else{
                [self changeEffectOtherViewStatus:YES];
                
                if (self.sendSelectSpecialModel) {
                    self.sendSelectSpecialModel(model,self.currentTime,NO);
                }
                //结束播放
                [self specialEffectsPause];
                BOOL isValid = [self.pictureProgressView endPressStateWithCurrentTime:self.currentTime];
                //如果添加不合法, 需要回撤
                if (!isValid) {
                    if (self.sendRevocationSpecial) {
                        self.sendRevocationSpecial();
                    }
                }
                [self.titleView setRevocationBtnState:[self.pictureProgressView existSpecialModel]];
                self.isLongPress = NO;

            }
        }];
        [_pictureView setSpecialEffectsTapBlock:^(MDSpecialEffectsModel *model) {
            [[UIApplication sharedApplication].delegate.window makeToast:@"特效需长按选择生效" duration:1.5f position:CSToastPositionCenter];
        }];
    }
    return _pictureView;
}

- (MDSpecialEffectsSelectView *)timeView{
    if (!_timeView) {
        _timeView = [[MDSpecialEffectsSelectView alloc]initWithFrame:CGRectMake(0, self.titleView.bottom, self.width, 112) type:MDRecordSpecialTypeTime];

        @weakify(self);
        [_timeView setSpecialEffectsTapBlock:^(MDSpecialEffectsModel *model) {
            @strongify(self);
            self.isTimeEffect = YES;
            //画面特效也需要保存, 因为有反转
            self.pictureProgressView.currentTimeEffectsModel = model;
            //时间特效
            self.timeProgressView.currentTimeEffectsModel = model;
            [self.timeProgressView updateReverseLayerState:(model.type != MDRecordSpecialEffectsTypeReverse) bgColor:model.bgColor];
            BOOL sliderHidden = NO;
            CMTime temporaryTime = [self.effectTimeManager getTimeWithType:model.type];
            if (model.type == MDRecordSpecialEffectsTypeTimeNone){
                //无
                sliderHidden = YES;
                self.isTimeEffect = NO;
            }
            else if (model.type == MDRecordSpecialEffectsTypeReverse){
                sliderHidden = YES;
            }
            if (self.sendSelectTimeModel) {
                self.sendSelectTimeModel(model,temporaryTime);
            }
            self.effectTimeManager.currentTimeEffect = model.type;
            //需要更新时间特效暂停键位置
            [self.timeProgressView updateTimeSpecialSliderProgress:temporaryTime isHidden:sliderHidden];
            [self.timeProgressView updateTimeSpecialSliderState:NO];
            //切换到指定时间 一直播放结束, 而且进度条不可点击
            [self specialEffectsSeekToTime:temporaryTime];
            [self specialEffectsPlay];
        }];
        _timeView.hidden = YES;

        //默认没有动效
        self.effectTimeManager.currentTimeEffect = MDRecordSpecialEffectsTypeTimeNone;
    }
    return _timeView;
}
- (MDSpecialEffectsTitleView *)titleView{
    if (!_titleView) {
        _titleView = [[MDSpecialEffectsTitleView alloc]initWithFrame:CGRectMake(0, 0, self.width, 50)];
        @weakify(self);
        [_titleView setSendSelectFilterBlock:^{
            @strongify(self);
            
            [self specialEffectsPause];
            [self.pictureProgressView updateCurrentTime:self.timeProgressView.currentTime];
            [self changeProgressState:NO];
            [self.titleView setRevocationBtnState:[self.pictureProgressView existSpecialModel]];
            
        }];
        [_titleView setSendSelectTimeBlock:^{
            @strongify(self);
            [self.timeProgressView updateTimeSpecialSliderState:YES];
            [self specialEffectsPause];
            //更新播放进度
            [self.timeProgressView updateCurrentTime:self.pictureProgressView.currentTime];
            [self changeProgressState:YES];
            self.titleView.revocationBtnState = NO;
        }];
        [_titleView setSendRevocationBlock:^{
            @strongify(self);
            [self specialEffectsPause];
            if (self.sendRevocationSpecial) {
                self.sendRevocationSpecial();
            }
             CMTime date = [self.pictureProgressView revocationLastSpecialEffects];
            [self specialEffectsSeekToTime:date];
            [self.titleView setRevocationBtnState:[self.pictureProgressView existSpecialModel]];
            
        }];
    }
    return _titleView;
}

- (MDSpecialEffectsProgressView *)pictureProgressView{
    if (!_pictureProgressView) {
        _pictureProgressView = [[MDSpecialEffectsProgressView alloc]initWithFrame:CGRectMake([MDSpecialEffectsManager getMargin], self.reminderLabel.bottom+10, self.width-2*[MDSpecialEffectsManager getMargin], 50)type:MDRecordSpecialTypeFilter];
        _pictureProgressView.allTime = self.assetDuration;
        @weakify(self);
        [_pictureProgressView setSendMoveBtnProgress:^(CMTime date) {
            @strongify(self);
            CMTime testDate = date;
            [self specialEffectsPause];
            [self specialEffectsSeekToTime:testDate];
        }];
    }

    return _pictureProgressView;
}
- (MDSpecialEffectsProgressView *)timeProgressView{
    if (!_timeProgressView) {
        
        _timeProgressView = [[MDSpecialEffectsProgressView alloc]initWithFrame:CGRectMake([MDSpecialEffectsManager getMargin], self.reminderLabel.bottom+10, self.width-2*[MDSpecialEffectsManager getMargin], 50)type:MDRecordSpecialTypeTime];
        _timeProgressView.allTime = self.assetDuration;

        @weakify(self);
        [_timeProgressView setSendMoveBtnProgress:^(CMTime date) {
            @strongify(self);
            [self specialEffectsPause];
            [self specialEffectsSeekToTime:date];
        }];
        [_timeProgressView setSendTimeBtnProgress:^(CMTime date) {
            @strongify(self);
            if (self.sendSelectTimeModel) {
                self.sendSelectTimeModel(self.timeProgressView.currentTimeEffectsModel, date);
            }
            
            //保存时间
            [self.effectTimeManager saveTimeWithType:self.timeProgressView.currentTimeEffectsModel.type date:date];
            [self.timeProgressView updateCurrentTime:date];

            [self specialEffectsSeekToTime:date];
            [self specialEffectsPlay];
        }];
        _timeProgressView.hidden = YES;
    }
    return _timeProgressView;
}
- (UILabel *)reminderLabel{
    if (!_reminderLabel) {
        _reminderLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width, 14)];
        [_reminderLabel setFont:[UIFont systemFontOfSize:10]];
        [_reminderLabel setTextColor:RGBCOLOR(255, 255, 255)];
        [_reminderLabel setTextAlignment:NSTextAlignmentCenter];
        _reminderLabel.text = @"拖动游标，选择开始位置";
    }
    return _reminderLabel;
}
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.pictureProgressView.bottom+20, self.width, self.height-(self.pictureProgressView.bottom+20))];
        [_bottomView setBackgroundColor:[UIColor clearColor]];

        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:_bottomView.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(10.0, 10.0)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = _bottomView.bounds;
        maskLayer.path = path.CGPath;
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        [_bottomView.layer addSublayer:maskLayer];
    }
    return _bottomView;
}
- (MDEffectsTimeManager *)effectTimeManager{
    if (!_effectTimeManager) {
        _effectTimeManager = [[MDEffectsTimeManager alloc]init];
    }
    return _effectTimeManager;
}
@end
