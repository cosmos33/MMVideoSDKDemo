//
//  MDRecordProgressView.h
//  MDChat
//
//  Created by 王璇 on 2017/4/13.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDRecordProgressView : UIView

@property(nonatomic) float progress;                        // 0.0 .. 1.0, default is 0.0. values outside are pinned.

@property(nonatomic, strong) UIColor* progressTintColor;
@property(nonatomic, strong) UIColor* trackTintColor;

//- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
