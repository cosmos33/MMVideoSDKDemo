//
//  MDGPUImageMediaEditorPreviewFilter.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/18.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDRecordFilter.h"
#import "MDBBGPUImageSlidingFilter.h"
@import GPUImage;
@import FaceDecorationKit;
@import FaceDecorationKitGPUImage;

NS_ASSUME_NONNULL_BEGIN

@interface MDGPUImageMediaEditorPreviewFilter : GPUImageFilterGroup <FDKDecorationFilterUpdating>

- (instancetype)init;
- (instancetype)initWithFDKDecorationFilterOptions:(FDKDecorationFilterOptions *)options;
- (instancetype)initWithFDKDecorationFilterOptions:(FDKDecorationFilterOptions *)options
                                 slidingFilterMode:(MDRGPUImageSlidingFilterMode)mode NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong) FDKDecoration *decoration;
@property (nonatomic, assign) float audioVolume;

- (void)udpateBeautySetting:(FDKBeautySettings *)beautySettings;

@property (nonatomic, copy) MDRecordFilter *slidingMDFilterA;
@property (nonatomic, copy) MDRecordFilter *slidingMDFilterB;
@property (nonatomic, assign) float slidingOffset;

@end

NS_ASSUME_NONNULL_END
