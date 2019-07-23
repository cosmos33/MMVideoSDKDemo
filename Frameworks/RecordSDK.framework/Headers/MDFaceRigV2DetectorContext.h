//
//  MDFaceRigV2DetectorContext.h
//  CXBeautyKit
//
//  Created by sunfei on 2018/11/27.
//

#import <Foundation/Foundation.h>
#import "MDImageDetectorProtocol.h"

@class MMFaceRigFeature;

NS_ASSUME_NONNULL_BEGIN

@interface MDFaceRigV2DetectorContext : NSObject <MDImageDetectorProtocol>

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)makeDetector;
+ (void)asyncAutoMakeDetector:(void(^)(MDFaceRigV2DetectorContext *))completed;

@property (nonatomic, readonly) MMFaceRigFeature *result;

@end

NS_ASSUME_NONNULL_END
