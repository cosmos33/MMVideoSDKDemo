//
//  MDMediaEditorContainerView.m
//  MDChat
//
//  Created by 符吉胜 on 2017/8/24.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMediaEditorContainerView.h"
#import "UIImage+MDUtility.h"
#import "MUAt8AlertBar.h"
#import "MUAlertBarDispatcher.h"
@import MomoCV;

const CGFloat kMediaEditorViewLeftRightMargin = 8;
const CGFloat kMediaEditorBottomToolButtonWidth = 45;
const CGFloat kMediaEditorMoreBetweenMargin = 22;
const CGFloat kMediaEditorBottomBelowMargin = 9;

#define kMediaEditorRightViewTopEdge (IS_IPHONE_X ? (130 + 44) : 130)

NSString * const kBtnTitleForFilter         = @"滤镜";
NSString * const kBtnTitleForSticker        = @"贴纸";
NSString * const kBtnTitleForText           = @"文字";
NSString * const kBtnTitleForMusic          = @"配乐";
NSString * const kBtnTitleForthumbSelect    = @"封面";
NSString * const kBtnTitleForMoreAction     = @"更多";
NSString * const kBtnTitleForSpeedVary      = @"变速";
NSString * const kBtnTitleForPainter        = @"涂鸦";
NSString * const kBtnTitleForSpecialEffect  = @"特效";
NSString * const kBtnTitleForBeauty         = @"人像";

NSString * const kImageNameForFilter         = @"editFilters";
NSString * const kImageNameForSticker        = @"editStiker";
NSString * const kImageNameForText           = @"editText";
NSString * const kImageNameForMusic          = @"editMusic";
NSString * const kImageNameForthumbSelect    = @"editThumbImage";
NSString * const kImageNameForMoreAction     = @"moment_more_actions";
NSString * const kImageNameForSpeedVary      = @"editSpeedVary";
NSString * const kImageNameForPainter        = @"editDraw";
NSString * const kImageNameForSpecialEffect  = @"editSpecial";
NSString * const kImageNameForBeauty         = @"editPersonalImage";

#define kBottomEdgeFor720p (IS_IPHONE_X ? ((MDScreenHeight - (MDScreenWidth * (1280.0/720.0))) / 2.0) : 0)

@interface MDMediaEditorContainerView ()
<
    MDNewMediaEditorBottomViewDelegate
>

// ************  UI  ***************
//文字涂鸦贴纸
@property (nonatomic, strong) MDHitTestExpandView    *costumContentView;  // 贴纸，涂鸦，文字的背景视图
@property (nonatomic, strong) BBMediaStickerAdjustmentView  *stickerAdjustView; //贴纸视图
@property (nonatomic, strong) UIImageView                   *graffitiCanvasView; //涂鸦视图
@property (nonatomic, strong) MDMomentTextAdjustmentView    *textAdjustView;  //文字视图
//顶部按钮
@property (nonatomic, strong) UIButton  *doneBtn; //完成按钮
//@property (nonatomic, strong) MDHitTestExpandView  *cancelBtn; //取消按钮
@property (nonatomic, strong) UIButton *cancelButton;

// 底部按钮
@property (nonatomic, strong) MDNewMediaEditorBottomView *buttonView;

@property (nonatomic, strong) UIButton  *stickerDeleteBtn; //删除贴纸按钮

@property (nonatomic, strong) UIButton              *reSendBtn;

@property (nonatomic, assign) CGFloat   edgeMargin;

@property (nonatomic, strong) UIButton  *qualityBlockBtn;

@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation MDMediaEditorContainerView

#pragma mark - life cycle
- (instancetype)initWithDelegate:(id<MDMediaEditorContainerViewDelegate>)delegate whRatio:(CGFloat)whRatio
{
    if (self = [self initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)]) {
        self.delegate = delegate;
        _edgeMargin = (whRatio > 0.5 && whRatio < 0.6) ? kBottomEdgeFor720p : (IS_IPHONE_X ? HOME_INDICATOR_HEIGHT : 0);
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    //上下遮罩
    [self addMask];
    
    [self addSubview:self.costumContentView];
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(custumContentViewTapped)];
    [self.costumContentView addGestureRecognizer:tapGesture];
    
    //贴纸，文字，涂鸦
    [self.costumContentView addSubview:self.stickerAdjustView];
    [self.costumContentView addSubview:self.graffitiCanvasView];
    [self.costumContentView addSubview:self.textAdjustView];
    
    //完成和取消
    [self addSubview:self.doneBtn];
