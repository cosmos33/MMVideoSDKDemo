//
//  MDRecordVideoNewSpeedSlider.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/19.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordVideoNewSpeedSlider : UIView

@property (nonatomic, copy) void(^valueChanged)(MDRecordVideoNewSpeedSlider *, CGFloat);

@property (nonatomic, assign) CGFloat value;

@end

NS_ASSUME_NONNULL_END
