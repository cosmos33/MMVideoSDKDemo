//
//  MDRecordContext.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/1/31.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDRecordHeader.h"
#import "MDRecordBeautySettingDataManager.h"
@class MDFaceDecorationManager;

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordContext : NSObject

+ (CGFloat)homeIndicatorHeight;
+ (CGFloat)onePX;
+ (CGFloat)statusBarHeight;
+ (NSString *)recordSDKUIVersion;
+ (BOOL)is32bit;
+ (float)systemVersion;
+ (NSString *)formatRemainSecondToStardardTime:(NSTimeInterval)second;
+ (UIWindow *)appWindow;
+ (NSString *)generateLongUUID;
+ (MDFaceDecorationManager *)faceDecorationManager;
+ (NSString *)videoTmpPath;
+ (NSString *)videoTmpPath2;
+ (NSString *)imageTmpPath;

+ (NSArray *)musicCatgary;
+ (void)setMusicCatgary:(NSArray *)musics;

+ (void)setBeautySetting:(NSDictionary *)beautySetting;
- (NSDictionary *)beautySetting;
+ (MDRecordBeautySettingDataManager *)beautySettingDataManager;

+ (void)setAssetViewShowCount:(NSInteger)assetViewShowCount;
+ (NSInteger)assetViewShowCount;

@end

NS_ASSUME_NONNULL_END
