//
//  MDRecordBeautySettingDataManager.h
//  MDChat
//
//  Created by YZK on 2018/5/7.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class CXBeautyConfiguration;

@interface MDRecordBeautySettingDataManager : NSObject

@property (nonatomic, strong, readonly) CXBeautyConfiguration *beautyConfiguration;
@property (nonatomic, strong, readonly) NSDictionary *beautySettingsDic;

- (CGFloat)realValueWithIndex:(NSInteger)index beautySettingTypeStr:(NSString *)typeStr;
- (NSInteger)indexWithRealValue:(CGFloat)realValue beautySettingTypeStr:(NSString *)typeStr;

- (BOOL)canUseAIBeautySetting;
- (BOOL)isCXMakeupBundleExist;
// 是否可以使用瘦身
- (BOOL)canUseBodyThinSetting;
// 是否可以使用长腿
- (BOOL)canUseLongLegSetting;

@end
