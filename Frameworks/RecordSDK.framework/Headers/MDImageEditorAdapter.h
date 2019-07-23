//
//  MDImageEditorAdapter.h
//  CXBeautyKit
//
//  Created by sunfei on 2019/2/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MDRecordFilter.h"

@class FDKDecoration;

NS_ASSUME_NONNULL_BEGIN

@interface MDImageEditorAdapter : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithToken:(NSString *)token;

@property (nonatomic, assign) BOOL canUseBodyThinSetting;

// 初始化
- (void)loadImage:(UIImage *)image completionHander:(void(^)(CVPixelBufferRef _Nullable, NSError * _Nullable))completion;

// 流程
- (void)startProcess;
- (void)stopProcess;

// 滤镜
- (void)configCurrentFilter:(MDRecordFilter *)filter;
- (void)configFilterA:(MDRecordFilter *)filterA configFilterB:(MDRecordFilter *)filterB offset:(float)offset;

// 美颜
- (void)updateDecoration:(FDKDecoration *)decoration;
- (void)setSkinWhitenValue:(float)value;
- (void)setSkinSmoothValue:(float)value;
- (void)setBeautyBigEyeValue:(float)value;
- (void)setBeautyThinFaceValue:(float)value;
- (void)setBeautyThinBodyValue:(float)value;
- (void)setBeautyLenghLegValue:(float)value;
- (void)removeDecoration;

@end

NS_ASSUME_NONNULL_END
