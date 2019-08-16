//
//  MDRecordEditTItleView.h
//  MomoChat
//
//  Created by RFeng on 2019/4/8.
//  Copyright © 2019年 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DidSelectBlock)(NSString *title);

@interface MDRecordEditTItleView : UIView

@property (nonatomic, copy) DidSelectBlock didSelectBlock;


/**
 右边按钮不调用设置方法为nil
 */
@property (nonatomic, strong, readonly) UIButton *rightButton;

/**
 设置选中

 @param index 第几个按钮选中不设置默认是第0个
 */
- (void)setSelectIndex:(NSUInteger)index;


- (instancetype)initWithTitles:(nullable NSArray<NSString *> *)titles;

/**
 设置右边按钮图片吗是固定的若需更改请再增加方法

 @param title 右边按钮标题
 @param didSelectBlock 右边按钮点击事件
 */
- (void)setRightButtonWithTitle:(NSString *)title didSelectBlock:(DidSelectBlock)didSelectBlock;


@end

NS_ASSUME_NONNULL_END
