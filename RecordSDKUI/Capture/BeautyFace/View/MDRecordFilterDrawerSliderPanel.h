//
//  MDRecordFilterDrawerSliderPanel.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/18.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDRecordFilterDrawerSliderPanel;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MDRecordFilterDrawerSliderPanelSliderPosition) {
    MDRecordFilterDrawerSliderPanelSliderPositionTop,
    MDRecordFilterDrawerSliderPanelSliderPositionBottom
};

@protocol MDRecordFilterDrawerSliderPanelDelegate <NSObject>

- (void)sliderValueChanged:(MDRecordFilterDrawerSliderPanel *)panel
                     value:(CGFloat)value
                  position:(MDRecordFilterDrawerSliderPanelSliderPosition)position;

@end

@interface MDRecordFilterDrawerSliderPanel : UIView

@property (nonatomic, copy) NSString *title1;
@property (nonatomic, copy) NSString *title2;

@property (nonatomic, weak) id<MDRecordFilterDrawerSliderPanelDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
