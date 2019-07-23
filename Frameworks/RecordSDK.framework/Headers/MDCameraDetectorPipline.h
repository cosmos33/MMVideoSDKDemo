//
//  MDCameraDetectorPipline.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/24.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDImageDetectorProtocol.h"

@class MMBodyFeature, MMHandFeature, FDKDecoration, FDKBeautySettings, FDKDecorationFilterUpdateRequest;
@protocol FDKObjectFeature;

NS_ASSUME_NONNULL_BEGIN

@interface MDCameraDetectorPiplineResult : NSObject

// 结果
@property (nonatomic, copy) FDKDecorationFilterUpdateRequest *request;
@property (nonatomic,strong) NSArray<id<FDKObjectFeature>> *objectFeatures;
@property (nonatomic,strong) NSArray<MMBodyFeature *> *bodyFeatures;
@property (nonatomic,strong) NSArray<MMHandFeature *> *handFeatures;

@end

@interface MDCameraDetectorPipline : NSObject <MDImageDetectorProtocol>

// 是否支持瘦身
@property (nonatomic, assign) BOOL canUseBodyThinSetting;

// 旋转方向
@property (nonatomic, assign) UIDeviceOrientation orientation;

// 是否检测到光膀子
@property (nonatomic, readonly) BOOL hasDetectorBareness;

@property (nonatomic, readonly) MDCameraDetectorPiplineResult *result;

// 根据decoration配置detectors
- (void)configUsingDecoration:(FDKDecoration *)decoration;

- (void)thinBodyConfiguration:(FDKBeautySettings *)beautySettings;

// 激活光膀子检测
@property (nonatomic, assign) BOOL barenessDetectorEnable;
- (void)activeBarenessDetector;
@property (nonatomic, copy) void(^ _Nullable detectBareness)(MDCameraDetectorPipline *detector);

@property (nonatomic, readonly) BOOL shouldEnable3DLayer;

// 移除decoration
- (void)removeAllDecoration;

// 重置状态
- (void)resetImageSegment;
- (void)resetExpressionDetector;
- (void)resetBarenessDetector;

- (void)resetBarenessState;

@end

NS_ASSUME_NONNULL_END
