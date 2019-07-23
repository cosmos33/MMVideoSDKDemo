//
//  MDSpeedVaryDocument.h
//  MomoChat
//
//  Created by YZK on 2018/5/8.
//  Copyright © 2018年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MDRecordSpeedVaryDocument : NSObject

@property (nonatomic, assign) BOOL enableSpeedVary;

- (BOOL)hasSpeedEffect;

- (void)resetTimeRangeMappingEffect;

- (void)addSpeedFactor:(CGFloat)factor;
- (void)removeLastTimeRangeMappingEffect;

- (AVAsset *)applyToAsset:(AVAsset *)asset segmentIndex:(NSInteger)index;

@end
