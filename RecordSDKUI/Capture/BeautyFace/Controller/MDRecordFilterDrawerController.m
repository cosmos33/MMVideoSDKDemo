//
//  MDRecordFilterDrawerController.m
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/2.
//  Copyright © 2017年 sdk. All rights reserved.
//

#define WEAKSelf __weak typeof(self) weakSelf = self;
#define MDScreenWidth     CGRectGetWidth([[UIScreen mainScreen] bounds])
#define MDScreenHeight    CGRectGetHeight([[[UIApplication sharedApplication].delegate window] bounds])

#import <POP/POP.h>
#import "UIView+Utils.h"
#import <MMFoundation/MMFoundation.h>
#import "UIConst.h"
#import "MDRecordFilterDrawerController.h"
//#import "MDRecordFilterDrawerDataManager.h"//数据请求

#import "MDRecordFilterListView.h"//滤镜
#import "MDRecordMakeUpListView.h"//美颜 瘦脸
#import "MDAlbumVideoSwitchButtonView.h"
#import "MDRecordMacro.h"
#import "MDRecordFilterModelLoader.h"
#import "MDRecordFilterDrawerSlider.h"
#import "MDRecordFilterDrawerSliderPanel.h"

NSString *const kDrawerControllerFilterKey       = @"滤镜";
NSString *const kDrawerControllerMakeupKey       = @"美肌";
NSString *const kDrawerControllerChangeFacialKey = @"美颜";
NSString *const kDrawerControllerMicroKey        = @"微整形";
NSString *const kDrawerControllerThinBodyKey     = @"瘦身";
NSString *const kDrawerControllerLongLegKey      = @"长腿";
NSString *const kDrawerControllerMakeUpKey       = @"美妆";
NSString *const kDrawerControllerMakeupStyleKey      = @"风格妆";


static NSInteger const kSelectViewHeiht = 41;
static CGFloat   const kDuration        = 0.3;
static CGFloat   const kContentInset    = 20;

#define kTotalHeight (200 + HOME_INDICATOR_HEIGHT)

@interface MDRecordFilterDrawerController () <MDRecordFilterDrawerSliderPanelDelegate>

@property (nonatomic, strong) UIVisualEffectView            *visualEffectView;//高斯模糊view
@property (nonatomic, strong) MDRecordFilterListView        *filterView;//滤镜
@property (nonatomic, strong) MDRecordMakeUpListView        *makeUpView;//美颜
@property (nonatomic, strong) MDRecordMakeUpListView        *microSurgeryView;//美颜
@property (nonatomic, strong) MDRecordMakeUpListView        *faceLiftView;//瘦脸（大眼）
@property (nonatomic, strong) MDRecordMakeUpListView        *thinBodyView;//瘦身
@property (nonatomic, strong) MDRecordMakeUpListView        *longLegView;//长腿
@property (nonatomic, strong) MDRecordMakeUpListView        *makeupBeautyView;//美妆
@property (nonatomic, strong) MDRecordMakeUpListView        *makeupStyleView;//风格妆
@property (nonatomic, strong) MDAlbumVideoSwitchButtonView  *switchView;
@property (nonatomic, strong) UIView                        *bottomBgView;//底部背景view

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) MDRecordFilterDrawerSlider *filterIntensitySlider;
@property (nonatomic, strong) MDRecordFilterDrawerSlider *makeupLookUpSlider;
@property (nonatomic, strong) MDRecordFilterDrawerSlider *microsurgerySlider;
@property (nonatomic, strong) MDRecordFilterDrawerSliderPanel *makeUpSliderPanel;
@property (nonatomic, strong) MDRecordFilterDrawerSliderPanel *faceListSliderPanel;
@property (nonatomic, strong) MDRecordFilterDrawerSliderPanel *makeStyleSliderPanel;


@property (nonatomic, strong) UIButton *detailButton;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic,strong) NSArray<NSString *>            *tagArray;

@end

@implementation MDRecordFilterDrawerController

- (void)dealloc
{
//    MDLogDebug(@"MDRecordFilterDrawerController");
}

