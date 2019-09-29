//
//  NSBundle+ImageScaled.m
//  RecordSDK
//
//  Created by 杜林 on 16/3/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "NSBundle+ImageScaled.h"

#define MM_OFFLINE_IMAGE [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/OfflineImage/images"]
@implementation NSBundle (ImageScaled)

- (NSString *)pathForAutoScaledImageName:(NSString *)name ofType:(NSString *)extension {
    
    if (name.length > 0 && extension.length > 0)
    {
        NSArray *scales = [self preferredScales];
        for (NSNumber *scale in scales) {
            NSString *scaledName = [self imageName:name appendingNameScale:[scale integerValue]];
            
            NSString *pathScaled = [[NSString alloc] initWithFormat:@"%@/%@.%@",[NSBundle mainBundle].bundlePath, scaledName, extension];
            if ([[NSFileManager defaultManager] fileExistsAtPath:pathScaled]) {
                if (pathScaled.length > 0) return pathScaled;
            }
        }
    }
    
    return nil;
}

- (UIImage *)scaledImageName:(NSString *)name ofType:(NSString *)extension
{
    NSString *path = [self pathForAutoScaledImageName:name ofType:extension];
    if (path.length <= 0) return nil;
    return [UIImage imageWithContentsOfFile:path];
}


- (NSString *)sandboxPathForAutoScaledImageName:(NSString *)name ofType:(NSString *)extension {
    if (name.length > 0 && extension.length > 0)
    {
        NSArray *scales = [self preferredScales];
        for (NSNumber *scale in scales) {
            NSString *scaledName = [self imageName:name appendingNameScale:[scale integerValue]];
            NSString *pathScaled = [[NSString alloc] initWithFormat:@"%@/%@.%@",MM_OFFLINE_IMAGE, scaledName, extension];
            if ([[NSFileManager defaultManager] fileExistsAtPath:pathScaled]) {
                if (pathScaled.length > 0) return pathScaled;
            }
        }
    }
    
    return nil;
}
- (UIImage *)scaledImageNameInSandBox:(NSString *)name ofType:(NSString *)extension
{
    NSString *path = [self sandboxPathForAutoScaledImageName:name ofType:extension];
    if (path.length <= 0) return nil;
    return [UIImage imageWithContentsOfFile:path];
}

- (NSArray *)preferredScales {
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat s = [UIScreen mainScreen].scale;
        if (s >= 3.0) {
            scales = @[@3, @2, @1];
        } else {
            scales = @[@2, @1, @3];
        }
    });
    return scales;
}

- (NSString *)imageName:(NSString *)name appendingNameScale:(NSInteger)scale
{
    //1x图不拼接后缀
    if (scale < 2 || name.length <= 0)  return [name copy];
    return [name stringByAppendingFormat:@"@%@x", @(scale)];
}

@end
