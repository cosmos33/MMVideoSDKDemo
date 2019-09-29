//
//  MDReturnButtonItem.h
//  RecordSDK
//
//  Created by 李龙翼 on 12-9-19.
//  Copyright (c) 2012年 RecordSDK. All rights reserved.
//  导航栏返回Item

#import <UIKit/UIKit.h>
#import "MFBarButtonItem.h"

@interface MDReturnButtonItem : MFBarButtonItem
//返回按钮为图片
- (id)initWithImage:(UIImage *)image;
//返回按钮为文字
- (id)initWithTitle:(NSString *)aTitle;

@end

