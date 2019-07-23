//
//  MDNavigationController.h
//  RecordSDK
//
//  Created by lly on 13-10-7.
//  Copyright (c) 2013年 RecordSDK. All rights reserved.
//

/*
 新结构中打算采用MDNavigationController为rootViewController
 MDNavigationController的rootViewController为MDTabBarController
 全局主体只有一个rootNavigationController对象，使用他来做push操作
 */

#import <UIKit/UIKit.h>

@interface MDNavigationController : UINavigationController
<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

- (void)removeImageViewForShadow:(UIView *)view;

@end
