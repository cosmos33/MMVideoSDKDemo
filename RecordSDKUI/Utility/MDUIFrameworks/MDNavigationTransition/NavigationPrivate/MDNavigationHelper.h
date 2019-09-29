//
//  MDNavigationHelper.h
//  RecordSDK
//
//  Created by 杜林 on 16/9/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MDNavigationHelper : NSObject

- (instancetype)initWithViewController:(UIViewController *)vc;

- (UIImage *)snapForViewController:(UIViewController *)viewcontroller;
- (void)removeSnapForViewController:(UIViewController *)viewController;

- (UIPanGestureRecognizer *)popGestureRecognizer;

- (void)setSnapshotSecondoryCacheEnable:(BOOL)en;

@end
