//
//  MDDeviceMotionObserver.h
//  CXBeautyKit
//
//  Created by sunfei on 2018/11/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MDDeviceMotionHandling <NSObject>

- (void)handleDeviceMotionOrientation:(UIDeviceOrientation)orientation;

@end

@interface MDDeviceMotionObserver : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (void)addDeviceMotionHandler:(id<MDDeviceMotionHandling>)deviceMotionHandler;
+ (void)removeDeviceMotionHandler:(id<MDDeviceMotionHandling>)deviceMotionHandler;

+ (void)startMotionObserve;
+ (void)stopMotionObserve;

@end

NS_ASSUME_NONNULL_END
