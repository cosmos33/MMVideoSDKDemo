//
//  UIImage+Bundle.h
//  RecordSDK
//
//  Created by 杜林 on 16/3/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Bundle)

//不是png的图片，在客户端的bunddle比较少，建议name直接带后缀，如xx.jpg, xx.JPEG等
//不是png的图片，且未带后缀的名字，直接返回空
+ (UIImage *)imageCachedInBundle:(NSString *)name;

@end
