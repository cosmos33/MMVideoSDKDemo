//
//  MDSpecialEffectsSelectViewCollectionViewCell.m
//  BlockTest
//
//  Created by litianpeng on 2018/8/7.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import "MDSpecialEffectsSelectViewCollectionViewCell.h"
#import "MDSpecialEffectsView.h"
#import <YYImage/YYImage.h>
#import "MDRecordHeader.h"

@interface MDSpecialEffectsSelectViewCollectionViewCell() <UIGestureRecognizerDelegate>
@property (nonatomic, strong) YYAnimatedImageView *previewImageView;///<预览icon
@property (nonatomic, strong) UIImageView *coverImageView;///<时间特效选中后的蒙层
@property (nonatomic, strong) UILabel *previewLabel;///<标题
@property (nonatomic, strong) MDSpecialEffectsModel *model;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end
@implementation MDSpecialEffectsSelectViewCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.previewImageView];
        [self addSubview:self.previewLabel];
        [self addSubview:self.coverImageView];
        [self addGesture];
    }
    return self;
}

- (void)addGesture{
    self.longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longAction:)];
    self.longPress.minimumPressDuration = 0.3;
    self.longPress.delegate = self;
    [self addGestureRecognizer:self.longPress];
    
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:self.tapGesture];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.longPress) {
        return [MDSpecialEffectsView cellLongPressShouldBegin];
    }
    return YES;
}

- (void)tapAction{
    if (self.previewTap) {
        self.previewTap(self.model);
    }
}

- (void)longAction:(UILongPressGestureRecognizer *)press{
    if (press.state == UIGestureRecognizerStateBegan) {        
        self.previewImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        [self.previewLabel setTextColor:RGBACOLOR(255, 255, 255, 1)];

        if (self.previewPress) {
            self.previewPress(YES,self.model);
        }
    }
    else if (press.state == UIGestureRecognizerStateEnded ||
             press.state == UIGestureRecognizerStateCancelled ){
        self.previewImageView.transform = CGAffineTransformIdentity;
        [self.previewLabel setTextColor:RGBACOLOR(255, 255, 255, 0.3)];

        if (self.previewPress) {
            self.previewPress(NO,self.model);
        }
    }
}
- (void)updateCellWithModel:(MDSpecialEffectsModel *)model{
    self.model = model;
    //时间特效
    if (model.type >= MDRecordSpecialEffectsTypeTimeNone) {
        self.longPress.enabled = NO;
        self.tapGesture.enabled = YES;
    }
    else {
        self.longPress.enabled = YES;
        self.tapGesture.enabled = YES;
    }
    
    [self.previewLabel setText:model.effectsTitle];
    self.previewImageView.image = [UIImage imageNamed:@"specialEffects_example_place"];
    self.coverImageView.hidden = YES;
    
    
    [self.previewLabel setTextColor:RGBACOLOR(255, 255, 255, 0.3)];
    [self.previewImageView setTransform: CGAffineTransformIdentity];
    if (model.isSelect && model.type >= MDRecordSpecialEffectsTypeTimeNone) {
        [self.previewLabel setTextColor:RGBACOLOR(255, 255, 255, 1)];
        self.coverImageView.hidden = NO;
    }
}

- (YYAnimatedImageView *)previewImageView{
    if (!_previewImageView) {
        _previewImageView = [[YYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 28, 55, 55)];
        _previewImageView.centerX = self.width/2.0;
        _previewImageView.clipsToBounds = YES;
        [_previewImageView.layer setCornerRadius:self.coverImageView.height/2.0];
    }
    return _previewImageView;
}
- (UILabel *)previewLabel{
    if (!_previewLabel) {
        _previewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.previewImageView.bottom+13, self.width, 16)];
        [_previewLabel setTextColor:RGBACOLOR(255, 255, 255, 0.3)];
        [_previewLabel setTextAlignment:NSTextAlignmentCenter];
        [_previewLabel setFont:[UIFont systemFontOfSize:12]];
    }
    return _previewLabel;
}
- (UIImageView *)coverImageView{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc]initWithFrame:self.previewImageView.frame];
        _coverImageView.clipsToBounds = YES;
        [_coverImageView.layer setCornerRadius:self.coverImageView.height/2.0];
        [_coverImageView setImage:[UIImage imageNamed:@"specialeffect_time_selected"]];
        _coverImageView.hidden = YES;
    }
    return _coverImageView;
}
@end
