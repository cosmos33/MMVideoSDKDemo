//
//  MDVideoSpeedControlView.h
//  MDChat
//
//  Created by wangxuan on 17/2/21.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MDVideoNewSpeedControlItem;
@interface MDVideoNewSpeedControlView : UIControl

@property (nonatomic,assign,readonly) NSInteger selectedIndex;
@property (nonatomic,assign,readonly) CGFloat selectedFactor;
@property (nonatomic,strong,readonly) NSArray<MDVideoNewSpeedControlItem *> *segmentTitleArray;

- (void)layoutWithSegmentTitleArray:(NSArray <MDVideoNewSpeedControlItem *> *)segmentTitleArray;
- (void)setCurrentSegmentIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setCurrentSegmentIndex:(NSInteger)index animated:(BOOL)animated withEvent:(BOOL)withEvent;

@end


@interface MDVideoNewSpeedControlItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CGFloat factor;

+ (instancetype)itemWithTitle:(NSString *)title factor:(CGFloat)factor;

@end
