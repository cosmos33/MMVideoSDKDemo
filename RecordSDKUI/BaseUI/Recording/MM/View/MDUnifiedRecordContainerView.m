//
//  MDUnifiedRecordContainerView.m
//  MDChat
//
//  Created by 符吉胜 on 2017/6/2.
//  Copyright © 2017年 sdk.com. All rights reserved.
//
#import "MDRecordWhiteRingView.h"

#import "MDUnifiedRecordContainerView.h"
#import "MDHitTestExpandView.h"
#import "UIImage+MDUtility.h"
#import "MDFaceDetectView.h"
#import "MDRecordFilterTipView.h"
#import "MDRecordGuideTipsManager.h"

#import "MDVideoNewSpeedControlView.h"
#import "MDMoment3DTouchView.h"
#import "MUAt8AlertBarModel.h"
#import "Toast/Toast.h"
//数码宝贝
#import "MDStrokeLabel.h"

#define kDefaultTopEdge 15.0f
#define kTopEdge (IS_IPHONE_X ? (kDefaultTopEdge + 44) : kDefaultTopEdge)

#define kCancelCaptureTipTop (MDScreenHeight - 200 - SAFEAREA_BOTTOM_MARGIN)

#define kLeftMarginOfTopView 75
#define kRightViewTopEdge (IS_IPHONE_X ? (100 + 44) : 100)

#define kCancelButtonImageViewTag   987462

static NSString * const kHighRecordBtnDeleteTip  = @"点击垃圾桶删除前段视频";

static const NSInteger kFilterGuideTipViewTag = 40;

@interface MDUnifiedRecordContainerView()
<
    MDUnifiedRecordTopViewDelegate,
    MDUnifiedRecordRightViewDelegate,
    MDUnifiedRecordBottomViewDelegate,
    MDUnifiedRecordButtonDelegate,
    MDRecordGuideTipsManagerDelegate,
    UIGestureRecognizerDelegate
>

@property (nonatomic,strong) MDHitTestExpandView                    *cancelButton;
@property (nonatomic,strong) MDUnifiedRecordBottomView              *bottomView;
@property (nonatomic,strong) BBMediaEditorSlidingOverlayView        *slidingFilterView;

@property (nonatomic,strong) MDUnifiedRecordTopView                 *topViewForNormal;
@property (nonatomic,strong) MDUnifiedRecordTopView                 *topViewForHigh;
@property (nonatomic,strong) MDUnifiedRecordTopView                 *currentTopView;

@property (nonatomic,strong) MDUnifiedRecordRightView               *rightViewForNormal;
@property (nonatomic,strong) MDUnifiedRecordRightView               *rightViewForHigh;
@property (nonatomic,strong) MDUnifiedRecordRightView               *currentRightView;

@property (nonatomic,strong) UIImageView                            *cameraFocusView; //聚焦圆圈视图
@property (nonatomic,strong) MDFaceDetectView                       *faceDecorationTipView;  //变脸露脸等提示

@property (nonatomic,strong) UIView                                 *highMiddleBottomBgView;  //高级拍摄拍摄按钮上方的背景视图
@property (nonatomic,strong) MDVideoNewSpeedControlView             *speedControlView;      //变速视图
@property (nonatomic,strong) UILabel                                *highRecordBtnTipView;  //高级拍摄提示

@property (nonatomic,strong) UIView                                 *tipBgContentView;       //拍摄按钮上方提示视图的背景视图
@property (nonatomic,strong) UILabel                                *cancelCaptureTipView;   //长按拖拽出手势范围的取消提示
@property (nonatomic,strong) UILabel                                *normalRecordBtnTipView; //普通拍摄提示
@property (nonatomic,strong) UILabel                                *loadingTipView;         //变脸推荐bar下载状态提示

//录制时长实时显示
@property (nonatomic,strong) UILabel                                *recordDurationLabel;
//滤镜名称
@property (nonatomic,strong) UILabel                                *filterTipLabel;
@property (nonatomic,assign) NSInteger                              filterTipTag;

//拍摄类型
@property (nonatomic,assign) MDUnifiedRecordLevelType               levelType;
//引导模块
@property (nonatomic,strong) MDRecordGuideTipsManager               *guideTipsManager;
//屏幕是否是垂直的
@property (nonatomic,assign) BOOL                                   isVertical;

//之前的时长
@property (nonatomic,assign) int                                    previousSeconds;
// 3D 引擎事件传递View
@property (nonatomic,strong) MDMoment3DTouchView                   *touchView;

@property (nonatomic, strong) UIView                               *topCoverView;
@property (nonatomic, strong) UIView                               *bottomCoverView;

//数码宝贝用拍摄按钮
@property (nonatomic, strong) UIButton                             *petRecordButton;

@property (nonatomic, assign) BOOL                                  fromAlbum;
@end

@implementation MDUnifiedRecordContainerView

#pragma mark - life cycle
- (instancetype)initWithDelegate:(id<MDUnifiedRecordViewDelegate>)delegate levelType:(MDUnifiedRecordLevelType)levelType fromAlbum:(BOOL)fromAlbum{
    if (self = [self initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)]) {
        _fromAlbum = fromAlbum;
        _delegate = delegate;
        _levelType = levelType;
        _isVertical = YES;
        
        self.previousSeconds = -1;
        [self setupGuideTipsManager];
        [self configUI];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<MDUnifiedRecordViewDelegate>)delegate levelType:(MDUnifiedRecordLevelType)levelType
{
    if (self = [self initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)]) {
        
        _delegate = delegate;
        _levelType = levelType;
        _isVertical = YES;
        
        self.previousSeconds = -1;
        [self setupGuideTipsManager];
        [self configUI];
    }
    return self;
}

- (void)dealloc
{
}

- (void)setupGuideTipsManager
{
    _guideTipsManager = [[MDRecordGuideTipsManager alloc] init];
    _guideTipsManager.delegate = self;
}

