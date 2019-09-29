//
//  MDRecordNewMusicTrimView.m
//  MDRecordSDK
//
//  Created by wangxuefei on 2019/9/19.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordNewMusicTrimView.h"
#import "MDSMSelectIntervalProgressView.h"


@interface MDRecordNewMusicTrimView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *upperView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) MDSMSelectIntervalProgressView *trimView;

@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, assign) CGFloat startPercent;

@end

@implementation MDRecordNewMusicTrimView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI{
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.trimView];
    [self addSubview:self.upperView];
    
    [self.upperView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.upperView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.upperView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.upperView.widthAnchor constraintEqualToConstant:330].active = YES;
    
    
    [self.scrollView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.scrollView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.scrollView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.scrollView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;

    [self.trimView.leftAnchor constraintEqualToAnchor:self.scrollView.leftAnchor].active = YES;
    [self.trimView.rightAnchor constraintEqualToAnchor:self.scrollView.rightAnchor].active = YES;
    [self.trimView.centerYAnchor constraintEqualToAnchor:self.scrollView.centerYAnchor].active = YES;
    [self.trimView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor].active = YES;
    [self.trimView.heightAnchor constraintEqualToAnchor:self.scrollView.heightAnchor multiplier:0.8].active = YES;
    
    self.widthConstraint = [self.trimView.widthAnchor constraintEqualToAnchor:self.widthAnchor];
    self.widthConstraint.active = YES;
    
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, (self.bounds.size.width - self.upperView.bounds.size.width) / 2.0, 0, (self.bounds.size.width - self.upperView.bounds.size.width) / 2.0);
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    __weak typeof(self)weakSelf = self;
    [self currentPositionScrollView:scrollView callBack:^(CGFloat start, CGFloat end) {
        
        [weakSelf updateTrimViewStart:start end:end];
    }];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    __weak typeof(self)weakSelf = self;
    [self currentPositionScrollView:scrollView callBack:^(CGFloat start, CGFloat end) {
        
        [weakSelf updateTrimViewStart:start end:end];
        weakSelf.startPercent = start;
        
        [weakSelf.delegate valueChanged:weakSelf startPercent:start endPercent:end];
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(decelerate){
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    [self currentPositionScrollView:scrollView callBack:^(CGFloat start, CGFloat end) {
        
        [weakSelf updateTrimViewStart:start end:end];
        weakSelf.startPercent = start;
        
        [weakSelf.delegate valueChanged:weakSelf startPercent:start endPercent:end];
    }];
}


- (void)currentPositionScrollView:(UIScrollView *)scrollView callBack:(void(^)(CGFloat start,CGFloat end))callBack{
    CGFloat offsetX = scrollView.contentOffset.x + scrollView.contentInset.left;
    CGFloat startPercent = offsetX / scrollView.contentSize.width;
    CGFloat endPercent = (offsetX + self.upperView.bounds.size.width) / scrollView.contentSize.width;
    callBack(startPercent,endPercent);
}


- (void)updateTrimViewStart:(CGFloat)start end:(CGFloat)end{
    _trimView.beginValue = start < 0.0 ? 0.0 : start;
    _trimView.endValue = end > 1.0 ? 1.0 : end;
    _trimView.currentValue = _trimView.beginValue;
}


#pragma mark -set get方法

- (UIScrollView *)scrollView{
    if(_scrollView == nil){
        UIScrollView * scrollView = [[UIScrollView alloc]init];
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.layer.cornerRadius = 5;
        scrollView.delegate = self;
        scrollView.bounces = YES;
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (MDSMSelectIntervalProgressView *)trimView{
    if(_trimView == nil){
        MDSMSelectIntervalProgressView *trimView = [[MDSMSelectIntervalProgressView alloc]init];
        
        trimView.translatesAutoresizingMaskIntoConstraints = NO;
        trimView.backgroundColor = [UIColor clearColor];
        trimView.marginLineHightColor = [UIColor clearColor];
        trimView.marginLineColor = [UIColor clearColor];
        trimView.progressColor = [UIColor colorWithRed:0.0 green:156.0 / 255.0 blue:1.0 alpha:1.0];
        
        trimView.trackColor = [UIColor colorWithRed:0.0 green:253.0 / 255.0 blue:211.0 / 255.0 alpha:1.0];
        trimView.inactiveColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        trimView.selectAreaBgColor = [UIColor clearColor];
        trimView.disable = NO;
        trimView.beginValue = 0;
        trimView.currentValue = 0;
        trimView.endValue = 1;
        trimView.linePadding = 6;
        _trimView = trimView;
    }
    return _trimView;
}


- (UIView *)upperView{
    if(_upperView == nil){
        UIView *upperView = [[UIView alloc]init];
        upperView.translatesAutoresizingMaskIntoConstraints = NO;
        upperView.userInteractionEnabled = NO;
        upperView.backgroundColor = [UIColor blackColor];
        upperView.alpha = 0.21;
        upperView.layer.cornerRadius = 5;
        _upperView = upperView;
    }
    return _upperView;
}

- (void)setDuration:(CGFloat)duration{
    
    if(self.trimView.window == nil){
        return;
    }
    _duration = duration;
    _widthConstraint.active = NO;
    if(duration <= 15){
        _widthConstraint = [self.trimView.widthAnchor constraintEqualToAnchor:self.widthAnchor];
    }else{
        _widthConstraint = [self.trimView.widthAnchor constraintEqualToConstant:duration * 22.0];
    }
    _widthConstraint.active = YES;
    [self.trimView layoutIfNeeded];
}

- (void)setDisable:(BOOL)disable{
    _disable = disable;
    _scrollView.userInteractionEnabled = !disable;
    _trimView.disable = disable;
}

- (void)setBeginTime:(CGFloat)beginTime{
    _startPercent = _duration > 0 ? beginTime / _duration : 0;
    _scrollView.contentOffset = CGPointMake(_startPercent * _scrollView.contentSize.width - _scrollView.contentInset.left, 0);
    [self updateTrimViewStart:_startPercent end:(_duration > 0 ? (beginTime + 15) / _duration : 0)];
}

- (CGFloat)beginTime{
    return _startPercent * _duration;
}

- (void)setCurrentValue:(CGFloat)currentValue{
    _trimView.currentValue = currentValue;
}

- (CGFloat)currentValue{
    return _trimView.currentValue;
}

@end