//    [self addSubview:self.cancelBtn];
    [self addSubview:self.cancelButton];
    
    [self addSubview:self.timeLabel];
    
    [self.timeLabel.centerYAnchor constraintEqualToAnchor:self.cancelButton.centerYAnchor].active = YES;
    [self.timeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    
    //普通页面配置
    [self configBottomViewForNormal];
}

- (void)configBottomViewForNormal
{
    [self addSubview:self.buttonView];
    [self.buttonView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.buttonView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.buttonView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.buttonView.heightAnchor constraintEqualToConstant:103].active = YES;
    
    [self addSubview:self.stickerDeleteBtn]; //贴纸删除按钮
}

#pragma mark - public

- (void)addArPetAlertPopView {
    
//    if (self.qualityResult) {
//        MUAt8AlertBarModel *model = [MUAt8AlertBarModel new];
//        model.maskFrame = self.bounds;
//        model.anchorType = MUAt8AnchorTypeTop;
//        
//        if (self.qualityResult.exposeType) {
//            model.title = @"衣冠不整，请重新拍摄";
//            model.anchorOffset = 50;
//            model.anchorPoint = CGPointMake(self.doneBtn.left + 25, self.doneBtn.bottom + 10);
//            
//            MUAlertBar *alertModelView = [MUAlertBarDispatcher alertBarWithModel:model];
//            [self addSubview:alertModelView];
//            [self createQualityBlockBtn];
//            self.doneBtn.hidden = YES;
//            
//            _qualityBlockBtn.hidden = NO;
//            return;
//        }
//        if (self.qualityResult.qualityType == MMQualityBackScreen) {
//            model.title = @"光线太暗，请重新拍摄";
//            model.anchorOffset = 50;
//            model.anchorPoint = CGPointMake(self.doneBtn.left + 25, self.doneBtn.bottom + 10);
//            
//            MUAlertBar *alertModelView = [MUAlertBarDispatcher alertBarWithModel:model];
//            [self addSubview:alertModelView];
//            [self createQualityBlockBtn];
//            self.doneBtn.hidden = YES;
//            _qualityBlockBtn.hidden = NO;
//            
//            return;
//        } else if (self.qualityResult.qualityType == MMQualitySharpnessLow) {
//            model.title = @"清晰度太低，请重新拍摄";
//            model.anchorOffset = 50;
//            model.anchorPoint = CGPointMake(self.doneBtn.left + 25, self.doneBtn.bottom + 10);
//            
//            MUAlertBar *alertModelView = [MUAlertBarDispatcher alertBarWithModel:model];
//            [self addSubview:alertModelView];
//            [self createQualityBlockBtn];
//            self.doneBtn.hidden = YES;
//            _qualityBlockBtn.hidden = NO;
//            return;
//        }
//        if (self.qualityResult.stationState == MMArpetPhotoStationStateSmoke) {
//            model.title = @"提升个人形象，请勿吸烟";
//            model.anchorPoint = CGPointMake(self.doneBtn.left + 25, self.doneBtn.bottom + 10);
//            model.anchorOffset = 50;
//            MUAlertBar *alertModelView = [MUAlertBarDispatcher alertBarWithModel:model];
//            [self addSubview:alertModelView];
//            [self createQualityBlockBtn];
//            self.doneBtn.hidden = YES;
//            _qualityBlockBtn.hidden = NO;
//            return;
//        }
//        
//        if (self.qualityResult.upwardType == MMArpetUpwardBad) {
//            model.title = @"大脸仰拍角度不好，建议镜头拉远重新拍";
//            model.anchorOffset = -140;
////            model.anchorPoint = CGPointMake(self.cancelBtn.right - 10, self.cancelBtn.bottom + 10);
//            model.anchorPoint = CGPointMake(self.cancelButton.right - 10, self.cancelButton.bottom + 10);
//            
//            MUAlertBar *alertModelView = [MUAlertBarDispatcher alertBarWithModel:model];
//            [self addSubview:alertModelView];
//            
//            _qualityBlockBtn.hidden = YES;
//            return;
//        }
//        if (self.qualityResult.qualityType == MMQualitySharpnessLow) {
//            model.title = @"光线不佳，建议重新拍摄";
////            model.anchorPoint = CGPointMake(self.cancelBtn.right, self.cancelBtn.bottom + 10);
//            model.anchorPoint = CGPointMake(self.cancelButton.right, self.cancelButton.bottom + 10);
//            model.anchorOffset = -60;
//            MUAlertBar *alertModelView = [MUAlertBarDispatcher alertBarWithModel:model];
//            [self addSubview:alertModelView];
//            
//            _qualityBlockBtn.hidden = YES;
//            return;
//        }
//    }
}

