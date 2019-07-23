//
//  MDSpecialEffectsSliderView.h
//  MDChat
//
//  Created by litianpeng on 2018/8/13.
//  Copyright © 2018年 sdk.com. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface MDSpecialEffectsSliderView : UIView
@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, copy) void (^sendSliderValueChange)(CGFloat value);
@property (nonatomic, copy) void (^sendSliderValueEnd)(CGFloat value);
@property (nonatomic, assign) BOOL enable;
@end