- (instancetype)init
{
    NSArray *tagArray = @[kDrawerControllerFilterKey,
                          kDrawerControllerMakeupKey,
                          kDrawerControllerChangeFacialKey,
                          kDrawerControllerMicroKey,
                          kDrawerControllerThinBodyKey,
                          kDrawerControllerLongLegKey,
                          kDrawerControllerMakeUpKey,
                          kDrawerControllerMakeupStyleKey
                        ];
    return [self initWithTagArray:tagArray];
}

- (instancetype)initWithFilterScenceType:(MDRecordFilterScenceType)scenceType {
    NSArray *tagArray = @[kDrawerControllerFilterKey,
                          kDrawerControllerMakeupKey,
                          kDrawerControllerChangeFacialKey,
                          ];
    return [self initWithTagArray:tagArray];
}

- (instancetype)initWithTagArray:(NSArray *)tagArray
{
    if (self = [super init]) {
        
//        BOOL canUseThinBody = [[MDContext beautySettingDataManager] canUseBodyThinSetting];
//        BOOL canUseLongLeg = [[MDContext beautySettingDataManager] canUseLongLegSetting];
        BOOL canUseThinBody = YES; //[[MDContext beautySettingDataManager] canUseBodyThinSetting];
        BOOL canUseLongLeg = YES; //[[MDContext beautySettingDataManager] canUseLongLegSetting];
        
        NSMutableArray *marr = [NSMutableArray arrayWithArray:tagArray];
        if ([tagArray containsObject:kDrawerControllerThinBodyKey] && !canUseThinBody) {
            [marr removeObject:kDrawerControllerThinBodyKey];
        }
        if ([tagArray containsObject:kDrawerControllerLongLegKey] && !canUseLongLeg) {
            [marr removeObject:kDrawerControllerLongLegKey];
        }
        _tagArray = [marr copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareSubviews];
    [self loadData];
}

- (void)loadData
{
    // 美颜
    if ([_tagArray containsObject:kDrawerControllerMakeupKey]) {
        [MDRecordFilterModelLoader requeseteRecordMakeUpData:^(NSArray *beautifyArray) {
            self.makeUpView.dataArray = beautifyArray;
            [self.makeUpView reloadData];
        }];
    }

    // 五官（瘦脸大眼）
    if ([_tagArray containsObject:kDrawerControllerChangeFacialKey]) {
        [MDRecordFilterModelLoader requeseteRecordChangeFaceData:^(NSArray *changeFaceArray) {
            self.faceLiftView.dataArray = changeFaceArray;
            [self.faceLiftView reloadData];
        }];
    }

    // 瘦身 长腿 等级和五官一致，暂时使用同一个方法获取，如后期需求变更，再另行处理。
    // 瘦身
    if ([_tagArray containsObject:kDrawerControllerThinBodyKey]) {
            [MDRecordFilterModelLoader requeseteRecordChangeFaceData:^(NSArray *changeFaceArray) {
                self.thinBodyView.dataArray = changeFaceArray;
                [self.thinBodyView reloadData];
            }];
    }

    // 长腿
    if ([_tagArray containsObject:kDrawerControllerLongLegKey]) {
            [MDRecordFilterModelLoader requeseteRecordChangeFaceData:^(NSArray *changeFaceArray) {
                self.longLegView.dataArray = changeFaceArray;
                [self.longLegView reloadData];
            }];
    }
    // 美妆
    if ([_tagArray containsObject:kDrawerControllerMakeUpKey]) {
        [MDRecordFilterModelLoader requeseteMakeupDataWithType:1 block:^(NSArray * _Nonnull beautifyArray) {
            self.makeupBeautyView.dataArray = beautifyArray;
            [self.makeupBeautyView reloadData];
        }];
    }
    // 风格妆
    if ([_tagArray containsObject:kDrawerControllerMakeupStyleKey]) {
        [MDRecordFilterModelLoader requeseteMakeupDataWithType:0 block:^(NSArray * _Nonnull beautifyArray) {
            self.makeupStyleView.dataArray = beautifyArray;
            [self.makeupStyleView reloadData];
        }];
    }
    // 微整形
    
    if ([_tagArray containsObject:kDrawerControllerMakeupStyleKey]) {
        [MDRecordFilterModelLoader requeseteMicroData:^(NSArray * _Nonnull microSurgeryArray) {
            self.microSurgeryView.dataArray = microSurgeryArray;
            [self.microSurgeryView reloadData];
        }];
    }
}

- (void)setFilterModels:(NSArray<MDRecordFilterModel *> *)filterModels
{
    self.filterView.dataArray = filterModels;
    [self.filterView reloadData];
}

- (void)prepareSubviews
{
    self.view.frame = CGRectMake(0, MDScreenHeight - kTotalHeight, MDScreenWidth, kTotalHeight);
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.visualEffectView];
//    [self.visualEffectView.contentView addSubview:self.selectView];
    [self.visualEffectView.contentView addSubview:self.switchView];
    [self.visualEffectView.contentView addSubview:self.detailButton];
    [self.visualEffectView.contentView addSubview:self.backButton];
    
    [self.detailButton.centerYAnchor constraintEqualToAnchor:self.switchView.centerYAnchor constant:-3].active = YES;
    [self.detailButton.rightAnchor constraintEqualToAnchor:self.visualEffectView.contentView.rightAnchor constant:-12].active = YES;
    
    [self.backButton.centerYAnchor constraintEqualToAnchor:self.switchView.centerYAnchor constant:-3].active = YES;
    [self.backButton.rightAnchor constraintEqualToAnchor:self.visualEffectView.contentView.rightAnchor constant:-12].active = YES;
    

    if ([_tagArray containsObject:kDrawerControllerFilterKey]) {
        [self.visualEffectView.contentView addSubview:self.filterView];
        [self.visualEffectView.contentView addSubview:self.filterIntensitySlider];
    }
    if ([_tagArray containsObject:kDrawerControllerMakeupKey]) {
        [self.visualEffectView.contentView addSubview:self.makeUpView];
        [self.visualEffectView.contentView addSubview:self.makeUpSliderPanel];
    }
    if ([_tagArray containsObject:kDrawerControllerChangeFacialKey]) {
        [self.visualEffectView.contentView addSubview:self.faceLiftView];
        [self.visualEffectView.contentView addSubview:self.faceListSliderPanel];
    }
    if ([_tagArray containsObject:kDrawerControllerThinBodyKey]) {
//        if ([[MDContext beautySettingDataManager] canUseBodyThinSetting]) {// 瘦身
            [self.visualEffectView.contentView addSubview:[self setupThinBodyView]];
//        }
    }
    if ([_tagArray containsObject:kDrawerControllerLongLegKey]) {
//        if ([[MDContext beautySettingDataManager] canUseLongLegSetting]) {// 长腿
            [self.visualEffectView.contentView addSubview:[self setupLongLegView]];
//        }
    }
    if ([_tagArray containsObject:kDrawerControllerMakeUpKey]) {
        [self.visualEffectView.contentView addSubview:self.makeupBeautyView];
        [self.visualEffectView.contentView addSubview:self.makeupLookUpSlider];
    }
    if ([_tagArray containsObject:kDrawerControllerMakeupStyleKey]) {
        [self.visualEffectView.contentView addSubview:self.makeupStyleView];
        [self.visualEffectView.contentView addSubview:self.makeStyleSliderPanel];
    }
    if ([_tagArray containsObject:kDrawerControllerMicroKey]) {
        [self.visualEffectView.contentView addSubview:self.microSurgeryView];
        [self.visualEffectView.contentView addSubview:self.microsurgerySlider];
    }
    
    [self.visualEffectView.contentView addSubview:self.bottomBgView];
//    [self.selectView addItems:self.tagArray];
//    [self setSelectedIndex:0];
    self.switchView.titles = self.tagArray;
    [self.switchView setSelectedIndex:0];
    
    self.view.hidden = YES;
    
    [self.visualEffectView.contentView addSubview:self.lineView];
    [self.lineView.leftAnchor constraintEqualToAnchor:self.visualEffectView.contentView.leftAnchor constant:20].active = YES;
    [self.lineView.centerXAnchor constraintEqualToAnchor:self.visualEffectView.contentView.centerXAnchor].active = YES;
    [self.lineView.heightAnchor constraintEqualToConstant:1.0 / [UIScreen mainScreen].scale].active = YES;
    [self.lineView.bottomAnchor constraintEqualToAnchor:self.switchView.bottomAnchor].active = YES;
}

