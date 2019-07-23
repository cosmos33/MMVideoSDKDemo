//
//  MDRegLoginPortraitManager.h
//  MDChat
//
//  Created by DoKeer on 2018/11/7.
//  Copyright © 2018 sdk.com. All rights reserved.
//
//  处理人像图片检测

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN
@class MDPhotoItem;
@interface MDRegLoginPortraitManager : NSObject
// 是不是人像
- (BOOL)faceFeatureWithImage:(UIImage *)photo;
// 人像 特征点
- (NSArray<NSValue *> *)detectorFaceFeaturePointsWithImage:(UIImage *)photo;

- (CGSize)currentDeviceScanSize;
- (NSArray<MDPhotoItem *> *)imageFaceRecognitionFromArray:(NSArray<MDPhotoItem *> *)items;

/**
 view底部显示不阻止用户交互的消息
 @param message
 @param view
 @param interval
 */
+ (void)showBottomMessage:(NSString *)message toView:(UIView *)view timeOut:(NSTimeInterval)interval;
@end

NS_ASSUME_NONNULL_END
