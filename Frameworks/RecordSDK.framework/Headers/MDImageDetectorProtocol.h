//
//  MDImageDetectorProtocol.h
//  CXBeautyKit
//
//  Created by sunfei on 2018/11/26.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import "MDImageDetectorOptions.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *MDDetectorContextClassName;

@protocol MDImageDetectorProtocol <NSObject>

@property (nonatomic, readonly) id result;

- (void)detectPixelBuffer:(CVPixelBufferRef)pixelBuffer options:(id<MDImageDetectorOptions> _Nullable)options;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
