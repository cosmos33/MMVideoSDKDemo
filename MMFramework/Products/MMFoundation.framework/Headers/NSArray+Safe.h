//
//  NSArray+Safe.h
//  MomoChat
//
//  Created by 杨 红林 on 13-7-4.
//  Copyright (c) 2013年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (Safe)

- (ObjectType)objectAtIndex:(NSUInteger)index kindOfClass:(Class)aClass;
- (ObjectType)objectAtIndex:(NSUInteger)index memberOfClass:(Class)aClass;
- (ObjectType)objectAtIndex:(NSUInteger)index defaultValue:(ObjectType)value;
- (NSString *)stringAtIndex:(NSUInteger)index defaultValue:(NSString *)value;
- (NSNumber *)numberAtIndex:(NSUInteger)index defaultValue:(NSNumber *)value;
- (NSDictionary *)dictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)value;
- (NSArray *)arrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)value;
- (NSData *)dataAtIndex:(NSUInteger)index defaultValue:(NSData *)value;
- (NSDate *)dateAtIndex:(NSUInteger)index defaultValue:(NSDate *)value;
- (float)floatAtIndex:(NSUInteger)index defaultValue:(float)value;
- (double)doubleAtIndex:(NSUInteger)index defaultValue:(double)value;
- (NSInteger)integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)value;
- (NSUInteger)unintegerAtIndex:(NSUInteger)index defaultValue:(NSUInteger)value;
- (BOOL)boolAtIndex:(NSUInteger)index defaultValue:(BOOL)value;

@end

@interface NSMutableArray<ObjectType> (Safe)

- (void)removeObjectAtIndexInBoundary:(NSUInteger)index;
- (void)insertObject:(ObjectType)anObject atIndexInBoundary:(NSUInteger)index;
- (void)replaceObjectAtInBoundaryIndex:(NSUInteger)index withObject:(ObjectType)anObject;

// 排除nil 和 NSNull
- (void)addObjectSafe:(ObjectType)anObject;

@end

