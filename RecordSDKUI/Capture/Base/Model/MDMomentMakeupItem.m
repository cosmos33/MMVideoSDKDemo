//
//  MDMomentMakeupItem.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/29.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDMomentMakeupItem.h"

@implementation MDMomentMakeupItem

- (NSString *)title {
    return @"无";
}

- (UIImage *)icon {
    return [UIImage imageNamed:@"icon_moment_revoke_select"];
}

- (NSURL *)rootPath {
    return [[NSBundle mainBundle] URLForResource:@"doki_res" withExtension:@"bundle"];
}

@end

// 日常
@implementation MDMomentMakeupDailyItem

- (NSString *)title {
    return @"日常";
}

- (UIImage *)icon {
    return [UIImage imageNamed:@"cell1"];
}

- (NSURL *)rootPath {
     return [[super rootPath] URLByAppendingPathComponent:@"daily"];
}

- (NSArray<NSURL *> *)items {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"daily.blush.0" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"daily.blush.1" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"daily.eye.0" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"daily.lips.1" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"daily.normal.0" isDirectory:YES]];
    return [array copy];
}

@end

// 少年感
@implementation MDMomentMakeupClearwaterItem

- (NSString *)title {
    return @"少年感";
}

- (UIImage *)icon {
    return [UIImage imageNamed:@"cell2"];
}

- (NSURL *)rootPath {
    return [[super rootPath] URLByAppendingPathComponent:@"clearwater"];
}

- (NSArray<NSURL *> *)items {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"clearwater.blush.0" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"clearwater.blush.1" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"clearwater.eyebrow.0" isDirectory:YES]];
    return [array copy];
}

@end

// 小雀斑
@implementation MDMomentMakeupFreckleItem

- (NSString *)title {
    return @"小雀斑";
}

- (UIImage *)icon {
    return [UIImage imageNamed:@"cell3"];
}

- (NSURL *)rootPath {
    return [[super rootPath] URLByAppendingPathComponent:@"freckle"];
}

- (NSArray<NSURL *> *)items {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"freckle.blush.0" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"freckle.eye.shadow" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"freckle.eyebrow.0" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"freckle.pupil.0" isDirectory:YES]];
    return [array copy];
}

@end

// 元气
@implementation MDMomentMakeupLeizhi

- (NSString *)title {
    return @"元气";
}

- (UIImage *)icon {
    return [UIImage imageNamed:@"cell4"];
}

- (NSURL *)rootPath {
    return [[super rootPath] URLByAppendingPathComponent:@"leizhi"];
}

- (NSArray<NSURL *> *)items {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"leizhi.blush.face" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"leizhi.eye.lash" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"leizhi.eye.light" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"leizhi.eye.shadow" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"leizhi.faceshadows.all" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"leizhi.lips.all" isDirectory:YES]];
    return [array copy];
}

@end

@implementation MDMomentMakeupTantanItem

- (NSString *)title {
    return @"探探";
}

- (UIImage *)icon {
    return [UIImage imageNamed:@"cell1"];
}

- (NSURL *)rootPath {
    return [[super rootPath] URLByAppendingPathComponent:@"makeup"];
}

- (NSArray<NSURL *> *)items {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"tantan.blush.sh" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"tantan.eye.yx" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"tantan.eye.yy" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"tantan.Eyebrow.mm" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"tantan.faceshadows.all" isDirectory:YES]];
    [array addObject:[[self rootPath] URLByAppendingPathComponent:@"tantan.lip.all" isDirectory:YES]];
    return [array copy];
}

@end
