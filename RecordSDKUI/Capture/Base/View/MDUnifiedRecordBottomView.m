//
//  MDUnifiedRecordBottomView.m
//  MDChat
//
//  Created by 符吉胜 on 2017/6/2.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordBottomView.h"
#import "MDUnifiedRecordButton.h"

//变脸推荐
#import "MDPhotoLibraryProvider.h"
#import "UIImage+ClipScaleRect.h"
#import "MDUnifiedRecordIconView.h"

static const CGFloat kFaceDecorationButtonWidth = 50;
static const CGFloat kTopEdge = 80;
static const CGFloat kBottomEdge = 20;
static const CGFloat kRecordButtonH = 90.0f;
static const CGFloat kViewH = kRecordButtonH + kTopEdge + kBottomEdge;

static const CGFloat kMargin = 50;

static NSString * const kDeleSegmentSelectedImageName = @"moment_record_delete_hilighted_new";
static NSString * const kDeleSegmentUnSelectedImageName = @"moment_record_delete";


@interface MDUnifiedRecordBottomView()

@property (nonatomic,strong) UIImageView                    *deleSegmentView;
@property (nonatomic,strong) UIImageView                    *gotoEditView;
@property (nonatomic,strong) MDUnifiedRecordButton          *recordButton;
@property (nonatomic,strong) UIImageView                    *delayCloseView;
@property (nonatomic,strong) UIButton                       *albumButton;
@property (nonatomic,strong) MDUnifiedRecordIconView        *faceDecorationButton;

@property (nonatomic,assign) MDUnifiedRecordLevelType       levelType;

@property (nonatomic,assign,getter=isDeleSegmentViewSelected) BOOL deleSegmentViewSelected;

@property (nonatomic,assign) BOOL                           disableAlbumEntrance;
@property (nonatomic,assign) BOOL                           hadShowAlert;
@end

@implementation MDUnifiedRecordBottomView

- (instancetype)initWithDelegate:(id<MDUnifiedRecordBottomViewDelegate,MDUnifiedRecordButtonDelegate>)delegate andLevelType:(MDUnifiedRecordLevelType)levelType;
{
    if (self = [self initWithFrame:CGRectMake(0, 0, MDScreenWidth, kViewH)]) {
        _delegate = delegate;
        _levelType = levelType;
        [self configUI];
    }
    return self;
}

- (void)configUI
{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.recordButton];
    if (!self.disableAlbumEntrance) {
        [self addSubview:self.albumButton];
    }
    [self addSubview:self.faceDecorationButton];
    [self addSubview:self.delayCloseView];
    [self addSubview:self.deleSegmentView];
    [self addSubview:self.gotoEditView];
    
    [_faceDecorationButton.widthAnchor constraintEqualToConstant:kFaceDecorationButtonWidth].active = YES;
    [_faceDecorationButton.heightAnchor constraintEqualToConstant:kFaceDecorationButtonWidth].active = YES;
    [_faceDecorationButton.rightAnchor constraintEqualToAnchor:self.recordButton.leftAnchor constant:-25].active = YES;
    [_faceDecorationButton.centerYAnchor constraintEqualToAnchor:self.recordButton.centerYAnchor].active = YES;
}

- (MDUnifiedRecordButton *)recordButton
{
    if (!_recordButton) {
        _recordButton = [[MDUnifiedRecordButton alloc] initWithFrame:CGRectMake(0, 0, 85, 85) andButtonType:[self buttonTypeWithRecordType:_levelType]];
        
        _recordButton.centerX = self.width * 0.5f;
        _recordButton.top = kTopEdge;
        
        _recordButton.delegate = self.delegate;
    }
    
    return _recordButton;
}

- (MDUnifiedRecordIconView *)faceDecorationButton {
    if (!_faceDecorationButton) {
        _faceDecorationButton = [[MDUnifiedRecordIconView alloc] initWithFrame:CGRectMake(0, 0, kFaceDecorationButtonWidth, kFaceDecorationButtonWidth) imageName:@"changeFace" title:@"特效" needScrollTitle:NO target:self action:@selector(clickFaceDecorationAction)];
        _faceDecorationButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _faceDecorationButton;
}

- (UIButton *)albumButton{
    if (!_albumButton) {
        _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _albumButton.frame = CGRectMake(0, 0, 32, 32);
        _albumButton.left = self.recordButton.left - 25 - 32;
        _albumButton.centerY = self.recordButton.centerY;
        [_albumButton setBackgroundImage:[UIImage imageNamed:@"camera_album_enter_icon"] forState:UIControlStateNormal];
        _albumButton.adjustsImageWhenHighlighted = NO;
        
        [_albumButton addTarget:self action:@selector(clickAlbumAction) forControlEvents:UIControlEventTouchUpInside];
        
        [MDPhotoLibraryProvider loadPhotolibraryMaxCount:1 type:MDPhotoItemTypeImage complite:^(NSArray *results) {
            if (results.count>0) {
                id asset = [results firstObject];
                if ([asset isKindOfClass:[PHAsset class]]) {
                    [MDPhotoLibraryProvider loadThumbImage:asset thumbSize:CGSizeMake(32 * 2, 32 * 2) contentMode:PHImageContentModeAspectFit readItem:^(MDPhotoItem *item) {
                        if (item.nailImage) {
                            UIImage *img = [item.nailImage clipImageInRect:_albumButton.bounds cornerRadius:6.0];
                            [_albumButton setBackgroundImage:img forState:UIControlStateNormal];
                        }
                    }];
                }
            }
        }];
    }
    
    return _albumButton;
}


- (UIImageView *)delayCloseView
{
    if (!_delayCloseView) {
        UIImage *image = [UIImage imageNamed:@"moment_record_delay_close"];
        _delayCloseView = [[UIImageView alloc] initWithImage:image];
        _delayCloseView.frame = CGRectMake(0, 0, 45, 45);
        _delayCloseView.center = self.recordButton.center;
        _delayCloseView.contentMode = UIViewContentModeCenter;
        _delayCloseView.userInteractionEnabled = YES;
        _delayCloseView.hidden = YES;
        
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapDelayCloseView)];
        [_delayCloseView addGestureRecognizer:tapGesture];
        
    }
    return _delayCloseView;
}

