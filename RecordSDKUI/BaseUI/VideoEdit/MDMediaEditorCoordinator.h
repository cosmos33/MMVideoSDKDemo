//
//  MDMediaEditorCoordinator.h
//  MDChat
//
//  Created by 符吉胜 on 2017/8/24.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDMediaEditorContainerView;
@class MDMediaEditorSettingItem;
@class MDMediaEditorModuleAggregate;

@interface MDMediaEditorCoordinator : NSObject

//协调视图和功能集合的交互
- (instancetype)initWithContainerView:(MDMediaEditorContainerView *)containerView
                          settingItem:(MDMediaEditorSettingItem *)settingItem
                      moduleAggregate:(MDMediaEditorModuleAggregate *)moduleAggregate;

- (void)moreActionsBtnTapped;

@end
