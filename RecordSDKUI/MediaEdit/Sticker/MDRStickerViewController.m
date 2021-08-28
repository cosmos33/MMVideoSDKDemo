//
//  MDRStickerViewController.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/7/1.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRStickerViewController.h"
#import "MDRecordEditStickersView.h"
#import "UIConst.h"
#import "MDRecordContext.h"
#import "UIView+Corner.h"
#import <RecordSDK/MDRecordDynamicSticker.h>
#import "MDMomentExpressionCellModel.h"
#import "MDSMSelectIntervalProgressView.h"
#import "Toast/Toast.h"
#import <FaceDecorationKit/FaceDecorationKit.h>
@import RecordSDK;

static NSUInteger kMaxStickerNumber = 3;

@interface MDRStickerViewController () <MDRecordStickersEditViewDelegate>

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL animatedShow;
@property (nonatomic, strong) UIView *playerBgView;

@property (nonatomic, strong) MDSMSelectIntervalProgressView *trimmerView;

@property (nonatomic, strong) MDRecordEditStickersView *stickersView;
@property (nonatomic, strong) UIViewController *playerController;
@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, assign) BOOL hasChanged;

@property (nonatomic, strong) MDRecordDynamicSticker *currentSelectedSticker;

@property (nonatomic, copy) void(^completion)(void);

@property (nonatomic, strong) NSMutableArray<MDRecordDynamicSticker *> *dynamicStickers;

@end

@implementation MDRStickerViewController

- (void)dealloc {
    
}