#pragma mark - configUI
- (void)configUI
{
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.contentView];
    [self addSubview:self.slidingFilterView];
    [self addSubview:self.touchView];
    
    UIView *topCover = [self coverViewWtihFrame:CGRectMake(0, 0, MDScreenWidth, 80) startAlpha:0.25f toBottom:YES];
    UIView *bottomCover = [self coverViewWtihFrame:CGRectMake(0, MDScreenHeight -115, MDScreenWidth, 115) startAlpha:0.35f toBottom:NO];
    self.topCoverView = topCover;
    self.bottomCoverView = bottomCover;
    [self addSubview:topCover];
    [self addSubview:bottomCover];
    
    [self addSubview:self.cancelButton];

    [self addSubview:[self topViewWithLevelType:MDUnifiedRecordLevelTypeHigh]];
    [self addSubview:[self topViewWithLevelType:MDUnifiedRecordLevelTypeNormal]];

    [self addSubview:self.progressView];
    [self setupFaceDecorationTipView];
    
    [self addSubview:self.filterTipLabel];
    [self addSubview:self.recordDurationLabel];
    [self setRecordDurationLabelTextWithSecond:0];


    [self setupTipBgContentView];
    [self setupHighMiddleBottomBgView];
    
    [self addSubview:[self rightViewWithLevelType:MDUnifiedRecordLevelTypeHigh]];
    [self addSubview:[self rightViewWithLevelType:MDUnifiedRecordLevelTypeNormal]];
    [self addSubview:self.speedControlView];

    [self addSubview:self.bottomView];
    
    [self setCurrentTopViewWithLevelType:_levelType animated:NO];
    [self setRecordBtnType:_levelType];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [super hitTest:point withEvent:event];
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _contentView;
}

- (BBMediaEditorSlidingOverlayView *)slidingFilterView
{
    if (!_slidingFilterView) {
        _slidingFilterView = [[BBMediaEditorSlidingOverlayView alloc] initWithSlidingOverlayViewType:BBMediaEditorSlidingOverlayViewTypeVertical sceneType:BBMediaEditorSlidingOverlayViewTypeRecord frame:self.bounds];
        
        _slidingFilterView.scrollEnabled = YES;

        //双击切换前后摄像头
        UITapGestureRecognizer* doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapCamera)];
        doubleRecognizer.numberOfTapsRequired = 2;
        [_slidingFilterView addGestureRecognizer:doubleRecognizer];
        
        //点击对焦
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slidingFilterViewTapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [_slidingFilterView addGestureRecognizer:tapRecognizer];
        [tapRecognizer requireGestureRecognizerToFail:doubleRecognizer];
        
        // 调整焦距
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(slidingFilterViewPinch:)];
        [_slidingFilterView addGestureRecognizer:pinchGesture];
    }
    
    return _slidingFilterView;
}

- (MDMoment3DTouchView *)touchView {
    if (!_touchView) {
        CGRect bounds = self.bounds;
        if (IS_IPHONE_X) {
            CGFloat offX = bounds.size.width * ((bounds.size.height / 667.0) - 1.0) * 0.5;
            bounds = CGRectMake(-offX, 0, bounds.size.width + 2 * offX, bounds.size.height);
        }
        _touchView = [[MDMoment3DTouchView alloc] initWithFrame:bounds];
        _touchView.backgroundColor = [UIColor clearColor];
        _touchView.multipleTouchEnabled = YES;
        __weak typeof(self) weakSelf = self;
        _touchView.touchLevelHandle = ^BOOL{
            if (weakSelf.delegate && [weakSelf.delegate hasModuleViewShowed]) {
                return true;
            }
            return false;
        };
    }
    return _touchView;
}

- (BOOL)video3DTouchViewAcceptTouch {
    return self.touchView.acceptTouct;
}

//上下icon下方遮罩
- (UIView *)coverViewWtihFrame:(CGRect)frame startAlpha:(CGFloat)alpha toBottom:(BOOL)toBottom
{
    UIView *cover = [[UIView alloc] initWithFrame:frame];
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    UIColor *color = RGBACOLOR(0, 0, 0, 0);
    maskLayer.colors = @[(__bridge id)RGBACOLOR(0, 0, 0, alpha).CGColor, (__bridge id)color.CGColor];
    
    maskLayer.anchorPoint = CGPointZero;
    
    if (toBottom) {
        maskLayer.startPoint = CGPointMake(0, 0);
        maskLayer.endPoint = CGPointMake(0, 1);
    } else {
        maskLayer.startPoint = CGPointMake(0, 1);
        maskLayer.endPoint = CGPointMake(0, 0);
    }
    
    maskLayer.position = CGPointMake(0, 0.5);
    maskLayer.bounds = cover.bounds;
    
    [cover.layer addSublayer:maskLayer];
    
    return cover;
}

- (MDHitTestExpandView *)cancelButton
{
    if (!_cancelButton) {
        NSString *imageName = @"camera_left_close_button_icon";
        if (self.fromAlbum) {
            imageName = @"UIBundle.bundle/nav_back_bg2";
        }
        
        UIImage *cancelImage = [UIImage imageNamed:imageName];
        _cancelButton = [[MDHitTestExpandView alloc] initWithFrame:CGRectMake(13, kTopEdge, cancelImage.size.width, cancelImage.size.height)];
        _cancelButton.minHitTestWidth = 44;
        _cancelButton.minHitTestHeight = 44;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_cancelButton.bounds];
        [imageView setImage:cancelImage];
        imageView.tag = kCancelButtonImageViewTag;
        [_cancelButton addSubview:imageView];
        
        [_cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelButton;
}

- (MDUnifiedRecordBottomView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[MDUnifiedRecordBottomView alloc] initWithDelegate:self andLevelType:_levelType];
        _bottomView.bottom = MDScreenHeight - 54 + 10 - SAFEAREA_BOTTOM_MARGIN;
        [_bottomView setDisableAlbumEntrance:(YES)];
    }
    return _bottomView;
}

- (MDUnifiedRecordTopView *)topViewWithLevelType:(MDUnifiedRecordLevelType)levelType
{
    MDUnifiedRecordTopView *topView = [[MDUnifiedRecordTopView alloc] initWithFrame:CGRectZero andGuideTipsManager:_guideTipsManager];
    topView.delegate = self;
    topView.top = kTopEdge;
    
    if (levelType == MDUnifiedRecordLevelTypeHigh) {
        self.topViewForHigh = topView;
    } else {
        self.topViewForNormal = topView;
//        self.topViewForNormal.countDownView.alpha = 0.0f;
    }
    
    return topView;
}

