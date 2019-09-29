//
//  MDRecordFilterModelLoader.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/15.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDRecordFilterModel.h"
#import <RecordSDK/MDRecordFilter.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordFilterModelLoader : NSObject

- (NSArray<MDRecordFilterModel *> *)getFilterModels;
- (NSArray<MDRecordFilter *> *)filtersArray;

+ (void)requeseteRecordChangeFaceData:(void(^)(NSArray *changeFaceArray))finishBlock;
+ (void)requeseteRecordMakeUpData:(void(^)(NSArray *beautifyArray))finishBlock;

@end

NS_ASSUME_NONNULL_END
