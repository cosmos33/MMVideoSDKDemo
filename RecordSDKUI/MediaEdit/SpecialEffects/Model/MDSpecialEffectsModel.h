//
//  MDSpecialEffectsModel.h
//  BlockTest
//
//  Created by litianpeng on 2018/8/7.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDSpecialEffectsLayer.h"

typedef NS_ENUM(NSInteger, MDRecordSpecialEffectsType){
    MDRecordSpecialEffectsTypeMirrImage = 1,///<四宫格
    MDRecordSpecialEffectsTypeRainWindow,   ///<雨窗
    MDRecordSpecialEffectsTypeShake,        ///<抖动
    MDRecordSpecialEffectsTypeSoulOut,      ///<灵魂出窍
    MDRecordSpecialEffectsTypeTVArtifact,   ///<故障
    MDRecordSpecialEffectsTypeDazzling,     ///<闪烁
    MDRecordSpecialEffectsTypeShadowing,    ///<VHS晃动
    MDRecordSpecialEffectsTypeHeartBeat,    ///<心跳
    MDRecordSpecialEffectsTypeBlack3,       ///<黑胶3格
    
    MDRecordSpecialEffectsTypeTimeNone = 100,    ///<无时间特效
    MDRecordSpecialEffectsTypeSlowMotion,        ///<慢动作
    MDRecordSpecialEffectsTypeQuickMotion,       ///<快动作
    MDRecordSpecialEffectsTypeRepeat,            ///<反复
    MDRecordSpecialEffectsTypeReverse,           ///<时间倒流
};

typedef NS_ENUM(NSInteger, MDRecordSpecialType){
    MDRecordSpecialTypeFilter,///<滤镜特效
    MDRecordSpecialTypeTime,///<时间特效
};


@interface MDSpecialEffectsModel : NSObject
@property (nonatomic, copy) NSString *effectsTitle;
@property (nonatomic, copy) NSString *effectsImageName;
@property (nonatomic, assign) MDRecordSpecialEffectsType type;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, assign) BOOL isSelect;

@end
