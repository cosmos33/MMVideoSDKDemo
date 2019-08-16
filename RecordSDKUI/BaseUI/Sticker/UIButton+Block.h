//
//  UIButton+Block.h
//  MomoChat
//
//  Created by RFeng on 2018/9/3.
//  Copyright © 2018年 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ButtonBlock)(UIButton* btn);

@interface UIButton (Block)

/**
 *  button 添加点击事件
 *
 *  @param block
 */
- (void)addAction:(ButtonBlock)block;

/**
 *  button 添加事件
 *
 *  @param block
 *  @param controlEvents 点击的方式 // 这个暂时有个缺点就是最后设置的点击的BLOCK 生效
 */
- (void)addAction:(ButtonBlock)block forControlEvents:(UIControlEvents)controlEvents;

@end