- (void)setDefaultSelectIndex:(NSUInteger)index
{
//    [self setSelectedIndex:index];
    [self.switchView setSelectedIndex:index];
}

- (void)setSelectedIndex:(NSInteger)index
{
//    NSInteger currentSelectedIndex = [self.switchView currentSelectedIndex];
//    if (index == currentSelectedIndex) return;
    
    [self hideAllView];
    
//    [self.selectView setCurrentSelectedIndex:index];
//    [self.switchView setSelectedIndex:index];
    
    NSString *title = [self.tagArray objectAtIndex:index defaultValue:nil];
    if ([title isEqualToString:kDrawerControllerFilterKey]) {
        self.filterView.hidden = NO;
        self.detailButton.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMakeupKey]) {
        self.makeUpView.hidden = NO;
        self.detailButton.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerChangeFacialKey]) {
        self.faceLiftView.hidden = NO;
        self.detailButton.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerThinBodyKey]) {
        self.thinBodyView.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerLongLegKey]) {
        self.longLegView.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMakeUpKey]){
        self.makeupBeautyView.hidden = NO;
        self.detailButton.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMakeupStyleKey]){
        self.makeupStyleView.hidden = NO;
        self.detailButton.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMicroKey]){
        self.detailButton.hidden = NO;
        self.microSurgeryView.hidden = NO;
    }
}