#pragma mark - event

- (void)custumContentViewTapped
{
    if ([self.delegate respondsToSelector:@selector(custumContentViewTapped)]) {
        [self.delegate custumContentViewTapped];
    }
}

- (void)doneButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(doneButtonTapped)]) {
        [self.delegate doneButtonTapped];
    }
}

- (void)qualityBlockEvent:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(arPetQualityCancelBlockEvent)]) {
        [self.delegate arPetQualityCancelBlockEvent];
    }
}

- (void)reSendBtnTapped
{
    if ([self.delegate respondsToSelector:@selector(reSendBtnTapped)]) {
        [self.delegate reSendBtnTapped];
    }
}

- (void)cancelButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(cancelButtonTapped)]) {
        [self.delegate cancelButtonTapped];
    }
}

- (void)showTopicSelectTable
{
    if ([self.delegate respondsToSelector:@selector(showTopicSelectTable)]) {
        [self.delegate showTopicSelectTable];
    }
}

- (void)filterButtonTapped {
    if ([self.delegate respondsToSelector:@selector(filterButtonTapped)]) {
        [self.delegate filterButtonTapped];
    }
}

- (void)stickerEditButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(stickerEditButtonTapped)]) {
        [self.delegate stickerEditButtonTapped];
    }
}

- (void)textButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(textButtonTapped)]) {
        [self.delegate textButtonTapped];
    }
}

- (void)audioMixButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(audioMixButtonTapped)]) {
        [self.delegate audioMixButtonTapped];
    }
}

- (void)thumbSelectButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(thumbSelectButtonTapped)]) {
        [self.delegate thumbSelectButtonTapped];
    }
}

- (void)moreActionsBtnTapped
{
    if ([self.delegate respondsToSelector:@selector(moreActionsBtnTapped)]) {
        [self.delegate moreActionsBtnTapped];
    }
}

- (void)saveButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(saveButtonTapped)]) {
        [self.delegate saveButtonTapped];
    }
}

- (void)speedVaryButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(speedVaryButtonTapped)]) {
        [self.delegate speedVaryButtonTapped];
    }
}

- (void)painterEditButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(painterEditButtonTapped)]) {
        [self.delegate painterEditButtonTapped];
    }
}

- (void)thinBodyBtnTapped {
    if ([self.delegate respondsToSelector:@selector(thinBodyBtnTapped)]) {
        [self.delegate thinBodyBtnTapped];
    }
}
- (void)specialEffectsBtnTapped {
    if ([self.delegate respondsToSelector:@selector(specialEffectsBtnTapped)]) {
        [self.delegate specialEffectsBtnTapped];
    }
}

- (UIImage *)selectedImageWithBtnTitle:(NSString *)btnTitle
{
    UIImage *selectedImage = nil;
    if ([btnTitle isEqualToString:kBtnTitleForMusic]) {
        selectedImage = [UIImage imageNamed:@"background_music_btn_selected"];
    }
    else if ([btnTitle isEqualToString:kBtnTitleForthumbSelect]) {
        selectedImage = [UIImage imageNamed:@"icon_moment_cover_select"];
    }
    return selectedImage;
}

#pragma mark - create UI

