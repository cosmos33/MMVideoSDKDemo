//
//  MDMediaEffect.h
//  MDChat
//
//  Created by Jc on 17/2/17.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#ifndef MDMediaEffect_h
#define MDMediaEffect_h

#import <MLMediaEditingModel/MLTimeRangeMappingEffect.h>

static inline id<MLTimeRangeMappingEffect>
MLTimeRangeMappingEffectMake(CMTimeRange timeRange, Float64 multiple)
{
    Float64 originalDuration = CMTimeGetSeconds(timeRange.duration);
    Float64 convertedDuration = originalDuration * multiple;
    CMTime targetDuration = CMTimeMakeWithSeconds(convertedDuration, timeRange.duration.timescale);
    return [[MLLinearTimeRangeMappingEffect alloc] initWithTimeRange:timeRange targetDuration:targetDuration];
}

#endif /* MDMediaEffect_h */
