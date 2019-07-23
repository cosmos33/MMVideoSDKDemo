//
//  MDRecordApi.h
//  CXBeautyKit
//
//  Created by sunfei on 2019/2/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordApi : NSObject

+ (void)registerToken:(NSString *)appId;

+ (void)fetchConfig:(NSString *)token;

+ (void)fetchConfigWithAppId:(NSString *)appId;

@end

NS_ASSUME_NONNULL_END
