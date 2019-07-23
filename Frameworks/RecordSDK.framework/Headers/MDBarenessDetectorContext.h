//
//  MDBarenessDetectorContext.h
//  CXBeautyKit
//
//  Created by sunfei on 2018/11/27.
//

#import <Foundation/Foundation.h>
#import "MDImageDetectorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDBarenessDetectorContext : NSObject <MDImageDetectorProtocol>

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)makeDetector;
+ (void)asyncAutoMakeDetector:(void(^)(MDBarenessDetectorContext *))completed;

@property (nonatomic, readonly) NSNumber *result;

@end

NS_ASSUME_NONNULL_END
