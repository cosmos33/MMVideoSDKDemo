//
//  MDVideoSpeedVaryHandler.m
//  MDChat
//
//  Created by wangxuan on 17/2/23.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDVideoSpeedVaryHandler.h"
#import "MDDocument.h"
#import "MDVideoTrimmerView.h"
#import "MDMediaEffect.h"
#import "MDRecordHeader.h"

@interface MDVideoSpeedVaryHandler ()
//<MDVideoTrimmerViewDelegate>

@property (nonatomic, strong) MDDocument *document;
@property (nonatomic, strong) AVAsset    *asset;
@property (nonatomic, strong) NSArray    *effectStash;
@property (nonatomic, strong) NSArray    *viewStash;
@property (nonatomic, strong) NSArray    *factorStash;

@end

@implementation MDVideoSpeedVaryHandler

- (instancetype)initWithDocument:(MDDocument *)document
{
    self = [super init];
    if (self) {
        self.document = document;
        self.asset = document.asset;

    }
    return self;
}

- (NSMutableArray *)segmentFactors
{
    if (!_segmentFactors) {
        _segmentFactors = [NSMutableArray array];
    }
    
    return _segmentFactors;
}

//- (Float64)checkSegmentSpeedFacetor:(MDVideoTrimmerView *)trimmerView
//{
//    Float64 multiple = 1.0f;
//    for (int i = 0; i < trimmerView.trimmerTimeRanges.count; i++) {
//        NSValue *timeRangeValue = [trimmerView.trimmerTimeRanges objectAtIndex:i defaultValue:nil];
//        CMTimeRange timeRange = [timeRangeValue CMTimeRangeValue];
//        if (CMTimeRangeContainsTime(timeRange, trimmerView.currentPointerTime)) {
//            id<MLTimeRangeMappingEffect> timeEffect = [self.document timeRangeMappingEffects][i];
//            
//            CMTime previousDuration = [(id<MLTimeRangeMappingEffect>)timeEffect timeRange].duration;
//            CMTime previousTargetDuration = [(id<MLTimeRangeMappingEffect>)timeEffect targetDuration];
//            multiple = CMTimeGetSeconds(previousTargetDuration) / CMTimeGetSeconds(previousDuration);
//        }
//    }
//    
//    return multiple;
//}

#pragma mark - effect
- (BOOL)addEffect:(float)factor duration:(NSTimeInterval)duration videoTrimView:(MDVideoTrimmerView *)trimView
{
    BOOL sucess = NO;
    if (factor == .0f || factor == 1.0f) {
        return sucess;
    }
    
    CMTime currentTime = trimView.currentPointerTime;
    CMTimeRange timeRange = CMTimeRangeMake(currentTime, CMTimeMakeWithSeconds(duration, self.asset.duration.timescale));
    
    if ([trimView insertTimeRange:timeRange]) {
        sucess = YES;
        id<MLTimeRangeMappingEffect> timeEffect = MLTimeRangeMappingEffectMake(timeRange, factor);
        
        [self.document addTimeRangeMappingEffect:timeEffect];
        [self.segmentFactors insertObject:@(factor) atIndex:trimView.selectedTrimmerRangeIndex];
    }
    
    return sucess;
}

- (BOOL)removeCurrentEffectOnVideoTrimView:(MDVideoTrimmerView *)trimView
{
    NSInteger index = trimView.selectedTrimmerRangeIndex;
    id<MLTimeRangeMappingEffect> timeEffect = [[self.document timeRangeMappingEffects] objectAtIndex:index defaultValue:nil];
    if (timeEffect) {
        [self.document removeTimeRangeMappingEffect:timeEffect];
        [self.segmentFactors removeObjectAtIndex:trimView.selectedTrimmerRangeIndex];
        return YES;
    }
    
    return NO;
}

- (BOOL)changeEffectFactor:(float)factor videoTrimView:(MDVideoTrimmerView *)trimView
{
    NSInteger index = trimView.selectedTrimmerRangeIndex;
    CMTimeRange targetTimeRange = trimView.selectedTrimmerTimeRange;
    id<MLTimeRangeMappingEffect> timeEffect = [[self.document timeRangeMappingEffects] objectAtIndex:index defaultValue:nil];
    
    if (timeEffect) {
        [self.document removeTimeRangeMappingEffect:timeEffect];
        
        id<MLTimeRangeMappingEffect> newTimeEffect = MLTimeRangeMappingEffectMake(targetTimeRange, factor);
        [self.document addTimeRangeMappingEffect:newTimeEffect];
        [self.segmentFactors removeObjectAtIndex:trimView.selectedTrimmerRangeIndex];
        [self.segmentFactors insertObject:@(factor) atIndex:trimView.selectedTrimmerRangeIndex];

        return YES;
    }
    
    return NO;
}