- (MDUnifiedRecordRightView *)rightViewWithLevelType:(MDUnifiedRecordLevelType)levelType
{
    MDUnifiedRecordRightView *rightView = [[MDUnifiedRecordRightView alloc] initWithFrame:CGRectZero andGuideTipsManager:_guideTipsManager];
    rightView.delegate = self;
    rightView.top = kRightViewTopEdge;
    
    if (levelType == MDUnifiedRecordLevelTypeHigh) {
        self.rightViewForHigh = rightView;
    } else {
        self.rightViewForNormal = rightView;
        self.rightViewForNormal.musicView.alpha = 0.0f;
        self.rightViewForNormal.speedView.alpha = 0.0f;
    }
    
    return rightView;
}


- (void)setCurrentTopViewWithLevelType:(MDUnifiedRecordLevelType)currentLevelType animated:(BOOL)animated
{
    _levelType = currentLevelType;
    
    void(^action)(void) = nil;
    
    if (currentLevelType == MDUnifiedRecordLevelTypeHigh) {
        
        action = ^(void) {
            self.currentTopView = self.topViewForHigh;
            self.currentTopView.top = kTopEdge;
            self.currentTopView.alpha = 1.0;
            
            self.topViewForNormal.alpha = 0.0f;
            
            
            self.currentRightView = self.rightViewForHigh;
            self.currentRightView.left = MDScreenWidth-(kMDUnifiedRecordRightViewIconWidth+kMDUnifiedRecordRightViewRightMargin);
            self.currentRightView.alpha = 1.0;
            self.rightViewForNormal.alpha = 0.0f;
            
        };
        
    } else {
        
        action = ^(void) {
            self.currentTopView = self.topViewForNormal;
            self.currentTopView.alpha = 1.0f;
            
            self.topViewForHigh.top = (-self.currentTopView.height);
            self.topViewForHigh.alpha = 0.0f;
            
            
            self.currentRightView = self.rightViewForNormal;
            self.currentRightView.alpha = 1.0f;
            self.rightViewForHigh.left = MDScreenWidth;
            self.rightViewForHigh.alpha = 0.0f;
            
        };
    }
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            action();
        }];
    } else {
        action();
    }
}

- (UIImageView *)cameraFocusView
{
    if (!_cameraFocusView) {
        _cameraFocusView = [[UIImageView alloc] initWithFrame:CGRectMake((MDScreenWidth -111) *0.5f, (MDScreenHeight -211) *0.5f, 111, 111)];
        UIImage *img = [UIImage imageWithColor:[UIColor clearColor] finalSize:CGSizeMake(100, 100)];
        img = [img clipCircleBorderColor:RGBACOLOR(255, 255, 255, 0.6f)
                         backgroundColor:[UIColor clearColor]
                                   alpha:1
                             borderWidth:1.0f
                               tintColor:nil
                               maskImage:nil];
        [_cameraFocusView setImage:img];
        _cameraFocusView.hidden = YES;
        
        [self addSubview:_cameraFocusView];
    }
    
    return _cameraFocusView;
}

- (MDVideoNewSpeedControlView *)speedControlView {
    if (!_speedControlView) {
        _speedControlView = [[MDVideoNewSpeedControlView alloc] initWithFrame:CGRectMake(0, 45, 275, 33)];
        _speedControlView.centerX = self.width/2.0;
        CGRect rect = [self.rightViewForHigh convertRect:self.rightViewForHigh.speedView.frame toView:self];
        _speedControlView.top = rect.origin.y;
        [_speedControlView addTarget:self action:@selector(speedControlViewDidChange) forControlEvents:UIControlEventValueChanged];
        _speedControlView.hidden = YES;
        
        NSArray *segmentArray = @[
                                  [MDVideoNewSpeedControlItem itemWithTitle:@"极慢" factor:2.0f],
                                  [MDVideoNewSpeedControlItem itemWithTitle:@"慢" factor:1.25f],
                                  [MDVideoNewSpeedControlItem itemWithTitle:@"标准" factor:1.0f],
                                  [MDVideoNewSpeedControlItem itemWithTitle:@"快" factor:0.5f],
                                  [MDVideoNewSpeedControlItem itemWithTitle:@"极快" factor:0.25f],
                                  ];
        [_speedControlView layoutWithSegmentTitleArray:segmentArray];
        [_speedControlView setCurrentSegmentIndex:2 animated:NO withEvent:YES];
    }
    return _speedControlView;
}

- (void)setupTipBgContentView {
    self.tipBgContentView = [[UIView alloc] initWithFrame:CGRectMake(0, kCancelCaptureTipTop, MDScreenWidth, 30)];
    [self addSubview:self.tipBgContentView];
    
    [self.tipBgContentView addSubview:self.cancelCaptureTipView];
    [self.tipBgContentView addSubview:self.normalRecordBtnTipView];
    [self.tipBgContentView addSubview:self.loadingTipView];
}

- (void)setupHighMiddleBottomBgView {
    self.highMiddleBottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kCancelCaptureTipTop-55, MDScreenWidth, 85)];
    [self addSubview:self.highMiddleBottomBgView];

    [self.highMiddleBottomBgView addSubview:self.highRecordBtnTipView];
//    [self.highMiddleBottomBgView addSubview:self.speedControlView];
    
    self.highMiddleBottomBgView.alpha = (_levelType == MDUnifiedRecordLevelTypeHigh) ? 1.0f : 0.0f;
}




- (UILabel *)cancelCaptureTipView
{
    if (!_cancelCaptureTipView) {
        _cancelCaptureTipView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, 30)];
        _cancelCaptureTipView.textColor = RGBACOLOR(255, 255, 255, 0.9);
        _cancelCaptureTipView.textAlignment = NSTextAlignmentCenter;
        _cancelCaptureTipView.text = @"松手取消录制";
        _cancelCaptureTipView.alpha = 0;
        _cancelCaptureTipView.font = [UIFont boldSystemFontOfSize:18.0];
        _cancelCaptureTipView.shadowColor = RGBACOLOR(0, 0, 0, 0.5f);
        _cancelCaptureTipView.shadowOffset = CGSizeMake(0, 0.5f);
    }
    
    return _cancelCaptureTipView;
}

