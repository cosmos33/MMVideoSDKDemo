//
//  MDFaceDecorationFileHelper.m
//  MDChat
//
//  Created by wangxuan on 16/8/24.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDFaceDecorationFileHelper.h"
#import "MDFaceDecorationItem.h"
#import "MDRecordHeader.h"
//zip包的临时路径
#define kFaceDecorationTempPath         [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/Face_Decoration_Temp"]

@implementation MDFaceDecorationFileHelper

+ (NSString *)FaceDecorationBasePath
{
    return kFaceDecorationPath;
}

+ (NSString *)resourceBasePathWithItem:(MDFaceDecorationItem *)item
{
    NSString *path = [kFaceDecorationPath stringByAppendingPathComponent:item.identifier];
    
    return path;
}

+ (NSString *)resourcePathWithItem:(MDFaceDecorationItem *)item
{
    NSString *name = [[item.zipUrlStr componentsSeparatedByString:@"/"] lastObject];
    name = [name stringByDeletingPathExtension];
    
    if (![name isNotEmpty]) {
        return nil;
    }

    NSString *path = [self resourceBasePathWithItem:item];
    NSString *resourcePath = [path stringByAppendingPathComponent:name];
 
    return resourcePath;
}

+ (NSString *)zipPathWithItem:(MDFaceDecorationItem *)item
{
    NSString *name = [[item.zipUrlStr componentsSeparatedByString:@"/"] lastObject];
    NSString *path = kFaceDecorationTempPath;
    NSString *zipPath = [path stringByAppendingPathComponent:name];

    return zipPath;
}

+ (void)removeAllComponentWithItem:(MDFaceDecorationItem *)item
{
    [self removeResourceWithItem:item];
}

+ (void)removeResourceWithItem:(MDFaceDecorationItem *)item
{
    if ([self existResourceWithItem:item]) {
        NSString *path = [self resourcePathWithItem:item];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

+ (BOOL)existResourceWithItem:(MDFaceDecorationItem *)item
{
    NSString *resourcePath = [self resourcePathWithItem:item];
    
    if ([resourcePath isNotEmpty]) {
        return [[NSFileManager defaultManager] fileExistsAtPath:resourcePath];
    } else {
        return NO;
    }
}

@end