- (void)hideAllView {
    self.filterIntensitySlider.hidden = YES;
    self.makeUpSliderPanel.hidden = YES;
    self.faceListSliderPanel.hidden = YES;
    self.filterView.hidden = YES;
    self.makeUpView.hidden = YES;
    self.faceLiftView.hidden = YES;
    self.thinBodyView.hidden = YES;
    self.longLegView.hidden = YES;
    self.detailButton.hidden = YES;
    self.backButton.hidden = YES;
    self.makeStyleSliderPanel.hidden = YES;
    self.makeupStyleView.hidden = YES;
    self.makeupBeautyView.hidden = YES;
    self.makeupLookUpSlider.hidden = YES;
    self.microsurgerySlider.hidden = YES;
    self.microSurgeryView.hidden = YES;
}

#pragma mark --显示隐藏

- (void)showAnimation
{
    if (self.isShowed || self.isAnimating) return;
    
    self.show = YES;
    self.animating = YES;
    self.view.hidden = NO;
    
    __weak __typeof(self) weakSelf = self;
    NSString *transFrameAniamtion = @"transFrameAniamtion";
    POPSpringAnimation *pointSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    pointSpring.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, MDScreenWidth, self.visualEffectView.height)];
    pointSpring.springBounciness = 7;
    pointSpring.springSpeed = 15;
    pointSpring.delegate = self;
    pointSpring.completionBlock = ^(POPAnimation *animation,BOOL finish) {
        if (finish) {
            weakSelf.animating = NO;
        }
    };
    [self.visualEffectView pop_removeAnimationForKey:transFrameAniamtion];
    [self.visualEffectView pop_addAnimation:pointSpring forKey:transFrameAniamtion];
}

- (void)hideAnimationWithCompleteBlock:(void(^)(void))completeBlock
{
    if (!self.isShowed || self.isAnimating) return;
    self.show = NO;
    self.animating = YES;
    
    [UIView animateWithDuration:kDuration animations:^{
        self.visualEffectView.top = kTotalHeight;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
        self.animating = NO;
        if (completeBlock) {
            completeBlock();
        }
    }];
}
- (void)setMicroSurgeryIndex:(NSUInteger)index{
    [self.microSurgeryView selectedAndReloadCollectionView:index];
}
- (void)setMakeupBeautyIndex:(NSUInteger)index{
    [self.makeupBeautyView selectedAndReloadCollectionView:index];
}
- (void)setMakeupStyleIndex:(NSUInteger)index{
    [self.makeupStyleView selectedAndReloadCollectionView:index];
}
- (void)setFilterIndex:(NSUInteger)index
{
    [self.filterView selectedAndReloadCollectionView:index];
}

- (void)setMakeUpIndex:(NSUInteger)index
{
    [self.makeUpView selectedAndReloadCollectionView:index];
}

