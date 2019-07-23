//
//  MDSpecialEffectsController.m
//  MDChat
//
//  Created by YZK on 2018/8/3.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDSpecialEffectsController.h"
#import "MDDocument.h"

#import "MDSpecialEffectsView.h"

@import RecordSDK;
@import KVOController;
#import "MDRecordSpecialEffectsManager.h"
#import "MDMediaEffect.h"

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "MDRecordHeader.h"

static const CGFloat kTopViewHeight = 23.0f;
static const CGFloat kBottomViewHeight = 297.0f;

@interface MDSpecialEffectsController ()

@property (nonatomic, weak) MDDocument *document;
@property (nonatomic, weak) id<MDSpecialEffectsControllerDelegate> delegate;
@property (nonatomic, weak) MDRecordPlayerViewController *playerViewController;

@property (nonatomic, strong) UIView                 *playerBgView;
@property (nonatomic, strong) UIButton               *completeButton;
@property (nonatomic, strong) UIButton               *cancelBtn;
@property (nonatomic, strong) UIImageView            *playButton;
@property (nonatomic, strong) UIView                 *bottomView;
@property (nonatomic, strong) MDSpecialEffectsView   *effectsView;

@property (nonatomic, readwrite) BOOL   isShow;
@property (nonatomic, assign   ) BOOL   isBackground;
@property (nonatomic, assign   ) CMTime beginTime;
@property (nonatomic, assign   ) CMTime assetDuration;

@end

@implementation MDSpecialEffectsController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.KVOController unobserveAll];
}

- (instancetype)initWithDocument:(MDDocument *)document
            playerViewController:(MDRecordPlayerViewController *)playerViewController
                        delegate:(id<MDSpecialEffectsControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.document = document;
        self.playerViewController = playerViewController;
        self.delegate = delegate;
        
        __weak typeof(self) weakSelf = self;
        [self.KVOController observe:self.playerViewController.player keyPath:@"currentItem"
                            options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
                              block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                                  AVPlayerItem *currentItem = [change objectForKey:NSKeyValueChangeNewKey];
                                  weakSelf.assetDuration = currentItem.duration;
                                  weakSelf.effectsView.assetDuration = currentItem.duration;
                              }];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
}

- (void)setupSubViews
{
    self.view.backgroundColor = RGBCOLOR(39, 39, 39);

    [self.view addSubview:[self setupCancelBtn]];
    [self.view addSubview:[self setupCompleteButton]];
    
    [self.view addSubview:[self setupPlayerBgView]];
    [self.playerBgView addSubview:[self setupPlayButton]];
    
    [self.view addSubview:[self setupBottomView]];
    [self.bottomView addSubview:[self setupEffectsView]];
}

#pragma mark - public

- (void)updateSpecialImageArray:(NSArray *)imageArray {
    self.specialImageArray = imageArray;
    [self.effectsView updateImageWithDataSource:imageArray];
}
- (void)seekPlayTime:(CMTime)time{
    [self.effectsView seekToTime:time];
}

#pragma mark - show or hide

- (void)showWithAnimated:(BOOL)animated {
    self.isShow = YES;
    self.effectsView.player = self.playerViewController.player;
    [self.effectsView seekToTime:kCMTimeZero];
    [self.effectsView pause];
    
    
    CGFloat scale = self.playerBgView.height/MDScreenHeight;
    
    [self addChildViewController:self.playerViewController];
    [self.view addSubview:self.playerViewController.view];
    [self.playerViewController didMoveToParentViewController:self];
    
    [UIView animateWithDuration:animated?0.3:0.001 animations:^{
        self.playerViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.playerViewController.view.center = self.playerBgView.center;
    } completion:^(BOOL finished) {
        [self.view insertSubview:self.playerViewController.view belowSubview:self.playerBgView];
    }];
}

