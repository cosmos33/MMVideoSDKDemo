//
//  MMBodyDetectorContext.h
//  CXBeautyKit
//
//  Created by sunfei on 2018/11/27.
//

#import <Foundation/Foundation.h>
#import "MDImageDetectorProtocol.h"
@import MomoCV;

NS_ASSUME_NONNULL_BEGIN

@interface MMBodyDetectionOptions (MDOptions) <MDImageDetectorOptions>

@end

@interface MDBodyDetectorContext : NSObject <MDImageDetectorProtocol>

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)makeDetector;
+ (void)asyncAutoMakeDetector:(void(^)(MDBodyDetectorContext *))completed;

@property (nonatomic, readonly) NSArray<MMBodyFeature *> *result;

@end

NS_ASSUME_NONNULL_END
