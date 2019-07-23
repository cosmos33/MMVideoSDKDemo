//
//  MDSpecialEffectsManager.h
//  MDChat
//
//  Created by YZK on 2018/8/8.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDSpecialEffectsModel.h"
#import <GPUImage/GPUImageOutput.h>
#import <GPUImage/GPUImageContext.h>
#import <RecordSDK/MDRSpecialFilterLifeStyleProtocol.h>

@interface MDRecordSpecialEffectsManager : NSObject

+ (GPUImageOutput<GPUImageInput,MDRSpecialFilterLifeStyleProtocol> *)getFilterWithSpecialEffectsType:(MDRecordSpecialEffectsType)type;
+ (MDRecordSpecialEffectsType)getSpecialEffectsTypeWithFilter:(GPUImageOutput<GPUImageInput,MDRSpecialFilterLifeStyleProtocol> *)filter;

+ (NSArray<MDSpecialEffectsModel*> *)getSpecialEffectsFilterModelArray;
+ (NSArray<MDSpecialEffectsModel*> *)getSpecialEffectsTimeModelArray;

@end