- (void)dismissWithAnimated:(BOOL)animated {
    self.isShow = NO;
    [self.effectsView pause];

    self.effectsView.player = nil;
    
    [self.view bringSubviewToFront:self.playerViewController.view];
    [UIView animateWithDuration:animated?0.3:0.001 animations:^{
        self.playerViewController.view.transform = CGAffineTransformIdentity;
        self.playerViewController.view.center = CGPointMake(MDScreenWidth/2.0, MDScreenHeight/2.0);
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(specialEffectsDidFinishedEditing)]) {
            [self.delegate specialEffectsDidFinishedEditing];
        }
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

#pragma mark - event

- (void)completeTapped
{
    [self dismissWithAnimated:YES];
}

- (void)cancelButtonTapped
{
    if (![self.document hasSpecialEffects]) {
        [self dismissWithAnimated:YES];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否放弃特效滤镜效果?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf removeAllTimeEffectsWithUpdate:YES];
//        [weakSelf.specialEffectsFilter deleteAllFilter];
        [self.document.adapter deleteAllSpecialFilters];
        [weakSelf.effectsView resetAllSpecialEffects];
        [weakSelf dismissWithAnimated:YES];
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)changePlayStatus
{
    if (self.playerViewController.player.rate == 0) {
        [self.effectsView play];
    } else {
        [self.effectsView pause];
    }
}

//画面特效处理
- (void)filterPressWithSpecialEffectsType:(MDRecordSpecialEffectsType)type currentTime:(CMTime)currentTime isStart:(BOOL)isStart {
    if (isStart) {
        self.beginTime = currentTime;
        
        GPUImageOutput<GPUImageInput,MDRSpecialFilterLifeStyleProtocol> *filter = [MDRecordSpecialEffectsManager getFilterWithSpecialEffectsType:type];
//        [self.specialEffectsFilter addFilter:filter timeRange:CMTimeRangeMake(self.beginTime, self.assetDuration)];
        [self.document.adapter addSpecialFilter:filter timeRange:CMTimeRangeMake(self.beginTime, self.assetDuration)];
    }else {
        CMTime endTime = currentTime;
        if (CMTimeCompare(endTime, self.beginTime)>0) {
            CMTimeRange timeRange = CMTimeRangeFromTimeToTime(self.beginTime, endTime);
//            [self.specialEffectsFilter updateCurrentFilterWithTime:endTime timeRange:timeRange];
            [self.document.adapter updateCurrentFilterWithTime:endTime timeRange:timeRange];
        }
        self.beginTime = kCMTimeZero;
    }
}
- (void)deleteLastSpecialEffects {
//    [self.specialEffectsFilter deleteLastFilter];
    [self.document.adapter deleteLastSpecialFilter];
}

//时间特效处理
- (void)filterPressWithTimeEffectsType:(MDRecordSpecialEffectsType)type currentTime:(CMTime)currentTime {
    [self removeAllTimeEffectsWithUpdate:NO];
    
    switch (type) {
        case MDRecordSpecialEffectsTypeSlowMotion:
        {
            CMTimeRange timeRange = [self getTimeRangeWithCurrentTime:currentTime second:0.2];
            id<MLTimeRangeMappingEffect> timeEffect = MLTimeRangeMappingEffectMake(timeRange, 3.0);
            self.document.timeEffectsItem = timeEffect;
        }
            break;
        case MDRecordSpecialEffectsTypeQuickMotion:
        {
            CMTimeRange timeRange = [self getTimeRangeWithCurrentTime:currentTime second:0.6];
            id<MLTimeRangeMappingEffect> timeEffect = MLTimeRangeMappingEffectMake(timeRange, 1.0/3);
            self.document.timeEffectsItem = timeEffect;
        }
            break;
        case MDRecordSpecialEffectsTypeRepeat:
        {
            CMTimeRange timeRange = [self getTimeRangeWithCurrentTime:currentTime second:0.2];
            self.document.presentRepeatRange = timeRange;
        }
            break;
        case MDRecordSpecialEffectsTypeReverse:
        {
            self.document.reserve = YES;
//            [self.specialEffectsFilter setReverse:YES];
            [self.document.adapter setReverse:YES];
        }
            break;
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(specialEffectsDidChange)]) {
        [self.delegate specialEffectsDidChange];
    }
}

