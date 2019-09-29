//
//  MDSpecialEffectsModel.m
//  BlockTest
//
//  Created by litianpeng on 2018/8/7.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import "MDSpecialEffectsModel.h"

@implementation MDSpecialEffectsModel
- (NSString *)description{
    return [NSString stringWithFormat:@" type-->%ld \n effectsTitle-->%@",(long)self.type,self.effectsTitle];
}
@end
