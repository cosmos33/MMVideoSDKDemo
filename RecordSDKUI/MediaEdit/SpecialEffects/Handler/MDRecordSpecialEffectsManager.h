//
//  MDSpecialEffectsManager.h
//  MDChat
//
//  Created by YZK on 2018/8/8.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDSpecialEffectsModel.h"
#import <RecordSDK/MMVideoSDK-umbrella.h>

@interface MDRecordSpecialEffectsManager : NSObject

+ (MDRecordSpecialEffectsType)getSpecialEffectsTypeWithMFilter:(id<MDRTimeFilter>)filter;
+ (id<MDRTimeFilter>)getMFilterWithSpecialEffectsType:(MDRecordSpecialEffectsType)type;

+ (NSArray<MDSpecialEffectsModel*> *)getSpecialEffectsFilterModelArray;
+ (NSArray<MDSpecialEffectsModel*> *)getSpecialEffectsTimeModelArray;

@end