- (UILabel *)recordDurationLabel
{
    if (!_recordDurationLabel) {
        _recordDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kCancelCaptureTipTop, 63, 25)];
        _recordDurationLabel.centerX = MDScreenWidth / 2.0f;
        
        _recordDurationLabel.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
        _recordDurationLabel.textColor = [UIColor whiteColor];
        _recordDurationLabel.textAlignment = NSTextAlignmentCenter;
        _recordDurationLabel.font = [UIFont systemFontOfSize:18.0];
        _recordDurationLabel.layer.cornerRadius = 4.0f;
        _recordDurationLabel.layer.masksToBounds = YES;
        _recordDurationLabel.alpha = 0.0f;
    }
    return _recordDurationLabel;
}

- (UILabel *)normalRecordBtnTipView
{
    if (!_normalRecordBtnTipView) {
        _normalRecordBtnTipView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, 30)];
        _normalRecordBtnTipView.textColor = RGBACOLOR(255, 255, 255, 0.9);
        _normalRecordBtnTipView.textAlignment = NSTextAlignmentCenter;
        _normalRecordBtnTipView.alpha = 0.0f;
        _normalRecordBtnTipView.font = [UIFont boldSystemFontOfSize:18.0];
        _normalRecordBtnTipView.shadowColor = RGBACOLOR(0, 0, 0, 0.5f);
        _normalRecordBtnTipView.shadowOffset = CGSizeMake(0, 0.5f);
    }
    return _normalRecordBtnTipView;
}

- (UILabel *)highRecordBtnTipView {
    if (!_highRecordBtnTipView) {
        _highRecordBtnTipView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, 30)];
        _highRecordBtnTipView.textColor = RGBACOLOR(255, 255, 255, 0.9);
        _highRecordBtnTipView.textAlignment = NSTextAlignmentCenter;
        _highRecordBtnTipView.font = [UIFont boldSystemFontOfSize:18.0];
        _highRecordBtnTipView.shadowColor = RGBACOLOR(0, 0, 0, 0.5f);
        _highRecordBtnTipView.shadowOffset = CGSizeMake(0, 0.5f);
        _highRecordBtnTipView.text = kHighRecordBtnDeleteTip;
        _highRecordBtnTipView.alpha = 0.0f;
    }
    return _highRecordBtnTipView;
}

- (UILabel *)loadingTipView
{
    if (!_loadingTipView) {
        _loadingTipView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, 30)];
        _loadingTipView.textColor = RGBACOLOR(255, 255, 255, 0.9);
        _loadingTipView.textAlignment = NSTextAlignmentCenter;
        _loadingTipView.alpha = 0.0f;
        _loadingTipView.font = [UIFont boldSystemFontOfSize:18.0];
        _loadingTipView.shadowColor = RGBACOLOR(0, 0, 0, 0.5f);
        _loadingTipView.shadowOffset = CGSizeMake(0, 0.5f);
    }
    return _loadingTipView;
}

- (void)setupFaceDecorationTipView
{
    //_faceDecorationTipView需要经常调用，所以不使用懒加载形式
    _faceDecorationTipView = [[MDFaceDetectView alloc] init];
    [self addSubview:_faceDecorationTipView];
}

- (MDDurationArrayProgressView *)progressView
{
    if (!_progressView) {
        UIColor *progressColor = RGBCOLOR(0, 192, 255);
        UIColor *trackColor = RGBACOLOR(255, 255, 255, 0.45f);
        _progressView = [[MDDurationArrayProgressView alloc] initWithProgressColor:progressColor trackColor:trackColor];
        _progressView.frame = CGRectMake(0, (IS_IPHONE_X ? 30 : 0), MDScreenWidth, 10);
        _progressView.hilightedColor = RGBCOLOR(245, 40, 36);
        
        _progressView.progress = 0.f;
    }
    return _progressView;
}



- (UILabel *)filterTipLabel
{
    if (!_filterTipLabel) {
        _filterTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, MDScreenWidth, 100)];
        _filterTipLabel.textColor = RGBCOLOR(255, 255, 255);
        _filterTipLabel.font = [UIFont systemFontOfSize:72];
        _filterTipLabel.textAlignment = NSTextAlignmentCenter;
        _filterTipLabel.shadowColor = RGBACOLOR(0, 0, 0, 0.5f);
        _filterTipLabel.shadowOffset = CGSizeMake(0, 0.5f);
        
        _filterTipLabel.alpha = 0.0f;
    }
    return _filterTipLabel;
}

#pragma mark - MDUnifiedRecordBottomViewDelegate
- (void)didTapDeleSegmentView:(UIImageView *)view isSelected:(BOOL)isSelected
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapDeleSegmentView:isSelected:)]) {
        [self.delegate didTapDeleSegmentView:view isSelected:isSelected];
    }
}

- (void)didTapGotoEditView:(UIImageView *)view
{
    _speedControlView.hidden = YES;
    if (!view.md_enableEvent) {
        [[MDRecordContext appWindow] makeToast:@"太短了，再拍一会" duration:1.5f position:CSToastPositionCenter];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(didTapGotoEditView:)]) {
        [self.delegate didTapGotoEditView:view];
    }
}

- (void)didTapDelayCloseView:(UIImageView *)view
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapDelayCloseView:)]) {
        [self.delegate didTapDelayCloseView:view];
    }
}

- (void)didTapAlbumButton:(BOOL)hadShowAlert{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapAlbumButton:)]) {
        [self.delegate didTapAlbumButton:hadShowAlert];
    }
}

- (BOOL)couldShowAlbumVideoAlert{
    if ([self.delegate respondsToSelector:@selector(couldShowAlbumVideoAlert)]) {
        return [self.delegate couldShowAlbumVideoAlert];
    }
    return YES;
}

- (BOOL)currentRecordDurationSmallerThanMinSegmentDuration{
    if ([self.delegate respondsToSelector:@selector(currentRecordDurationSmallerThanMinSegmentDuration)]) {
        return [self.delegate currentRecordDurationSmallerThanMinSegmentDuration];
    }
    return YES;
}

#pragma mark - MDUnifiedRecordButtonDelegate
- (void)didTapRecordButton
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapRecordButton)]) {
        [self.delegate didTapRecordButton];
    }
}

