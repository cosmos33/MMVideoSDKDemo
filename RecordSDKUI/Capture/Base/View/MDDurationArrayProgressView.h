//
//  MDDurationArrayProgressView.h
//  MDChat
//
//  Created by wangxuan on 16/12/28.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDDurationArrayProgressView : UIView

@property (nonatomic, strong) UIColor     *progressColor;
@property (nonatomic, strong) UIColor     *trackColor;
@property (nonatomic, strong) UIColor     *hilightedColor;
@property (nonatomic, assign) double      progress;
@property (nonatomic, assign) BOOL        hilighted;

- (instancetype)initWithProgressColor:(UIColor *)progressColor trackColor:(UIColor *)trackColor;
- (void)refreshSegmentsAppearrence:(NSArray *)durations;

@end
