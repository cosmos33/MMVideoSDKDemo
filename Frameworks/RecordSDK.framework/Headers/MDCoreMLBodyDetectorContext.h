//
//  MDCoreMLBodyDetectorContext.h
//  
//
//  Created by sunfei on 2018/11/27.
//

#import <Foundation/Foundation.h>
#import "MDImageDetectorProtocol.h"
@import MomoCV;

NS_ASSUME_NONNULL_BEGIN

@interface MMCoreMLBodyDetectOptions (MDOptions) <MDImageDetectorOptions>

@end

API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0))
@interface MDCoreMLBodyDetectorContext : NSObject <MDImageDetectorProtocol>

+ (instancetype)makeDetector;
+ (void)asyncAutoMakeDetector:(void(^)(MDCoreMLBodyDetectorContext *))completed;

@property (nonatomic, readonly) NSArray<MMBodyFeature *> *result;

@end

NS_ASSUME_NONNULL_END
