//
//  UIUtility+View.h
//  RecordSDK
//
//  Created by RecordSDK on 2017/1/11.
//  Copyright © 2017年 RecordSDK. All rights reserved.
//

#import "UIUtility.h"

@interface UIUtility (View)


+(UIView*)addLineToView:(UIView*)cell withFrame:(CGRect)lineFrame;
+(UIView*)addLineToView:(UIView*)view color:(UIColor *)color withFrame:(CGRect)lineFrame;

// cell样式调整
+ (void)decorateCell:(UITableViewCell *)aCell;
+ (void)decorateCell:(UITableViewCell *)aCell withArrow:(BOOL)flag;

@end
