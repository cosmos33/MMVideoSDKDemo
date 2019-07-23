//
//  MDCameraRenderFilter.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/18.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDProcessImageProtocol.h"
#import "MDRecordFilter.h"
#import "MDBBGPUImageSlidingFilter.h"

@class FDKDecoration, FDKDecorationFilterOptions, CXBeautyConfiguration, FDKBeautySettings;
@protocol FDKDecorationFilterUpdating;

NS_ASSUME_NONNULL_BEGIN

@interface MDCameraRenderFilter : NSObject <MDProcessImageProtocol, FDKDecorationFilterUpdating>

- (instancetype)init;
- (instancetype)initWithFDKDecorationFilterOptions:(FDKDecorationFilterOptions *)options;
- (instancetype)initWithFDKDecorationFilterOptions:(FDKDecorationFilterOptions *)options
                                 slidingFilterMode:(MDRGPUImageSlidingFilterMode)mode NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong) FDKDecoration * _Nullable decoration;
@property (nonatomic, assign) float audioVolume;

@property (nonatomic, assign) BOOL canUseAIBeautySetting;
@property (nonatomic, strong) CXBeautyConfiguration *beautyConfiguration;

@property (nonatomic, copy) MDRecordFilter *slidingMDFilterA;
@property (nonatomic, copy) MDRecordFilter *slidingMDFilterB;
@property (nonatomic, assign) float slidingOffset;

- (void)updateBeautySetting:(FDKBeautySettings *)beautySetting;

- (void)cleanCache;
- (void)purgeGPUCache;

@end

NS_ASSUME_NONNULL_END
