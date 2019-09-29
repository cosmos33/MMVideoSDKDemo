//
//  MDMediaEditorRightView.m
//  MDChat
//
//  Created by YZK on 2018/8/1.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDMediaEditorRightView.h"
#import "MDRecordGuideTipsManager.h"
//#import "MDVideoRecordDefine.h"
#import "UIImage+MDUtility.h"


const CGFloat kMDMediaEditorRightViewIconWidth = 50;
const CGFloat kMDMediaEditorRightViewRightMargin = 5.0;

static const CGFloat kMarginHeight = 20.0;

const NSInteger kViewRedPointTag        = 10001;

@interface MDMediaEditorRightView ()

@property (nonatomic,strong) MDRecordGuideTipsManager   *tipsManager;

@property (nonatomic,strong) MDUnifiedRecordIconView *thinView;
@property (nonatomic,strong) MDUnifiedRecordIconView *specialEffectsView;

@end


@implementation MDMediaEditorRightView

- (instancetype)initWithFrame:(CGRect)frame andGuideTipsManager:(MDRecordGuideTipsManager *)guideManager {
    self = [super initWithFrame:frame];
    if (self) {
        _tipsManager = guideManager;
        [self configUI];
    }
    return self;
}

- (void)configUI
{
    BOOL canUseThin = YES; //[[MDContext beautySettingDataManager] canUseBodyThinSetting];

    NSInteger index = 0;
    if (canUseThin) {
        self.thinView = [self imageViewWithImageName:@"moment_record_thin_icon"
                                               title:@"瘦身"
                                               index:index
                                              selStr:@"didTapThinView"];
        [self addSubview:self.thinView];
        index++;
    }
    self.specialEffectsView = [self imageViewWithImageName:@"moment_record_special_effects"
                                                     title:@"特效滤镜"
                                                     index:index
                                                    selStr:@"didTapSpecialEffectsView"];
    [self addSubview:self.specialEffectsView];
    
    self.left = MDScreenWidth - kMDMediaEditorRightViewIconWidth - kMDMediaEditorRightViewRightMargin;
    self.size = CGSizeMake(kMDMediaEditorRightViewIconWidth, self.specialEffectsView.bottom);
    
    if ([self.tipsManager canShowRedPointWithIdentifier:kRecordTipOfVideoEditThin]) {
        UIImageView *redPointView = [self redPointViewLeft:(_thinView.width - 18) withTag:kViewRedPointTag];
        [_thinView addSubview:redPointView];
    }
    if ([self.tipsManager canShowRedPointWithIdentifier:kRecordTipOfSpecialEffects]) {
        UIImageView *redPointView = [self redPointViewLeft:(self.specialEffectsView.width - 18) withTag:kViewRedPointTag];
        [self.specialEffectsView addSubview:redPointView];
    }
}

#pragma mark - public

- (CGRect)absoluteFrameOfThinView
{
    CGRect absoluteFrame = CGRectZero;
    absoluteFrame = [self convertRect:self.thinView.frame toView:[MDRecordContext appWindow]];
    return absoluteFrame;
}
- (CGRect)absoluteFrameOfSpecialEffectsView
{
    CGRect absoluteFrame = CGRectZero;
    absoluteFrame = [self convertRect:self.specialEffectsView.frame toView:[MDRecordContext appWindow]];
    return absoluteFrame;
}

#pragma mark - event

- (void)didTapThinView
{
    UIView *redPointView = [self.thinView viewWithTag:kViewRedPointTag];
    if (redPointView) {
        [redPointView removeFromSuperview];
        [self.tipsManager redPointDidShowWithIdentifier:kRecordTipOfVideoEditThin];
    }
    if ([self.delegate respondsToSelector:@selector(didTapThinView:)]) {
        [self.delegate didTapThinView:self.thinView];
    }
}

- (void)didTapSpecialEffectsView
{
    UIView *redPointView = [self.specialEffectsView viewWithTag:kViewRedPointTag];
    if (redPointView) {
        [redPointView removeFromSuperview];
        [self.tipsManager redPointDidShowWithIdentifier:kRecordTipOfSpecialEffects];
    }
    if ([self.delegate respondsToSelector:@selector(didTapSpecialEffectsView:)]) {
        [self.delegate didTapSpecialEffectsView:self.specialEffectsView];
    }
}

#pragma mark - private

- (MDUnifiedRecordIconView *)imageViewWithImageName:(NSString *)imageName
                                              title:(NSString *)title
                                              index:(NSInteger)index
                                             selStr:(NSString *)selStr
{
    return [self imageViewWithImageName:imageName title:title index:index selStr:selStr needScrollTitle:NO];
}

- (MDUnifiedRecordIconView *)imageViewWithImageName:(NSString *)imageName
                                              title:(NSString *)title
                                              index:(NSInteger)index
                                             selStr:(NSString *)selStr
                                    needScrollTitle:(BOOL)needScrollTitle {
    CGFloat top = (kMDMediaEditorRightViewIconWidth + kMarginHeight) * index;
    CGRect frame = CGRectMake(0, top, kMDMediaEditorRightViewIconWidth, kMDMediaEditorRightViewIconWidth);
    MDUnifiedRecordIconView *iconView = [[MDUnifiedRecordIconView alloc] initWithFrame:frame imageName:imageName title:title needScrollTitle:needScrollTitle target:self action:NSSelectorFromString(selStr)];
    return iconView;
}

- (UIImageView *)redPointViewLeft:(CGFloat)left withTag:(NSUInteger)tag {
    UIImageView *redPointView = [[UIImageView alloc] initWithFrame:CGRectMake(left, 0, 8, 8)];
    redPointView.tag = tag;
    UIImage *img = [UIImage imageWithColor:[UIColor redColor] finalSize:CGSizeMake(8, 8)];
    img = [img clipCircle];
    redPointView.image = img;
    return redPointView;
}


@end