// 上下阴影遮罩
- (void)addMask
{
    UIView *topCover = [self coverViewWithFrame:CGRectMake(0, 0, MDScreenWidth, 80) startAlpha:0.25f toBottom:YES];
    [self addSubview:topCover];
    
    UIView *bottomCover = [self coverViewWithFrame:CGRectMake(0, MDScreenHeight -115, MDScreenWidth, 115) startAlpha:0.35f toBottom:NO];
    [self addSubview:bottomCover];
}

// 贴纸，文字，涂鸦背景视图
- (MDHitTestExpandView *)costumContentView {
    if (!_costumContentView) {
        CGRect frame = CGRectZero;
        if ([self.delegate respondsToSelector:@selector(videoRenderFrame)]) {
            frame = [self.delegate videoRenderFrame];
        }
        _costumContentView = [[MDHitTestExpandView alloc] initWithFrame:frame];
        _costumContentView.minHitTestWidth = MDScreenWidth;
        _costumContentView.minHitTestHeight = MDScreenHeight;
    }
    return _costumContentView;
}

// 贴纸的view
- (BBMediaStickerAdjustmentView *)stickerAdjustView
{
    if (!_stickerAdjustView) {
        _stickerAdjustView = [[BBMediaStickerAdjustmentView alloc] initWithFrame:self.costumContentView.bounds];
    }
    return _stickerAdjustView;
}

// 涂鸦的view
- (UIImageView *)graffitiCanvasView
{
    if (!_graffitiCanvasView) {
        _graffitiCanvasView = [[UIImageView alloc] initWithFrame:self.costumContentView.bounds];
        UIImage *image = [UIImage imageWithColor:[UIColor clearColor] finalSize:_graffitiCanvasView.size];
        _graffitiCanvasView.image = image;
        _graffitiCanvasView.alpha = 0;
    }
    return _graffitiCanvasView;
}

// 文字的view
- (MDMomentTextAdjustmentView *)textAdjustView
{
    if (!_textAdjustView) {
        _textAdjustView = [[MDMomentTextAdjustmentView alloc] initWithFrame:self.costumContentView.bounds];
    }
    return _textAdjustView;
}

// 完成按钮
- (UIButton *)doneBtn
{
    if (!_doneBtn) {
        UIFont *titleFont = [UIFont boldSystemFontOfSize:14.0f];
        NSString *title = nil;
        if ([self.delegate respondsToSelector:@selector(doneButtonTitle)]) {
            title = [self.delegate doneButtonTitle];
        }
        
        UIImage *image = [UIImage imageNamed:@"icon_moment_edit_check"];
        UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20.0f + _edgeMargin, 85, 40)];
        doneButton.backgroundColor = RGBCOLOR(0, 192, 255);
        doneButton.right = MDScreenWidth - 12.0f;
        
        [doneButton setImage:image forState:UIControlStateNormal];
        [doneButton setImage:image forState:UIControlStateHighlighted];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton setTitle:title forState:UIControlStateNormal];
        doneButton.titleLabel.font = titleFont;
        
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName : titleFont}];
        [doneButton setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width + 5, 0, -titleSize.width)];
        [doneButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width, 0, image.size.width)];
        
        doneButton.layer.cornerRadius = doneButton.height / 2.0f;
        doneButton.layer.masksToBounds = YES;
        [doneButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchDown];
        
        _doneBtn = doneButton;
    }
    return _doneBtn;
}

- (void)createQualityBlockBtn {
    if (!_qualityBlockBtn) {
        
        UIFont *titleFont = [UIFont boldSystemFontOfSize:14.0f];
        NSString *title = @"重新拍摄";

        UIImage *image = [UIImage imageNamed:@"icon_moment_edit_check"];
        UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20.0f + _edgeMargin, 85, 40)];
        doneButton.backgroundColor = RGBCOLOR(0, 192, 255);
        doneButton.right = MDScreenWidth - 12.0f;
        
        [doneButton setImage:image forState:UIControlStateNormal];
        [doneButton setImage:image forState:UIControlStateHighlighted];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton setTitle:title forState:UIControlStateNormal];
        doneButton.titleLabel.font = titleFont;
        
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName : titleFont}];
        [doneButton setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width + 5, 0, -titleSize.width)];
        [doneButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width, 0, image.size.width)];
        
        doneButton.layer.cornerRadius = doneButton.height / 2.0f;
        doneButton.layer.masksToBounds = YES;
        [doneButton addTarget:self action:@selector(qualityBlockEvent:) forControlEvents:UIControlEventTouchDown];
        
        _qualityBlockBtn = doneButton;
        
        [self addSubview:_qualityBlockBtn];
        
    }
}

