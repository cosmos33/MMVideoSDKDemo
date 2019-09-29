//
//  MDRecordExposureAdjustView.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/5.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MDRecordExposureAdjustSlider;

@protocol MDRecordExposureAdjustSliderDelegate <NSObject>

- (void)slider:(MDRecordExposureAdjustSlider *)slider value:(CGFloat)value;

@end

@interface MDRecordExposureAdjustSlider : UIView

@property (nonatomic, weak) id<MDRecordExposureAdjustSliderDelegate> delegate;

+ (MDRecordExposureAdjustSlider *)showSlider:(BOOL)animated onView:(UIView *)superView;
- (void)dismiss:(BOOL)animated;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
