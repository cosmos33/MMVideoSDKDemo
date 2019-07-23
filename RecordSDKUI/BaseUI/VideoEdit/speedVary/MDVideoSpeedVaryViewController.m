//
//  MDVideoSpeedVaryViewController.m
//  MDChat
//
//  Created by wangxuan on 17/2/21.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDVideoSpeedVaryViewController.h"
#import "MDVideoTrimmerView.h"
//#import "MDVideoNewSpeedControlView.h"
#import "MDVideoSpeedVaryHandler.h"
#import "MDDocument.h"
#import "MDRecordHeader.h"
#import "MDPublicSwiftHeader.h"
#import "Toast/Toast.h"

static NSInteger kControlViewDefaultIndex;

@interface MDVideoSpeedVaryViewController ()<MDVideoTrimmerViewDelegate>

//UI
@property (nonatomic, strong) UIButton      *completeButton;
@property (nonatomic, strong) UIButton      *cancelBtn;
@property (nonatomic, strong) UIImageView   *playButton;
@property (nonatomic, strong) MDVideoTrimmerView *videoTrimmerView;
//@property (nonatomic, strong) MDVideoNewSpeedControlView *controlView;
@property (nonatomic, strong) UILabel       *guideLabel;
@property (nonatomic, strong) UIView        *visualBgEffectView;//高斯模糊view

@property (nonatomic, assign) NSTimeInterval imageInterval;

//
@property (nonatomic, strong) AVAsset       *asset;
@property (nonatomic, strong) MDVideoSpeedVaryHandler   *handler;
@property (nonatomic, weak)   id<MDVideoSpeedVaryDelegate> delegate;
@property (nonatomic, strong) id            timeObserver;
@property (nonatomic, strong) NSValue       *playTimeRange;
@property (nonatomic, assign) BOOL          isSeeking;

@property (nonatomic, strong) VideoNewSpeedSlider *sliderView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation MDVideoSpeedVaryViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeTimeObserver];
}

- (instancetype)initWithAsset:(AVAsset *)asset
                     document:(MDDocument *)document
                     delegate:(id<MDVideoSpeedVaryDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.asset = asset;
        self.handler = [[MDVideoSpeedVaryHandler alloc] initWithDocument:document];
        self.delegate = delegate;
        
//        kControlViewDefaultIndex = 2;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubViews];
    [self addNotifiations];
    [self addTimeObserver];
    [self synchronizeWithPlayer:self.player];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.handler stashEffectsOnVideoTrimView:self.videoTrimmerView];
    self.playButton.hidden = YES;
    [self seekPlayerTime:kCMTimeZero];
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - play control
- (void)addNotifiations
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self pause];
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
    if ([self isViewVisible]) {
        [self pause];
    }
}

- (void)removeTimeObserver
{
    if (_timeObserver && _player) {
        [_player removeTimeObserver:self.timeObserver];
        _timeObserver = nil;
    }
}

- (void)addTimeObserver
{
    [self removeTimeObserver];
    if (self.player) {
        __weak __typeof(self) weakSelf = self;
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0/60.0, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [weakSelf periodicTimeCallback:time];
        }];
    }
}

- (void)periodicTimeCallback:(CMTime)time
{
    if (self.isSeeking) return;
        
    if ([self isViewVisible] && self.playTimeRange) {
        CMTimeRange playTimeRange = [self.playTimeRange CMTimeRangeValue];
        CMTime endTime = CMTimeAdd(playTimeRange.start, playTimeRange.duration);
        if (CMTimeCompare(time, endTime) >= 0) {
            [self pause];
        }
    }
}

- (BOOL)isViewVisible
{
    return self.isViewLoaded && self.view.window;
}

- (void)synchronizeWithPlayer:(AVPlayer *)player
{
    [self.videoTrimmerView synchronizeWithPlayer:player];
}

- (void)synchronizePlayerTime
{
    CMTime time = self.videoTrimmerView.currentPointerTime;
    CMTime convertTime = [self.handler convertToMediaSouceTimeFromPresentationTime:time];
    [self.player seekToTime:convertTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - UI
- (void)setupSubViews
{
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.visualBgEffectView addSubview:self.label];
    
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.completeButton];

    [self.view addSubview:self.playButton];

    [self.view addSubview:self.visualBgEffectView];
    [self.view addSubview:self.videoTrimmerView];
//    [self.view addSubview:self.controlView];
    [self.view addSubview:self.sliderView];
    
    [self.label.leftAnchor constraintEqualToAnchor:self.visualBgEffectView.leftAnchor constant:27].active = YES;
    [self.label.topAnchor constraintEqualToAnchor:self.visualBgEffectView.topAnchor constant:20].active = YES;
    
    [self.cancelBtn.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:10].active = YES;
    [self.cancelBtn.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15 + HOME_INDICATOR_HEIGHT].active = YES;
    
    [self.completeButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-10].active = YES;
    [self.completeButton.centerYAnchor constraintEqualToAnchor:self.cancelBtn.centerYAnchor].active = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView:)];
    [self.view addGestureRecognizer:tap];
}

