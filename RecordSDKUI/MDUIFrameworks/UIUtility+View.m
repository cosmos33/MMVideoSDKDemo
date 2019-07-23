//
//  UIUtility+View.m
//  RecordSDK
//
//  Created by RecordSDK on 2017/1/11.
//  Copyright © 2017年 RecordSDK. All rights reserved.
//

#import "UIUtility+View.h"
#import "UIConst.h"

@implementation UIUtility (View)

#pragma mark --

+(UIView*)addLineToView:(UIView*)view withFrame:(CGRect)lineFrame {
    
    UIView *lineView = [[UIView alloc] initWithFrame:lineFrame];
    lineView.backgroundColor = SEPARATOR_COLOR;
    
    if ([view isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell*)view;
        [cell.contentView addSubview:lineView];
    } else {
        [view addSubview:lineView];
    }
    return lineView;
}

+(UIView*)addLineToView:(UIView*)view color:(UIColor *)color withFrame:(CGRect)lineFrame {
    
    UIView *lineView = [[UIView alloc] initWithFrame:lineFrame];
    lineView.backgroundColor = color;
    
    if ([view isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell*)view;
        [cell.contentView addSubview:lineView];
    } else {
        [view addSubview:lineView];
    }
    return lineView;
}

// cell样式调整
+ (void)decorateCell:(UITableViewCell *)aCell
{
    [self decorateCell:aCell withArrow:YES];
}

+ (void)decorateCell:(UITableViewCell *)aCell withArrow:(BOOL)flag;
{
    if (aCell.textLabel) {
        aCell.textLabel.backgroundColor = [UIColor clearColor];
        aCell.textLabel.textColor = TEXT_COLOR;
        aCell.textLabel.font = [UIFont systemFontOfSize:16];
    }
    
    if (aCell.detailTextLabel) {
        aCell.detailTextLabel.backgroundColor = [UIColor clearColor];
        aCell.detailTextLabel.textColor = DETAIL_COLOR;
        aCell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    }
    
    if (UITableViewCellSelectionStyleNone == aCell.selectionStyle) {
        aCell.selectedBackgroundView = nil;
    } else {
        UIView *selectedBgView = [[UIView alloc] initWithFrame:aCell.bounds];
        aCell.selectedBackgroundView = selectedBgView;
        aCell.selectedBackgroundView.backgroundColor = SELECT_BACKGROUND_COLOR;
    }
    if (!flag) {
        aCell.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
