//
//  NSObject+MFDictionaryAdapter.h
//  MomoChat
//
//  Created by Latermoon on 12-9-16.
//  Copyright (c) 2012年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>
/**
 * 实现了MFDictionaryAccessor协议的类可使用下列方法
 */
@interface NSObject (MFDictionaryAdapter)

#pragma mark - Wrap for objectForKey:aKey
- (id)objectForKey:(NSString *)aKey defaultValue:(id)value;
- (NSString *)stringForKey:(NSString *)aKey defaultValue:(NSString *)value;
- (NSArray *)arrayForKey:(NSString *)aKey defaultValue:(NSArray *)value;
- (NSDictionary *)dictionaryForKey:(NSString *)aKey defaultValue:(NSDictionary *)value;
- (NSData *)dataForKey:(NSString *)aKey defaultValue:(NSData *)value;
- (NSUInteger)unsignedIntegerForKey:(NSString *)aKey defaultValue:(NSUInteger)value;
- (NSInteger)integerForKey:(NSString *)aKey defaultValue:(NSInteger)value;
- (float)floatForKey:(NSString *)aKey defaultValue:(float)value;
- (double)doubleForKey:(NSString *)aKey defaultValue:(double)value;
- (long long)longLongValueForKey:(NSString *)aKey defaultValue:(long long)value;
- (BOOL)boolForKey:(NSString *)aKey defaultValue:(BOOL)value;
- (NSDate *)dateForKey:(NSString *)aKey defaultValue:(NSDate *)value;
- (NSNumber *)numberForKey:(NSString *)aKey defaultValue:(NSNumber *)value;
- (id)objectforKeyThreadSafety:(id)key lock:(OSSpinLock)lock defaultValue:(id)value;
- (int)intForKey:(NSString *)aKey defaultValue:(int)value;

#pragma mark - Wrap for setObject:value forKey:aKey
- (void)setObjectSafe:(id)value forKey:(id)aKey;
- (void)setString:(NSString *)value forKey:(NSString *)aKey;
- (void)setNumber:(NSNumber *)value forKey:(NSString *)aKey;
- (void)setInteger:(NSInteger)value forKey:(NSString *)aKey;
- (void)setInt:(int)value forKey:(NSString *)aKey;
- (void)setFloat:(float)value forKey:(NSString *)aKey;
- (void)setDouble:(double)value forKey:(NSString *)aKey;
- (void)setLongLongValue:(long long)value forKey:(NSString *)aKey;
- (void)setBool:(BOOL)value forKey:(NSString *)aKey;
- (void)setObjectThreadSafety:(id)value forKey:(id)key lock:(OSSpinLock)lock;
- (void)removeAllObjectThreadSafety:(OSSpinLock)lock;
- (void)removeObjectThreadSafetyForKey:(id)key lock:(OSSpinLock)lock;
- (void)removeObjectsThreadSafetyForKeys:(NSArray *)keys lock:(OSSpinLock)lock;

@end