- (UIImageView *)deleSegmentView
{
    if (!_deleSegmentView) {
        UIImage *deleteSegmentImage = [UIImage imageNamed:kDeleSegmentUnSelectedImageName];
        _deleSegmentView = [[UIImageView alloc] initWithImage:deleteSegmentImage];
        _deleSegmentView.frame = CGRectMake(0, 0, deleteSegmentImage.size.width, deleteSegmentImage.size.height);
//        _deleSegmentView.right = self.recordButton.left - kMargin;
//        _deleSegmentView.centerY = self.recordButton.centerY;
        _deleSegmentView.centerX = self.recordButton.centerX;
        _deleSegmentView.bottom = self.recordButton.top - 8;
        _deleSegmentView.userInteractionEnabled = YES;
        
        _deleSegmentView.alpha = 0.0f;
        
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapDeleSegmentView)];
        [_deleSegmentView addGestureRecognizer:tapGesture];
    }
    return _deleSegmentView;
}

- (UIImageView *)gotoEditView
{
    if (!_gotoEditView) {
        UIImage *image = [UIImage imageNamed:@"moment_record_goto_edit"];
        _gotoEditView = [[UIImageView alloc] initWithImage:image];
        _gotoEditView.frame = CGRectMake(self.recordButton.right + kMargin, 0, image.size.width, image.size.height);
        _gotoEditView.centerY = self.recordButton.centerY;
        _gotoEditView.userInteractionEnabled = YES;
        
        _gotoEditView.alpha = 0.0f;
        
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGotoEditView)];
        [_gotoEditView addGestureRecognizer:tapGesture];
    }
    return _gotoEditView;
}

#pragma mark - 交互事件
- (void)didTapDelayCloseView
{
    if ([self.delegate respondsToSelector:@selector(didTapDelayCloseView:)]) {
        [self.delegate didTapDelayCloseView:self.delayCloseView];
    }
}

- (void)didTapDeleSegmentView
{
    if ([self.delegate respondsToSelector:@selector(didTapDeleSegmentView:isSelected:)]) {
        [self.delegate didTapDeleSegmentView:self.deleSegmentView isSelected:self.isDeleSegmentViewSelected];
    }
}

- (void)didTapGotoEditView
{
    if ([self.delegate respondsToSelector:@selector(didTapGotoEditView:)]) {
        [self.delegate didTapGotoEditView:self.gotoEditView];
    }
}

- (void)clickAlbumAction{
    if ([self.delegate respondsToSelector:@selector(didTapAlbumButton:)]) {
        [self.delegate didTapAlbumButton:self.hadShowAlert];
        self.hadShowAlert = NO;
    }
}

- (void)clickFaceDecorationAction {
    if ([self.delegate respondsToSelector:@selector(didTapFaceDecorationButton:)]) {
        [self.delegate didTapFaceDecorationButton:self.faceDecorationButton.iconView];
    }
}

#pragma mark - public function
- (void)setRecordBtnEnable:(BOOL)enadble
{
    self.recordButton.userInteractionEnabled = enadble;
}

- (void)setRecordBtnActive:(BOOL)active
{
    self.recordButton.active = active;
    
    //高级拍摄在非active时 要判断是否有拍摄内容 没有拍摄内容才展示相册入口
    BOOL haveRecord = NO;
    if ([self.delegate respondsToSelector:@selector(currentRecordDurationSmallerThanMinSegmentDuration)]) {
        //代理返回YES表示没录制 返回NO表示已经录制
        haveRecord = ![self.delegate currentRecordDurationSmallerThanMinSegmentDuration];
    }

    if (haveRecord) {
        [self setAlbumButtonHidden:YES];
    }else{
        [self setAlbumButtonHidden:active];
    }
}