- (void)setThinFaceIndex:(NSInteger)index
{
    [self.faceLiftView selectedAndReloadCollectionView:index];
}

- (void)setThinBodyIndex:(NSInteger)index
{
    if (index < 0) {
        index = 0;
    }
    [self.thinBodyView selectedAndReloadCollectionView:index];
}

- (void)setLongLegIndex:(NSInteger)index
{
    if (index < 0) {
        index = 0;
    }
    [self.longLegView selectedAndReloadCollectionView:index];
}

- (void)detailButtonClicked:(UIButton *)button {
    NSInteger index = self.switchView.currentSelectedIndex;
    
    [self hideAllView];
    NSString *title = [self.tagArray objectAtIndex:index defaultValue:nil];
    
    if ([title isEqualToString:kDrawerControllerFilterKey]) { // 0
        self.filterIntensitySlider.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMakeupKey]) { // 1
        self.makeUpSliderPanel.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerChangeFacialKey]) { // 2
        self.faceListSliderPanel.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerThinBodyKey]) { // 4
        self.microsurgerySlider.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerLongLegKey]) { // 5
        self.longLegView.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMakeUpKey]){ // 6
        self.makeupLookUpSlider.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMakeupStyleKey]){ // 7
        self.makeStyleSliderPanel.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMicroKey]){ // 3
        self.microsurgerySlider.hidden = NO;
    }
    self.backButton.hidden = NO;
}

- (void)backButtonClicked:(UIButton *)button {
    NSInteger index = self.switchView.currentSelectedIndex;
    
    [self hideAllView];
    NSString *title = [self.tagArray objectAtIndex:index defaultValue:nil];
    
    if ([title isEqualToString:kDrawerControllerFilterKey]) { // 0
        self.filterView.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMakeupKey]) { // 1
        self.makeUpView.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerChangeFacialKey]) { // 2
        self.faceLiftView.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerThinBodyKey]) { // 4
        self.microsurgerySlider.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerLongLegKey]) { // 5
        self.longLegView.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMakeUpKey]){ // 6
        self.makeupBeautyView.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMakeupStyleKey]){ // 7
        self.makeupStyleView.hidden = NO;
    } else if ([title isEqualToString:kDrawerControllerMicroKey]){ // 3
        self.microSurgeryView.hidden = NO;
    }
    self.detailButton.hidden = NO;
}

#pragma mark --lazy

