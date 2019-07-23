//
//  MDRecordColorDazzledFilter.h
//  MomoChat
//
//  Created by jichuan on 2017/5/3.
//  Copyright © 2017年 wemomo.com. All rights reserved.
//

@import GPUImage;

@interface MDRecordColorDazzledFilter : GPUImageFilter
@property (nonatomic) float mix;
@property (nonatomic) float offset;
@end

@interface MDRecordColorDazzledTransformFilter: GPUImageFilterGroup
@property (nonatomic) float mix;        // 0~1
@property (nonatomic) float offset;     // 0~1
@property (nonatomic) CGAffineTransform transform;
@end
