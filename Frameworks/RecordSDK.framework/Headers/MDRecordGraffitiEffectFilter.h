//
//  BBGPUImageGraffitEffectFilter.h
//  BiBi
//
//  Created by YuAo on 12/12/15.
//  Copyright © 2015 wemomo.com. All rights reserved.
//

//#import "Mantle.h"
@import GPUImage;

@interface MDRecordGraffitiEffectFilterTextures : NSObject <NSCopying>

@property (nonatomic, copy, readonly) UIImage *graffitiCanvasImage;

@property (nonatomic, copy, readonly) UIImage *mosaicCanvasImage;

- (instancetype)initWithGraffitiCanvasImage:(UIImage *)graffitiCanvasImage mosaicCanvasImage:(UIImage *)mosaicCanvasImage;

@end

@interface MDRecordGraffitiEffectFilter : GPUImageFilterGroup

@property (nonatomic,copy) MDRecordGraffitiEffectFilterTextures *textures;

@end
