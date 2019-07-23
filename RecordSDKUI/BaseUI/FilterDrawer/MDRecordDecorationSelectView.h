//
//  MDRecordDecorationTabView.h
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/2.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDRecordDecorationSelectView : UIView

// 点击按钮回调
@property (copy,nonatomic) void(^didSelectedItemBlock)(NSInteger index);

@property (nonatomic, strong) UIColor       *tintColor;

- (void)addItems:( NSArray<NSString *> *)items;

- (void)setCurrentSelectedIndex:(NSInteger)index;
- (NSInteger)currentSelectedIndex;

@end
