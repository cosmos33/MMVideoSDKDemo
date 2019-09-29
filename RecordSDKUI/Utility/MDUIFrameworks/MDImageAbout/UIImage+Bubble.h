//
//  UIImage+Bubble.h
//  RecordSDK
//
//  Created by 杜林 on 16/1/22.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+MDBase.h"

@interface UIImage (Bubble)

- (UIImage *)convertLeftBubbleImageWithSize:(CGSize)size triangle:(CGSize)tSize offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY cornerRadius:(CGFloat)radius tintColor:(UIColor *)tintColor lineColor:(UIColor *)lineColor;
- (UIImage *)convertRightBubbleImageWithSize:(CGSize)size triangle:(CGSize)tSize offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY cornerRadius:(CGFloat)radius tintColor:(UIColor *)tintColor lineColor:(UIColor *)lineColor;

@end
