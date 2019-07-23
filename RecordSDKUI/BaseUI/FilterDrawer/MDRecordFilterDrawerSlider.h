//
//  MDRecordFilterDrawerSlider.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/20.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordFilterDrawerSlider : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) void(^valueChanged)(MDRecordFilterDrawerSlider *slider, NSInteger value);

@property (nonatomic, assign) NSInteger sliderValue;

@end

NS_ASSUME_NONNULL_END
