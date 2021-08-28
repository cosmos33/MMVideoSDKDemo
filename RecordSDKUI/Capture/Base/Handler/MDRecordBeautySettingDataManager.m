//
//  MDRecordBeautySettingDataManager.m
//  MDChat
//
//  Created by YZK on 2018/5/7.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDRecordBeautySettingDataManager.h"
#import "MDBeautySettings.h"
#import "MDRecordHeader.h"

#import <MetalPetal/MetalPetal.h>

#define kBeautySettingBasePath  [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/filters/beautySetting"]


@interface MDRecordBeautySettingDataManager ()

@property (nonatomic,strong) NSMutableSet *urlStrSet;
@property (nonatomic,strong) NSString *path;

@property (nonatomic, strong) NSDictionary *beautySettingsDic;

@end

@implementation MDRecordBeautySettingDataManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.urlStrSet = [NSMutableSet set];
        [self getBeautySettingLevel];
    }
    return self;
}


static NSArray * kMDBeautySettingsSkinSmoothingLevels;
static NSArray * kMDBeautySettingsSkinWhitenLevels;
static NSArray * kMDBeautySettingsEyesEnhancementLevels;
static NSArray * kMDBeautySettingsFaceThinningLevels;
static NSArray * kMDBeautySettingsBodyThinningLevels;
static NSArray * kMDBeautySettingsLegLongerLevels;
- (void)getBeautySettingLevel {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kMDBeautySettingsSkinSmoothingLevels = @[@0,@20,@40,@60,@80,@100];
        kMDBeautySettingsSkinWhitenLevels = @[@0,@20,@40,@65,@80,@100];
        kMDBeautySettingsEyesEnhancementLevels = @[@0,@10,@20,@35,@45,@65];
        kMDBeautySettingsFaceThinningLevels = @[@0,@10,@20,@35,@55,@70];
        kMDBeautySettingsBodyThinningLevels = @[@0,@20,@40,@60,@80,@100];
        kMDBeautySettingsLegLongerLevels = @[@0,@30,@50,@60,@80,@100];
    });
}

- (CGFloat)realValueWithIndex:(NSInteger)index beautySettingTypeStr:(NSString *)typeStr
{
    CGFloat result = 0.f;
    
    if ([typeStr isEqualToString:MDBeautySettingsSkinSmoothingAmountKey]) {          //磨皮
        
        NSArray *numberArray = kMDBeautySettingsSkinSmoothingLevels;
        result = [[numberArray objectAtIndex:index defaultValue:0] floatValue];
        
    } else if ([typeStr isEqualToString:MDBeautySettingsSkinWhitenAmountKey]) {      //美白
        if ([self canUseAIBeautySetting]) {
            NSArray *numberArray = kMDBeautySettingsSkinWhitenLevels;
            result = [[numberArray objectAtIndex:index defaultValue:0] floatValue];
        }else {
            result = 0;
        }
        
    } else if ([typeStr isEqualToString:MDBeautySettingsEyesEnhancementAmountKey]) { //大眼
        NSArray *numberArray = kMDBeautySettingsEyesEnhancementLevels;
        result = [[numberArray objectAtIndex:index defaultValue:0] floatValue];
        
    } else if ([typeStr isEqualToString:MDBeautySettingsFaceThinningAmountKey]) {    //瘦脸
        
        NSArray *numberArray = kMDBeautySettingsFaceThinningLevels;
        result = [[numberArray objectAtIndex:index defaultValue:0] floatValue];
    } else if ([typeStr isEqualToString:MDBeautySettingsThinBodyAmountKey]) {// 瘦身
        if ([self canUseBodyThinSetting]) {
            NSArray *numberArray = kMDBeautySettingsBodyThinningLevels;
            result = [[numberArray objectAtIndex:index defaultValue:@(-1)] floatValue];
        }
    } else if ([typeStr isEqualToString:MDBeautySettingsLongLegAmountKey]) {// 长腿
        if ([self canUseLongLegSetting]) {
            NSArray *numberArray = kMDBeautySettingsLegLongerLevels;
            result = [[numberArray objectAtIndex:index defaultValue:@(-1)] floatValue];
        }
    }
    return result / 100.0;
}

- (NSInteger)indexWithRealValue:(CGFloat)realValue beautySettingTypeStr:(NSString *)typeStr
{
    NSInteger index = 0;
    NSInteger levelValue = (NSInteger)round(realValue*100.0);
    NSArray *numberArray = nil;
    if ([typeStr isEqualToString:MDBeautySettingsSkinSmoothingAmountKey]) {          //磨皮
        numberArray = kMDBeautySettingsSkinSmoothingLevels;
        
    } else if ([typeStr isEqualToString:MDBeautySettingsSkinWhitenAmountKey]) {      //美白
        if ([self canUseAIBeautySetting]) {
            numberArray = kMDBeautySettingsSkinWhitenLevels;
        }
        
    } else if ([typeStr isEqualToString:MDBeautySettingsEyesEnhancementAmountKey]) { //大眼
        numberArray = kMDBeautySettingsEyesEnhancementLevels;
        
    } else if ([typeStr isEqualToString:MDBeautySettingsFaceThinningAmountKey]) {    //瘦脸
        
        numberArray = kMDBeautySettingsFaceThinningLevels;
    } else if ([typeStr isEqualToString:MDBeautySettingsThinBodyAmountKey]) {// 瘦身
        if ([self canUseBodyThinSetting]) {
            numberArray = kMDBeautySettingsBodyThinningLevels;
        }
    } else if ([typeStr isEqualToString:MDBeautySettingsLongLegAmountKey]) {// 长腿
        if ([self canUseLongLegSetting]) {
            numberArray = kMDBeautySettingsLegLongerLevels;
        }
    }
    index = [numberArray indexOfObject:@(levelValue)];
    if (index == NSNotFound) {
        index = 0;
    }
    return index;
}


//是否可以使用AI美颜
- (BOOL)canUseAIBeautySetting {
    if (@available(iOS 10.0, *)) {
        if ([MTIContext defaultMetalDeviceSupportsMPS]) {
            BOOL canUse = YES; //[[MDContext currentUser].dbStateHoldProvider canUseAIBeautySetting];
            return canUse;
        }
    }
    return NO;
}

// 是否可以使用瘦身
- (BOOL)canUseBodyThinSetting {
    return YES;
}

// 是否可以使用长腿
- (BOOL)canUseLongLegSetting {
    return [self canUseBodyThinSetting];
}

- (BOOL)isCXMakeupBundleExist {
    return YES;
}

- (void)downloadCXMakeupBundleWithCompltion:(void (^)(BOOL))completion {
    completion(YES);
}


@end
