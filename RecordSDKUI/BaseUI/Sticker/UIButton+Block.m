//
//  UIButton+Block.m
//  MomoChat
//
//  Created by RFeng on 2018/9/3.
//  Copyright © 2018年 wemomo.com. All rights reserved.
//


#import "UIButton+Block.h"

#import <objc/runtime.h>

@implementation UIButton (Block)
static char ActionTag;

/**
 *  button 添加点击事件 默认点击方式UIControlEventTouchUpInside
 *
 *  @param block
 */
- (void)addAction:(ButtonBlock)block {
    
     [self removeTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(self, &ActionTag, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  button 添加事件
 *
 *  @param block
 *  @param controlEvents 点击的方式
 */
- (void)addAction:(ButtonBlock)block forControlEvents:(UIControlEvents)controlEvents {
    
    [self removeTarget:self action:@selector(action:) forControlEvents:controlEvents];
    objc_setAssociatedObject(self, &ActionTag, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(action:) forControlEvents:controlEvents];
}

/**
 *  button 事件的响应方法
 *
 *  @param sender
 */
- (void)action:(id)sender {
    ButtonBlock blockAction = (ButtonBlock)objc_getAssociatedObject(self, &ActionTag);
    if (blockAction) {
        blockAction(self);
    }
}
@end

