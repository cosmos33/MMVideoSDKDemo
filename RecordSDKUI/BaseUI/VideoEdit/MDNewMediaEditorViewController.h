//
//  MDNewMediaEditorViewController.h
//  MDChat
//
//  Created by 符吉胜 on 2017/8/24.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDViewController.h"

@class MDMediaEditorSettingItem;

@interface MDNewMediaEditorViewController : MDViewController

- (instancetype)initWithSettingItem:(MDMediaEditorSettingItem *)setttingItem;


- (void)playVideo;

@end
