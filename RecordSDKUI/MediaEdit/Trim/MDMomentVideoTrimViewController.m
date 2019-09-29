//
//  MDMomentVideoTrimViewController.m
//  MDChat
//
//  Created by wangxuan on 17/2/15.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMomentVideoTrimViewController.h"
#import "MDVideoTrimmerView.h"
#import "MDNavigationTransitionExtra.h"
//#import "MDVideoRecordDefine.h"
#import "SDDownloadProgressView.h"
#import "MDBluredProgressView.h"
#import "MUAt8AlertBar.h"
#import "MUAlertBarDispatcher.h"

static const NSTimeInterval kDefaultInsertDuration = 20.0f;

@interface MDMomentVideoTrimViewController ()<MDVideoTrimmerViewDelegate,MDNavigationBarAppearanceDelegate>


@property (nonatomic, strong) MDVideoTrimmerView *videoTrimmerView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIButton  *doneBtn;
@property (nonatomic, strong) UIButton  *cancelBtn;
@property (nonatomic, strong) UIImageView   *playButton;
@property (nonatomic, strong) UILabel   *tipLabel;

@property (nonatomic, copy)   videoTrimClosedHandler closeHandler;
@property (nonatomic, strong) id periodicTimeObserver;
@property (nonatomic, assign) BOOL          isSeeking;
@property (nonatomic, strong) NSValue        *playTimeRange;

@property (nonatomic, assign) NSTimeInterval maxDuration;

//导出
@property (nonatomic, assign) BOOL isBackground;

@end

@implementation MDMomentVideoTrimViewController

- (void)dealloc
{
    [_player removeTimeObserver:self.periodicTimeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithMaxDuration:(NSTimeInterval)maxDuration CloseHandler:(videoTrimClosedHandler)closeHandler
{
    self = [super init];
    if(self){
        self.closeHandler = closeHandler;
        self.maxDuration = maxDuration;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAVPlayer];
    [self setupSubviews];
    [self addNotifiations];
    [self.videoTrimmerView synchronizeWithPlayer:self.player];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setupAVPlayer
{
    self.player = [[AVPlayer alloc] init];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.playerLayer];
    
    
    if (self.originVideoURL) {
        self.asset = [AVURLAsset assetWithURL:self.originVideoURL];
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.asset];
    [self.player replaceCurrentItemWithPlayerItem:item];
    
    
    __weak __typeof(self) weakSelf = self;
    self.periodicTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0/60.0, NSEC_PER_SEC)
                                                                      queue:NULL
                                                                 usingBlock:^(CMTime time) {
                                                                     [weakSelf checkNeedPause:time];
                                                                 }];
    
}

- (void)addNotifiations
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    self.isBackground = YES;
    [self pause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    self.isBackground = NO;
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
    [self pause];
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIImage *image = [UIImage imageNamed:@"moment_record_complete"];
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(MDScreenWidth - 15 -image.size.width, 15 + HOME_INDICATOR_HEIGHT, image.size.width, image.size.height)];
    [doneButton setImage:image forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
    self.doneBtn = doneButton;
    
    UIImage *cancelImg = [UIImage imageNamed:@"moment_return"];
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 15 + HOME_INDICATOR_HEIGHT, 40, 40)];
    [cancelBtn setImage:cancelImg forState:UIControlStateNormal];
    cancelBtn.centerY = doneButton.centerY;
    [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    self.cancelBtn = cancelBtn;
    
    //trimView
    AVAsset *asset = self.player.currentItem.asset;
    NSTimeInterval imageInteval = CMTimeGetSeconds(self.asset.duration) > 2 *60.0f ? 10 : 5;
    
    MDVideoTrimmerView *videoTrimmerView = [[MDVideoTrimmerView alloc] initWithFrame:CGRectMake(0, MDScreenHeight - 100, self.view.width, 48) asset:asset imageTimeInterval:imageInteval];
    videoTrimmerView.maxVideoSesonds = self.maxDuration;
    videoTrimmerView.borderTimeLabelHidden = YES;
    videoTrimmerView.delegate = self;
    self.videoTrimmerView = videoTrimmerView;
    [self.view addSubview:videoTrimmerView];
    
    NSTimeInterval insertDuration = self.insertDuration > 0 ? self.insertDuration : MIN(self.maxDuration, kDefaultInsertDuration);
    CMTimeRange range = CMTimeRangeMake(CMTimeMakeWithSeconds(0, self.asset.duration.timescale), CMTimeMakeWithSeconds(insertDuration, self.asset.duration.timescale));
    [videoTrimmerView insertTimeRange:range];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MDScreenHeight -25, self.view.width, 15)];
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.text = [NSString stringWithFormat:@"你已裁剪%.0f秒",insertDuration];
    [self.view addSubview:tipLabel];
    self.tipLabel = tipLabel;
    
    [self showThumbSelectGuideView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView:)];
    [self.view addGestureRecognizer:tap];
}

