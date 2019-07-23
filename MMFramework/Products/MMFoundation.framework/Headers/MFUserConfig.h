//
//  MFUserConfig.h
//  MomoChat
//
//  Created by Latermoon on 12-9-11.
//  Copyright (c) 2012年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MMFoundation/MFDictionaryAccessor.h>

/**
 * 用户配置接口
 * NSUserDefaults无法提供独立于用户账户的配置管理，因此自己管理
 */
@protocol MFUserConfig <NSObject, MFDictionaryAccessor>

#pragma mark - Base Method
- (id)objectForKey:(id)aKey;
- (void)setObject:(id)value forKey:(id)aKey;
- (void)removeObjectForKey:(NSString *)aKey;
- (void)checkAndSynchronize;

@end
