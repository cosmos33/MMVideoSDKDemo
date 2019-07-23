//
//  MDMediaEditTextColorSelectView.h
//  MDChat
//
//  Created by wangxuan on 17/3/4.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDMediaEditTextColorSelectView : UIView

@property (nonatomic, copy) void (^colorSelectHandler)(UIColor *color);
@property (nonatomic, assign, readonly) NSInteger colorIndex;

- (void)showPainterAnimation;
- (void)configSelectedColor:(NSInteger)index;

@end
