//
//  MDSpecialEffectsProgressModel.m
//  BlockTest
//
//  Created by litianpeng on 2018/8/8.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import "MDSpecialEffectsProgressModel.h"

@implementation MDSpecialEffectsProgressModel
- (NSString *)description{
    return [NSString stringWithFormat:@" startTime-->%ld    endTime-->%ld    ColorRect-->%@  pictureType-->%ld",(long) CMTimeGetSeconds(self.startTime),(long)CMTimeGetSeconds(self.endTime),NSStringFromCGRect(self.colorRect),(long)self.pictureType];
}
- (id)copyWithZone:(NSZone *)zone{
    MDSpecialEffectsProgressModel *model = [[[self class] allocWithZone:zone] init];
    model.bgColor = self.bgColor;
    model.startTime = self.startTime;
    model.colorRect = self.colorRect;
    model.endTime = self.endTime;
    model.timeType = self.timeType;
    model.pictureType = self.pictureType;
    return model;
}

- (void)configDataWithModel:(MDSpecialEffectsModel *)model timeModel:(MDSpecialEffectsModel *)timeModel{
    self.bgColor = model.bgColor;
    self.pictureType = model.type;
    if (timeModel) {
        self.timeType = timeModel.type;
    }
    else{
        self.timeType = MDRecordSpecialEffectsTypeTimeNone;
    }
}
@end