- (void)didLongPressBegan
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didLongPressBegan)]) {
        [self.delegate didLongPressBegan];
    }
}

- (void)didLongPressDragExit
{
    if (isFloatEqual(_cancelCaptureTipView.alpha, 1.0f) || ![self.delegate canUseRecordFunction]) {
        return;
    }
    
    //取消录制的提示
    [UIView animateWithDuration:0.1f animations:^{
        self.cancelCaptureTipView.alpha = 1;
        [self setRecordDurationLabelAlpha:0.0f];
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1f delay:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.cancelCaptureTipView.alpha = 0;
        } completion:^(BOOL finished) {
            if ([self.delegate isRecording]) {
                [self setRecordDurationLabelAlpha:1.0f];
            }
        }];
    }];
}

- (void)didLongPressEnded:(BOOL)pointInside
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didLongPressEnded:)]) {
        [self.delegate didLongPressEnded:pointInside];
    }
}


#pragma mark - MDUnifiedRecordTopViewDelegate
- (void)didTapSwitchCameraView:(UIImageView *)view
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapSwitchCameraView:)]) {
        [self.delegate didTapSwitchCameraView:view];
    }
}

- (void)didTapFlashLightView:(UIImageView *)view
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapFlashLightView:)]) {
        [self.delegate didTapFlashLightView:view];
    }
}

- (void)didTapCountDownView:(UIImageView *)view
{
//    if ([self.delegate respondsToSelector:@selector(didTapCountDownView:)]) {
//        [self.delegate didTapCountDownView:view];
//    }
}

#pragma mark - MDUnifiedRecordRightViewDelegate

- (void)didTapFaceDecorationView:(MDUnifiedRecordIconView *)view
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapFaceDecorationView:)]) {
        [self.delegate didTapFaceDecorationView:view.iconView];
    }
}

- (void)didTapFaceDecorationButton:(UIImageView *)imageView {
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapFaceDecorationView:)]) {
        [self.delegate didTapFaceDecorationView:imageView];
    }
}

- (void)didTapFilterView:(MDUnifiedRecordIconView *)view
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapFilterView:)]) {
        [self.delegate didTapFilterView:view.iconView];
    }
}

- (void)didTapMusicView:(MDUnifiedRecordIconView *)view
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapMusicView:)]) {
        [self.delegate didTapMusicView:view.iconView];
    }
}

- (void)didTapThinView:(MDUnifiedRecordIconView *)view
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapThinView:)]) {
        [self.delegate didTapThinView:view.iconView];
    }
}

- (void)didTapDelayView:(MDUnifiedRecordIconView *)view {
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapCountDownView:)]) {
        [self.delegate didTapCountDownView:view.iconView];
    }
}

- (void)didTapSpeedView:(MDUnifiedRecordIconView *)view {
    _speedControlView.hidden = !_speedControlView.isHidden;
    if ([self.delegate respondsToSelector:@selector(didTapSpeedView:)]) {
        [self.delegate didTapSpeedView:view.iconView];
    }
}

- (void)didTapMakeUpView:(MDUnifiedRecordIconView *)view {
    if ([self.delegate respondsToSelector:@selector(didTapMakeUpView:)]) {
        [self.delegate didTapMakeUpView:view.iconView];
    }
}

#pragma mark - 事件交互
- (void)cancelButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(didClickCancelBtn:)]) {
        [self.delegate didClickCancelBtn:self.cancelButton];
    }
}

- (void)slidingFilterViewTapped:(UITapGestureRecognizer *)tapGesture
{
    _speedControlView.hidden = YES;
    if ([self.delegate isModuleViewShowed]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(filterViewTapped:)]) {
        [self.delegate filterViewTapped:tapGesture];
    }
}

- (void)didDoubleTapCamera
{
    _speedControlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didDoubleTapCamera)]) {
        [self.delegate didDoubleTapCamera];
    }
}

- (void)slidingFilterViewPinch:(UIPinchGestureRecognizer *)gesture {
    if ([self.delegate isModuleViewShowed] || [self video3DTouchViewAcceptTouch]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(filterViewPinched:)]) {
        [self.delegate filterViewPinched:gesture];
    }
}

- (void)speedControlViewDidChange
{
    CGFloat factor = self.speedControlView.selectedFactor;
    if (isFloatEqual(factor, 0)) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(speedControlViewDidChangeWithFactor:)]) {
        [self.delegate speedControlViewDidChangeWithFactor:factor];
    }
}

#pragma mark - public function
- (void)showFaceDecorationTip:(NSString *)text
{
    //这个方法会频繁调用,应该限制一下
    BOOL isHideShapeLayer = ![text isNotEmpty] || ([text isNotEmpty] && ![text isEqualToString:@"露个脸吧"]);
    
    [_faceDecorationTipView showWithText:text hideShapeLayer:isHideShapeLayer animation:YES];
}

- (void)showFilterNameTipAnimateWithText:(NSString *)text
{
    self.filterTipTag++;
    [self.filterTipLabel.layer removeAllAnimations];

    if ([self viewWithTag:kFilterGuideTipViewTag]) {
        return;
    }
    
    self.filterTipLabel.text = text;
    self.filterTipLabel.alpha = 1.0f;
    self.filterTipLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
    
    __block NSInteger tag = self.filterTipTag;
    [UIView animateWithDuration:1.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.filterTipLabel.alpha = .1f;
                         self.filterTipLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
                     } completion:^(BOOL finished) {
                         if (tag == self.filterTipTag) {
                             self.filterTipLabel.alpha = .0f;
                             self.filterTipLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
                         }
                     }];
}


- (void)musicViewShow:(BOOL)isShow animated:(BOOL)animated
{
    if (_levelType != MDUnifiedRecordLevelTypeHigh) {
        return;
    }
    
    CGFloat alpha = isShow ? 1.0f : 0.0f;
    if (![self.delegate currentRecordDurationSmallerThanMinSegmentDuration]) {
        //已经开拍，不可切换音乐，隐藏音乐按钮
        alpha = 0.0f;
    }
    
    [self.rightViewForHigh enableMusicSelected:alpha == 1.0f];
    [self.rightViewForNormal enableMusicSelected:alpha == 1.0f];
//    if (animated) {
//        [UIView animateWithDuration:0.2 animations:^{
//            self.rightViewForHigh.musicView.alpha = alpha;
//            self.rightViewForNormal.musicView.alpha = alpha;
//        }];
//
//    } else {
//        self.rightViewForHigh.musicView.alpha = alpha;
//        self.rightViewForNormal.musicView.alpha = alpha;
//    }
}

