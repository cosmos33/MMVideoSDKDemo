//
//  MDBeautySettings.h
//  MDChat
//
//  Created by jichuan on 2017/6/9.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <FaceDecorationKit/FDKDecoration.h>
#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const MDBeautySettingsSkinSmoothingAmountKey;
FOUNDATION_EXPORT NSString * const MDBeautySettingsEyesEnhancementAmountKey;
FOUNDATION_EXPORT NSString * const MDBeautySettingsFaceThinningAmountKey;
FOUNDATION_EXPORT NSString * const MDBeautySettingsSkinWhitenAmountKey;
FOUNDATION_EXPORT NSString * const MDBeautySettingsThinBodyAmountKey;
FOUNDATION_EXPORT NSString * const MDBeautySettingsLongLegAmountKey;

@interface MDBeautySettings : NSObject <NSSecureCoding, NSCopying>

@property (readonly) float skinSmoothingAmount;
@property (readonly) float eyesEnhancementAmount;
@property (readonly) float faceThinningAmount;
@property (readonly) float skinWhitenAmount;
@property (readonly) float thinBodyAmount;
@property (readonly) float longLegAmount;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (FDKDecoration *)makeDecoration;

- (void)updateDecorationBeautySetting:(FDKDecoration *)decoration;

@end
