//
//  ImageFixOrientationHelper.h
//  MDChat
//
//  Created by yeye(* ￣＾￣) on 2018/8/9.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageFixOrientationHelper : NSObject

// 图片方向的矫正方法
+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end