- (MDVideoTrimmerView *)videoTrimmerView
{
    if (!_videoTrimmerView) {
        NSTimeInterval interval = CMTimeGetSeconds(self.asset.duration) <= 20.0f ? 1 : 2;
        self.imageInterval = interval;

        _videoTrimmerView = [[MDVideoTrimmerView alloc] initWithFrame:CGRectMake(0, MDScreenHeight - 60 - HOME_INDICATOR_HEIGHT, CGRectGetWidth(self.view.frame), 48) asset:self.asset imageTimeInterval:interval];
        _videoTrimmerView.delegate = self;
    }
    return _videoTrimmerView;
}

- (UIButton *)completeButton
{
    if (!_completeButton) {
//        UIImage *image = [UIImage imageNamed:@"media_editor_compelete"];
//        _completeButton = [[UIButton alloc] initWithFrame:CGRectMake(MDScreenWidth -15 - image.size.width, 15 + HOME_INDICATOR_HEIGHT, image.size.width, image.size.height)];
//        [_completeButton setImage:image forState:UIControlStateNormal];
        _completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_completeButton setTitle:@"完成" forState:UIControlStateNormal];
        [_completeButton addTarget:self action:@selector(completeTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _completeButton;
}

- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
//        UIImage *cancelImg = [UIImage imageNamed:@"moment_return"];
//        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 11 + HOME_INDICATOR_HEIGHT, cancelImg.size.width +20, cancelImg.size.height +20)];
//        [cancelBtn setImage:cancelImg forState:UIControlStateNormal];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelBtn = cancelBtn;
    }
    
    return _cancelBtn;
}

- (UIImageView *)playButton
{
    if (!_playButton) {
        UIImage *pauseImage = [UIImage imageNamed:@"moment_play_pause"];
        _playButton = [[UIImageView alloc] initWithImage:pauseImage];
        
        _playButton.frame = CGRectMake(0, 0, pauseImage.size.width, pauseImage.size.height);
        _playButton.center = self.view.center;
        _playButton.hidden = YES;
    }
    
    return _playButton;
}

- (UILabel *)guideLabel
{
    if (!_guideLabel) {
        _guideLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, 200)];
        _guideLabel.textColor = [UIColor whiteColor];
        _guideLabel.font = [UIFont systemFontOfSize:130];
        _guideLabel.textAlignment = NSTextAlignmentCenter;
        _guideLabel.centerY = self.view.height *0.5f;
        _guideLabel.transform = CGAffineTransformMakeScale(0.6, 0.6);
        [self.view addSubview:_guideLabel];
        
    }
    return _guideLabel;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.font = [UIFont systemFontOfSize:14];
        _label.textColor = UIColor.whiteColor;
        _label.text = @"变速";
    }
    return _label;
}

//- (MDVideoNewSpeedControlView *)controlView {
//    if (!_controlView) {
//        _controlView = [[MDVideoNewSpeedControlView alloc] initWithFrame:CGRectMake(0, MDScreenHeight - 150 - HOME_INDICATOR_HEIGHT, 275, 33)];
//        _controlView.centerX = self.view.width/2.0;
//        [_controlView addTarget:self action:@selector(videoControlValueChanged:) forControlEvents:UIControlEventValueChanged];
//
//        NSArray *segmentArray = @[
//                                  [MDVideoNewSpeedControlItem itemWithTitle:@"极慢" factor:2.0f],
//                                  [MDVideoNewSpeedControlItem itemWithTitle:@"慢" factor:1.5f],
//                                  [MDVideoNewSpeedControlItem itemWithTitle:@"标准" factor:1.0f],
//                                  [MDVideoNewSpeedControlItem itemWithTitle:@"快" factor:0.5f],
//                                  [MDVideoNewSpeedControlItem itemWithTitle:@"极快" factor:0.25f],
//                                  ];
//        [_controlView layoutWithSegmentTitleArray:segmentArray];
//        [_controlView setCurrentSegmentIndex:kControlViewDefaultIndex animated:NO];
//    }
//    return _controlView;
//}

