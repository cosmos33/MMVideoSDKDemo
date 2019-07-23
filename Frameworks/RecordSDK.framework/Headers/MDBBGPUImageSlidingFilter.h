//
//  BBGPUImageSlidingFilter.h
//  BiBi
//
//  Created by YuAo on 12/10/15.
//  Copyright © 2015 wemomo.com. All rights reserved.
//

@import GPUImage;

typedef NS_ENUM(NSUInteger, MDRGPUImageSlidingFilterMode) {
    MDRGPUImageSlidingFilterModeHorizontal,
    MDRGPUImageSlidingFilterModeVertical
};

@interface MDBBGPUImageSlidingFilter : GPUImageFilterGroup

- (instancetype)init;
- (instancetype)initWithMode:(MDRGPUImageSlidingFilterMode *)mode NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) MDRGPUImageSlidingFilterMode mode;

@property (nonatomic) double offset; //-1...0...1

@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *filterA;
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *filterB;

@end
