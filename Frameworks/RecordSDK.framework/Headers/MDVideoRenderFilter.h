//
//  MDVideoRenderFilter.h
//  RecordSDK
//
//  Created by sunfei on 2018/11/30.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDProcessImageProtocol.h"
#import "MDImageDetectorProtocol.h"
#import "MDRecordPiplineSpecificFilterGroup.h"
#import "MDBBGPUImageSlidingFilter.h"
#import "MDRecordFilter.h"

@class FDKDecoration, FDKBeautySettings, CXBeautyConfiguration;
@protocol FDKDecorationFilterUpdating;

@class MDRecordDynamicSticker;

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoRenderFilter : NSObject <MDProcessImageProtocol, FDKDecorationFilterUpdating>

- (instancetype)init;
- (instancetype)initWithSlidingFilterMode:(MDRGPUImageSlidingFilterMode)mode NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) UIImage * _Nullable graffitiCanvasImage;
@property (nonatomic, readonly) UIImage * _Nullable mosaicCanvasImage;

// 特效滤镜
@property (nonatomic, strong, readonly) MDRecordPiplineSpecificFilterGroup *specialFilterGroup;

// overlay image
@property (nonatomic, strong) UIImage * _Nullable overlayImage;

// 静态贴纸，瘦身
@property (nonatomic, strong) FDKDecoration * _Nullable decoration;

- (void)updateBeautySetting:(FDKBeautySettings *)beautySetting;

// 涂鸦
- (void)setGraffitiCanvasImage:(UIImage * _Nullable)graffitiCanvasImage mosaicCanvasImage:(UIImage * _Nullable)mosaicCanvasImage;

// 动态贴纸
- (void)addDynamicSticker:(MDRecordDynamicSticker *)dynamicSticker;
- (void)removeDynamicSticker:(MDRecordDynamicSticker *)dynamicSticker;

// 普通滤镜
@property (nonatomic, copy) MDRecordFilter *slidingMDFilterA;
@property (nonatomic, copy) MDRecordFilter *slidingMDFilterB;
@property (nonatomic, assign) float slidingOffset;

// AI 美颜
@property (nonatomic, assign) BOOL canUseAIBeautySetting;
@property (nonatomic, strong) CXBeautyConfiguration *beautyConfiguration;

// 变声
//- (void)prepareAudioBeatWithURL:(NSURL *)url audioBeatType:(MDRecordAudioBeatType)type;

@end

NS_ASSUME_NONNULL_END