- (VideoNewSpeedSlider *)sliderView {
    if (!_sliderView) {
        _sliderView = [[VideoNewSpeedSlider alloc] initWithFrame:CGRectMake(0, MDScreenHeight - 180 - HOME_INDICATOR_HEIGHT, MDScreenWidth - 60, 83)];
        _sliderView.centerX = self.view.centerX;
        __weak typeof(self) weakself = self;
        _sliderView.valueChanged = ^(VideoNewSpeedSlider * slider, float value) {
            if ([weakself varySpeedSegment:value]) {
                [weakself showGuideTipWithText:@"变速"];
            }
        };
        _sliderView.value = 1.0;
    }
    return _sliderView;
}

- (UIView *)visualBgEffectView
{
    if(!_visualBgEffectView){
        _visualBgEffectView = [[UIView alloc] initWithFrame:CGRectMake(0, MDScreenHeight-HOME_INDICATOR_HEIGHT-235, MDScreenWidth, HOME_INDICATOR_HEIGHT+245)];
        _visualBgEffectView.layer.cornerRadius = 10;
        _visualBgEffectView.layer.masksToBounds = YES;
        
        UIView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        visualEffectView.frame = _visualBgEffectView.bounds;
        [_visualBgEffectView addSubview:visualEffectView];
    }
    return _visualBgEffectView;
}

#pragma mark - MDVideoTrimmerViewDelegate
- (CMTime)videoTrimmerView:(MDVideoTrimmerView *)trimmerView mediaSouceTimeFromPresentationTime:(CMTime)presentationTime
{
    return [self.handler convertToMediaSouceTimeFromPresentationTime:presentationTime];
}

- (CMTime)videoTrimmerView:(MDVideoTrimmerView *)trimmerView presentationTimeFromMediaSourceTime:(CMTime)mediaSourceTime
{
    return [self.handler convertToPresentationTimeFromMediaSourceTime:mediaSourceTime];
}

- (void)videoTrimmerViewDidChangeSelected:(MDVideoTrimmerView *)trimmerView
{
    if (trimmerView.selectedTrimmerRangeIndex != NSNotFound) {
        if (self.handler.segmentFactors.count != self.videoTrimmerView.trimmerTimeRanges.count) {
            return;
        }
        
//        self.controlView.hidden = NO;
//        float factor = [self.handler speedFactorWithVideoTrimView:self.videoTrimmerView];
//        NSInteger index = kControlViewDefaultIndex;
//        for (int i = 0; i < self.controlView.segmentTitleArray.count; i++) {
//            MDVideoNewSpeedControlItem *item = [self.controlView.segmentTitleArray objectAtIndex:i defaultValue:nil];
//            if (item.factor == factor) {
//                index = i; break;
//            }
//        }
//        [self.controlView setCurrentSegmentIndex:index animated:NO];
        self.sliderView.hidden = NO;
        float factor = [self.handler speedFactorWithVideoTrimView:self.videoTrimmerView];
        self.sliderView.value = factor;
        CMTimeRange timeRange = [self.handler convertToPresentationTimeRange:self.videoTrimmerView];
        self.playTimeRange = [NSValue valueWithCMTimeRange:timeRange];
    } else {
//        [self.controlView setCurrentSegmentIndex:kControlViewDefaultIndex animated:NO];
        self.sliderView.value = 1.0;
        self.playTimeRange = nil;
    }
}

- (void)videoTrimmerViewDidStartChange:(MDVideoTrimmerView *)trimmerView
{
    [self pause];
    [self.delegate speedEffectDidStartChanged];
}

- (void)videoTrimmerViewDidEndChange:(MDVideoTrimmerView *)trimmerView
{
    [self.handler scaleEffectOnVideoTrimView:trimmerView];
    [self notifyDelegateDidEndChanged];
}

#pragma mark - control
- (void)didTapView:(UIGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.view];
//    if (CGRectContainsPoint(self.videoTrimmerView.frame, point) || CGRectContainsPoint(self.controlView.frame, point)) {
//        return;
//    }
    
    if (CGRectContainsPoint(self.videoTrimmerView.frame, point) || CGRectContainsPoint(self.sliderView.frame, point)) {
        return;
    }

    if (self.player.rate != 0) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)completeTapped
{
    [self exitSpeedVaryEditing];
}

- (void)cancelButtonTapped:(id)sender
{
    //调速栏回原速 ：
//    [self.controlView setCurrentSegmentIndex:kControlViewDefaultIndex animated:NO];
    self.sliderView.value = 1.0;

    self.playTimeRange = nil;
    [self.handler recoverFromEffectsStashOnVideoTrimView:self.videoTrimmerView];
    [self notifyDelegateDidEndChanged];

    [self exitSpeedVaryEditing];
}