- (void)highMiddleBottomViewShow:(BOOL)isShow animated:(BOOL)animated
{
    if (isShow && _levelType != MDUnifiedRecordLevelTypeHigh) {
        return;
    }
    
    CGFloat alpha = isShow ? 1.0f : 0.0f;
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.highMiddleBottomBgView.alpha = alpha;
        }];
    } else {
        self.highMiddleBottomBgView.alpha = alpha;
    }
}

- (void)setHighRecordBtnTipViewTextWithDeleteSelected:(BOOL)deleteSelected {
    CGFloat alpha = deleteSelected ? 1.0f : 0.0f;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.highRecordBtnTipView.alpha = alpha;
    }];
}



- (void)setFlashViewImageWithFlashMode:(MDRecordCaptureFlashMode)flashMode
{
    self.currentTopView.flashLightView.image = [self flashImageWithFlashMode:flashMode targetLevelType:_levelType];
}

- (void)switchFlashLightAfterRotateCamera
{
    CGFloat alpha = self.currentTopView.flashLightView.alpha;
    self.currentTopView.flashLightView.alpha = isFloatEqual(alpha, 1.0) ? 0.0f : 1.0f;
}

- (UIImage *)flashImageWithFlashMode:(MDRecordCaptureFlashMode)flashMode targetLevelType:(MDUnifiedRecordLevelType)targetLevelType
{
    NSString *imageName = @"btn_moment_flashLight_off";
    
    switch (flashMode) {
        case MDRecordCaptureFlashModeOff:
        {
            imageName = @"btn_moment_flashLight_off";
            break;
        }
        case MDRecordCaptureFlashModeAuto:
        {
            imageName = @"btn_moment_flashLight_on";
            break;
        }
        default:
            break;
    }
    
    return [UIImage imageNamed:imageName];
}


- (void)setBottomViewAlpha:(CGFloat)alpha
{
    self.bottomView.alpha = alpha;
}

- (void)setRecordBtnEnable:(BOOL)enadble
{
    [self.bottomView setRecordBtnEnable:enadble];
}

- (void)setRecordBtnProgress:(CGFloat)progress
{
    [self.bottomView setRecordBtnProgress:progress];
}

- (void)setDelayCloseViewHidden:(BOOL)hidden
{
    [self.bottomView setDelayCloseViewHidden:hidden];
}

- (void)setCountDownViewWithImage:(UIImage *)image
{
//    self.currentTopView.countDownView.image = image;
//    if (self.levelType == MDUnifiedRecordLevelTypeHigh) {
        self.rightViewForHigh.delayView.iconView.image = image;
//    } else {
        self.rightViewForNormal.delayView.iconView.image = image;
//    }
}

- (void)setDeleSegmentViewEnable:(BOOL)enable
{
    self.bottomView.deleSegmentView.userInteractionEnabled = enable;
}

- (void)setDeleSegmentViewSelected:(BOOL)selected
{
    [self.bottomView setDeleSegmentViewSelected:selected];
}

- (void)setDeleSegmentViewAlpha:(CGFloat)alpha
{
    self.bottomView.deleSegmentView.alpha = alpha;
}

- (void)setBottomAlbumButtonHidden:(BOOL)hidden{
    [self.bottomView setAlbumButtonHidden:hidden];
}

- (void)setEditButtonEnable:(BOOL)enable {
    self.bottomView.gotoEditView.userInteractionEnabled = enable;
}

- (void)setEditButtonEnableEvent:(BOOL)enableEvent {
    CGFloat alpha = enableEvent ? 1.0f : 0.5f;
    if ([self.delegate currentRecordDurationSmallerThanMinSegmentDuration]) {
        //没有开拍，不会出现下一步按钮
        alpha = 0.f;
    }
    
    self.bottomView.gotoEditView.alpha = alpha;
    self.bottomView.gotoEditView.md_enableEvent = enableEvent;
}

- (void)topViewShow:(BOOL)show animated:(BOOL)animated
{
    CGFloat top = show ? kTopEdge : (-self.currentTopView.height);
    CGFloat left = show ? (MDScreenWidth-kMDUnifiedRecordRightViewIconWidth-kMDUnifiedRecordRightViewRightMargin): MDScreenWidth;
    self.currentTopView.alpha = 1.0;
    self.currentRightView.alpha = 1.0;

    if (isFloatEqual(self.currentTopView.top, top)) {
        return;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.currentTopView.top = top;
            self.currentRightView.left = left;
        }];
        
    } else {
        self.currentTopView.top = top;
        self.currentRightView.left = left;
    }
}

- (void)updateForVideoRecording:(BOOL)isRecording animated:(BOOL)animated
{
    switch (self.levelType) {
        case MDUnifiedRecordLevelTypeNormal:
            [self updateNormalCaptureForVideoRecording:isRecording animated:animated];
            break;
            
        case MDUnifiedRecordLevelTypeHigh:
            [self updateHighCaptureUIForVideoRecording:isRecording animated:animated];
            
        default:
            break;
    }

    [self topViewShow:!isRecording animated:YES];
}

- (void)updateNormalCaptureForVideoRecording:(BOOL)isRecording animated:(BOOL)animated
{
    void(^action)(void) = ^(void) {
        self.cancelButton.alpha = isRecording ? 0.f : 1.f;
        self.slidingFilterView.userInteractionEnabled = !isRecording;
        self.loadingTipView.hidden = isRecording;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            action();
        }];
    } else {
        action();
    }
    
    [self.bottomView setRecordBtnActive:isRecording];
}

