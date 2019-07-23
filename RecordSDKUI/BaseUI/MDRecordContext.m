//
//  MDRecordContext.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/1/31.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordContext.h"
#import "MDRecordMacro.h"
#import "MDFaceDecorationManager.h"

static float _systemVersionFloat;
static MDFaceDecorationManager  *_faceDecorationManager;
static NSArray *_musicCatgary;
static NSDictionary *_beautySettingsDic;
static MDRecordBeautySettingDataManager *_beautySettingDataManager;
static NSInteger _assetViewShowCount;

@implementation MDRecordContext

+ (CGFloat)homeIndicatorHeight
{
    static CGFloat height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (IS_IPHONE_X) {
            height = 34.f;
        } else {
            height = 0.f;
        }
    });
    return height;
}

+ (CGFloat)statusBarHeight
{
    static CGFloat height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (IS_IPHONE_X) {
            height = 44.f;
        } else {
            height = 20.f;
        }
    });
    return height;
    //    return CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
}

+ (CGFloat)onePX
{
    static CGFloat onePx;
    static dispatch_once_t onceToke;
    dispatch_once(&onceToke, ^{
        onePx = 1.f / [UIScreen mainScreen].scale;
    });
    return onePx;
}

+ (NSString *)recordSDKUIVersion {
    return @"11890";
}

+ (BOOL)is32bit
{
#if defined(__LP64__) && __LP64__
    return NO;
#else
    return YES;
#endif
}

+ (float)systemVersion
{
    if (!_systemVersionFloat) {
        _systemVersionFloat = [[[UIDevice currentDevice] systemVersion] floatValue];
    }
    
    return _systemVersionFloat;
}

+ (NSString *)formatRemainSecondToStardardTime:(NSTimeInterval)second {
    NSString *durStr = @"";
    if (second > 0) {
        static const NSInteger h = 3600;
        static const NSInteger m = 60;
        
        NSUInteger time = roundf(second);
        
        NSInteger hour = MAX(0, time / h);
        NSInteger min = MAX(0, time % h / m);
        NSInteger sec = MAX(0, time % m);
        
        NSString *secStr = (sec < 10) ? [NSString stringWithFormat:@"0%@", @(sec)] : [NSString stringWithFormat:@"%@", @(sec)];
        NSString *minStr = (min < 10) ? [NSString stringWithFormat:@"0%@", @(min)] : [NSString stringWithFormat:@"%@", @(min)];
        NSString *hourStr = @"";
        if (hour > 0) {//小于1小时不展示hour
            hourStr = (hour < 10) ? [NSString stringWithFormat:@"0%@", @(hour)] : [NSString stringWithFormat:@"%@", @(hour)];
        }
        durStr = [hourStr isNotEmpty] ? [NSString stringWithFormat:@"%@:%@:%@", hourStr, minStr, secStr] : [NSString stringWithFormat:@"%@:%@", minStr, secStr];
    }
    return durStr;
}

+ (UIWindow *)appWindow {
    return [UIApplication sharedApplication].delegate.window;
}

+ (NSString *)generateLongUUID
{
    NSString *result = [[NSUUID UUID] UUIDString];
    return result;
}

+ (MDFaceDecorationManager *)faceDecorationManager
{
    if (!_faceDecorationManager) {
        _faceDecorationManager = [[MDFaceDecorationManager alloc] init];
    }
    
    return _faceDecorationManager;
}

+ (NSString *)videoTmpPath {
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *dir = [homePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [MDRecordContext recordSDKUIVersion]]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        NSError *error = nil;
        BOOL rst = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rst) {
            NSLog(@"error = %@", error);
        }
    }
    return [dir stringByAppendingPathComponent:@"tmp.mp4"];
}

+ (NSString *)videoTmpPath2 {
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *dir = [homePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [MDRecordContext recordSDKUIVersion]]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        NSError *error = nil;
        BOOL rst = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rst) {
            NSLog(@"error = %@", error);
        }
    }
    return [dir stringByAppendingPathComponent:@"tmp2.mp4"];
}

+ (NSString *)imageTmpPath {
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *dir = [homePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [MDRecordContext recordSDKUIVersion]]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        NSError *error = nil;
        BOOL rst = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rst) {
            NSLog(@"error = %@", error);
        }
    }
    return [dir stringByAppendingPathComponent:@"tmp.jpg"];
}

+ (NSArray *)musicCatgary {
    return _musicCatgary;
}

+ (void)setMusicCatgary:(NSArray *)musics {
    _musicCatgary = musics;
}

+ (void)setBeautySetting:(NSDictionary *)beautySetting {
    _beautySettingsDic = [beautySetting copy];
}

- (NSDictionary *)beautySetting {
    return _beautySettingsDic;
}

+ (MDRecordBeautySettingDataManager *)beautySettingDataManager {
    if (!_beautySettingDataManager) {
        _beautySettingDataManager = [[MDRecordBeautySettingDataManager alloc] init];
    }
    return _beautySettingDataManager;
}

+ (NSInteger)assetViewShowCount {
    return _assetViewShowCount;
}

+ (void)setAssetViewShowCount:(NSInteger)assetViewShowCount {
    _assetViewShowCount = assetViewShowCount;
}

@end
