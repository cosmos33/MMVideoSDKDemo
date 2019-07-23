//
//  MFSortedArray.h
//  MomoChat
//
//  Created by Latermoon on 12-10-9.
//  Copyright (c) 2012年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MFSortedArrayItem;

/**
 * 带有自动按权重排序的Array
 * 可用于消息列表这种按时间排序的场景
 * 或实现排行榜
 * 在iOS5上才有NSOrderedSet
 */
@interface MFSortedArray : NSObject
{
    NSMutableArray *innerArray;
}

@property (atomic, retain) NSMutableArray *innerArray;
//setObject返回bool值，YES表示已经存在同样key值的数据，更新数据和时间。 NO表示不存在同样数据，新建一条并插入
- (BOOL)setObject:(id)obj forKey:(NSString *)aKey withScore:(double)score delayResort:(BOOL)needDelay;
- (void)updateScore:(double)score forKey:(NSString *)aKey;
- (void)removeObjectForKey:(NSString *)aKey;
- (void)removeAllObjects;

- (id)objectAtIndex:(NSUInteger)index;
- (id)objectForKey:(NSString *)aKey;
- (int)indexForKey:(NSString *)aKey;
- (void)removeObjectAtIndex:(int)idx;
- (NSMutableArray *)objectArray;
- (int)count;

- (void)resortAll;

- (NSSet *)innerArray2Set;

- (NSString *)description;

@end

@interface MFSortedArray (Private)
- (int)innerIndexForKey:(NSString *)aKey;
- (MFSortedArrayItem *)innerItemForKey:(NSString *)aKey;
@end

/**
 * 辅助类
 */
@interface MFSortedArrayItem : NSObject
{
    id object;
    NSString *key;
    double score;
}

@property(retain, atomic)id object;
@property(retain, atomic)NSString *key;
@property(atomic)double score;

- (id)initWithObject:(id)obj key:(NSString *)aKey score:(double)aScore;

- (NSString *)description;

@end
