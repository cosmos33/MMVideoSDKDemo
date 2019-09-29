//
//  MDNewMakeupView.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/26.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDMomentMakeupItem.h"

@class MDRecordNewMakeupView;

NS_ASSUME_NONNULL_BEGIN

@protocol MDRecordNewMakeupViewDelegate <NSObject>

- (void)makeupView:(MDRecordNewMakeupView *)view item:(MDMomentMakeupItem *)item;
- (void)didClearWithMakeupView:(MDRecordNewMakeupView *)view;

@end

@interface MDRecordNewMakeupView : UIView

@property (nonatomic, weak) id<MDRecordNewMakeupViewDelegate> delegate;
@property (nonatomic, copy) NSArray<MDMomentMakeupItem *> *items;

@end

NS_ASSUME_NONNULL_END
