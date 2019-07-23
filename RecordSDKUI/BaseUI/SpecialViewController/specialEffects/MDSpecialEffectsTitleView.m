//
//  MDSpecialEffectsTitleView.m
//  BlockTest
//
//  Created by litianpeng on 2018/8/7.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import "MDSpecialEffectsTitleView.h"
#import "MDRecordHeader.h"
#import "MDRecordContext.h"

@interface MDSpecialEffectsTitleView()
@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UIButton *timeBtn;
@property (nonatomic, strong) UIButton *revocationbtn;
@property (nonatomic, assign) BOOL revocationState;
@property (nonatomic, strong) UIView *moveLineView;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation MDSpecialEffectsTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.filterBtn];
        [self addSubview:self.timeBtn];
        [self addSubview:self.revocationbtn];
        [self addSubview:self.lineView];
        [self addSubview:self.moveLineView];
        self.revocationState = YES;
    }
    return self;
}
- (void)resetSelectTitleView{
    [self filterAction];
}
- (void)filterAction{
    if (self.filterBtn.selected) {
        return;
    }
    self.filterBtn.selected = YES;
    self.timeBtn.selected = NO;
    if (self.sendSelectFilterBlock) {
        self.sendSelectFilterBlock();
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.moveLineView.mj_x = self.filterBtn.left;
    }];
}
- (void)timeAction{
    //这里要隐藏撤销, 但是要记录上一次状态
    
    if (self.timeBtn.selected) {
        return;
    }
    self.filterBtn.selected = NO;
    self.timeBtn.selected = YES;
    if (self.sendSelectTimeBlock) {
        self.sendSelectTimeBlock();
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.moveLineView.mj_x = self.timeBtn.left;
    }];
}
- (void)revocationAction{
    if (self.sendRevocationBlock) {
        self.sendRevocationBlock();
    }
}
- (void)setRevocationBtnState:(BOOL)revocationBtnState{
    _revocationBtnState = revocationBtnState;
    self.revocationbtn.hidden = !revocationBtnState;
}

#pragma mark -- Lazy
- (UIButton *)revocationbtn{
    if(!_revocationbtn){
        _revocationbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_revocationbtn setFrame:CGRectMake(self.right-60-30, 0, 60, self.height)];
        [_revocationbtn addTarget:self action:@selector(revocationAction) forControlEvents:UIControlEventTouchUpInside];
        [_revocationbtn setTitle:@"撤销" forState:UIControlStateNormal];
        [_revocationbtn setImage:[UIImage imageNamed:@"specialEffects_titleView_revocation"] forState:UIControlStateNormal];
        [_revocationbtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _revocationbtn.hidden = YES;
    }
    return _revocationbtn;
}
- (UIButton *)filterBtn{
    if (!_filterBtn) {
        _filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_filterBtn setFrame:CGRectMake(28, 0, 60, self.height)];
        [_filterBtn addTarget:self action:@selector(filterAction) forControlEvents:UIControlEventTouchUpInside];
        [_filterBtn setTitle:@"画面特效" forState:UIControlStateNormal];
        [_filterBtn setTitleColor:RGBACOLOR(255, 255, 255, 0.3) forState:UIControlStateNormal];
        [_filterBtn setTitleColor:RGBCOLOR(255, 255, 255)  forState:UIControlStateSelected];
        _filterBtn.selected = YES;
        [_filterBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    }
    return _filterBtn;
}
- (UIButton *)timeBtn{
    if (!_timeBtn) {
        _timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeBtn setFrame:CGRectMake(self.filterBtn.right+30, 0, 60, self.height)];
        [_timeBtn addTarget:self action:@selector(timeAction) forControlEvents:UIControlEventTouchUpInside];
        [_timeBtn setTitle:@"时间特效" forState:UIControlStateNormal];
        [_timeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_timeBtn setTitleColor:RGBACOLOR(255, 255, 255, 0.3) forState:UIControlStateNormal];
        [_timeBtn setTitleColor:RGBCOLOR(255, 255, 255) forState:UIControlStateSelected];


    }
    return _timeBtn;
}
- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(self.filterBtn.left, self.height-[MDRecordContext onePX], self.width-2*self.filterBtn.left, self.filterBtn.left)];
        [_lineView setBackgroundColor:RGBACOLOR(255, 255, 255, 0.1)];
    }
    return _lineView;
}
- (UIView *)moveLineView{
    if (!_moveLineView) {
        _moveLineView = [[UIView alloc]initWithFrame:CGRectMake(28, self.height-3, self.filterBtn.width, 3)];
        [_moveLineView setBackgroundColor:[UIColor whiteColor]];
        
    }
    return _moveLineView;
}
@end