- (void)showThumbSelectGuideView {
    
    CGPoint anchorPoint = CGPointMake(self.view.width *0.5f, self.videoTrimmerView.top -30);
    MUAt8AlertBarModel *model = [[MUAt8AlertBarModel alloc] init];
    model.maskFrame = self.view.bounds;
    CGFloat duration = self.maxDuration;
    model.title = [NSString stringWithFormat:@"视频时长超过%.0fs，请截取",duration];
    model.anchorPoint = anchorPoint;
    model.anchorType = MUAt8AnchorTypeBottom;
    model.anchorOffset = 0;
    MUAlertBar *guideView = [MUAlertBarDispatcher alertBarWithModel:model];
    [self.view addSubview:guideView];
}

- (UIImageView *)playButton
{
    if (!_playButton) {
        UIImage *pauseImage = [UIImage imageNamed:@"moment_play_pause"];
        _playButton = [[UIImageView alloc] initWithImage:pauseImage];
        
        _playButton.frame = CGRectMake(0, 0, pauseImage.size.width, pauseImage.size.height);
        _playButton.center = self.view.center;
        _playButton.hidden = YES;
        [self.view addSubview:_playButton];
    }
    
    return _playButton;
}

#pragma mark - control
- (void)done:(id)sender
{
    if (self.needShowConfirm) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"裁剪后不可重新编辑，是否确认？"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        [alert show];
    } else {
        CMTimeRange timeRange = [self.videoTrimmerView.trimmerTimeRanges.firstObject CMTimeRangeValue];
        [self exitWithTimeRange:timeRange];
    }
}

- (void)cancel:(id)sender
{
    [self exitWithTimeRange:kCMTimeRangeInvalid];
}

- (void)exitWithTimeRange:(CMTimeRange)timeRange
{
    if (self.closeHandler) {
        self.closeHandler(self, self.asset, timeRange);
    }
}

- (void)checkNeedPause:(CMTime)currentTime
{
    if (self.isSeeking) {
        return;
    }
    
    CMTimeRange playTimeRange = [self.playTimeRange CMTimeRangeValue];
    CMTime endTime = CMTimeAdd(playTimeRange.start, playTimeRange.duration);
    
    if (CMTimeCompare(currentTime, endTime) >= 0) {
        [self pause];
    }
}

- (void)didTapView:(UIGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.view];
    //fix:点击区域
    if (CGRectContainsPoint(self.videoTrimmerView.frame, point) || CGRectContainsPoint(CGRectMake(self.cancelBtn.left - 35, self.cancelBtn.top - 35, 70, 70), point)) {
        return;
    }
    
    if (self.player.rate != 0) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)play
{
    self.playButton.hidden = YES;
    
    MDVideoTrimmerView *trimmerView = self.videoTrimmerView;
    
    if (trimmerView.selectedTrimmerRangeIndex != NSNotFound
        && [trimmerView isCurrentPointerInSelectedRange]) {
        CMTimeRange timeRange = trimmerView.selectedTrimmerTimeRange;
        self.playTimeRange = [NSValue valueWithCMTimeRange:timeRange];
        [self seekPlayerTime:timeRange.start];
    } else {
        self.playTimeRange = nil;
        
        if (CMTimeCompare(self.player.currentTime, self.asset.duration) >= 0) {
            [self seekPlayerTime:kCMTimeZero];
            
        } else {
            [self seekPlayerTime:trimmerView.currentPointerTime];
        }
    }

    [self.player play];
}

- (void)pause
{
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        CMTimeRange timeRange = [self.videoTrimmerView.trimmerTimeRanges.firstObject CMTimeRangeValue];
        [self exitWithTimeRange:timeRange];
    }
}

#pragma mark - MDNavigationBarAppearanceDelegate
- (UINavigationBar *)md_CustomNavigationBar
{
    return nil;
}

#pragma mark - MDVideoTrimmerViewDelegate
- (CMTime)videoTrimmerView:(MDVideoTrimmerView *)trimmerView mediaSouceTimeFromPresentationTime:(CMTime)presentationTime
{
    return presentationTime;
}

- (CMTime)videoTrimmerView:(MDVideoTrimmerView *)trimmerView presentationTimeFromMediaSourceTime:(CMTime)mediaSourceTime
{
    return mediaSourceTime;
}

- (void)videoTrimmerViewDidChangeSelected:(MDVideoTrimmerView *)trimmerView
{
    if (trimmerView.selectedTrimmerRangeIndex != NSNotFound) {
        self.playTimeRange = [NSValue valueWithCMTimeRange:trimmerView.selectedTrimmerTimeRange];
    } else {
        self.playTimeRange = nil;
    }
}

- (void)videoTrimmerViewDidStartChange:(MDVideoTrimmerView *)trimmerView
{
    [self pause];
}

- (void)videoTrimmerViewDidChanged:(MDVideoTrimmerView *)trimmerView
{
    self.playTimeRange = trimmerView.trimmerTimeRanges.firstObject;
    
    CGFloat duration = CMTimeGetSeconds([self.playTimeRange CMTimeRangeValue].duration);
    self.tipLabel.text = [NSString stringWithFormat:@"你已裁剪%.0f秒",duration];
}

- (void)videoTrimmerViewDidEndChange:(MDVideoTrimmerView *)trimmerView
{
    self.playTimeRange = trimmerView.trimmerTimeRanges.firstObject;
    
    CGFloat duration = CMTimeGetSeconds([self.playTimeRange CMTimeRangeValue].duration);
    self.tipLabel.text = [NSString stringWithFormat:@"你已裁剪%.0f秒",duration];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
