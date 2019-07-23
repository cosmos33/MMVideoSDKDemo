//
//  MDNormalButtonItem.h
//  RecordSDK
//
//  Created by 李龙翼 on 12-9-19.
//  Copyright (c) 2012年 RecordSDK. All rights reserved.
//  导航栏正常Item

#import <UIKit/UIKit.h>
#import "MFBarButtonItem.h"

@interface MDNormalButtonItem : MFBarButtonItem
//按钮为图片
{
}
- (id)initWithImage:(UIImage *)aImage;
//按钮为文字
- (id)initWithTitle:(NSString *)aTitle;

//- (void) setBadgeValue:(NSInteger)value ;

@end