- (void)exitSpeedVaryEditing
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if ([self.delegate respondsToSelector:@selector(videoSpeedVarydidFinishedEditing)]) {
        [self.delegate videoSpeedVarydidFinishedEditing];
    }
}

//- (void)videoControlValueChanged:(MDVideoNewSpeedControlView *)sender
//{
//    MDVideoNewSpeedControlItem *item = [sender.segmentTitleArray objectAtIndex:sender.selectedIndex defaultValue:nil];
//    if ([self varySpeedSegment:item.factor]) {
//        [self showGuideTipWithText:item.title];
//    }
//}

- (BOOL)checkCanAddScaleEffect
{
    BOOL canAdd = self.videoTrimmerView.trimmerTimeRanges.count < 5;
//    BOOL canAdd = YES;

    //最大5个变速区时提示用户
    if (!canAdd) {
        [self.view makeToast:@"变速已达上限" duration:1.5f position:CSToastPositionCenter];
//        self.controlView.hidden = YES;
        self.sliderView.hidden = YES;
    }
    
    return canAdd;
}

- (BOOL)varySpeedSegment:(float)speedFactor
{
    [self pause];
    
    BOOL success = NO;
    if (self.videoTrimmerView.selectedTrimmerRangeIndex != NSNotFound) {
        if (speedFactor == 1.0f) {
            success = [self.handler removeCurrentEffectOnVideoTrimView:self.videoTrimmerView];
            [self.videoTrimmerView deleteSelectedTimeRange];
        } else {
           success = [self.handler changeEffectFactor:speedFactor videoTrimView:self.videoTrimmerView];
        }        
    } else if ([self checkCanAddScaleEffect] && speedFactor != 1.0) {
        success = [self.handler addEffect:speedFactor duration:self.imageInterval *2 videoTrimView:self.videoTrimmerView];
        if (!success) {
            [self.view makeToast:@"当前位置不足2s" duration:1.5f position:CSToastPositionCenter];
//            [self.controlView setCurrentSegmentIndex:kControlViewDefaultIndex animated:NO];
            self.sliderView.value = 1.0;
        }
    }
    [self notifyDelegateDidEndChanged];
    
    return success;
}

- (void)notifyDelegateDidEndChanged
{
    [self.delegate speedEffectDidEndChanged:kCMTimeRangeZero];
    [self.player seekToTime:self.videoTrimmerView.currentPointerTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)showGuideTipWithText:(NSString *)text
{
    [self.guideLabel.layer removeAllAnimations];
    self.guideLabel.text = text;
    self.guideLabel.alpha = 1.0f;
    self.guideLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
    self.playButton.hidden = YES;
    [UIView animateWithDuration:2.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.guideLabel.alpha = .1f;
                         self.guideLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
                     } completion:^(BOOL finished) {
                         self.guideLabel.alpha = .0f;
                         self.guideLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
                         if (finished) {
                             self.playButton.hidden = self.player.rate > 0;
                         } else {
                             self.playButton.hidden = YES;
                         }
                     }];
}

- (void)play
{
//    self.controlView.hidden = YES;
    self.sliderView.hidden = YES;
    self.playButton.hidden = YES;
    
    [self playWithTimeRange];
}

- (void)playWithTimeRange
{
    MDVideoTrimmerView *trimmerView = self.videoTrimmerView;
    
    if (trimmerView.selectedTrimmerRangeIndex != NSNotFound
        && [trimmerView isCurrentPointerInSelectedRange]) {
        CMTimeRange playTimeRange = [self.handler convertToPresentationTimeRange:trimmerView];
        self.playTimeRange = [NSValue valueWithCMTimeRange:playTimeRange];
        [self seekPlayerTime:playTimeRange.start];
    } else {
        self.playTimeRange = nil;
        
        if (CMTimeCompare(self.player.currentTime, self.player.currentItem.duration) >= 0) {
            [self seekPlayerTime:kCMTimeZero];
        } else {
            CMTime playTime = [self.handler convertToPresentationTimeFromMediaSourceTime:trimmerView.currentPointerTime];
            [self seekPlayerTime:playTime];
        }
    }
    
    [self.player play];
}

- (void)pause
{
//    self.controlView.hidden = NO;
    self.sliderView.hidden = NO;
    self.playButton.hidden = NO;
    
    [self.player pause];
}

- (void)seekPlayerTime:(CMTime)time
{
    self.isSeeking = YES;
    __weak __typeof(self) weakSelf = self;
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        weakSelf.isSeeking = NO;
    }];
}

@end
