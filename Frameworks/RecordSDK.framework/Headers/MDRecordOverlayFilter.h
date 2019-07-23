//
//  MDGPUImageOverlayFilter.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/13.
//  Copyright © 2018 sunfei. All rights reserved.
//

@import GPUImage;

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordOverlayFilter : GPUImageFilterGroup

- (instancetype)initWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
