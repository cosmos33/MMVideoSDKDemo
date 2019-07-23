//
//  MDThreadSafeDictionary.h
//  MomoChat
//
//  Created by xu bing on 16/3/8.
//  Copyright © 2016年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 pthread_mutex_t保证线程安全
 */
@interface MDThreadSafeDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>

@property (nonatomic, strong) NSString *name;/*name字段用于内存标识，暂时只给Eta使用*/

@end