- (CMTimeRange)getTimeRangeWithCurrentTime:(CMTime)currentTime second:(NSTimeInterval)second {
    //TODO:yzk 这里不应使用self.assetDuration，应该使用document.asset
    CMTime duration = CMTimeMakeWithSeconds(second, NSEC_PER_SEC);
    CMTime maxTime = CMTimeSubtract(self.assetDuration, duration);
    if (CMTimeCompare(currentTime, maxTime)>0) {
        currentTime = maxTime;
    }
    CMTimeRange timeRange = CMTimeRangeMake(currentTime, duration);
    return timeRange;
}

- (void)removeAllTimeEffectsWithUpdate:(BOOL)update {
    self.document.timeEffectsItem = nil;
    self.document.presentRepeatRange = kCMTimeRangeInvalid;
    self.document.reserve = NO;
//    [self.specialEffectsFilter setReverse:NO];
    [self.document.adapter setReverse:NO];
    
    if (update && [self.delegate respondsToSelector:@selector(specialEffectsDidChange)]) {
        [self.delegate specialEffectsDidChange];
    }
}

#pragma mark - UI

- (UIButton *)setupCompleteButton
{
    if (!_completeButton) {
        _completeButton = [[UIButton alloc] initWithFrame:CGRectMake(MDScreenWidth-42-10 , STATUS_BAR_HEIGHT, 42, kTopViewHeight)];
        [_completeButton setTitle:@"保存" forState:UIControlStateNormal];
        [_completeButton setTitleColor:RGBCOLOR(255, 255, 255) forState:UIControlStateNormal];
        _completeButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_completeButton addTarget:self action:@selector(completeTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeButton;
}

- (UIButton *)setupCancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, STATUS_BAR_HEIGHT, 42, kTopViewHeight)];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:RGBACOLOR(255, 255, 255, 0.3) forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelBtn addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelBtn;
}

- (UIView *)setupPlayerBgView {
    if (!_playerBgView) {
        CGFloat top = self.completeButton.bottom+7;
        CGFloat height = MDScreenHeight-top-(kBottomViewHeight+HOME_INDICATOR_HEIGHT);
        _playerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, top, MDScreenWidth, height)];
        _playerBgView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePlayStatus)];
        [_playerBgView addGestureRecognizer:tapGR];
    }
    return _playerBgView;
}

- (UIImageView *)setupPlayButton
{
    if (!_playButton) {
        UIImage *pauseImage = [UIImage imageNamed:@"specialeffect_play_pause"];
        _playButton = [[UIImageView alloc] initWithImage:pauseImage];
        _playButton.center = CGPointMake(self.playerBgView.width/2.0, self.playerBgView.height/2.0);
        _playButton.hidden = YES;
    }
    
    return _playButton;
}

- (UIView *)setupBottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MDScreenHeight-(kBottomViewHeight+HOME_INDICATOR_HEIGHT), MDScreenWidth, kBottomViewHeight+HOME_INDICATOR_HEIGHT)];
    }
    return _bottomView;
}

- (MDSpecialEffectsView *)setupEffectsView
{
    if (!_effectsView) {
        _effectsView = [[MDSpecialEffectsView alloc] initWithFrame:CGRectMake(0, 20, MDScreenWidth, self.bottomView.height -20) assetDuration:self.assetDuration];
        _effectsView.playButton = self.playButton;
        _effectsView.playerControlView = self.playerBgView;
        [_effectsView updateImageWithDataSource:self.specialImageArray];
        @weakify(self);
        _effectsView.sendSelectSpecialModel = ^(MDSpecialEffectsModel *model, CMTime currentTime, BOOL isStart) {
            @strongify(self);
            [self filterPressWithSpecialEffectsType:model.type currentTime:currentTime isStart:isStart];
        };
        _effectsView.sendSelectTimeModel = ^(MDSpecialEffectsModel *model, CMTime currentTime) {
            @strongify(self);
            [self filterPressWithTimeEffectsType:model.type currentTime:currentTime];
        };
        _effectsView.sendRevocationSpecial = ^{
            @strongify(self);
            [self deleteLastSpecialEffects];
        };
    }
    return _effectsView;
}


@end
