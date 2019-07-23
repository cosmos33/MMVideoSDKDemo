//
//  MDRecordDetectorPreloader.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MDRecordDetectorPreloader <NSObject>

- (void)preloadDetectorModelsIfNeededWithModelInfos:(NSDictionary *)modelInfos;

@end

NS_ASSUME_NONNULL_END
