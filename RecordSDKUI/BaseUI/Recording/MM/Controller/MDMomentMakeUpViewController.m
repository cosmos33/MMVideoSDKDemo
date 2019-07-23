//
//  MDMomentFaceDecorationController.m
//  MDChat
//
//  Created by wangxuan on 16/8/19.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDMomentMakeUpViewController.h"
#import "MDFaceDecorationItem.h"
//#import "MDFaceDecorationView.h"
#import "MDFaceDecorationPageView.h"
#import "MDPublicSwiftHeader.h"

static const NSString *kMomentFaceDecorationCell = @"MDMomentFaceDecorationCell";

#define kFaceDecorationViewH (250 + HOME_INDICATOR_HEIGHT)

@interface MDMomentMakeUpViewController ()
<UIGestureRecognizerDelegate,
NewMakeupViewDelegate>

@property (nonatomic, strong) UIVisualEffectView          *effectView;
@property (nonatomic, strong) UIView                      *contentView;
@property (nonatomic, strong) NewMakeupView *newDecorationView;

@end

@implementation MDMomentMakeUpViewController

#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.hidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = CGRectMake(0, MDScreenHeight - kFaceDecorationViewH , MDScreenWidth, kFaceDecorationViewH);
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.effectView];
    [self.contentView addSubview:self.newDecorationView];
    
    [self.newDecorationView updateHasResourceWithHasResource:YES type:MakeupCellTypeDaily];
    [self.newDecorationView updateHasResourceWithHasResource:YES type:MakeupCellTypeClearwater];
    [self.newDecorationView updateHasResourceWithHasResource:YES type:MakeupCellTypeFreckle];
    [self.newDecorationView updateHasResourceWithHasResource:YES type:MakeupCellTypeLeizi];
}

- (void)dealloc {
}

#pragma mark - 显示 隐藏变脸抽屉View
- (BOOL)showAnimate
{
    if (self.isShowed || self.isAnimating) return NO;
    
    self.view.hidden = NO;
    self.show = YES;
    self.animating = YES;
    
    UIView* view = self.contentView;
    view.transform = CGAffineTransformMakeTranslation(0, view.height);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.animating = NO;
    }];
    
    return YES;
}

- (void)hideAnimateWithCompleteBlock:(void(^)(void))completeBlock
{
    if (!self.isShowed || self.isAnimating) return;

    self.view.hidden = NO;
    self.show = NO;
    self.animating = YES;
    
    UIView* view = self.contentView;
    view.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.25 animations:^{
        view.transform = CGAffineTransformMakeTranslation(0, view.height);
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
        self.animating = NO;
        if (completeBlock) {
            completeBlock();
        }
    }];
}

#pragma mark - lazy
- (UIView *)contentView {
    if(!_contentView){
        _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
        _contentView.height += 50;
    }
    return _contentView;
}

- (NewMakeupView *)newDecorationView {
    if (!_newDecorationView) {
        _newDecorationView = [[NewMakeupView alloc] initWithFrame:self.view.bounds];
        _newDecorationView.delegate = self;
    }
    return _newDecorationView;
}

- (UIVisualEffectView *)effectView {
    if(!_effectView) {
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _effectView.frame = self.contentView.bounds;
        _effectView.layer.cornerRadius = 10.0f;
        _effectView.layer.masksToBounds = YES;
    }
    return _effectView;
}

#pragma mark - NewMakeupViewDelegate Methods

- (void)selectedWithView:(NewMakeupView *)view type:(enum MakeupCellType)type {
    [self.delegate clickWithVC:self index:(int)type];
}

- (void)didClearWithView:(NewMakeupView *)view {
    [self.delegate clearWithVC:self];
}

@end
