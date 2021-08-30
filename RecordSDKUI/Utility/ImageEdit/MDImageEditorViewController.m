//
//  MDImageEditorViewController.m
//  MDChat
//
//  Created by 符吉胜 on 2017/6/12.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDImageEditorViewController.h"
#import "MDHitTestExpandView.h"
#import "UIImage+MDUtility.h"
#import "MDNavigationTransitionExtra.h"
#import "MDPhotoLibraryProvider.h"
//滤镜相关
#import "MDRecordFilterDrawerController.h"
#import "MDRecordFilterModel.h"
//贴纸相关
#import "BBMediaStickerAdjustmentView.h"
#import "MDMomentExpressionViewController.h"
#import "MDMomentExpressionCellModel.h"

//文字编辑相关
#import "MDMomentTextAdjustmentView.h"
#import "MDMomentTextOverlayEditorView.h"
//涂鸦相关
#import "BBMediaGraffitiEditorViewController.h"

#import "MDBeautySettings.h"
#import "MUAlertBarDispatcher.h"
#import "MUAlertBar.h"
#import "MUAlertBarModel.h"
#import "MDRecordContext.h"
#import "MDRecordMacro.h"
@import RecordSDK;
@import VideoToolbox;

#import "MDRecordFilterModelLoader.h"
#import "Toast/Toast.h"

#import "MDRecordCropImageViewController.h"
#import "MDRecordVideoSettingManager.h"

#import <MomoCV/MomoCV.h>
#import <FaceDecorationKitMomoCV/FaceDecorationKitMomoCV.h>
#import <MLMediaFoundation/MLMediaFoundation.h>

static const CGFloat kViewLeftRightMargin   = 30;
static const CGFloat kBottomToolButtonWidth = 45;
static const CGFloat kBottomBelowMargin     = 9;
static const NSInteger kMaxStickerCount     = 20;

#define isPhoneX ({\
BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
    if (!UIEdgeInsetsEqualToEdgeInsets([UIApplication sharedApplication].delegate.window.safeAreaInsets, UIEdgeInsetsZero)) {\
    isPhoneX = YES;\
    }\
}\
isPhoneX;\
})

#define kBottomButtonMargin (MDScreenWidth -kViewLeftRightMargin *2 -kBottomToolButtonWidth *6) / 5

#define kEdgeFor720p (isPhoneX ? ((MDScreenHeight - (MDScreenWidth * (1280.0/720.0))) / 2.0) : 0)

@interface MDImageEditorViewController ()
<
BBMediaStickerAdjustmentViewDelegate,
MDMomentTextAdjustmentViewDelegate,
MDRecordFilterDrawerControllerDelegate,
MDNavigationBarAppearanceDelegate,
MDPopGestureRecognizerDelegate,
MDRecordCropImageViewControllerDelegate
>

@property (nonatomic,strong) MDHitTestExpandView                *cancelBtn;
@property (nonatomic,strong) UIButton                           *doneBtn;
@property (nonatomic,strong) UIView                             *contentView;
@property (nonatomic,strong) UIImageView                        *imageView;
@property (nonatomic,strong) UIImage                            *originImage;
@property (nonatomic,strong) MDHitTestExpandView                *customContentView;
@property (nonatomic,  copy) MDImageEditorCompleteBlock         completeBlock;
@property (nonatomic,strong) UIView                             *stickerMask;
//底部工具按钮
@property (nonatomic,strong) UIButton                           *filterSwitchButton;
@property (nonatomic,strong) UIButton                           *thinBodyButton;
@property (nonatomic,strong) UIButton                           *stickerButton;
@property (nonatomic,strong) UIButton                           *textButton;
@property (nonatomic,strong) UIButton                           *painterButton;
@property (nonatomic,strong) UIButton                           *cropButton;

//滤镜相关

@property (nonatomic,strong) MDRecordFilterDrawerController     *filterDrawerController;
@property (nonatomic,  copy) NSArray<MDRecordFilter *>                *filters;
@property (nonatomic,  copy) NSArray<MDRecordFilterModel *>     *filterModels;
@property (nonatomic,strong) NSMutableDictionary                *beautySettingDict;
@property (nonatomic,strong) NSMutableDictionary                *realBeautySettingDict;
@property (nonatomic,assign) NSInteger                          currentFilterIndex;

//贴纸相关
@property (nonatomic,strong) NSMutableArray                     *stickers;
@property (nonatomic,strong) BBMediaStickerAdjustmentView       *stickerAdjustView;
@property (nonatomic,strong) MDMomentExpressionViewController   *stickerChooseView;
@property (nonatomic,strong) UIButton                           *stickerDeleteBtn;
@property (nonatomic,assign) BOOL                               needDeleteSticker;
//涂鸦相关
@property (nonatomic,strong) UIImageView                        *graffitiCanvasView;
//文字编辑相关
@property (nonatomic,strong) MDMomentTextAdjustmentView         *textAdjustView;
@property (nonatomic,strong) MDMomentTextOverlayEditorView      *textEditView;
@property (nonatomic,strong) NSMutableArray                     *textStickers;
@property (nonatomic,strong) MDMomentTextSticker                *handlingSticker;


@property (nonatomic, strong) UIImage                           *graffitiCanvasViewOriginImage;

@property (nonatomic, assign) CVPixelBufferRef                  renderedPixelBuffer;

@property (nonatomic, assign) CGFloat                           edgeMargin;

@property (nonatomic, strong) UIButton                          *qualityBlockBtn;

//@property (nonatomic, strong) MDImageEditorContext *context;
//@property (nonatomic, strong) MDImageRenderPipline *renderPipline;
//@property (nonatomic, strong) MDPhotoRenderFilter *filter;
//@property (nonatomic, strong) MDPhotoDetectorPipline *detector;

@property (nonatomic, strong) MDImageEditorAdapter *adapter;
@property (nonatomic, strong) UIView<MLPixelBufferDisplay> *previewView;

@property (nonatomic, strong) UIImage *cropImage;

// AR宠物需要再编辑页面增添气泡提示
//@property (nonatomic, strong) MMArpetResult             *qualityResult;

@property (nonatomic, copy) NSString *makeupType;
@property (nonatomic, copy) NSString *microSurgeryType;

@end

@implementation MDImageEditorViewController

- (MDImageEditorAdapter *)adapter {
    if (!_adapter) {
        _adapter = [[MDImageEditorAdapter alloc] initWithToken:@""];
    }
    return _adapter;
}