- (MDRecordFilterListView *)filterView
{
    if(!_filterView){
        _filterView = [[MDRecordFilterListView alloc] initWithFrame:CGRectMake(0, kSelectViewHeiht, MDScreenWidth, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        WEAKSelf
        [_filterView setSetselectedItemBlock:^(NSInteger index){
            if([weakSelf.delegate respondsToSelector:@selector(didSelectedFilterItem:)]){
                [weakSelf.delegate didSelectedFilterItem:index];
            }
        }];
    }
    return _filterView;
}

- (MDRecordMakeUpListView *)makeUpView
{
    if(!_makeUpView){
        _makeUpView = [[MDRecordMakeUpListView alloc] initWithFrame:CGRectMake(0, kSelectViewHeiht, MDScreenWidth, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        WEAKSelf
        [_makeUpView setSelectedIndexBlock:^(NSInteger index){
            if([weakSelf.delegate respondsToSelector:@selector(didSelectedMakeUpItem:)]){
                [weakSelf.delegate didSelectedMakeUpItem:index];
            }
        }];
    }
    return _makeUpView;
}

- (MDRecordMakeUpListView *)microSurgeryView{
    if (!_microSurgeryView) {
        _microSurgeryView = [[MDRecordMakeUpListView alloc] initWithFrame:CGRectMake(0, kSelectViewHeiht, MDScreenWidth, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        WEAKSelf
        [_microSurgeryView setSelectedIndexBlock:^(NSInteger index){
            if([weakSelf.delegate respondsToSelector:@selector(didselectedMicroSurgeryModel:)]){
                MDRecordMakeUpModel *model = [weakSelf.microSurgeryView.dataArray objectAtIndex:index];
                weakSelf.microsurgerySlider.sliderType = model.sliderType.intValue;
                [weakSelf.delegate didselectedMicroSurgeryModel:model.type];
            }
        }];
    }
    return _microSurgeryView;
}

- (MDRecordMakeUpListView *)faceLiftView
{
    
    if(!_faceLiftView){
        _faceLiftView = [[MDRecordMakeUpListView alloc] initWithFrame:CGRectMake(0, kSelectViewHeiht, MDScreenWidth, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        WEAKSelf
        [_faceLiftView setSelectedIndexBlock:^(NSInteger index){
            if([weakSelf.delegate respondsToSelector:@selector(didSelectedFaceLiftItem:)]){
                [weakSelf.delegate didSelectedFaceLiftItem:index];
            }
        }];
    }
    return _faceLiftView;
}

- (MDRecordMakeUpListView *)setupThinBodyView
{
    if (!_thinBodyView) {
        _thinBodyView = [[MDRecordMakeUpListView alloc] initWithFrame:CGRectMake(0, kSelectViewHeiht, MDScreenWidth, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        WEAKSelf
        [_thinBodyView setSelectedIndexBlock:^(NSInteger index) {
            if ([weakSelf.delegate respondsToSelector:@selector(didSelectedThinBodyItem:)]) {
                [weakSelf.delegate didSelectedThinBodyItem:index];
            }
        }];
    }
    return _thinBodyView;
}

- (MDRecordMakeUpListView *)setupLongLegView
{
    if (!_longLegView) {
        _longLegView = [[MDRecordMakeUpListView alloc] initWithFrame:CGRectMake(0, kSelectViewHeiht, MDScreenWidth, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        WEAKSelf
        [_longLegView setSelectedIndexBlock:^(NSInteger index) {
            if ([weakSelf.delegate respondsToSelector:@selector(didSelectedLongLegItem:)]) {
                [weakSelf.delegate didSelectedLongLegItem:index];
            }
        }];
    }
    return _longLegView;
}

- (MDRecordMakeUpListView *)makeupBeautyView{
    if (!_makeupBeautyView) {
        _makeupBeautyView = [[MDRecordMakeUpListView alloc] initWithFrame:CGRectMake(0, kSelectViewHeiht, MDScreenWidth, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        WEAKSelf
        [_makeupBeautyView setSelectedIndexBlock:^(NSInteger index) {
            if([weakSelf.delegate respondsToSelector:@selector(didSelectedMakeUpModel:)]){
                MDRecordMakeUpModel *model = [weakSelf.makeupBeautyView.dataArray objectAtIndex:index];
                [weakSelf.delegate didSelectedMakeUpModel:model.makeUpId];
            }
        }];
    }
    return  _makeupBeautyView;
}

- (MDRecordMakeUpListView *)makeupStyleView{
    if (!_makeupStyleView) {
        _makeupStyleView = [[MDRecordMakeUpListView alloc] initWithFrame:CGRectMake(0, kSelectViewHeiht, MDScreenWidth, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        WEAKSelf
        [_makeupStyleView setSelectedIndexBlock:^(NSInteger index) {
            if([weakSelf.delegate respondsToSelector:@selector(didSelectedMakeUpModel:)]){
                MDRecordMakeUpModel *model = [weakSelf.makeupStyleView.dataArray objectAtIndex:index];
                [weakSelf.delegate didSelectedMakeUpModel:model.makeUpId];
            }
        }];
    }
    return  _makeupStyleView;
}

- (MDAlbumVideoSwitchButtonView *)switchView {
    if (!_switchView) {
        _switchView = [[MDAlbumVideoSwitchButtonView alloc] initWithFrame:CGRectMake(10, 8, MDScreenWidth - 30, kSelectViewHeiht - 8)];
        __weak typeof(self) weakself = self;
        _switchView.titleButtonClicked = ^(MDAlbumVideoSwitchButtonView *switchButtonView, NSInteger index) {
            [weakself setSelectedIndex:index];
        };
    }
    return _switchView;
}

- (UIButton *)detailButton {
    if (!_detailButton) {
        _detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _detailButton.translatesAutoresizingMaskIntoConstraints = NO;
        _detailButton.hidden = YES;
        [_detailButton setImage:[UIImage imageNamed:@"filterDrawerSetting"] forState:UIControlStateNormal];
        [_detailButton addTarget:self action:@selector(detailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTounchBtnClick:)];
        longGesture.minimumPressDuration = 0.8;
        [_detailButton addGestureRecognizer:longGesture];
    }
    return _detailButton;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.translatesAutoresizingMaskIntoConstraints = NO;
        _backButton.hidden = YES;
        [_backButton setImage:[UIImage imageNamed:@"filterDrawerSetting"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTounchBtnClick:)];
        longGesture.minimumPressDuration = 0.8;
        [_backButton addGestureRecognizer:longGesture];
    }
    return _backButton;
}

- (void)longTounchBtnClick:(UILongPressGestureRecognizer *)longPrss{
    NSLog(@"bobo start long");
    if (longPrss.state == UIGestureRecognizerStateBegan) {
        if([self.delegate respondsToSelector:@selector(longTounchBtnClickStart)]){
            NSLog(@"bobo longTounchBtnClickStart");
            [self.delegate longTounchBtnClickStart];
        }
    } else {
        if([self.delegate respondsToSelector:@selector(longTounchBtnClickEnd)]){
            NSLog(@"bobo longTounchBtnClickEnd");
            [self.delegate longTounchBtnClickEnd];
        }
    }
   
}

- (MDRecordFilterDrawerSlider *)microsurgerySlider{
    if (!_microsurgerySlider) {
        _microsurgerySlider = [[MDRecordFilterDrawerSlider alloc] initWithFrame:CGRectMake(28, kSelectViewHeiht, MDScreenWidth - 56, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        _microsurgerySlider.title = @"浓度";
        _microsurgerySlider.sliderValue = 1.0;
        __weak typeof(self) weakself = self;
        _microsurgerySlider.valueChanged = ^(MDRecordFilterDrawerSlider *slider, CGFloat intensity) {
            if ([weakself.delegate respondsToSelector:@selector(didSetMicroSurgeryIntensity:)]) {
                [weakself.delegate didSetMicroSurgeryIntensity:intensity];
            }
        };
    }
    return _microsurgerySlider;
}

- (MDRecordFilterDrawerSlider *)makeupLookUpSlider{
    if (!_makeupLookUpSlider) {
        _makeupLookUpSlider = [[MDRecordFilterDrawerSlider alloc] initWithFrame:CGRectMake(28, kSelectViewHeiht, MDScreenWidth - 56, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        _makeupLookUpSlider.title = @"浓度";
        _makeupLookUpSlider.sliderValue = 1.0;
        __weak typeof(self) weakself = self;
        _makeupLookUpSlider.valueChanged = ^(MDRecordFilterDrawerSlider *slider, CGFloat intensity) {
            if ([weakself.delegate respondsToSelector:@selector(didSetMakeUpBeautyIntensity:)]) {
                [weakself.delegate didSetMakeUpBeautyIntensity:intensity];
            }
        };
    }
    return _makeupLookUpSlider;
}

- (MDRecordFilterDrawerSlider *)filterIntensitySlider {
    if (!_filterIntensitySlider) {
        _filterIntensitySlider = [[MDRecordFilterDrawerSlider alloc] initWithFrame:CGRectMake(28, kSelectViewHeiht, MDScreenWidth - 56, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        _filterIntensitySlider.title = @"浓度";
        _filterIntensitySlider.sliderValue = 1.0;
        __weak typeof(self) weakself = self;
        _filterIntensitySlider.valueChanged = ^(MDRecordFilterDrawerSlider *slider, CGFloat intensity) {
            if ([weakself.delegate respondsToSelector:@selector(didSetFilterIntensity:)]) {
                [weakself.delegate didSetFilterIntensity:intensity];
            }
        };
    }
    return _filterIntensitySlider;
}

- (MDRecordFilterDrawerSliderPanel *)makeUpSliderPanel {
    if (!_makeUpSliderPanel) {
        _makeUpSliderPanel = [[MDRecordFilterDrawerSliderPanel alloc] initWithFrame:CGRectMake(28, kSelectViewHeiht, MDScreenWidth - 56, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        _makeUpSliderPanel.title1 = @"美白";
        _makeUpSliderPanel.title2 = @"磨皮";
        _makeUpSliderPanel.delegate = self;
        _makeUpSliderPanel.hidden = YES;
    }
    return _makeUpSliderPanel;
}


- (MDRecordFilterDrawerSliderPanel *)makeStyleSliderPanel{
    if (!_makeStyleSliderPanel) {
        _makeStyleSliderPanel = [[MDRecordFilterDrawerSliderPanel alloc] initWithFrame:CGRectMake(28, kSelectViewHeiht, MDScreenWidth - 56, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        _makeStyleSliderPanel.title1 = @"滤镜";
        _makeStyleSliderPanel.title2 = @"整装";
        _makeStyleSliderPanel.delegate = self;
        _makeStyleSliderPanel.hidden = YES;
    }
    return _makeStyleSliderPanel;
}

- (MDRecordFilterDrawerSliderPanel *)faceListSliderPanel {
    if (!_faceListSliderPanel) {
        _faceListSliderPanel = [[MDRecordFilterDrawerSliderPanel alloc] initWithFrame:CGRectMake(28, kSelectViewHeiht, MDScreenWidth - 56, kTotalHeight - kSelectViewHeiht - HOME_INDICATOR_HEIGHT)];
        _faceListSliderPanel.title1 = @"大眼";
        _faceListSliderPanel.title2 = @"瘦脸";
        _faceListSliderPanel.delegate = self;
        _faceListSliderPanel.hidden = YES;
    }
    return _faceListSliderPanel;
}

- (UIVisualEffectView *)visualEffectView
{
    if(!_visualEffectView){
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _visualEffectView.frame = CGRectMake(0, kTotalHeight, MDScreenWidth, kTotalHeight + kContentInset+10);
        _visualEffectView.backgroundColor = [UIColor clearColor];
        _visualEffectView.layer.cornerRadius = 10.0f;
        _visualEffectView.layer.masksToBounds = YES;
    }
    return _visualEffectView;
}

- (UIView *)bottomBgView {
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kTotalHeight-HOME_INDICATOR_HEIGHT, MDScreenWidth, HOME_INDICATOR_HEIGHT)];
        _bottomBgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.05);
    }
    return _bottomBgView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.translatesAutoresizingMaskIntoConstraints = NO;
        _lineView.backgroundColor = UIColor.whiteColor;
        _lineView.alpha = 0.1;
    }
    return _lineView;
}

#pragma mark - FilterDrawerSliderPanelDelegate methods

- (void)sliderValueChanged:(MDRecordFilterDrawerSliderPanel *)panel value:(CGFloat)value position:(MDRecordFilterDrawerSliderPanelSliderPosition)position {
    switch (position) {
        case MDRecordFilterDrawerSliderPanelSliderPositionTop:
            if (panel == self.makeUpSliderPanel) {
                if ([self.delegate respondsToSelector:@selector(didSetSkinWhitenValue:)]) {
                    [self.delegate didSetSkinWhitenValue:value];
                }
            } else if (panel == self.faceListSliderPanel) {
                if ([self.delegate respondsToSelector:@selector(didSetBigEyeValue:)]) {
                    [self.delegate didSetBigEyeValue:value];
                }
            } else if (panel == self.makeStyleSliderPanel){
                if ([self.delegate respondsToSelector:@selector(didSetMakeUpLookIntensity:)]) {
                    [self.delegate didSetMakeUpLookIntensity:value];
                }
            }
            break;
        case MDRecordFilterDrawerSliderPanelSliderPositionBottom:
            if (panel == self.makeUpSliderPanel) {
                if ([self.delegate respondsToSelector:@selector(didSetSmoothSkinValue:)]) {
                    [self.delegate didSetSmoothSkinValue:value];
                }
            } else if (panel == self.faceListSliderPanel) {
                if ([self.delegate respondsToSelector:@selector(didSetThinFaceValue:)]) {
                    [self.delegate didSetThinFaceValue:value];
                }
            } else if (panel == self.makeStyleSliderPanel){
                if ([self.delegate respondsToSelector:@selector(didSetMakeUpBeautyIntensity:)]) {
                    [self.delegate didSetMakeUpBeautyIntensity:value];
                }
            }
            break;
        default:
            break;
    }
}

@end