//重新拍摄按钮
- (UIButton *)reSendBtn
{
    if (!_reSendBtn) {
        UIFont *titleFont = [UIFont boldSystemFontOfSize:14.0f];
        UIButton *reSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20.0f + _edgeMargin, 85, 40)];
        reSendBtn.backgroundColor = RGBCOLOR(0, 192, 255);
        reSendBtn.right = MDScreenWidth - 12.0f;
        [reSendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [reSendBtn setTitle:@"重新拍摄" forState:UIControlStateNormal];
        reSendBtn.titleLabel.font = titleFont;
        reSendBtn.layer.cornerRadius = reSendBtn.height / 2.0f;
        reSendBtn.layer.masksToBounds = YES;
        
        [reSendBtn addTarget:self action:@selector(reSendBtnTapped) forControlEvents:UIControlEventTouchDown];
        
        _reSendBtn = reSendBtn;
    }
    return _reSendBtn;
}

// 取消按钮
//- (MDHitTestExpandView *) cancelBtn
//{
//    if (!_cancelBtn) {
//        UIImage *cancelImage = [UIImage imageNamed:@"UIBundle.bundle/nav_back_bg2"];
//        _cancelBtn = [[MDHitTestExpandView alloc] initWithFrame:CGRectMake(15, 20 + _edgeMargin, cancelImage.size.width, cancelImage.size.height)];
//        _cancelBtn.minHitTestWidth = 44;
//        _cancelBtn.minHitTestHeight = 44;
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_cancelBtn.bounds];
//        [imageView setImage:cancelImage];
//        [_cancelBtn addSubview:imageView];
//        
//        [_cancelBtn addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _cancelBtn;
//}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(15, 20 + _edgeMargin, 40, 40);
        [_cancelButton setTitle:@"返回" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (MDNewMediaEditorBottomView *)buttonView {
    if (!_buttonView) {
        NSArray<NSString *> *titles = @[kBtnTitleForFilter, kBtnTitleForMusic, kBtnTitleForSticker, kBtnTitleForText, kBtnTitleForPainter, kBtnTitleForthumbSelect, kBtnTitleForSpeedVary, kBtnTitleForSpecialEffect, kBtnTitleForBeauty];
        NSArray<NSString *> *imageNames = @[kImageNameForFilter, kImageNameForMusic, kImageNameForSticker, kImageNameForText, kImageNameForPainter, kImageNameForthumbSelect, kImageNameForSpeedVary, kImageNameForSpecialEffect, kImageNameForBeauty];
        
        _buttonView = [[MDNewMediaEditorBottomView alloc] initWithFrame:CGRectZero titles:titles imageNames:imageNames];
        _buttonView.translatesAutoresizingMaskIntoConstraints = NO;
        _buttonView.delegate = self;
    }
    return _buttonView;
}

- (UIButton *)stickerDeleteBtn
{
    if (!_stickerDeleteBtn) {
        UIImage *img = [UIImage imageNamed:@"sticker_delete_btn_2"];
        _stickerDeleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        _stickerDeleteBtn.center = CGPointMake(self.width * 0.5f, self.height - 15 -img.size.height *0.5f - _edgeMargin);
        [_stickerDeleteBtn setImage:img forState:UIControlStateNormal];
        _stickerDeleteBtn.alpha = .0f;
    }
    return _stickerDeleteBtn;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.textColor = UIColor.whiteColor;
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.text = @"00:00:00";
    }
    return _timeLabel;
}

#pragma mark - UI helper

