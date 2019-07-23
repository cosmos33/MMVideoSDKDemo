//
//  MirrImageFrameFilter.h
//  testGPU
//
//  Created by MOMO on 2018/7/17.
//  Copyright © 2018 MOMO. All rights reserved.
//

@import GPUImage;

//四宫格
@interface MDRecordMirrImageFrameFilter : GPUImageFilter

@property (nonatomic, assign) NSTimeInterval interval;

- (void)reset;

@end
