//
//  MDSpecialEffectsView.h
//  BlockTest
//
//  Created by litianpeng on 2018/8/7.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "MDSpecialEffectsModel.h"

@interface MDSpecialEffectsView : UIView
@property (nonatomic, weak) AVPlayer *player;
@property (nonatomic, assign) CMTime assetDuration;

@property (nonatomic, weak) UIView *playerControlView;///<暂停开始view
@property (nonatomic, weak) UIImageView            *playButton;///<开始键

@property (nonatomic, copy) void (^sendRevocationSpecial)(void);///<回撤回调
@property (nonatomic, copy) void (^sendSelectTimeModel)(MDSpecialEffectsModel *model,CMTime currentTime);///<时间动效
@property (nonatomic, copy) void (^sendSelectSpecialModel)(MDSpecialEffectsModel *model,CMTime currentTime ,BOOL isStart);///<画面特效

- (id)initWithFrame:(CGRect)frame assetDuration:(CMTime)duration;
- (void)updateImageWithDataSource:(NSArray *)imageArray;

//播放
- (void)play;
- (void)pause;
- (void)seekToTime:(CMTime)time;
//重置所有动效
- (void)resetAllSpecialEffects;

+ (BOOL)cellLongPressShouldBegin;
@end
