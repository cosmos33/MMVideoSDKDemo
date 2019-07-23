//
//  MDFeatureOptions.h
//  CXBeautyKit
//
//  Created by sunfei on 2018/11/27.
//

#import <Foundation/Foundation.h>
#import "MDImageDetectorOptions.h"

@class MMFaceFeature;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT MMCVImageOrientation cvImageOrientationFromOrientation(UIDeviceOrientation deviceOrientation);

@interface MDDetectorOptions : NSObject <MDImageDetectorOptions>

@property (nonatomic) MMCVImageOrientation orientation;

@end

@interface MDFeatureOptions : MDDetectorOptions

@property (nonatomic, strong) MMFaceFeature *faceFeature;

@end

NS_ASSUME_NONNULL_END
