//
//  UIImage+Bundle.m
//  RecordSDK
//
//  Created by 杜林 on 16/3/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "UIImage+Bundle.h"
#import "NSBundle+ImageScaled.h"
#import <MMFoundation/MMFoundation.h>

@implementation UIImage (Bundle)

+ (NSMutableDictionary *)bundleImageCache {
    static NSMutableDictionary *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[MDThreadSafeDictionary alloc] init];
    });
    return cache;
}


//不是png的图片，在客户端的bunddle比较少，建议name直接带后缀，如xx.jpg, xx.JPEG等
//不是png的图片，且未带后缀的名字，直接返回空
//目前客户端图片未分路径，所以名字就是图片唯一表示，等以后客户端图片要分路径了，可以用
+ (UIImage *)imageCachedInBundle:(NSString *)name
{
    if (name.length == 0) return nil;
    
    NSString *extension = name.pathExtension;
    NSString *nameUnExtension = [name stringByDeletingPathExtension];
    
    //读cache
    UIImage *image = [[self bundleImageCache] objectForKey:nameUnExtension];
    if (image) return image;
    
    //读图
    image = [UIImage imageNamed:name];
    if (!image) {
        image = [UIImage imageInBundle:nameUnExtension type:extension];
    }
    if (!image) {
        image = [UIImage imageInSandBox:nameUnExtension type:extension];
    }
    //todo::该图片再解码一次,再返回
    //写 cache
    if (image){
        [[self bundleImageCache] setObject:image forKey:nameUnExtension];
    }
    
    return image;
}

+ (UIImage *)imageInBundle:(NSString *)name type:(NSString *)extension
{
    if (extension.length > 0) {
        return [[NSBundle mainBundle] scaledImageName:name ofType:extension];
    }
    return [[NSBundle mainBundle] scaledImageName:name ofType:@"png"];
}

+ (UIImage *)imageInSandBox:(NSString *)name type:(NSString *)extension
{
    if (extension.length > 0) {
        return [[NSBundle mainBundle] scaledImageNameInSandBox:name ofType:extension];
    }
    return [[NSBundle mainBundle] scaledImageNameInSandBox:name ofType:@"png"];
}
@end
