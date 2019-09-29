//
//  MDBeautySettings.m
//  MDChat
//
//  Created by jichuan on 2017/6/9.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDBeautySettings.h"
@import FaceDecorationKit.FDKBeautySettings;
#import <MMFoundation/MMFoundation.h>

NSString * const MDBeautySettingsSkinSmoothingAmountKey     = @"MDBeautySettingsSkinSmoothingAmountKey";
NSString * const MDBeautySettingsEyesEnhancementAmountKey   = @"MDBeautySettingsEyesEnhancementAmountKey";
NSString * const MDBeautySettingsFaceThinningAmountKey      = @"MDBeautySettingsFaceThinningAmountKey";
NSString * const MDBeautySettingsSkinWhitenAmountKey        = @"MDBeautySettingsSkinWhitenAmountKey";
NSString * const MDBeautySettingsThinBodyAmountKey          = @"MDBeautySettingsThinBodyAmountKey";
NSString * const MDBeautySettingsLongLegAmountKey           = @"MDBeautySettingsLongLegAmountKey";

@interface MDBeautySettings ()
@property (nonatomic) float skinSmoothingAmount;
@property (nonatomic) float eyesEnhancementAmount;
@property (nonatomic) float faceThinningAmount;
@property (nonatomic) float skinWhitenAmount;
@property (nonatomic) float thinBodyAmount;
@property (nonatomic) float longLegAmount;
@end

@implementation MDBeautySettings

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.skinSmoothingAmount) forKey:NSStringFromSelector(@selector(skinSmoothingAmount))];
    [aCoder encodeObject:@(self.faceThinningAmount) forKey:NSStringFromSelector(@selector(faceThinningAmount))];
    [aCoder encodeObject:@(self.eyesEnhancementAmount) forKey:NSStringFromSelector(@selector(eyesEnhancementAmount))];
    [aCoder encodeObject:@(self.skinWhitenAmount) forKey:NSStringFromSelector(@selector(skinWhitenAmount))];
    [aCoder encodeObject:@(self.thinBodyAmount) forKey:NSStringFromSelector(@selector(thinBodyAmount))];
    [aCoder encodeObject:@(self.longLegAmount) forKey:NSStringFromSelector(@selector(longLegAmount))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.skinSmoothingAmount = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(skinSmoothingAmount))] floatValue];
        self.faceThinningAmount = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(faceThinningAmount))] floatValue];
        self.eyesEnhancementAmount = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(eyesEnhancementAmount))] floatValue];
        self.skinWhitenAmount = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(skinWhitenAmount))] floatValue];
        self.thinBodyAmount = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(thinBodyAmount))] floatValue];
        self.longLegAmount = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(longLegAmount))] floatValue];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.skinSmoothingAmount = [dictionary floatForKey:MDBeautySettingsSkinSmoothingAmountKey defaultValue:0];
        self.faceThinningAmount = [dictionary floatForKey:MDBeautySettingsFaceThinningAmountKey defaultValue:0];
        self.eyesEnhancementAmount = [dictionary floatForKey:MDBeautySettingsEyesEnhancementAmountKey defaultValue:0];
        self.skinWhitenAmount = [dictionary floatForKey:MDBeautySettingsSkinWhitenAmountKey defaultValue:0];
        self.thinBodyAmount = [dictionary floatForKey:MDBeautySettingsThinBodyAmountKey defaultValue:0];
        self.longLegAmount = [dictionary floatForKey:MDBeautySettingsLongLegAmountKey defaultValue:0];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MDBeautySettings *settings = [[MDBeautySettings alloc] init];
    settings.skinSmoothingAmount = self.skinSmoothingAmount;
    settings.faceThinningAmount = self.faceThinningAmount;
    settings.eyesEnhancementAmount = self.eyesEnhancementAmount;
    settings.skinWhitenAmount = self.skinWhitenAmount;
    settings.thinBodyAmount = self.thinBodyAmount;
    settings.longLegAmount = self.longLegAmount;
    return settings;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if ([object isKindOfClass:[MDBeautySettings class]]) {
        MDBeautySettings *aObject = (MDBeautySettings *)object;
        return self.skinWhitenAmount == aObject.skinWhitenAmount && self.skinSmoothingAmount == aObject.skinSmoothingAmount && self.faceThinningAmount == aObject.faceThinningAmount && self.eyesEnhancementAmount == aObject.eyesEnhancementAmount && self.thinBodyAmount == aObject.thinBodyAmount && self.longLegAmount == aObject.longLegAmount;
    }
    return NO;
}

- (FDKDecoration *)makeDecoration {
    FDKDecoration *decoration = [[FDKDecoration alloc] init];
    [self updateDecorationBeautySetting:decoration];
    return decoration;
}

- (void)updateDecorationBeautySetting:(FDKDecoration *)decoration {
    decoration.beautySettings = [[FDKBeautySettings alloc] init];
    decoration.beautySettings.bigEyeFactor = self.eyesEnhancementAmount;
    decoration.beautySettings.thinFaceFactor = self.faceThinningAmount;
    decoration.beautySettings.skinSmoothingFactor = self.skinSmoothingAmount;
    decoration.beautySettings.skinWhitenFactor = self.skinWhitenAmount;
    decoration.beautySettings.bodyWidthFactor = self.thinBodyAmount;
    decoration.beautySettings.legsLenghtFactor = self.longLegAmount;
}

@end
