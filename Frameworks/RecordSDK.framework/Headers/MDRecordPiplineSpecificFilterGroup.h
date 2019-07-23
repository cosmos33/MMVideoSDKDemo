//
//  MDRecordPiplineFilterGroup.h
//  testGPU
//
//  Created by sunfei on 2018/8/1.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "MDRSpecialFilterLifeStyleProtocol.h"
#import "MDRecordPiplineManager.h"
@import GPUImage;

@interface MDRecordPiplineSpecificFilterGroup  : GPUImageFilterGroup

@property (nonatomic, assign) CMTimeRange timeRange;
@property (nonatomic, assign) BOOL reverse;
@property (nonatomic, strong, readonly) MDRecordPiplineManager *pipline;

- (void)addFilter:(GPUImageOutput<GPUImageInput, MDRSpecialFilterLifeStyleProtocol> *)newTarget timeRange:(CMTimeRange)range;
- (void)updateCurrentFilterWithTime:(CMTime)time timeRange:(CMTimeRange)timeRange;

- (void)deleteLastFilter;
- (void)deleteAllFilter;

@end

