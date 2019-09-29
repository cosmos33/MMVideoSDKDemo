//
//  MDSpecialEffectsSelectView.h
//  BlockTest
//
//  Created by litianpeng on 2018/8/7.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDSpecialEffectsModel.h"
@interface MDSpecialEffectsSelectView : UIView
@property (nonatomic, copy) void (^specialEffectsLongBlock)(BOOL status,MDSpecialEffectsModel *model);
@property (nonatomic, copy) void (^specialEffectsTapBlock)(MDSpecialEffectsModel *model);
//重置选择的动效
- (void)resetSelectEffect;
- (id)initWithFrame:(CGRect)frame type:(MDRecordSpecialType)type;
@end