- (void)setOffsetPercentage:(CGFloat)percentage withTargetLevelType:(MDUnifiedRecordLevelType)recordLevelType
{
    [self.recordButton setOffsetPercentage:percentage withTargetButtonType:[self buttonTypeWithRecordType:recordLevelType]];
}

- (void)setRecordBtnProgress:(CGFloat)progress
{
    self.recordButton.progress = progress;
}

- (void)setRecordBtnType:(MDUnifiedRecordLevelType)recordLevelType
{
    _levelType = recordLevelType;
    
    [self.recordButton setCurrentButtonType:[self buttonTypeWithRecordType:recordLevelType]];
}

- (void)setDelayCloseViewHidden:(BOOL)hidden
{
    self.delayCloseView.hidden = hidden;
    self.recordButton.userInteractionEnabled = hidden;
}

- (void)setDelayClosViewWithImage:(UIImage *)delayImage
{
    self.delayCloseView.image = delayImage;
}

- (void)setRecordButtonAlpha:(CGFloat)alpha
{
    self.recordButton.alpha = alpha;
}

- (void)setAlbumButtonHidden:(BOOL)hidden{
    //有内容和明确声明禁止展示相册入口的情况下 直接设置隐藏
    if (self.disableAlbumEntrance || ![self.delegate currentRecordDurationSmallerThanMinSegmentDuration]) {
        _albumButton.hidden = YES;
        return;
    }

    _albumButton.hidden = hidden;
}

- (void)setDisableAlbumEntrance:(BOOL)disableAlbumEntrance{
    _disableAlbumEntrance = disableAlbumEntrance;
    if (disableAlbumEntrance) {
        _albumButton.hidden = YES;
    }else{
        [self showAlbumVideoAlertGuide];
    }
}

- (void)setDeleSegmentViewSelected:(BOOL)selected
{
    _deleSegmentViewSelected = selected;
    NSString *imageName = selected ? kDeleSegmentSelectedImageName : kDeleSegmentUnSelectedImageName;
    self.deleSegmentView.image = [UIImage imageNamed:imageName];
}

- (void)handleRotateWithTransform:(CGAffineTransform)transform
{
    self.recordButton.transform = transform;
    self.deleSegmentView.transform = transform;
    self.gotoEditView.transform = transform;
}

- (CGRect)absoluteFrameOfRecordButton
{
    CGRect absoluteFrame = CGRectZero;
    absoluteFrame = [self convertRect:self.recordButton.frame toView:[MDRecordContext appWindow]];
    return absoluteFrame;
}

#pragma mark - 辅助方法
- (MDUnifiedRecordButtonType)buttonTypeWithRecordType:(MDUnifiedRecordLevelType)levelType
{
    MDUnifiedRecordButtonType buttonType = MDUnifiedRecordButtonTypeNormal;
    if (levelType == MDUnifiedRecordLevelTypeHigh) {
        buttonType = MDUnifiedRecordButtonTypeHigh;
    }
    return buttonType;
}

#pragma mark - 影集引导
- (void)showAlbumVideoAlertGuide{
//    BOOL couldShow = YES;
//    //按钮隐藏 不展示
//    if (_albumButton.hidden) {
//        couldShow = NO;
//    }
//    //如果是点点个人资料设置头像图片等内容 不展示（这两种情况相册页不会有影集帧）
//    if ([self.delegate respondsToSelector:@selector(couldShowAlbumVideoAlert)]) {
//        if (![self.delegate couldShowAlbumVideoAlert]) {
//            couldShow = NO;
//        }
//    }
//    //展示过了不展示
//    if ([[[MDContext currentUser] dbStateHoldProvider] hadShowAlbumVideoAlertTip]) {
//        couldShow = NO;
//    }
//
//    if (!couldShow) {
//        return;
//    }
//    [[[MDContext currentUser] dbStateHoldProvider] setHadShowAlbumVideoAlertTip:YES];
//    MUAt8AlertBarModel *model = [MUAt8AlertBarModel new];
//    model.maskFrame = self.bounds;
//    model.textColor = RGBCOLOR(32, 33, 33);
//    model.backgroundColor = [UIColor whiteColor];
//    model.title = @"体验影集,让照片动起来!";
//    model.anchorType = MUAt8AnchorTypeBottom;
//    if(MDScreenWidth <= 320){
//        model.anchorOffset = - 33;
//    }
//    model.anchorPoint = CGPointMake(_albumButton.centerX, _albumButton.top);
//    __block MUAlertBar *alertBar = [MUAlertBarDispatcher alertBarWithModel:model];
//    [self addSubview:alertBar];
//    [self bringSubviewToFront:alertBar];
//    self.hadShowAlert = YES;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [alertBar removeFromSuperview];
//        alertBar = nil;
//    });
}


@end



@implementation UIImageView (userEnableEvent)

- (void)setMd_enableEvent:(BOOL)md_enableEvent {
    objc_setAssociatedObject(self, @selector(md_enableEvent), @(md_enableEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)md_enableEvent {
    NSNumber *object = objc_getAssociatedObject(self, _cmd);
    return [object boolValue];
}

@end
