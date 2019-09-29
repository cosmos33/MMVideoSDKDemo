//
//  MDVideoSpeedVaryHandler.h
//  MDChat
//
//  Created by wangxuan on 17/2/23.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
@class MDDocument;
@class MDVideoTrimmerView;

@interface MDVideoSpeedVaryHandler : NSObject

@property (nonatomic, strong) NSMutableArray    *segmentFactors;

- (instancetype)initWithDocument:(MDDocument *)document;

/*增,删,改*/
- (BOOL)addEffect:(float)factor duration:(NSTimeInterval)duration videoTrimView:(MDVideoTrimmerView *)trimView;
- (BOOL)removeCurrentEffectOnVideoTrimView:(MDVideoTrimmerView *)trimView;
- (BOOL)changeEffectFactor:(float)factor videoTrimView:(MDVideoTrimmerView *)trimView;
- (void)scaleEffectOnVideoTrimView:(MDVideoTrimmerView *)trimView;
- (void)stashEffectsOnVideoTrimView:(MDVideoTrimmerView *)trimView;
- (void)recoverFromEffectsStashOnVideoTrimView:(MDVideoTrimmerView *)trimView;

- (CMTime)convertToMediaSouceTimeFromPresentationTime:(CMTime)presentationTime;
- (CMTime)convertToPresentationTimeFromMediaSourceTime:(CMTime)mediaSourceTime;

- (CMTimeRange)convertToPresentationTimeRange:(MDVideoTrimmerView *)trimmerView;
- (float)speedFactorWithVideoTrimView:(MDVideoTrimmerView *)trimmerView;

@end