#pragma mark - life cycle
- (void)dealloc
{
    [self.adapter stopProcess];
    
    if (self.renderedPixelBuffer) {
        CVPixelBufferRelease(self.renderedPixelBuffer);
        self.renderedPixelBuffer = NULL;
    }
#if DEBUG
    NSLog(@"MDImageEditorViewController dealloc");
#endif
}

- (instancetype)initWithImage:(UIImage *)originImage completeBlock:(MDImageEditorCompleteBlock)completeBlock
{
    if (self = [self init]) {
        _originImage = originImage;
        _completeBlock = completeBlock;
        
        self.renderedPixelBuffer = NULL;
        
        __weak typeof(self) weakself = self;
        [self.adapter loadImage:originImage completionHander:^(CVPixelBufferRef renderedPixelBuffer, NSError * error) {
            __strong typeof(self) strongself = weakself;
            
            // save to renderredPixelBuffer
            if (strongself.renderedPixelBuffer) {
                CVPixelBufferRelease(strongself.renderedPixelBuffer);
                strongself.renderedPixelBuffer = NULL;
            }
            
            strongself.renderedPixelBuffer = renderedPixelBuffer;
            CVPixelBufferRetain(strongself.renderedPixelBuffer);
            
            // show image
            [strongself.previewView presentPixelBuffer:renderedPixelBuffer];

        }];
        
        if (!CGRectEqualToRect(MDRecordVideoSettingManager.cropRegion, CGRectZero)) {
            self.adapter.cropRegion = MDRecordVideoSettingManager.cropRegion;
        }
        
        NSAssert(completeBlock, @"completeBlock can not be nil");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    if (!_useFastInit) {
        [self doInitWork];
    }
    
}

- (void)doInitWork
{
    MDRecordFilterModelLoader *loader = [[MDRecordFilterModelLoader alloc] init];
    _filterModels = [loader getFilterModels];
    _filters = [loader filtersArray];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.adapter startProcess];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_useFastInit) {
        _useFastInit = NO;
        [self doInitWork];
    }
    
    //设置美颜效果
    [self setBeautySetting];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.adapter stopProcess];
}

#pragma mark - config UI
- (void)configUI
{
    CGFloat whRatio = self.originImage.size.width / self.originImage.size.height;
    _edgeMargin = (whRatio > 0.5 && whRatio < 0.6) ? kEdgeFor720p : (isPhoneX ? HOME_INDICATOR_HEIGHT : 0);
    
    [self.contentView addSubview:self.previewView];
    [self.view addSubview:self.contentView];
    [self addMask];
    
    self.customContentView = [[MDHitTestExpandView alloc] initWithFrame:self.contentView.frame];
    self.customContentView.minHitTestWidth = MDScreenWidth;
    self.customContentView.minHitTestHeight = MDScreenHeight;
    
    //贴纸，文字，涂鸦
    [self.customContentView addSubview:self.stickerAdjustView];
    [self.customContentView addSubview:self.graffitiCanvasView];
    [self.customContentView addSubview:self.textAdjustView];
    [self.view addSubview:self.customContentView];
    
    
    [self.view addSubview:self.textEditView];
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.doneBtn];
    
    [self.view addSubview:self.filterSwitchButton];
    [self.view addSubview:self.thinBodyButton];
    [self.view addSubview:self.stickerButton];
    [self.view addSubview:self.textButton];
    [self.view addSubview:self.painterButton];
    [self.view addSubview:self.cropButton];
    [self.view addSubview:self.stickerDeleteBtn];
    self.stickerDeleteBtn.alpha = 0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.customContentView addGestureRecognizer:tap];
}

- (void)reloadImage:(UIImage *)image {
    
    _cropImage = image;
    
    CGSize size = image.size;
    self.contentView.frame = [self renderFrameForSize:size];
    self.previewView.frame = self.contentView.bounds;
    
    self.customContentView.frame = self.contentView.frame;
    self.stickerAdjustView.frame = self.customContentView.bounds;
    self.graffitiCanvasView.frame = self.customContentView.bounds;
    self.textAdjustView.frame = self.customContentView.bounds;
    
    [self.adapter reloadImage:image];
}

- (void)tapAction:(UITapGestureRecognizer*)tapGuesture {
    
    if (_filterDrawerController.isShowed) {
        [_filterDrawerController hideAnimationWithCompleteBlock:nil];
    }
}

- (void)addMask
{
    UIView *topCover = [self coverViewWithFrame:CGRectMake(0, 0, MDScreenWidth, 80) startAlpha:0.25f toBottom:YES];
    [self.view addSubview:topCover];
    
    UIView *bottomCover = [self coverViewWithFrame:CGRectMake(0, MDScreenHeight -115, MDScreenWidth, 115) startAlpha:0.35f toBottom:NO];
    [self.view addSubview:bottomCover];
}

//上下icon下方遮罩
- (UIView *)coverViewWithFrame:(CGRect)frame startAlpha:(CGFloat)alpha toBottom:(BOOL)toBottom
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

#pragma mark - getter & setter
- (MDHitTestExpandView *) cancelBtn
{
    if (!_cancelBtn) {
        
        UIImage *cancelImage = [UIImage imageNamed:@"btn_moment_record_close"];
        _cancelBtn = [[MDHitTestExpandView alloc] initWithFrame:CGRectMake(13, 16 + _edgeMargin, cancelImage.size.width, cancelImage.size.height)];
        _cancelBtn.minHitTestWidth = 44;
        _cancelBtn.minHitTestHeight = 44;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_cancelBtn.bounds];
        [imageView setImage:cancelImage];
        [_cancelBtn addSubview:imageView];
        
        [_cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelBtn;
}

- (UIButton *)doneBtn
{
    if (!_doneBtn) {
        UIFont *titleFont = [UIFont boldSystemFontOfSize:14.0f];
        NSString *title = @"完成";
        if ([self.doneButtonTitle isNotEmpty]) {
            title = self.doneButtonTitle;
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
        [doneButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width, 0, image.size.width)];
        [doneButton setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width + 5, 0, -titleSize.width)];
        
        doneButton.layer.cornerRadius = doneButton.height / 2.0f;
        doneButton.layer.masksToBounds = YES;
        [doneButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchDown];
        
        _doneBtn = doneButton;
    }
    return _doneBtn;
}

