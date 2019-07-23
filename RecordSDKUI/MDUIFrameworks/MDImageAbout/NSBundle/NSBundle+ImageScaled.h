//
//  NSBundle+ImageScaled.h
//  RecordSDK
//
//  Created by 杜林 on 16/3/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (ImageScaled)

- (NSString *)pathForAutoScaledImageName:(NSString *)name ofType:(NSString *)extension;
- (UIImage *)scaledImageName:(NSString *)name ofType:(NSString *)extension;

- (NSString *)sandboxPathForAutoScaledImageName:(NSString *)name ofType:(NSString *)extension;
- (UIImage *)scaledImageNameInSandBox:(NSString *)name ofType:(NSString *)extension;
@end
