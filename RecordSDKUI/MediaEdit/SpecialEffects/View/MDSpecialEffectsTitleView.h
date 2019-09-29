//
//  MDSpecialEffectsTitleView.h
//  BlockTest
//
//  Created by litianpeng on 2018/8/7.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDSpecialEffectsTitleView : UIView
@property (nonatomic, copy) void (^sendRevocationBlock)(void);
@property (nonatomic, copy) void (^sendSelectFilterBlock)(void);
@property (nonatomic, copy) void (^sendSelectTimeBlock)(void);
@property (nonatomic, assign) BOOL revocationBtnState;
- (void)resetSelectTitleView;
@end
