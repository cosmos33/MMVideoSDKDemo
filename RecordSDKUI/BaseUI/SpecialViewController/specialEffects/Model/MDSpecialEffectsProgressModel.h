//
//  MDSpecialEffectsProgressModel.h
//  BlockTest
//
//  Created by litianpeng on 2018/8/8.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDSpecialEffectsLayer.h"
#import "MDSpecialEffectsModel.h"
#import <CoreMedia/CoreMedia.h>

@interface MDSpecialEffectsProgressModel : NSObject<NSCopying>
@property (nonatomic, assign) MDRecordSpecialEffectsType pictureType;///<记录当前画面特效
@property (nonatomic, assign) MDRecordSpecialEffectsType timeType;///<记录当前时间特效
@property (nonatomic, assign) CGRect colorRect;
@property (nonatomic, assign) CMTime startTime;
@property (nonatomic, assign) CMTime endTime;
@property (nonatomic, strong) UIColor *bgColor;
- (void)configDataWithModel:(MDSpecialEffectsModel *)model timeModel:(MDSpecialEffectsModel *)timeModel;
@end
