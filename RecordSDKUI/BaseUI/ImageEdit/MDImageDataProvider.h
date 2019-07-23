//
//  MDImageDataProvider.h
//  MDChat
//
//  Created by 杜林 on 16/5/24.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

/*
 * 苹果有bug，ARC下，转data不会释放，会造成内存警告
 * 这段代码放在一个MARC下来运行
 * 这个类必须MARC
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MDImageDataProvider : NSObject

+ (NSData *)JPEGData:(UIImage *)image compressionQuality:(CGFloat)compressionQuality;
+ (NSData *)PNGData:(UIImage *)image;

@end