//上下icon下方遮罩
- (UIView *)coverViewWithFrame:(CGRect)frame startAlpha:(CGFloat)alpha toBottom:(BOOL)toBottom
{
    UIView *cover = [[UIView alloc] initWithFrame:frame];
    
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    UIColor *color = RGBACOLOR(0, 0, 0, 0);
    maskLayer.colors = @[(__bridge id)RGBACOLOR(0, 0, 0, alpha).CGColor, (__bridge id)color.CGColor];
    if (toBottom) {
        maskLayer.startPoint = CGPointMake(0, 0);
        maskLayer.endPoint = CGPointMake(0, 1);
    } else {
        maskLayer.startPoint = CGPointMake(0, 1);
        maskLayer.endPoint = CGPointMake(0, 0);
    }
    maskLayer.frame = cover.bounds;
    
    [cover.layer addSublayer:maskLayer];
    return cover;
}

- (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)text image:(NSString *)imageName
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    UIImage *image = [UIImage imageNamed:imageName];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:11];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    
    CGFloat space = 5;
    CGFloat titleW = [text sizeWithAttributes:@{NSFontAttributeName:btn.titleLabel.font}].width;
    CGFloat titleH = [text sizeWithAttributes:@{NSFontAttributeName:btn.titleLabel.font}].height;
    CGFloat imageW = CGRectGetWidth(btn.imageView.bounds);//imageView的宽度
    CGFloat imageH = CGRectGetHeight(btn.imageView.bounds);//imageView的高度
    
    [btn setTitleEdgeInsets:UIEdgeInsetsMake((imageH +space),-imageW, .0f, .0f)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-titleH, 0, .0f, -titleW)];
    
    return btn;
}

- (UIImage *)renderOverlaySnapshot:(UIView *)view needWatermark:(BOOL)needWaterMark
{
    UIGraphicsBeginImageContextWithOptions(view.size, NO, 2.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGSize size = view.size;
    
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    
    //加水印
    if (needWaterMark) {
        NSString *desc = [MDRecordContext recordSDKUIVersion];
        UIFont *font = [UIFont boldSystemFontOfSize:11];
        
        UIImage *img = [UIImage imageNamed:@"moment_waterMark"];
        
        CGSize textSize = [desc boundingRectWithSize:CGSizeMake(size.width, 20)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{
                                                       NSFontAttributeName: font,
                                                       }
                                             context:nil].size;
        
        CGFloat totalWidth = img.size.width +textSize.width +20;
        
        CGRect rect = CGRectMake(size.width -totalWidth -12, 55 *size.height /667, totalWidth, 20);
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10] addClip];
        CGContextSetFillColorWithColor(context,[UIColor colorWithWhite:1 alpha:0.2].CGColor);
        CGContextFillRect(context, rect);
        
        [img drawAtPoint:CGPointMake(rect.origin.x +8, rect.origin.y +(20 -img.size.height) *0.5f)];
        [desc drawAtPoint:CGPointMake(rect.origin.x +img.size.width + 12, rect.origin.y +(20 -textSize.height) *0.5f) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGBACOLOR(0, 0, 0, 0.4), NSForegroundColorAttributeName, font,NSFontAttributeName, nil]];
    }
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [[UIColor clearColor] setFill];
    UIRectFill(view.bounds);
    
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - MDNewMediaEditorBottomViewDelegate methods

- (void)buttonClicked:(MDNewMediaEditorBottomView *)view title:(NSString *)title {
    if ([title isEqualToString:kBtnTitleForFilter]) {
        [self filterButtonTapped];
    } else if ([title isEqualToString:kBtnTitleForSticker]) {
        [self stickerEditButtonTapped];
    } else if ([title isEqualToString:kBtnTitleForText]) {
        [self textButtonTapped];
    } else if ([title isEqualToString:kBtnTitleForMusic]) {
        [self audioMixButtonTapped];
    } else if ([title isEqualToString:kBtnTitleForthumbSelect]) {
        [self thumbSelectButtonTapped];
    } else if ([title isEqualToString:kBtnTitleForSpeedVary]) {
        [self speedVaryButtonTapped];
    } else if ([title isEqualToString:kBtnTitleForPainter]) {
        [self painterEditButtonTapped];
    } else if ([title isEqualToString:kBtnTitleForSpecialEffect]) {
        [self specialEffectsBtnTapped];
    } else if ([title isEqualToString:kBtnTitleForBeauty]) {
        [self thinBodyBtnTapped];
    }
}

@end
