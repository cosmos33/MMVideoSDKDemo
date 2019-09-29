//
//  MDTimeEffectsManager.h
//  MDChat
//
//  Created by litianpeng on 2018/8/13.
//  Copyright © 2018年 sdk.com. All rights reserved.
//
/*
 这个类只用了寄存各个时间特效的添加的时间
 */
#import <Foundation/Foundation.h>
#import "MDSpecialEffectsModel.h"
#import <CoreMedia/CoreMedia.h>

@interface MDEffectsTimeManager : NSObject
@property (nonatomic, assign) CMTime assetDuration;
@property (nonatomic, assign) CMTime repeatTime;///<反复时间
@property (nonatomic, assign) CMTime slowTime;///<慢动作时间
@property (nonatomic, assign) CMTime reverseTime;///<时光倒流
@property (nonatomic, assign) CMTime quickTime;///<快动作时间
@property (nonatomic, assign) MDRecordSpecialEffectsType currentTimeEffect;///<当前时间特效
- (void)configDefaultValue:(CMTime )duration;
- (CMTime)getTimeWithType:(MDRecordSpecialEffectsType )type;
- (void)saveTimeWithType:(MDRecordSpecialEffectsType )type date:(CMTime)date;
- (void)resetDefultTime;


@end
