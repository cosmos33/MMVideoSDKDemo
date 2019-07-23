//
//  MDPhotoRenderFilter.h
//  MDRecordSDK
//
//  Created by sunfei on 2018/11/28.
//

#import <Foundation/Foundation.h>
#import "MDProcessImageProtocol.h"
#import "MDBBGPUImageSlidingFilter.h"
#import "MDRecordFilter.h"

@class FDKDecoration, FDKBeautySettings, FDKDecorationFilterOptions;
@protocol FDKDecorationFilterUpdating;

NS_ASSUME_NONNULL_BEGIN

@interface MDPhotoRenderFilter : NSObject <MDProcessImageProtocol, FDKDecorationFilterUpdating>

- (instancetype)init;
- (instancetype)initWithFDKDecorationFilterOptions:(FDKDecorationFilterOptions *)options;
- (instancetype)initWithFDKDecorationFilterOptions:(FDKDecorationFilterOptions *)options
                                 slidingFilterMode:(MDRGPUImageSlidingFilterMode)mode NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong) FDKDecoration * _Nullable decoration;

@property (nonatomic, copy) MDRecordFilter *slidingMDFilterA;
@property (nonatomic, copy) MDRecordFilter *slidingMDFilterB;
@property (nonatomic, assign) float slidingOffset;

- (void)updateBeautySetting:(FDKBeautySettings *)beautySetting;

@end

NS_ASSUME_NONNULL_END
