//
//  MFDictionaryAccessor.h
//  MomoChat
//
//  Created by Latermoon on 12-9-16.
//  Copyright (c) 2012年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 实现该协议的类，可以使用MFDictionaryAdapter系列方法增强数据访问
 */
@protocol MFDictionaryAccessor <NSObject>
@optional
- (id)objectForKey:(id)aKey;
- (void)setObject:(id)value forKey:(id)aKey;

@end