- (void)updateHighCaptureUIForVideoRecording:(BOOL)isRecording animated:(BOOL)animated
{
    void(^action)(void) = ^(void) {
        self.slidingFilterView.userInteractionEnabled = !isRecording;
        [self setRecordDurationLabelAlpha:(isRecording ? 1.f:0.f)];
        
        if (isRecording) {
            self.progressView.hilighted = NO;
            self.bottomView.deleSegmentView.alpha = 0.0f;
            self.bottomView.gotoEditView.alpha = 0.0f;
            self.highMiddleBottomBgView.alpha = 0.0f;
        } else {
            BOOL show = ![self.delegate currentRecordDurationSmallerThanMinSegmentDuration];
            CGFloat alpha = show ? 1.0f : .0f;
            
            self.bottomView.deleSegmentView.alpha = alpha;
            self.bottomView.gotoEditView.alpha = alpha;
            self.highMiddleBottomBgView.alpha = 1.0f;
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            action();
        } completion:nil];
    } else {
        action();
    }
    
    [self.bottomView setRecordBtnActive:isRecording];
}

- (void)updateForCountDownAnimation:(BOOL)showAnimation
{
    if (showAnimation) {
        //延时拍摄倒计时的时候把相册入口隐藏掉
        [self.bottomView setAlbumButtonHidden:YES];
    }else if([self.delegate currentRecordDurationSmallerThanMinSegmentDuration]){
        //延时拍摄中途停止 且没有拍摄片段 展示入口
        [self.bottomView setAlbumButtonHidden:NO];
    }
    CGFloat alpha = showAnimation ? 0.0f : 1.0f;
    self.cancelButton.alpha = alpha;
    self.currentTopView.alpha = alpha;
    self.currentRightView.alpha = alpha;
    [self highMiddleBottomViewShow:!showAnimation animated:NO];

    if ([self.delegate currentRecordDurationSmallerThanMinSegmentDuration]) {
        self.bottomView.gotoEditView.alpha = 0.0f;
        self.bottomView.deleSegmentView.alpha = 0.0f;
    } else {
        self.bottomView.gotoEditView.alpha = alpha;
        self.bottomView.deleSegmentView.alpha = alpha;
    }
}

- (void)setRecordDurationLabelAlpha:(CGFloat)alpha
{
    if (_levelType == MDUnifiedRecordLevelTypeNormal) return;
    
    if (isFloatEqual(self.cancelCaptureTipView.alpha, 1.0)) {
        self.recordDurationLabel.alpha = 0.0;
        return;
    }
    self.recordDurationLabel.alpha = alpha;
}

- (void)setRecordDurationLabelTextWithSecond:(int)second
{
    if (self.previousSeconds == second) return;
    
    self.previousSeconds = second;
    
    NSMutableString *text = [[NSMutableString alloc] initWithCapacity:1];
    
    int minute = second / 60;
    second = second - minute * 60;
    if (second < 10) {
        [text appendFormat:@"%d:0%d",minute,second];
    } else {
        [text appendFormat:@"%d:%d",minute,second];
    }
    
    self.recordDurationLabel.text = text;
}

- (void)normalRecordBtnTipViewShow:(BOOL)isShow animated:(BOOL)animated
{
    CGFloat alpha = isShow ? 1.0f : 0.0f;
    
    if (![self.delegate shouldShowNormalBtnTipView] || isFloatEqual(self.loadingTipView.alpha, 1.0)) {
        alpha = 0.f;
    }
    
    if (isFloatEqual(self.normalRecordBtnTipView.alpha, alpha)) {
        return;
    }
    
    self.normalRecordBtnTipView.text = [self.delegate normalBtnTip];

    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.normalRecordBtnTipView.alpha = alpha;
        }];
        
    } else {
        self.normalRecordBtnTipView.alpha = alpha;
    }
}

- (void)loadingTipViewShow:(BOOL)isShow animated:(BOOL)animated
{
    CGFloat alpha = isShow ? 1.0f : 0.0f;
    
    if (_levelType == MDUnifiedRecordLevelTypeHigh) {
        alpha = 0.f;
    }
    
    if (isFloatEqual(self.loadingTipView.alpha, alpha)) {
        return;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.loadingTipView.alpha = alpha;
        }];
        
    } else {
        self.loadingTipView.alpha = alpha;
    }
}

- (void)syschronizaRightView
{
    CGFloat alpha = self.currentTopView.flashLightView.alpha;
    self.topViewForNormal.flashLightView.alpha = alpha;
    self.topViewForHigh.flashLightView.alpha = alpha;
    
    self.topViewForNormal.flashLightView.image = self.currentTopView.flashLightView.image;
    self.topViewForHigh.flashLightView.image = self.currentTopView.flashLightView.image;
    
    [self.rightViewForNormal didShowFilter:self.currentRightView.currentShowFilter];
    [self.rightViewForHigh didShowFilter:self.currentRightView.currentShowFilter];
}

- (void)showTopViewWithOffset:(CGFloat)offset
{
    //滑动方向
    BOOL isLeft = offset < 0;
    
    MDUnifiedRecordTopView *nextTopView = (_levelType == MDUnifiedRecordLevelTypeHigh) ? self.topViewForNormal : self.topViewForHigh;
    MDUnifiedRecordRightView *nextRightView = (_levelType == MDUnifiedRecordLevelTypeHigh) ? self.rightViewForNormal : self.rightViewForHigh;
    MDUnifiedRecordLevelType *nextRecordLevelType = (_levelType == MDUnifiedRecordLevelTypeHigh) ? MDUnifiedRecordLevelTypeNormal : MDUnifiedRecordLevelTypeHigh;
    
    CGFloat changePercent = MIN(ABS(offset) / (MDScreenWidth / 1.5f), 1.0);
    CGFloat alpha = changePercent;
    CGFloat realOffset = (self.currentTopView.height + kTopEdge) * changePercent;
    CGFloat realRightOffset = (kMDUnifiedRecordRightViewIconWidth + kMDUnifiedRecordRightViewRightMargin) * changePercent;

    [self.bottomView setOffsetPercentage:changePercent withTargetLevelType:nextRecordLevelType];
    
    if (isLeft) {
        self.currentTopView.alpha = MAX(1.0 - alpha - 0.2, 0.0);
        self.currentRightView.alpha = MAX(1.0 - alpha - 0.2, 0.0);
        nextTopView.alpha = alpha;
        nextRightView.alpha = alpha;
        nextTopView.top = (-self.currentTopView.height) + realOffset;
        nextRightView.left = MDScreenWidth - realRightOffset;
    } else {
        nextTopView.alpha = MAX(alpha - 0.2, 0) ;
        nextRightView.alpha = MAX(alpha - 0.2, 0) ;
        self.currentTopView.alpha = MAX(1.0 - alpha, 0.0);
        self.currentRightView.alpha = MAX(1.0 - alpha, 0.0);

        self.currentTopView.top = kTopEdge - realOffset;
        self.currentRightView.left = MDScreenWidth-(kMDUnifiedRecordRightViewIconWidth + kMDUnifiedRecordRightViewRightMargin)+realRightOffset;
    }
}

