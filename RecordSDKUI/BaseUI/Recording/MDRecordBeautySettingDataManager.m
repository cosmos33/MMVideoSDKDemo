//
//  MDRecordBeautySettingDataManager.m
//  MDChat
//
//  Created by YZK on 2018/5/7.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDRecordBeautySettingDataManager.h"
#import "MDBeautySettings.h"
#import "UIDevice-Hardware.h"
#import "MDRecordHeader.h"

@import CXBeautyKit;
@import MetalPetal;

#define kBeautySettingBasePath  [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/filters/beautySetting"]


@interface MDRecordBeautySettingDataManager ()

@property (nonatomic,strong) NSMutableSet *urlStrSet;
@property (nonatomic,strong) NSString *path;

@property (nonatomic, strong) CXBeautyConfiguration *beautyConfiguration;
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
        kMDBeautySettingsSkinWhitenLevels = @[@0,@20,@40,@60,@80,@100];
        kMDBeautySettingsEyesEnhancementLevels = @[@0,@10,@20,@35,@45,@65];
        kMDBeautySettingsFaceThinningLevels = @[@0,@10,@20,@35,@50,@70];
        kMDBeautySettingsBodyThinningLevels = @[@0,@20,@40,@60,@80,@100];
        kMDBeautySettingsLegLongerLevels = @[@0,@30,@50,@60,@80,@100];
    });
}

- (void)getBeautyConfigurationWithCompletion:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *jsonDict = nil;
        if ([self.path isNotEmpty] && [[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
            NSData *data = [NSData dataWithContentsOfFile:self.path];
            
            @try {
                jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
            } @catch (NSException *exception) {
            } @finally {
            }
        }
        
        if (jsonDict) {
            __weak typeof(self) weakSelf = self;
            [self downloadCXMakeupBundleWithCompltion:^(BOOL success) {
                if (success) {
                  CXBeautyConfiguration *config  = [CXBeautyConfiguration beautyConfigurationFromJSONObject:jsonDict error:nil];
                    weakSelf.beautyConfiguration = config;
                        if (completion) completion();
                    
                }
            }];
        }
    });
}

- (void)getBeautySettingLevelWithConfiguration:(CXBeautyConfiguration *)configuration {
    CGFloat skinSmoothingAmount = configuration.skinSmoothingSettings.amount;
    CGFloat eyesEnhancementAmount = configuration.faceAdjustments.eyeSize;
    CGFloat faceThinningAmount = configuration.faceAdjustments.thinFace;
    CGFloat bodyThinningAmout = 0.f;
    CGFloat longLegAmount = 0.f;
    
    NSInteger skinSmoothingLevel = [self indexWithRealValue:skinSmoothingAmount beautySettingTypeStr:MDBeautySettingsSkinSmoothingAmountKey];
    NSInteger eyesEnhancementLevel = [self indexWithRealValue:eyesEnhancementAmount beautySettingTypeStr:MDBeautySettingsEyesEnhancementAmountKey];
    NSInteger faceThinningLevel = [self indexWithRealValue:faceThinningAmount beautySettingTypeStr:MDBeautySettingsFaceThinningAmountKey];
    NSInteger bodyThinningLevel = [self indexWithRealValue:bodyThinningAmout beautySettingTypeStr:MDBeautySettingsThinBodyAmountKey];
    NSInteger longLegLevel = [self indexWithRealValue:longLegAmount beautySettingTypeStr:MDBeautySettingsLongLegAmountKey];
    
    self.beautySettingsDic = @{
                               MDBeautySettingsSkinSmoothingAmountKey:@(skinSmoothingLevel),
                               MDBeautySettingsSkinWhitenAmountKey:@(skinSmoothingLevel),
                               MDBeautySettingsEyesEnhancementAmountKey:@(eyesEnhancementLevel),
                               MDBeautySettingsFaceThinningAmountKey:@(faceThinningLevel),
                               MDBeautySettingsThinBodyAmountKey:@(bodyThinningLevel),
                               MDBeautySettingsLongLegAmountKey:@(longLegLevel),
                               };
    
    [MDRecordContext  setBeautySetting:self.beautySettingsDic];
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
