//
//  MDRecordDetectorManger.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/7.
//

#import <Foundation/Foundation.h>
#import "MDRecordDetectorCreator.h"
#import "MDRecordDetectorPreloader.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordDetectorManger : NSObject <MDRecordDetectorPreloader>

+ (MDRecordDetectorManger *)config;

@end

@interface MDRecordDetectorManger (DelegateMethods)  <MDRecordDetectorCreator>

@end

NS_ASSUME_NONNULL_END
