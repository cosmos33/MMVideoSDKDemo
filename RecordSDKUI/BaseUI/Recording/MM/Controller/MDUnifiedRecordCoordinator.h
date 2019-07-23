//
//  MDUnifiedRecordCoordinator.h
//  MDChat
//
//  Created by 符吉胜 on 2017/7/19.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDUnifiedRecordContainerView;
@class MDUnifiedRecordModuleAggregate;
@class MDCameraContainerViewController;
@class MDUnifiedRecordSettingItem;
@class MDUnifiedRecordViewController;

@interface MDUnifiedRecordCoordinator : NSObject

@property (nonatomic, weak) MDUnifiedRecordViewController *viewController;
//协调视图和功能集合的交互
- (instancetype)initWithContainerView:(MDUnifiedRecordContainerView *)containerView
                            settingItem:(MDUnifiedRecordSettingItem *)settingItem
                      moduleAggregate:(MDUnifiedRecordModuleAggregate *)moduleAggregate;

@end
