//
//  MDFaceDecorationClassSelecteView.h
//  DEMO
//
//  Created by 姜自佳 on 2017/5/7.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDFaceDecorationClassItem;

@interface MDFaceDecorationClassSelecteView : UIView

@property (nonatomic, strong) NSArray<MDFaceDecorationClassItem *> *classItems;

// 点击按钮回调
@property (nonatomic, copy) void(^clickCompeletionHandler)(UIButton *button, NSInteger index);
// 点击清空按钮调用
@property (nonatomic, copy) void(^clearDecorationBlock)(UIButton *button);

// 联动设置当前选中按钮
- (void)setCurrentButtonIndex:(NSInteger)index;
- (NSInteger)currentIndex;
- (NSInteger)myClassIndex; //如果没有“我的”分类，返回NSNotFound

@end
