//
//  MDGPUImageColorPackingFilter.h
//  MomoChat
//
//  Created by jichuan on 2017/5/3.
//  Copyright © 2017年 wemomo.com. All rights reserved.
//

@import GPUImage;

@interface MDRecordColorPackingFilter : GPUImageFilterGroup

/** Contrast ranges from 0.0 to 4.0 (max contrast), with 1.0 as the normal level
 */
@property(readwrite, nonatomic) CGFloat contrast;

@end
