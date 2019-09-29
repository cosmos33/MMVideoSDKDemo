//
//  MDSpecialEffectsLayer.h
//  BlockTest
//
//  Created by litianpeng on 2018/8/6.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@interface MDSpecialEffectsLayer : CALayer
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) NSArray *transparentArr;///<透明区域
@end
