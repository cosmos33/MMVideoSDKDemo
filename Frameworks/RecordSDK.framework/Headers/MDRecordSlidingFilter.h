//
//  MDGPUImageSlidingFilter.h
//  MomoChat
//
//  Created by jichuan on 2017/4/25.
//  Copyright © 2017年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GPUImage;

@interface MDRecordSlidingFilter : GPUImageFilterGroup

@property (nonatomic) double offset; //-1...0...1

@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *filterA;
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *filterB;

@end
