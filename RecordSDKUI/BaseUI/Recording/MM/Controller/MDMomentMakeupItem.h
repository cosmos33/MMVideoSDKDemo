//
//  MDMomentMakeupItem.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/29.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDMomentMakeupItem : NSObject

@property (nonatomic, readonly) NSArray<NSURL *> *items;

@end

// 日常
@interface MDMomentMakeupDailyItem : MDMomentMakeupItem

@end

// 少年感
@interface MDMomentMakeupClearwaterItem : MDMomentMakeupItem

@end

// 小雀斑
@interface MDMomentMakeupFreckleItem : MDMomentMakeupItem

@end

// 元气
@interface MDMomentMakeupLeizhi : MDMomentMakeupItem

@end

// tantan
@interface MDMomentMakeupTantanItem: MDMomentMakeupItem

@end

NS_ASSUME_NONNULL_END