- (instancetype)initWithAdapter:(MDVideoEditorAdapter *)adapter asset:(AVAsset *)asset {
    self = [super init];
    if (self) {
        _playerController = adapter.playerViewController;
        
        _videoSize = [adapter videoDisplaySize];
        if (CGSizeEqualToSize(_videoSize, CGSizeZero)) {
            AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            CGSize presentationSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
            presentationSize.width = ABS(presentationSize.width);
            presentationSize.height = ABS(presentationSize.height);
            _videoSize = presentationSize;
        }
        
        _asset = asset.copy;
        
        _dynamicStickers = [NSMutableArray arrayWithCapacity:kMaxStickerNumber];
        
        _maxStickerCount = kMaxStickerNumber;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = RGBACOLOR(37, 37, 37, 1.0);
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupUI {

    UIButton *(^createButton)(NSString *, NSInteger) = ^(NSString *title, NSInteger tag) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.tag = tag;
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitleColor:[UIColor.whiteColor colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        return button;
    };
    
    UIButton *saveButton = ({
        createButton(@"保存", 1001);
    });
    saveButton.selected = YES;
    
    UIButton *cancelButton = ({
        createButton(@"取消", 1002);
    });
    
    UIStackView *stackView = ({
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[cancelButton, saveButton]];
        stackView.translatesAutoresizingMaskIntoConstraints = NO;
        stackView.axis = UILayoutConstraintAxisHorizontal;
        if (@available(iOS 11, *)) {
            stackView.spacing = UIStackViewSpacingUseSystem;
        } else {
            stackView.spacing = 8;
        }
        stackView.alignment = UIStackViewAlignmentCenter;
        stackView.distribution = UIStackViewDistributionEqualCentering;
        [self.view addSubview:stackView];
        
        [stackView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:15].active = YES;
        [stackView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        if (@available(iOS 11.0, *)) {
            [stackView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:21].active = YES;
        } else {
            [stackView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:21].active = YES;
        }
        [stackView.heightAnchor constraintEqualToConstant:23].active = YES;
        stackView;
    });
    
    self.stickersView = ({
        CGRect rect = CGRectMake(0, MDScreenHeight - 230, MDScreenWidth, 230);
        if (@available(iOS 11.0, *)) {
            rect = (CGRect) {
                .origin = CGPointMake(0, MDScreenHeight - 230 - self.view.safeAreaInsets.bottom),
                .size = rect.size
            };
        }
        MDRecordEditStickersView *view = [[MDRecordEditStickersView alloc] initWithFrame:rect
                                                                   isDynamicDecoratorMode:YES];
        [self.view addSubview:view];
        view.delegate = self;
        view.backgroundColor = RGBACOLOR(39, 39, 39, 1);
        view.collectionView.contentInset = UIEdgeInsetsMake(0, 0, HOME_INDICATOR_HEIGHT, 0);
        [view setCornerType:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadius:8];
        view;
    });

    self.trimmerView = ({
        MDSMSelectIntervalProgressView *trimmerView = [[MDSMSelectIntervalProgressView alloc] initWithFrame:CGRectMake(8, self.stickersView.top - 8 - 35, MDScreenWidth-16, 35)];
        trimmerView.backgroundColor = [UIColor clearColor];
        trimmerView.marginLineHightColor = [UIColor whiteColor];
        trimmerView.marginLineColor = RGBCOLOR(92, 92, 92);
        trimmerView.progressColor = RGBCOLOR(0, 156, 255);
        trimmerView.trackColor = RGBCOLOR(0, 253, 211);
        trimmerView.inactiveColor = RGBACOLOR(255, 255, 255, 0.2);
        trimmerView.selectAreaBgColor = [UIColor clearColor];
        trimmerView.beginValue = 0;
        trimmerView.endValue = 1.0;
        trimmerView.currentValue = 0;
        trimmerView.leftMargin = 8;
        trimmerView.rightMargin = 3;
        trimmerView.linePadding = 11;
        trimmerView.getLineHeightBlock = ^CGFloat(NSUInteger number) {
            number = number - 1;
            if(number % 6 == 0) return 20;
            if(number % 6 == 1) return 9;
            if(number % 6 == 2) return 13;
            if(number % 6 == 3) return 7;
            if(number % 6 == 4) return 13;
            if(number % 6 == 5) return 9;
            return 7;
        };

        trimmerView.disable = YES;
        __weak __typeof(self) weakSelf = self;
        [trimmerView setValueHandleBlock:^(CGFloat value, ChangeValueType valueType, TouchStatus status) {
            if(status != TouchStatusMove) {
                if(valueType == ChangeValueTypeBegin) {
                    [weakSelf changeStickerTimeWithBeginTime:value];
                }else{
                    [weakSelf changeStickerTimeWithEndTime:value];
                }
            }
        }];
        [self.view addSubview:trimmerView];

        trimmerView;
    });
    
    self.playerBgView = ({
        UIView *view = [[UIView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:view];
        [view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
        [view.topAnchor constraintEqualToAnchor:stackView.bottomAnchor].active = YES;
        [view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [view.bottomAnchor constraintEqualToAnchor:self.trimmerView.topAnchor constant:-28].active = YES;
        view;
    });
    
}

- (void)changeStickerTimeWithBeginTime:(CGFloat)begin {
    if (!self.currentSelectedSticker) {
        return;
    }
    CMTime assetDuration = self.asset.duration;
    CGFloat duration = CMTimeGetSeconds(assetDuration);
    CMTime startTime = CMTimeMakeWithSeconds(begin * duration, assetDuration.timescale);
    CMTime endTime = CMTimeRangeGetEnd(self.currentSelectedSticker.duration);
    self.currentSelectedSticker.duration = CMTimeRangeFromTimeToTime(startTime, endTime);
}

- (void)changeStickerTimeWithEndTime:(CGFloat)end {
    if (!self.currentSelectedSticker) {
        return;
    }
    CMTime assetDuration = self.asset.duration;
    CGFloat duration = CMTimeGetSeconds(assetDuration);
    CMTime startTime = self.currentSelectedSticker.duration.start;
    CMTime endTime = CMTimeMakeWithSeconds(end * duration, assetDuration.timescale);
    self.currentSelectedSticker.duration = CMTimeRangeFromTimeToTime(startTime, endTime);
}

- (void)buttonClicked:(UIButton *)button {
    if (button.tag == 1001) {
        [self dissmissWithAnimated:YES completion:^{
            [self.delegate didCompleteEditSticker:self];
        }];
    } else {
        // 没做任何改变，直接消失不弹窗
        if (!self.hasChanged) {
            [self dissmissWithAnimated:YES completion:^{
                [self.delegate cancelEditSticker:self];
            }];
            return;
        }
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"是否放弃?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dissmissWithAnimated:YES completion:^{
                [self.delegate cancelEditSticker:self];
            }];
        }];
        [alertVC addAction:action1];
        [alertVC addAction:action2];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

#pragma mark - layout override

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.isShow) {
        return;
    }
    
    self.isShow = YES;
    CGFloat playerBgViewHeight = CGRectGetMaxY(self.playerBgView.bounds);
    CGFloat scale = playerBgViewHeight / MDScreenHeight;
    [self.view addSubview:self.playerController.view];
    [UIView animateWithDuration:self.animatedShow ? 0.3f : 0.001 animations:^{
        self.playerController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.playerController.view.center = self.playerBgView.center;
    } completion:^(BOOL finished) {
        [self.view bringSubviewToFront:self.playerController.view];
        
        self.completion ? self.completion() : nil;
        self.completion = nil;
    }];
}

#pragma mark - show/hide animation

- (void)showWithAnimated:(BOOL)animated {
    [self showWithAnimated:animated completion:nil];
}

- (void)showWithAnimated:(BOOL)animated completion:(void(^ _Nullable)(void))completion {
    self.animatedShow = animated;
    self.hasChanged = NO;
    
    self.completion = completion;
}

- (void)dissmissWithAnimated:(BOOL)animated {
    [self dissmissWithAnimated:animated completion:nil];
}

- (void)dissmissWithAnimated:(BOOL)animated completion:(void(^)(void))completion {
    [self.view bringSubviewToFront:self.playerController.view];
    [UIView animateWithDuration:animated ? 0.3 : 0.001 animations:^{
        self.playerController.view.transform = CGAffineTransformIdentity;
        self.playerController.view.center = CGPointMake(MDScreenWidth / 2, MDScreenHeight / 2);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        self.isShow = NO;
        completion ? completion() : nil;
    }];
}

#pragma mark - MDRecordStickersEditViewDelegate Methods

- (void)collectionViewDidSelectDateArrayAtIndexUrlDictionary:(NSDictionary *)urlDict {
    
    if (self.dynamicStickers.count == self.maxStickerCount) {
        [self.view makeToast:[NSString stringWithFormat:@"最多添加%ud张贴纸", self.maxStickerCount]
                    duration:1.5
                    position:CSToastPositionCenter];
        return;
    }
    
    CGPoint center = [[urlDict valueForKey:@"center"] CGPointValue];
    MDRecordDynamicSticker *sticker = nil;
    NSString *stickerId       = nil;
    NSString *resourcePath    = nil;
    
    MDMomentExpressionCellModel *model = [urlDict objectForKey:@"data"];
    if (model) {
        stickerId = model.resourceId;
        resourcePath = model.downLoadModel.resourcePath;
    }
    
    if (stickerId.length == 0 || resourcePath.length == 0) {
        [self.delegate didSelecedSticker:self sticker:nil center:center];
        return;
    }
    
    sticker = [[MDRecordDynamicSticker alloc] initWithDecorationURL:[NSURL fileURLWithPath:resourcePath]
                                                     inputFrameSize:self.videoSize];
    sticker.stickerId = stickerId;
    sticker.duration = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
    
    // 更新sticker UI 显示 bounds
    CGSize stickerSize = [sticker stickerSize];
    CGFloat x = center.x - stickerSize.width / 2.0f;
    CGFloat y = center.y - stickerSize.height / 2.0f;
    CGRect viewFrame = CGRectMake(x, y, stickerSize.width, stickerSize.height);
    //为了方面stickerAdjustView 调整frame, 先使用屏幕坐标赋值
    sticker.bounds = viewFrame;
    
    [self.dynamicStickers addObject:sticker];
    
    [self selectSticker:sticker];
    
    [self.delegate didSelecedSticker:self sticker:sticker center:center];
}

- (void)removeSticker:(MDRecordDynamicSticker *)sticker {
    [self.dynamicStickers removeObject:sticker];
    if (self.currentSelectedSticker == sticker) {
        self.currentSelectedSticker = nil;
        self.trimmerView.beginValue = 0;
        self.trimmerView.endValue = 1;
        self.trimmerView.disable = YES;
    }
}

- (NSArray<MDRecordDynamicSticker *> *)stickerArray {
    return self.dynamicStickers.copy;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UINavigationBar *)md_CustomNavigationBar {
    return nil;
}

- (BOOL)md_isCurrentCustomed {
    return YES;
}

- (void)selectSticker:(MDRecordDynamicSticker *)sticker {
    if (![self.dynamicStickers containsObject:sticker] || self.currentSelectedSticker == sticker) {
        return;
    }
    
    self.currentSelectedSticker = sticker;
    
    if (!sticker) {
        self.trimmerView.disable = YES;
        return;
    }
    
    if (CMTimeRangeEqual(kCMTimeRangeInvalid, sticker.duration)) {
        self.trimmerView.beginValue = 0;
        self.trimmerView.endValue = 1;
        self.trimmerView.disable = YES;
    } else {
        CGFloat duration = CMTimeGetSeconds(self.asset.duration);
        self.trimmerView.beginValue = CMTimeGetSeconds(sticker.duration.start) / duration;
        self.trimmerView.endValue = CMTimeGetSeconds(CMTimeRangeGetEnd(sticker.duration)) / duration;
    }
    self.trimmerView.disable = NO;
}

- (void)removeAllStickers {
    NSArray<MDRecordDynamicSticker *> *stickers = self.dynamicStickers.copy;
    for (MDRecordDynamicSticker *sticker in stickers) {
        [self removeSticker:sticker];
    }
}

@end