- (void)setRecordBtnType:(MDUnifiedRecordLevelType)recordLevelType
{
    [self.bottomView setRecordBtnType:recordLevelType];
}

//横屏旋转
- (void)handleViewRotate:(UIDeviceOrientation)orientation
{
    CGAffineTransform rotate = CGAffineTransformMakeRotation(0);
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            rotate = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            rotate = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationPortrait:
        default:
            rotate = CGAffineTransformMakeRotation(0);
            break;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.cancelButton.transform = rotate;
        [self.currentRightView handleRotateWithTransform:rotate];
        [self.currentTopView handleRotateWithTransform:rotate];
        [self.bottomView handleRotateWithTransform:rotate];
        
    } completion:nil];
}


//引导动画
- (void)doGuideAnimationWithLevelType:(MDUnifiedRecordLevelType)levelType
{
//    BOOL filterGuide = nil;// [[MDContext currentUser].dbStateHoldProvider hasShowedMomentRecordFilterGuide];
//    if (!filterGuide) {
//        [[MDContext currentUser].dbStateHoldProvider setHasShowedMomentRecordFilterGuide:YES];
//        MDRecordFilterTipView *tipView = [[MDRecordFilterTipView alloc] initWithFrame:self.bounds];
//        tipView.tag = kFilterGuideTipViewTag;
//        __weak typeof(self) weakSelf = self;
//        [tipView showWithContainView:self comletion:^{
//            MDRecordGuideTipsType tipsType = (levelType == MDUnifiedRecordLevelTypeHigh) ? MDRecordGuideTipsTypeHighCapture : MDRecordGuideTipsTypeNormalCapture;
//            [weakSelf.guideTipsManager doGuideAnimationWithTipsType:tipsType andContainerView:weakSelf];
//        }];
//        return;
//    }
//
//    MDRecordGuideTipsType tipsType = (levelType == MDUnifiedRecordLevelTypeHigh) ? MDRecordGuideTipsTypeHighCapture : MDRecordGuideTipsTypeNormalCapture;
//    [self.guideTipsManager doGuideAnimationWithTipsType:tipsType andContainerView:self];
}

#pragma mark - MDRecordGuideTipsManagerDelegate
- (void)anchorPoint:(CGPoint *)point
       anchorOffSet:(CGFloat *)anchorOffSet
         anchorType:(NSInteger *)anchorType
      withIdentifer:(NSString *)identifier
{
}

- (BOOL)shouldShowLocalGuideWithIdentifier:(NSString *)identifier
{
    return NO;
}

//宠物扫描相关
- (void)applyPetScannerMode {
    
    [self applyPetRecordMode];
}

//宠物拍摄分享
- (void)applyPetRecordMode {
    [_normalRecordBtnTipView removeFromSuperview];
    _normalRecordBtnTipView = nil;
    [_speedControlView removeFromSuperview];
    _speedControlView = nil;
    [_currentRightView removeFromSuperview];
    _currentRightView = nil;
    [_filterTipLabel removeFromSuperview];
    _filterTipLabel = nil;
    [_currentTopView removeFromSuperview];
    _currentTopView = nil;
    [_topCoverView removeFromSuperview];
    _topCoverView = nil;
    [_bottomCoverView removeFromSuperview];
    _bottomCoverView = nil;
    [_bottomView removeFromSuperview];
    _bottomView = nil;
    [_cancelButton removeFromSuperview];
    _cancelButton = nil;
    
    [self addPetRecordBtnTipView];
    [self addPetButtonView];
    
}
- (void)addPetRecordBtnTipView{
    MDStrokeLabel *strokeLabel = [[MDStrokeLabel alloc] initWithFrame:CGRectMake(0, MDScreenHeight - 136 - 18, MDScreenWidth, 18)];
    strokeLabel.text = [self.delegate normalBtnTip];
    strokeLabel.strokeColor = RGBCOLOR(41, 134, 179);
    strokeLabel.strokeWidth = 2;
    strokeLabel.font = [UIFont systemFontOfSize:15];
    strokeLabel.textAlignment = NSTextAlignmentCenter;
    strokeLabel.textColor = UIColor.whiteColor;
    [self addSubview:strokeLabel];
}
- (void)addPetButtonView{
    self.petRecordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, MDScreenHeight - 56.5 - 77, 77, 77)];
     self.petRecordButton.centerX = self.bottomView.width * 0.5f;
    [self.petRecordButton addTarget:self action:@selector(didTapRecordButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: self.petRecordButton];
}

- (void)setPetRecordButtonMode:(BOOL)isEnable{
//    self.petRecordButton.enabled = isEnable;
//    if(isEnable){
//        [self.petRecordButton setBackgroundImage:[UIImage imageWithContentsOfFile:[MDPetHelper getFilePath:@"zhaoxiang2.png"]] forState:UIControlStateNormal];
//        
//    }else{
//        [self.petRecordButton setBackgroundImage:[UIImage imageWithContentsOfFile:[MDPetHelper getFilePath:@"zhaoxiang.png"]] forState:UIControlStateNormal];
//    }
}

#pragma mark - 从相册点击进来
- (void)setFromAlbum:(BOOL)fromAlbum{
    _fromAlbum = fromAlbum;
    [_bottomView setDisableAlbumEntrance:YES];
    
    UIImageView *imageView = [_cancelButton viewWithTag:kCancelButtonImageViewTag];
    if (fromAlbum) {
        [imageView setImage:[UIImage imageNamed:@"UIBundle.bundle/nav_back_bg2"]];
    }else{
        [imageView setImage:[UIImage imageNamed:@"btn_moment_record_close"]];
    }
}

@end
