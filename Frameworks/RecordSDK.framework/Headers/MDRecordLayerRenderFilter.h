//
//  MDLayerRenderFilter.h
//  MomoChat
//
//  Created by jichuan on 2017/8/15.
//  Copyright © 2017年 wemomo.com. All rights reserved.
//

@import GPUImage;

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordLayerRenderFilter : GPUImageFilterGroup

@property (nonatomic, strong, nullable) CALayer *layer;

@end

NS_ASSUME_NONNULL_END
