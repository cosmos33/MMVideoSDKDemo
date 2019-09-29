//
//  MDRecordEditContainerPanelView.m
//  MomoChat
//
//  Created by RFeng on 2019/4/8.
//  Copyright © 2019年 wemomo.com. All rights reserved.
//

#import "MDRecordEditContainerPanelView.h"
#import "MDRecordEditTItleView.h"
#import "MDRecordEditFuntionButtonView.h"
//#import "MDRecordEditGraffitiView.h"
#import "UIConst.h"
#import "UIView+Utils.h"
#import "MDRecordContext.h"

@interface MDRecordEditContainerPanelView()

@property (nonatomic, strong, readonly) UIView *stickersEditView; // 贴纸

@property (nonatomic, strong, readonly) UIView *graffitiToolView;


@property (nonatomic, strong, readonly) UIView * filterEditView;

@property (nonatomic, strong) MDRecordEditTItleView *titleView;

@property (nonatomic, strong) UIView * editView;

@property (nonatomic, strong) MDRecordEditFuntionButtonView *funtionView;

@end

@implementation MDRecordEditContainerPanelView




+ (MDRecordEditContainerPanelView *)editPanelView
{
    MDRecordEditContainerPanelView *editPanel = [[MDRecordEditContainerPanelView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, 45 + HOME_INDICATOR_HEIGHT)];
    return editPanel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}


- (void)layoutUI
{

    [self addSubview:self.funtionView];
    self.funtionView.bottom = self.bottom;
}

- (void)updatePanelWithEditView:(UIView *)editView
{
   
    if (editView != self.editView) {
        CGFloat height =  self.funtionView.height + self.editView.height;
        
        if ([self.animationDelegate respondsToSelector:@selector(animationWillStartToChangePanelHeight:)]) {
            [self.animationDelegate animationWillStartToChangePanelHeight:height];
        }
        
        CGFloat bottom = self.bottom;
        editView.top = self.funtionView.top;
        [self insertSubview:editView belowSubview:self.funtionView];
        [UIView animateWithDuration:0.25 animations:^{
            self.editView.top = self.funtionView.bottom;
            editView.top = self.funtionView.top - editView.height;
            self.height = self.funtionView.height + editView.height;
            editView.top = 0;
            self.funtionView.bottom = self.height;
            self.bottom = bottom ;
            if ([self.animationDelegate respondsToSelector:@selector(animationInProgressTochangePanelHeight:)]) {
                [self.animationDelegate animationInProgressTochangePanelHeight:height];
            }
        } completion:^(BOOL finished) {
            self.editView.top = self.funtionView.bottom;
            [self.editView removeFromSuperview];
            editView.top = self.funtionView.top - editView.height;
            self.editView = editView;
            self.height = self.funtionView.height + self.editView.height;
            self.editView.top = 0;
            self.funtionView.bottom = self.height;
            self.bottom = bottom;
            
            if ([self.animationDelegate respondsToSelector:@selector(animationDidFinsh:panelHeight:)]) {
                [self.animationDelegate animationDidFinsh:finished panelHeight:height];
            }
            if (editView != nil) {
                [self.funtionView setBgViewHiden:NO];
            }else{
                [self.funtionView setBgViewHiden:YES];
            }
        }];
    }

}


- (MDRecordEditFuntionButtonView *)funtionView
{
    if (!_funtionView) {
        __weak typeof(self) weakself = self;
        _funtionView = [[MDRecordEditFuntionButtonView alloc] initWithButtonWithType:MDRecordEditFuntionFilter|MDRecordEditFuntionGraffiti|MDRecordEditFuntionStickers|MDRecordEditFuntionWord tapFuntionBlock:^(MDRecordEditFuntionType funtionType) {
            [weakself funtionWithType:funtionType];
        } frame:CGRectMake(0, 0, MDScreenWidth, 45 + HOME_INDICATOR_HEIGHT)];
    }
    return _funtionView;
}

- (void)funtionWithType:(MDRecordEditFuntionType)type
{
    switch (type) {
        case MDRecordEditFuntionStickers:
        // 点击贴纸
            [self updatePanelWithEditView:self.stickersEditView];
            if ([self.delegate respondsToSelector:@selector(showEmationStickersPanel)]) {
                [self.delegate showEmationStickersPanel];
            }
            break;
        case MDRecordEditFuntionGraffiti:
            [self updatePanelWithEditView:self.graffitiToolView];
            if ([self.delegate respondsToSelector:@selector(showGrafftieEditPanel)]) {
               [self.delegate showGrafftieEditPanel];
            }
            break;
        case MDRecordEditFuntionWord:
            [self updatePanelWithEditView:nil];
            if ([self.delegate respondsToSelector:@selector(showTextStickers)]) {
                [self.delegate showTextStickers];
            }

            break;
        case MDRecordEditFuntionFilter: // 滤镜
            [self updatePanelWithEditView:self.filterEditView];
            if ([self.delegate respondsToSelector:@selector(showFilterPanel)]) {
                [self.delegate showFilterPanel];
            }
            break;
        default:
            break;
    }
}

- (UIView *)stickersEditView
{

    if ([self.delegate respondsToSelector:@selector(stickersEditView)]) {
        return (id)self.delegate.stickersEditView;
    }
    
    return nil;
}

-(UIView *)graffitiToolView
{
    if ([self.delegate respondsToSelector:@selector(graffitiEditView)]) {
        return self.delegate.graffitiEditView;
    }

    return nil;
}

-(UIView *)filterEditView
{
    if ([self.delegate respondsToSelector:@selector(filterEditView)]) {
        return self.delegate.filterEditView;
    }
    return nil;
}


- (void)funtionConsolidate
{
    [self updatePanelWithEditView:nil];
    self.funtionView.selectButton.selected = NO;
    self.funtionView.selectButton = nil;
}


@end