- (UIButton *)qualityBlockBtn {
    if (!_qualityBlockBtn) {
        UIFont *titleFont = [UIFont boldSystemFontOfSize:14.0f];
        NSString *title = @"重新拍摄";
        
        UIImage *image = [UIImage imageNamed:@"icon_moment_edit_check"];
        UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20.0f + _edgeMargin, 100, 40)];
        doneButton.backgroundColor = RGBCOLOR(0, 192, 255);
        doneButton.right = MDScreenWidth - 12.0f;
        
        [doneButton setImage:image forState:UIControlStateNormal];
        [doneButton setImage:image forState:UIControlStateHighlighted];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton setTitle:title forState:UIControlStateNormal];
        doneButton.titleLabel.font = titleFont;
        
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName : titleFont}];
        [doneButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width, 0, image.size.width)];
        [doneButton setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width + 5, 0, -titleSize.width)];
        
        doneButton.layer.cornerRadius = doneButton.height / 2.0f;
        doneButton.layer.masksToBounds = YES;
        [doneButton addTarget:self action:@selector(qualityBlockEvent:) forControlEvents:UIControlEventTouchDown];
        
        _qualityBlockBtn = doneButton;
        
        [self.view addSubview:_qualityBlockBtn];
    }
    return _qualityBlockBtn;
}

- (UIView *)contentView
{
    if (!_contentView) {
        CGSize size = self.originImage.size;
        _contentView = [[UIView alloc] initWithFrame:[self renderFrameForSize:size]];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.center = self.view.center;
    }
    return _contentView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:self.originImage];
        _imageView.frame = self.contentView.bounds;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    
    return _imageView;
}

- (UIView<MLPixelBufferDisplay> *)previewView
{
    if (!_previewView) {
        _previewView = [[MLCVPixelBufferView alloc] initWithFrame:self.contentView.bounds];
        _previewView.scalingMode = MLPixelBufferDisplayScalingModeResizeAspectFit;
    }
    return _previewView;
}


- (BBMediaStickerAdjustmentView *)stickerAdjustView
{
    if (!_stickerAdjustView) {
        _stickerAdjustView = [[BBMediaStickerAdjustmentView alloc] initWithFrame:self.customContentView.bounds];
        _stickerAdjustView.delegate = self;
    }
    
    return _stickerAdjustView;
}

- (MDMomentTextAdjustmentView *)textAdjustView
{
    if (!_textAdjustView) {
        _textAdjustView = [[MDMomentTextAdjustmentView alloc] initWithFrame:self.customContentView.bounds];
        _textAdjustView.delegate = self;
    }
    
    return _textAdjustView;
}

- (UIImageView *)graffitiCanvasView
{
    if (!_graffitiCanvasView) {
        _graffitiCanvasView = [[UIImageView alloc] initWithFrame:self.customContentView.bounds];
        UIImage *image = [UIImage imageWithColor:[UIColor clearColor] finalSize:_graffitiCanvasView.size];
        _graffitiCanvasView.image = image;
        _graffitiCanvasView.alpha = 0;
        self.graffitiCanvasViewOriginImage = image;
    }
    
    return _graffitiCanvasView;
}

