//
//  MDRecordUtility.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/20.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordUtility : NSObject

+ (UIImage *)checkOrScaleImage:(UIImage *)anImage ignoreLongPic:(BOOL)ignore;
+ (UIImage *)oldCompressImage:(UIImage *)anImage;

@end

NS_ASSUME_NONNULL_END
