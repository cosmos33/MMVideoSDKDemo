//
//  MDSpecialEffectsView.h
//  BlockTest
//
//  Created by litianpeng on 2018/8/6.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDSpecialEffectsProgressModel.h"


@interface MDSpecialEffectsProgressView : UIView
@property (nonatomic, strong) MDSpecialEffectsModel *currentTimeEffectsModel;///<时间特效
@property (nonatomic, strong) MDSpecialEffectsProgressModel *currentPictureEffectsModel;///<当前画面效果
@property (nonatomic, assign) CMTime allTime;
@property (nonatomic, assign) CMTime currentTime;///<当前进度

@property (nonatomic, copy) void (^sendMoveBtnProgress)(CMTime date);///<当前进度回调
@property (nonatomic, copy) void (^sendTimeBtnProgress)(CMTime date);///<时间特效进度回调
- (id)initWithFrame:(CGRect)frame type:(MDRecordSpecialType)type;
- (CMTime)revocationLastSpecialEffects;
- (void)updateImageWithDataSource:(NSArray *)dataSource;
- (BOOL)existSpecialModel;

//清除所有特效
- (void)resetAllEffects;
//更新当前进度
- (void)updateCurrentTime:(CMTime)currentTime;
//长按画面特效开始
- (void)startPressStateWithCurrentTime:(CMTime)currentTime currentModel:(MDSpecialEffectsModel *)model;
//长按画面特效结束
- (BOOL)endPressStateWithCurrentTime:(CMTime)currentTime;

//时间特效在修改进度的时候进度条是不可点的
- (void)updateTimeSpecialSliderState:(BOOL)isEnable;

//时间特效, 修改暂停键位置
- (void)updateTimeSpecialSliderProgress:(CMTime)currentTime isHidden:(BOOL)isHidden;

//更新时光倒流状态
- (void)updateReverseLayerState:(BOOL)isHidden bgColor:(UIColor *)bgColor;


@end