- (UIButton *)filterSwitchButton
{
    if(!_filterSwitchButton) {
        
        _filterSwitchButton = [self buttonWithFrame:CGRectMake(kViewLeftRightMargin, MDScreenHeight - kBottomBelowMargin -kBottomToolButtonWidth - _edgeMargin, kBottomToolButtonWidth, kBottomToolButtonWidth) title:@"滤镜" image:@"btn_moment_filter_switch"];
        
        [_filterSwitchButton addTarget:self action:@selector(filterSwitchButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _filterSwitchButton;
}

- (UIButton *)thinBodyButton
{
    if(!_thinBodyButton) {

        _thinBodyButton = [self buttonWithFrame:CGRectMake(self.filterSwitchButton.right + kBottomButtonMargin, MDScreenHeight - kBottomBelowMargin -kBottomToolButtonWidth - _edgeMargin, kBottomToolButtonWidth, kBottomToolButtonWidth) title:@"瘦身" image:@"beauty"];

        [_thinBodyButton addTarget:self action:@selector(thinBodyButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }

    return _thinBodyButton;
}

- (UIButton *)stickerButton
{
    if (!_stickerButton) {
        _stickerButton = [self buttonWithFrame:CGRectMake(self.thinBodyButton.right + kBottomButtonMargin, MDScreenHeight - kBottomBelowMargin -kBottomToolButtonWidth - _edgeMargin, kBottomToolButtonWidth, kBottomToolButtonWidth) title:@"贴纸" image:@"btn_moment_edit_sticker"];

        [_stickerButton addTarget:self action:@selector(stickerEditButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }

    return _stickerButton;
}

- (UIButton *)textButton
{
    if (!_textButton) {
        _textButton = [self buttonWithFrame:CGRectMake(self.stickerButton.right + kBottomButtonMargin, MDScreenHeight - kBottomBelowMargin -kBottomToolButtonWidth - _edgeMargin, kBottomToolButtonWidth, kBottomToolButtonWidth) title:@"文字" image:@"btn_moment_edit_text"];
        
        [_textButton addTarget:self action:@selector(textButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _textButton;
}

- (UIButton *)painterButton
{
    if (!_painterButton) {
        _painterButton = [self buttonWithFrame:CGRectMake(self.textButton.right + kBottomButtonMargin, MDScreenHeight - kBottomBelowMargin -kBottomToolButtonWidth - _edgeMargin, kBottomToolButtonWidth, kBottomToolButtonWidth) title:@"涂鸦" image:@"btn_moment_edit_painter"];
        
        [_painterButton addTarget:self action:@selector(painterEditButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _painterButton;
}

- (UIButton *)cropButton {
    if (!_cropButton) {
        _cropButton = [self buttonWithFrame:CGRectMake(self.painterButton.right + kBottomBelowMargin, MDScreenHeight - kBottomBelowMargin - kBottomToolButtonWidth - _edgeMargin, kBottomToolButtonWidth, kBottomToolButtonWidth) title:@"裁剪" image:@"btn_moment_edit_cut_image"];
        [_cropButton addTarget:self action:@selector(cropButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cropButton;
}

- (UIButton *)stickerDeleteBtn
{
    if (!_stickerDeleteBtn) {
        UIImage *img = [UIImage imageNamed:@"sticker_delete_btn_2"];
        _stickerDeleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        _stickerDeleteBtn.center = CGPointMake(self.view.width * 0.5f, self.view.height - 15 -img.size.height *0.5f - _edgeMargin);
        [_stickerDeleteBtn setImage:img forState:UIControlStateNormal];
    }
    
    return _stickerDeleteBtn;
}

- (MDMomentExpressionViewController *)stickerChooseView
{
    if (!_stickerChooseView) {
        
        __weak __typeof(self) weakSelf = self;
        _stickerChooseView = [[MDMomentExpressionViewController alloc] initWithSelectBlock:^(NSDictionary *urlDict) {
            [weakSelf handleStickerChoose:urlDict];
        }];
        
    }
    return _stickerChooseView;
}

- (MDMomentTextOverlayEditorView *)textEditView
{
    if (!_textEditView) {
        _textEditView = [[MDMomentTextOverlayEditorView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)];
        
        __weak __typeof(self) weakSelf = self;
        
        [_textEditView setBeginEditingHandler:^{
            weakSelf.stickerAdjustView.userInteractionEnabled = NO;
        }];
        
        [_textEditView setEndEditingHandler:^(UILabel *label, NSInteger colorIndex) {
            weakSelf.stickerAdjustView.userInteractionEnabled = YES;
            weakSelf.textEditView.text = @"";
            [weakSelf updateViewElementsWithAlpha:1.0f animated:YES];
            
            if (weakSelf.textStickers.count < kMaxStickerCount) {
                
                if ([label.text isNotEmpty]) {
                    
                    MDMomentTextSticker *sticker = [[MDMomentTextSticker alloc] initWithLabel:label];
                    sticker.colorIndex = colorIndex;
                    if (weakSelf.handlingSticker) {
                        [weakSelf.textAdjustView addSticker:sticker center:weakSelf.handlingSticker.center transform:weakSelf.handlingSticker.transform];
                        weakSelf.handlingSticker = nil;
                    } else {
                        [weakSelf.textAdjustView addSticker:sticker center:CGPointMake(weakSelf.textAdjustView.width *0.5f, weakSelf.textAdjustView.height *0.3f) transform:CGAffineTransformIdentity];
                    }
                    [weakSelf.textStickers addObjectSafe:sticker];
                }
            }else {
                [[UIApplication sharedApplication].delegate.window makeToast:@"最多使用20个贴纸" duration:1.5f position:CSToastPositionCenter];
            }
        }];
        _textEditView.placeholder = @"描述这张图片";
    }
    
    return _textEditView;
}

- (MDRecordFilterDrawerController *)filterDrawerController
{
    if (!_filterDrawerController) {
        NSArray *tagArray = @[kDrawerControllerFilterKey,
                              kDrawerControllerMakeupKey,
                              kDrawerControllerChangeFacialKey,
                              kDrawerControllerMicroKey,
                              kDrawerControllerMakeUpKey,
                              kDrawerControllerLongLegKey,
                              kDrawerControllerThinBodyKey,
                              kDrawerControllerMakeupStyleKey
                              ];
        _filterDrawerController = [[MDRecordFilterDrawerController alloc] initWithTagArray:tagArray];
        _filterDrawerController.delegate = self;
        
        [self addChildViewController:_filterDrawerController];
        [self.view addSubview:_filterDrawerController.view];
        
        [_filterDrawerController setMakeUpIndex:0];
        [_filterDrawerController setThinFaceIndex:0];
        [_filterDrawerController setThinBodyIndex:0];
        [_filterDrawerController setLongLegIndex:0];
        
        [_filterDrawerController setFilterModels:_filterModels];
        
        [_filterDrawerController setFilterIndex:0];
        [_filterDrawerController setMakeupBeautyIndex:0];
        [_filterDrawerController setMakeupStyleIndex:0];
        [_filterDrawerController setMicroSurgeryIndex:0];
        
    }
    return _filterDrawerController;
}

- (NSMutableDictionary *)beautySettingDict
{
    if (!_beautySettingDict) {
        _beautySettingDict = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return _beautySettingDict;
}

- (NSMutableDictionary *)realBeautySettingDict
{
    if (!_realBeautySettingDict) {
        _realBeautySettingDict = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return _realBeautySettingDict;
}


#pragma mark - 交互事件
- (void)cancel
{
    if (self.cancelBlock) {
        self.cancelBlock([self isEditValid]);
    }
}

- (void)doneButtonTapped
{

    CVPixelBufferRef renderedPixelBuffer = self.renderedPixelBuffer;
    
    if (renderedPixelBuffer == NULL) {
        return;
    }
    
    CVPixelBufferRetain(renderedPixelBuffer);
    UIImage *renderedImage = [UIImage imageFromPixelBuffer:renderedPixelBuffer context:nil];
    UIImage *customOverlayImage = [self.customContentView md_snapshot];
    
    UIImage *outputImage = [MDImageBlender imageByBlendImage:renderedImage withOverlayImage:customOverlayImage];
    CVPixelBufferRelease(renderedPixelBuffer);
    
    BOOL isEdited = [self isEditValid];
    
    if (isEdited) {
        //打点
        if (self.imageUploadParamModel) {
            self.imageUploadParamModel.paramsOfEditing = [[MDImageUploadParamsOfEditing alloc] init];
            
            MDRecordFilterModel *filterModel = [self.filterModels objectAtIndex:self.currentFilterIndex];
            self.imageUploadParamModel.paramsOfEditing.filterID = filterModel.identifier;
            
            self.imageUploadParamModel.paramsOfEditing.bigEyeLevel = [self.beautySettingDict integerForKey:MDBeautySettingsSkinSmoothingAmountKey defaultValue:0];
            self.imageUploadParamModel.paramsOfEditing.beautyFaceLevel = [self.beautySettingDict integerForKey:MDBeautySettingsSkinSmoothingAmountKey defaultValue:0];
            self.imageUploadParamModel.paramsOfEditing.thinBodyLevel = [self.beautySettingDict integerForKey:MDBeautySettingsThinBodyAmountKey defaultValue:0];
            self.imageUploadParamModel.paramsOfEditing.longLegLevel = [self.beautySettingDict integerForKey:MDBeautySettingsLongLegAmountKey defaultValue:0];
            
            self.imageUploadParamModel.paramsOfEditing.stickerIds = [[NSMutableArray alloc] init];
            for (MDRecordBaseSticker *sticker in self.stickers) {
                if ([sticker.stickerId isNotEmpty]) {
                    [self.imageUploadParamModel.paramsOfEditing.stickerIds addObjectSafe:sticker.stickerId];
                }
            }
            
            self.imageUploadParamModel.paramsOfEditing.decorateTexts = [NSMutableArray array];
            for (MDMomentTextSticker *sticker in self.textStickers) {
                [self.imageUploadParamModel.paramsOfEditing.decorateTexts addObjectSafe:sticker.text];
            }
            
            self.imageUploadParamModel.paramsOfEditing.hasGraffiti = BBUIImageContainsVisiblePixelData(self.graffitiCanvasView.image);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [PHPhotoLibrary savePhoto:outputImage toAlbumWithName:@"VideoSDK" completion:NULL];
        });
        
    }
    
    self.completeBlock ? self.completeBlock(outputImage, isEdited) : nil;
}

- (void)qualityBlockEvent:(UIButton *)sender {
    if (self.qualityCancelBlock) {
        self.qualityCancelBlock();
    }
}

- (void)stickerEditButtonTapped
{
    if (!_stickers) {
        self.stickers = [[NSMutableArray alloc] initWithCapacity:kMaxStickerCount];
    }
    
    //    [_textEditView hide];
    
    [self updateViewElementsWithAlpha:0 animated:YES];
    
    UIImage *previewImage = [self.previewView md_snapshot];
    UIImage *customOverlayImage = [self.customContentView md_snapshot];
    
    UIImage *outputImage = [MDImageBlender imageByBlendImage:previewImage withOverlayImage:customOverlayImage];
    [self.stickerChooseView setBackGroundViewWithImage:outputImage];

    [self.stickerChooseView show];
}

- (void)filterSwitchButtonTapped
{

    [self.filterDrawerController setDefaultSelectIndex:0];
    [self.filterDrawerController showAnimation];
}

- (void)thinBodyButtonTapped
{
    [self.filterDrawerController setDefaultSelectIndex:3];
    [self.filterDrawerController showAnimation];
}

- (void)textButtonTapped
{
    if (!_textStickers) {
        self.textStickers = [NSMutableArray array];
    }
    
    [self showTextEditView:!_textEditView.visible];
}

- (void)painterEditButtonTapped
{
    _graffitiCanvasView.alpha = 0;
    BBMediaGraffitiEditorViewController *viewController = [[BBMediaGraffitiEditorViewController alloc] init];
    viewController.initialGraffitiCanvasImage = self.graffitiCanvasView.image;
    //不需要马赛克
    viewController.initialMosaicCanvasImage = nil;
    //这个frame必须为整数，否则涂鸦不正常
    viewController.renderFrame = CGRectIntegral(self.contentView.frame);
    [self updateViewElementsWithAlpha:0 animated:NO];
    
    [self showPainterViewController:viewController];
}

- (void)cropButtonTapped {
    MDRecordCropImageViewController *vc = [[MDRecordCropImageViewController alloc] initWithImage:self.cropImage ?: self.originImage];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showPainterViewController:(BBMediaGraffitiEditorViewController *)vc
{
    __weak __typeof(self) weakSelf = self;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [vc setCompletionHandler:^{
        
        weakSelf.graffitiCanvasView.alpha = 1;
        [weakSelf updateViewElementsWithAlpha:1 animated:YES];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [vc setCanvasImageUpdatedHandler:^(UIImage *canvasImage, UIImage *mosaicCanvasImage) {
        weakSelf.graffitiCanvasView.image = canvasImage;
    }];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (UIImageView *)redPointViewLeft:(CGFloat)left withTag:(NSUInteger)tag
{
    UIImageView *redPointView = [[UIImageView alloc] initWithFrame:CGRectMake(left, 0, 8, 8)];
    redPointView.tag = tag;
    UIImage *img = [UIImage imageWithColor:[UIColor redColor] finalSize:CGSizeMake(8, 8)];
    img = [img clipCircle];
    redPointView.image = img;
    
    return redPointView;
}


#pragma mark - MDRecordFilterDrawerControllerDelegate

- (void)didSelectedMakeUpModel:(NSString *)modelType{
    if ([modelType isEqualToString: @"无"]) {
        [self.adapter removeAllMakeupEffect];
        return;
    }
    self.makeupType = [self getTypeWithName:modelType];
    [self.adapter removeAllMakeupEffect];
    NSString *rescousePath = [self getPathWithName:modelType];
    [self.adapter addMakeupEffect:rescousePath];
    [self.adapter setMakeupEffectIntensity:1 makeupType:self.makeupType];
}

- (NSString *)getTypeWithName:(NSString*)name{
    if ([name hasPrefix:@"腮红"]) {
        return  @"makeup_blush";
    }
    if ([name hasPrefix:@"修容"]) {
        return  @"makeup_facial";
    }
    if ([name hasPrefix:@"眉毛"]) {
        return  @"makeup_eyebrow";
    }
    if ([name hasPrefix:@"眼妆"]) {
        return  @"makeup_eyes";
    }
    if ([name hasPrefix:@"口红"]) {
        return  @"makeup_lips";
    }
    if ([name hasPrefix:@"美瞳"]){
        return @"makeup_pupil";
    }
    return @"makeup_all";
}

- (NSString *)getPathWithName:(NSString *)name{
    NSString *rootPath = [[NSBundle mainBundle] pathForResource:@"makeup" ofType:@"bundle"];
    NSURL *path = [[NSBundle bundleForClass:self.class] URLForResource:@"makeup" withExtension:@"bundle"];
    NSURL *jsonPath = [[NSBundle bundleWithURL:path] URLForResource:@"makeup_list" withExtension:@"geojson"];
    NSArray *items = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:jsonPath] options:0 error:nil];
    NSDictionary *dict = @{
        @"甜拽":@"makeup_style/abg",
        @"白雪":@"makeup_style/baixue",
        @"芭比":@"makeup_style/babi",
        @"黑童话":@"makeup_style/heitonghua",
        @"裸装":@"makeup_style/luozhuang",
        @"韩式":@"makeup_style/hanshi",
        @"玉兔":@"makeup_style/yutu",
        @"闪闪":@"makeup_style/hanshi",
        @"秋日":@"makeup_style/qiuri",
        @"跨年装":@"makeup_style/kuanianzhuang",
        @"蜜桃":@"makeup_style/mitao",
        @"元气":@"makeup_style/yuanqi",
        @"混血":@"makeup_style/hunxue",
        @"神秘":@"makeup_style/shenmi",
    };
    if ([dict objectForKey:name]) {
        return [NSString stringWithFormat:@"%@/%@",rootPath,[dict objectForKey:name]];;
    }
    
    for (NSDictionary *item in items) {
        NSString *title = [item objectForKey:@"title"];
        if ([title isEqualToString:name]) {
            NSString *path = [item objectForKey:@"highlight"] ;
            if ([path isEqualToString:@"none"]) {
                path = @"";
            }
            return [NSString stringWithFormat:@"%@/%@",rootPath,path];
        }
    }
    return  @"";
}
- (void)didselectedMicroSurgeryModel:(NSString *)index{
    if (index) {
        self.microSurgeryType = index;
        [self.adapter adjustBeauty:1.0 forKey:index];
    }
    
}
- (void)didSetMicroSurgeryIntensity:(CGFloat)value{
    if (self.microSurgeryType) {
        [self.adapter adjustBeauty:value forKey:self.microSurgeryType];
    }
}

- (void)longTounchBtnClickEnd{
    [self.adapter setRenderStatus:YES];
}

- (void)longTounchBtnClickStart{
    [self.adapter setRenderStatus:NO];
}
- (void)didSetMakeUpLookIntensity:(CGFloat)value{
    [self.adapter setMakeupEffectIntensity:value makeupType:@"makeup_lut"];
}
- (void)didSetMakeUpBeautyIntensity:(CGFloat)value{
    if (self.makeupType) {
        [self.adapter setMakeupEffectIntensity:value makeupType:self.makeupType];
    }
}

// 滤镜
- (void)didSelectedFilterItem:(NSInteger)index
{
    self.currentFilterIndex = index;
    
    if (self.filters.count >= 2) {
        MDRecordFilter *filterA = [self.filters objectAtIndex:self.currentFilterIndex defaultValue:nil];
        [self.adapter configCurrentFilter:filterA];
    }

}

// 磨皮美白
- (void)didSelectedMakeUpItem:(NSInteger)index
{
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsSkinSmoothingAmountKey];
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsSkinWhitenAmountKey];
    
    CGFloat skinSmoothFactor = [self realValueWithIndex:index beautySettingTypeStr:MDBeautySettingsSkinSmoothingAmountKey];
    CGFloat skinWhitenFactor = [self realValueWithIndex:index beautySettingTypeStr:MDBeautySettingsSkinWhitenAmountKey];
    
    [self.adapter setSkinSmoothValue:skinSmoothFactor];
    [self.adapter setSkinWhitenValue:skinWhitenFactor];
}

// 大眼瘦脸
- (void)didSelectedFaceLiftItem:(NSInteger)index
{
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsEyesEnhancementAmountKey];
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsFaceThinningAmountKey];
    
    CGFloat bigEyeFactor = [self realValueWithIndex:index beautySettingTypeStr:MDBeautySettingsEyesEnhancementAmountKey];
    CGFloat thinFaceFactor = [self realValueWithIndex:index beautySettingTypeStr:MDBeautySettingsFaceThinningAmountKey];
    
    [self.adapter setBeautyBigEyeValue:bigEyeFactor];
    [self.adapter setBeautyThinFaceValue:thinFaceFactor];
}

- (void)didSetFilterIntensity:(CGFloat)value {
    MDRecordFilter *filterA = [self.filters objectAtIndex:self.currentFilterIndex defaultValue:nil];
    [filterA setLutIntensity:value];
}

// 瘦身
- (void)didSelectedThinBodyItem:(NSInteger)index {
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsThinBodyAmountKey];
    
    CGFloat thinBodyFactor = [self realValueWithIndex:index beautySettingTypeStr:MDBeautySettingsThinBodyAmountKey];
    [self.adapter setBeautyThinBodyValue:thinBodyFactor];
}
// 长腿
- (void)didSelectedLongLegItem:(NSInteger)index {
    [self.beautySettingDict setInteger:index forKey:MDBeautySettingsLongLegAmountKey];
    
    CGFloat longLegFactor = [self realValueWithIndex:index beautySettingTypeStr:MDBeautySettingsLongLegAmountKey];
    [self.adapter setBeautyLenghLegValue:longLegFactor];
}

- (void)didSetSkinWhitenValue:(CGFloat)value {
    [self.adapter setSkinWhitenValue:value];
}

- (void)didSetSmoothSkinValue:(CGFloat)value {
    [self.adapter setSkinSmoothValue:value];
}

- (void)didSetBigEyeValue:(CGFloat)value {
    [self.adapter setBeautyBigEyeValue:value];
}

- (void)didSetThinFaceValue:(CGFloat)value {
    [self.adapter setBeautyThinFaceValue:value];
}

- (void)updateBeautySetting {
    MDBeautySettings *beautySettings = [[MDBeautySettings alloc] initWithDictionary:self.realBeautySettingDict];
    FDKDecoration *decoration = [beautySettings makeDecoration];
    decoration.beautySettings.gradualSwitch = NO;
    [self.adapter updateDecoration:decoration];

}

- (void)setBeautySetting
{
    [self transferBeautySettingToRealBeautySetting];

    [self updateBeautySetting];
}

- (void)transferBeautySettingToRealBeautySetting
{
    [self.beautySettingDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        CGFloat realValue = [self realValueWithIndex:[obj integerValue] beautySettingTypeStr:key];
        [self.realBeautySettingDict setFloat:realValue forKey:key];
    }];
}

- (CGFloat)realValueWithIndex:(NSInteger)index beautySettingTypeStr:(NSString *)typeStr
{
    CGFloat result = 0.f;

    if ([typeStr isEqualToString:MDBeautySettingsSkinSmoothingAmountKey]) {          //磨皮

        NSArray *numberArray = [NSArray arrayWithObjects:@0,@15,@30,@45,@65,@100, nil];
        result = [[numberArray objectAtIndex:index defaultValue:0] floatValue];

    } else if ([typeStr isEqualToString:MDBeautySettingsSkinWhitenAmountKey]) {      //美白
        result = 0;

    } else if ([typeStr isEqualToString:MDBeautySettingsEyesEnhancementAmountKey]) { //大眼
        NSArray *numberArray = [NSArray arrayWithObjects:@0,@15,@30,@45,@60,@80, nil];
        result = [[numberArray objectAtIndex:index defaultValue:0] floatValue];

    } else if ([typeStr isEqualToString:MDBeautySettingsFaceThinningAmountKey]) {    //瘦脸

        NSArray *numberArray = [NSArray arrayWithObjects:@0,@15,@30,@45,@60,@80, nil];
        result = [[numberArray objectAtIndex:index defaultValue:0] floatValue];
    } else if ([typeStr isEqualToString:MDBeautySettingsThinBodyAmountKey]) {// 瘦身
        NSArray *numberArray = [NSArray arrayWithObjects:@0,@20,@40,@60,@80,@100, nil];
        result = [[numberArray objectAtIndex:index defaultValue:@(-1)] floatValue];
    } else if ([typeStr isEqualToString:MDBeautySettingsLongLegAmountKey]) {// 长腿
        NSArray *numberArray = [NSArray arrayWithObjects:@0,@30,@50,@60,@80,@100, nil];
        result = [[numberArray objectAtIndex:index defaultValue:@(-1)] floatValue];
    }

    return result / 100.0;
}

#pragma mark - BBMediaStickerAdjustmentViewDelegate

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerWillBeginChange:(MDRecordBaseSticker *)sticker frame:(CGRect)frame {
    [self updateBottomToolsWithAlpha:0 animate:YES];
    self.stickerDeleteBtn.alpha = 1.0f;
}

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidMove:(MDRecordBaseSticker *)sticker frame:(CGRect)frame touchPoint:(CGPoint)point {
    CGPoint touchPoint = [view convertPoint:point toView:self.stickerDeleteBtn];
    CGRect touchFrame = CGRectMake(touchPoint.x -35, touchPoint.y -35, 70, 70);
    self.needDeleteSticker = CGRectIntersectsRect(self.stickerDeleteBtn.bounds, touchFrame);
    
    //除了直接接近删除框之外, 如果超越边界, 删除
    CGPoint viewCenter = CGPointMake(frame.origin.x+frame.size.width/2, frame.origin.y+frame.size.height/2);
    if (viewCenter.x > view.width || viewCenter.x < 0) {
        self.needDeleteSticker = YES;
    }
    
    if (viewCenter.y > self.customContentView.height || viewCenter.y < 0) {
        self.needDeleteSticker = YES;
    }
    
    if (self.needDeleteSticker) {
        
        CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
        if (!CGAffineTransformEqualToTransform(scale, self.stickerDeleteBtn.transform)) {
            //需要删除状态使用红色
            UIImage *img = [UIImage imageNamed:@"sticker_delete_btn"];
            [self.stickerDeleteBtn setImage:img forState:UIControlStateNormal];
            self.stickerDeleteBtn.transform = scale;
        }
        
    } else {
        
        //非删除状态需要灰色
        UIImage *img = [UIImage imageNamed:@"sticker_delete_btn_2"];
        [self.stickerDeleteBtn setImage:img forState:UIControlStateNormal];
        self.stickerDeleteBtn.transform = CGAffineTransformIdentity;
    }
}

- (void)mediaStickerAdjustmentView:(BBMediaStickerAdjustmentView *)view stickerDidEndChange:(MDRecordBaseSticker *)sticker frame:(CGRect)frame {
    
    [UIView animateWithDuration:0.3f animations:^{
        self.stickerDeleteBtn.alpha = .0f;
        self.stickerDeleteBtn.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
        if (self.stickerDeleteBtn.alpha == 0.0f) {
            [self updateBottomToolsWithAlpha:1 animate:YES];
        }
    }];
    
    
    if (self.needDeleteSticker) {
        [view removeSticker:sticker];
        [self.stickers removeObject:sticker];
        self.needDeleteSticker = NO;
        return;
    }
    
    //    if (!CGRectContainsRect(self.stickerAdjustView.bounds, frame)) {
    //        [[MDContext sharedIndicate] showWarningInView:self.view withText:@"超出图片区域的部分将不会显示！" timeOut:1.5f];
    //        [self showStickerMask:YES];
    //    }
}

- (void)handleStickerChoose:(NSDictionary *)dic
{
    [self updateViewElementsWithAlpha:1 animated:YES];
    
    CGPoint center = [[dic valueForKey:@"center"] CGPointValue];
    NSString *imgURL = nil;
    NSString *stickerId = nil;
    MDMomentExpressionCellModel *model = [dic objectForKey:@"data"];
    if (model) {
        imgURL = model.picUrl;
        stickerId = model.resourceId;
    }
    
    if (self.stickers.count < kMaxStickerCount) {
        
        if (![imgURL isNotEmpty] || ![stickerId isNotEmpty]) {
            return;
        }
        
        MDRecordSticker *sticker = [[MDRecordSticker alloc] initWithImageURL:imgURL];
        sticker.stickerId = stickerId;
        
        [self.stickerAdjustView addSticker:sticker center:center];
        [self.stickers addObjectSafe:sticker];
        
    }else {
        [[UIApplication sharedApplication].delegate.window makeToast:@"最多使用20个贴纸" duration:1.5f position:CSToastPositionCenter];
    }
}

#pragma mark - MDMomentTextAdjustmentViewDelegate
-(void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerDidTap:(MDMomentTextSticker *)sticker frame:(CGRect)frame
{
    [view removeSticker:sticker];
    [self.textStickers removeObject:sticker];
    self.handlingSticker = sticker;
    
    self.textEditView.text = sticker.label.text;
    [self showTextEditView:YES];
    [self.textEditView configSelectedColor:sticker.colorIndex];
}

- (void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerWillBeginChange:(MDMomentTextSticker *)sticker frame:(CGRect)frame
{
    [self updateBottomToolsWithAlpha:0 animate:YES];
    
    self.stickerDeleteBtn.alpha = 1.0f;
}

- (void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerDidMove:(MDMomentTextSticker *)sticker frame:(CGRect)frame touchPoint:(CGPoint)point
{
    CGPoint touchPoint = [view convertPoint:point toView:self.stickerDeleteBtn];
    CGRect touchFrame = CGRectMake(touchPoint.x -35, touchPoint.y -35, 70, 70);
    self.needDeleteSticker = CGRectIntersectsRect(self.stickerDeleteBtn.bounds, touchFrame);
    
    //除了直接接近删除框之外, 如果超越边界, 删除
    CGPoint viewCenter = CGPointMake(frame.origin.x+frame.size.width/2, frame.origin.y+frame.size.height/2);
    if (viewCenter.x > view.width || viewCenter.x < 0) {
        self.needDeleteSticker = YES;
    }
    
    if (viewCenter.y > view.height || viewCenter.y < 0) {
        self.needDeleteSticker = YES;
    }
    
    if (self.needDeleteSticker) {
        
        CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
        if (!CGAffineTransformEqualToTransform(scale, self.stickerDeleteBtn.transform)) {
            //需要删除状态使用红色
            UIImage *img = [UIImage imageNamed:@"sticker_delete_btn"];
            [self.stickerDeleteBtn setImage:img forState:UIControlStateNormal];
            self.stickerDeleteBtn.transform = scale;
        }
        
    } else {
        
        //非删除状态需要灰色
        UIImage *img = [UIImage imageNamed:@"sticker_delete_btn_2"];
        [self.stickerDeleteBtn setImage:img forState:UIControlStateNormal];
        self.stickerDeleteBtn.transform = CGAffineTransformIdentity;
    }
}

- (void)momentTextAdjustmentView:(MDMomentTextAdjustmentView *)view stickerDidEndChange:(MDMomentTextSticker *)sticker frame:(CGRect)frame
{
    [UIView animateWithDuration:0.3f animations:^{
        self.stickerDeleteBtn.alpha = .0f;
        self.stickerDeleteBtn.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
        if (self.stickerDeleteBtn.alpha == 0.0f) {
            [self updateBottomToolsWithAlpha:1 animate:YES];
        }    }];
    
    
    if (self.needDeleteSticker) {
        [view removeSticker:sticker];
        [self.textStickers removeObject:sticker];
        self.needDeleteSticker = NO;
        return;
    }
    
    //    if (!CGRectContainsRect(self.stickerAdjustView.bounds, frame)) {
    //        [[MDContext sharedIndicate] showWarningInView:self.view withText:@"超出图片区域的部分将不会显示！" timeOut:1.5f];
    //        [self showStickerMask:YES];
    //    }
}

#pragma mark - MDNavigationBarAppearanceDelegate
- (UINavigationBar *)md_CustomNavigationBar
{
    return nil;
}

- (BOOL)md_popGestureRecognizerEnabled
{
    return NO;
}

#pragma mark - 辅助方法
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
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-titleH, 0, 2.0f, -titleW)];
    
    return btn;
}

- (void)updateBottomToolsWithAlpha:(CGFloat)alpha animate:(BOOL)animated
{
    void(^action)(void) = ^(void) {
        self.filterSwitchButton.alpha = alpha;
        self.thinBodyButton.alpha = alpha;
        self.stickerButton.alpha = alpha;
        self.textButton.alpha = alpha;
        self.painterButton.alpha = alpha;
        self.cropButton.alpha = alpha;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2f animations:^{
            action();
        }];
    }else {
        action();
    }
}

- (void)updateViewElementsWithAlpha:(CGFloat)alpha animated:(BOOL)animated
{
    void(^action)(void) = ^(void) {
        self.cancelBtn.alpha = alpha;
        self.doneBtn.alpha = alpha;
        self.filterSwitchButton.alpha = alpha;
        self.thinBodyButton.alpha = alpha;
        self.stickerButton.alpha = alpha;
        self.textButton.alpha = alpha;
        self.painterButton.alpha = alpha;
        self.cropButton.alpha = alpha;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            action();
        }];
    }else {
        action();
    }
}

- (void)showTextEditView:(BOOL)show
{
    if (show) {
        [self updateViewElementsWithAlpha:.0f animated:NO];
        [_textEditView active];
        
    } else {
        [self updateViewElementsWithAlpha:1.0f animated:YES];
        [_textEditView hide];
    }
}

- (CGRect)renderFrameForSize:(CGSize)size {
    CGRect result = CGRectZero;
    
    if (size.width > 0 && size.height > 0) {
        
        CGFloat widthRatio = size.width/MDScreenWidth;
        CGFloat heightRatio = size.height/MDScreenHeight;
        CGFloat imageRatio = size.width/size.height;
        
        CGFloat newWidth = 0;
        CGFloat newHeight = 0;
        
        if (widthRatio > heightRatio) {
            
            newHeight = MDScreenWidth * (1.0 / imageRatio);
            //宽比例大于高比例, 以宽作为基准
            result = CGRectMake(0, (MDScreenHeight-newHeight)/2, MDScreenWidth, MDScreenWidth * (1.0 / imageRatio));
            
        } else {
            
            newWidth = MDScreenHeight * imageRatio;
            result = CGRectMake((MDScreenWidth-newWidth)/2, 0, MDScreenHeight * imageRatio, MDScreenHeight);
        }
    }
    
    return result;
}

- (void)showStickerMask:(BOOL)show
{
    if (!self.stickerMask) {
        self.stickerMask = [[UIView alloc] initWithFrame:self.view.bounds];
        self.stickerMask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        CGRect videoRegion = self.contentView.bounds;
        
        //背景
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.stickerMask.bounds cornerRadius:.0f];
        
        //镂空
        UIBezierPath *hollwPath = [UIBezierPath bezierPathWithRect:videoRegion];
        [path appendPath:[hollwPath bezierPathByReversingPath]];
        
        //shapeLayer
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        
        self.stickerMask.layer.mask = shapeLayer;
        [self.view addSubview:self.stickerMask];
    }
    
    self.stickerMask.alpha = show ? 1.0f :.0f;
    [self.view bringSubviewToFront:self.stickerMask];
    [UIView animateWithDuration:0.2f
                          delay:1.5f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.stickerMask.alpha = .0f;
                     } completion:^(BOOL finished) {
                     }];
}

- (BOOL)isEditValid {
    
    BOOL hasEdit = NO;
    
    //滤镜是否更改
    if (self.currentFilterIndex != 0) {
        hasEdit = YES;
    }
    
    //磨皮美白是否更改
    NSInteger skinSmoothParam = [self.beautySettingDict integerForKey:MDBeautySettingsSkinSmoothingAmountKey defaultValue:0];
    if (skinSmoothParam != 0) {
        hasEdit = YES;
    }
    
    //大眼瘦脸是否更改
    NSInteger eyesEnhancement = [self.beautySettingDict integerForKey:MDBeautySettingsEyesEnhancementAmountKey defaultValue:0];
    if (eyesEnhancement != 0) {
        hasEdit = YES;
    }
    
    //瘦身是否更改
    NSInteger thinBodyAmount = [self.beautySettingDict integerForKey:MDBeautySettingsThinBodyAmountKey defaultValue:0];
    if (thinBodyAmount != 0) {
        hasEdit = YES;
    }
    
    //长腿是否更改
    NSInteger longLegAmount = [self.beautySettingDict integerForKey:MDBeautySettingsLongLegAmountKey defaultValue:0];
    if (longLegAmount != 0) {
        hasEdit = YES;
    }

    //图片贴纸是否添加
    if (self.stickers.count > 0) {
        hasEdit = YES;
    }
    
    //涂鸦是否添加
    if (self.graffitiCanvasView.image && (self.graffitiCanvasViewOriginImage!=self.graffitiCanvasView.image)) {
        hasEdit = YES;
    }
    
    //文字帖子是否添加
    if (self.textStickers.count > 0) {
        hasEdit = YES;
    }
    
    // 裁剪图片
    if (self.cropImage) {
        hasEdit = YES;
    }
    
    return hasEdit;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - MDRecordCropImageViewControllerDelegate Methods

- (void)cropImageViewController:(MDRecordCropImageViewController *)vc resizedImage:(UIImage *)resizedImage {
    [self reloadImage:resizedImage];
}

- (void)cropImageViewControllerCancelCrop:(MDRecordCropImageViewController *)vc {
    
}

@end