- (void)scaleEffectOnVideoTrimView:(MDVideoTrimmerView *)trimView
{
    NSInteger index = trimView.selectedTrimmerRangeIndex;
    NSArray *trimmerTimeRanges = trimView.trimmerTimeRanges;
    
    BOOL needCheckCross = NO;
    NSInteger leftIndex = index - 1;
    if (leftIndex >= 0 && leftIndex < trimmerTimeRanges.count) {
        CMTimeRange leftTimeRnage = [trimmerTimeRanges[leftIndex] CMTimeRangeValue];
        CMTimeRange selectedTimeRange = trimView.selectedTrimmerTimeRange;
        if (CMTimeRangeGetEnd(leftTimeRnage).value == selectedTimeRange.start.value) {
            needCheckCross = YES;
        }
    }
    
    NSArray *timeRangeEffects = self.document.timeRangeMappingEffects;
    id<MLTimeRangeMappingEffect> timeEffect = [timeRangeEffects objectAtIndex:index defaultValue:nil];
    [self.document removeTimeRangeMappingEffect:timeEffect];
    
    CMTime previousDuration = [(id<MLTimeRangeMappingEffect>)timeEffect timeRange].duration;
    CMTime previousTargetDuration = [(id<MLTimeRangeMappingEffect>)timeEffect targetDuration];
    
    Float64 multiple = CMTimeGetSeconds(previousTargetDuration) / CMTimeGetSeconds(previousDuration);
    
    CMTimeRange selectedViewTimeRange = trimView.selectedTrimmerTimeRange;
    id<MLTimeRangeMappingEffect>newTimeEffect = MLTimeRangeMappingEffectMake(selectedViewTimeRange, multiple);
    [self.document addTimeRangeMappingEffect:newTimeEffect];
}

- (CMTimeRange)mappedTimeRange:(id<MLTimeRangeMappingEffect>)timeEffect
{
    id<MLTimeRangeMappingEffect> mappedTimeRangeEffect =
    MLTimeRangeMappingEffectSquenceGetMappedSquence(@[(id<MLTimeRangeMappingEffect>)timeEffect]).firstObject;
    return mappedTimeRangeEffect.timeRange;
}

- (void)removeAllEffects:(MDVideoTrimmerView *)trimView
{
    for (id<MLTimeRangeMappingEffect> timeEffect in self.document.timeRangeMappingEffects) {
        [self.document removeTimeRangeMappingEffect:timeEffect];
    }
    
    [trimView deleteAllTimeRange];
}

- (void)stashEffectsOnVideoTrimView:(MDVideoTrimmerView *)trimView
{
    self.effectStash = [self.document.timeRangeMappingEffects copy];
    self.viewStash = [trimView.trimmerTimeRanges copy];
    self.factorStash = [self.segmentFactors copy];
}

- (void)recoverFromEffectsStashOnVideoTrimView:(MDVideoTrimmerView *)trimView
{
    for (id<MLTimeRangeMappingEffect> timeEffect in self.document.timeRangeMappingEffects) {
        [self.document removeTimeRangeMappingEffect:timeEffect];
    }
    
    [trimView deleteAllTimeRange];
    
    for (id<MLTimeRangeMappingEffect> timeEffect in self.effectStash) {
        [self.document addTimeRangeMappingEffect:timeEffect];
    }
    
    for (NSValue *value in self.viewStash) {
        CMTimeRange timeRange = [value CMTimeRangeValue];
        [trimView insertTimeRange:timeRange];
    }
    
    self.segmentFactors = [NSMutableArray arrayWithArray:self.factorStash];
}

- (CMTimeRange)convertToPresentationTimeRange:(MDVideoTrimmerView *)trimmerView
{
    NSInteger index = trimmerView.selectedTrimmerRangeIndex;
    
    id<MLTimeRangeMappingEffect> timeEffect = [[self.document timeRangeMappingEffects] objectAtIndex:index defaultValue:nil];
    CMTime targetDuration = [(id<MLTimeRangeMappingEffect>)timeEffect targetDuration];
    
    CMTimeRange timeRange = trimmerView.selectedTrimmerTimeRange;
    CMTime convertedTime = [self.document convertToPresentationTimeFromMediaSourceTime:timeRange.start];
    CMTimeRange convertedTimeRange = CMTimeRangeMake(convertedTime, targetDuration);
    
    return convertedTimeRange;
}


- (CMTime)convertToMediaSouceTimeFromPresentationTime:(CMTime)presentationTime
{
    return [self.document convertToMediaSouceTimeFromPresentationTime:presentationTime];
}

- (CMTime)convertToPresentationTimeFromMediaSourceTime:(CMTime)mediaSourceTime
{
    return [self.document convertToPresentationTimeFromMediaSourceTime:mediaSourceTime];
}

- (float)speedFactorWithVideoTrimView:(MDVideoTrimmerView *)trimmerView
{
    return [self.segmentFactors floatAtIndex:trimmerView.selectedTrimmerRangeIndex defaultValue:.0f];
}

@end
