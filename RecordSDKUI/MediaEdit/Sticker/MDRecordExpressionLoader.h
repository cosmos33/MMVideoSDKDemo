//
//  MDRecordExpressionLoader.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/18.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordExpressionLoader : NSObject

+ (void)loadDynamicExpressionWithCompletion:(void(^)(NSString * _Nullable, NSError * _Nullable))completion;
+ (void)loadStaticExpressionWithCompletion:(void(^)(NSString * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
