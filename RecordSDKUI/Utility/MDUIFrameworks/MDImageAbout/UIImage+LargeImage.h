//
//  UIImage+LargeImage.h
//  RecordSDK
//
//  Created by YZK on 2018/12/20.
//  Copyright © 2018 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (LargeImage)

+ (void)setHandleLargeImageEnable:(BOOL)enable;

//同步调用
- (UIImage *)downsize;
- (UIImage *)downsizeWithTargetScale:(float)imageScale;

- (void)downsizeWithCompltion:(void (^)(UIImage *result))completion;
- (void)downsizeWithTargetScale:(float)imageScale compltion:(void (^)(UIImage *result))completion;

@end

NS_ASSUME_NONNULL_END
