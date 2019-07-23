//
//  MDVideoBackgroundMusicManager.m
//  RecordSDK
//
//  Created by wangxuan on 17/2/20.
//  Copyright © 2017年 RecordSDK. All rights reserved.
//

#import "MDVideoBackgroundMusicManager.h"

@interface MDVideoBackgroundMusicManager ()

@end

@implementation MDVideoBackgroundMusicManager

#pragma mark - life
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}

#pragma mark - public
+ (NSString *)getLocalMusicResourcePathWithItem:(MDBeautyMusic *)musicItem {
    NSString *localPath = nil;
    if ([[self class] existResourceWithItem:musicItem]) {
        localPath = [[self class] resourcePathWithItem:musicItem];
    }
    return localPath;
}

#pragma mark - file
+ (NSString *)resourcePathWithItem:(MDBeautyMusic *)item {
    NSString *extensionStr = @"";
    NSArray *array = [item.m_remoteUrl componentsSeparatedByString:@"?"]; //从字符A中分隔成2个元素的数组
    if (array.count) {
        extensionStr = [array.firstObject pathExtension];
    } else {
        extensionStr = [item.m_remoteUrl pathExtension];
    }
    NSString *name = [NSString stringWithFormat:@"%@.%@",item.m_musicID,extensionStr];
    NSString *path = kVideoBackgroundMusicPath;
    NSString *resourcePath = [path stringByAppendingPathComponent:name];
    return resourcePath;
}

+ (BOOL)existResourceWithItem:(MDBeautyMusic *)item {
    NSString *resourcePath = [self resourcePathWithItem:item];
    return [[NSFileManager defaultManager] fileExistsAtPath:resourcePath];
}

+ (void)removeResourceWithItem:(MDBeautyMusic *)item {
    if ([self existResourceWithItem:item]) {
        NSString *path = [self resourcePathWithItem:item];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

@end
