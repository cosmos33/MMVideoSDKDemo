//
//  MDImageDataProvider.m
//  MDChat
//
//  Created by 杜林 on 16/5/24.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDImageDataProvider.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@implementation MDImageDataProvider

+ (NSData *)JPEGData:(UIImage *)image compressionQuality:(CGFloat)compressionQuality
{
    if (!image) return nil;

    NSData *imageData = UIImageJPEGRepresentation(image, compressionQuality);
    return imageData;
}

+ (NSData *)PNGData:(UIImage *)image
{
    if (!image) return nil;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    return imageData;
}

@end
