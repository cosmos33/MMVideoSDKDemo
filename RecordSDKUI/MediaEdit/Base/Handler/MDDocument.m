//
//  MDDocument.m
//  MDChat
//
//  Created by Jc on 17/2/16.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDDocument.h"

@interface MDDocument ()
@property (nonatomic, strong) MLMediaEditingDocumentContent *content;
@property (nonatomic, assign           ) CMTimeRange presentRepeatRange;
@property (nonatomic, assign, readwrite) CMTimeRange mediaSourceRepeatRange;
//@property (nonatomic, readwrite) MDVideoAssetProcessBuilder *builder;
@end

@implementation MDDocument

- (instancetype)initWithAsset:(AVAsset *)asset documentContent:(MLMediaEditingDocumentContent *)documentContent
{
    self = [super init];
    if (self) {
        self.sourceAudioVolume = 1.f;
        self.backgroundMusicVolume = 1.f;
        
        self.asset = asset;
        self.content = documentContent ? documentContent : [[MLMediaEditingDocumentContent alloc] init];
        
        AVAssetTrack *videoTrack = [[self.asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (videoTrack) {
            self.videoPreferredTransform = videoTrack.preferredTransform;
        } else {
            self.videoPreferredTransform = CGAffineTransformIdentity;
        }
        
        self.presentRepeatRange = kCMTimeRangeInvalid;
        
//        _builder = [[MDVideoAssetProcessBuilder alloc] init];
    }
    return self;
}

- (NSArray<id<MLTimeRangeMappingEffect>> *)timeRangeMappingEffects
{
    return [self.content timeRangeMappingEffects];
}

- (void)addTimeRangeMappingEffect:(id<MLTimeRangeMappingEffect>)effect
{
    [self.content addTimeRangeMappingEffect:effect];
}

- (void)removeTimeRangeMappingEffect:(id<MLTimeRangeMappingEffect>)effect
{
    [self.content removeTimeRangeMappingEffect:effect];
}

- (CMTime)convertToMediaSouceTimeFromPresentationTime:(CMTime)presentationTime
{
    return [self.content convertToMediaSouceTimeFromPresentationTime:presentationTime];
}

- (CMTime)convertToPresentationTimeFromMediaSourceTime:(CMTime)mediaSourceTime
{
    return [self.content convertToPresentationTimeFromMediaSourceTime:mediaSourceTime];
}

#pragma mark - audio mix
- (void)setBackgroundMusicURL:(NSURL *)backgroundMusicURL
{
    _backgroundMusicURL = backgroundMusicURL;
    if (backgroundMusicURL) {
        AVAsset *asset = [AVURLAsset assetWithURL:backgroundMusicURL];
        MLBackgroundMusicEffect *backgroundMusicEffect = [[MLBackgroundMusicEffect alloc] initWithSourceAssetURL:backgroundMusicURL volume:self.backgroundMusicVolume sourceTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)];
        self.content.backgroundMusicEffects = @[backgroundMusicEffect];
    } else {
        self.content.backgroundMusicEffects = @[];
    }
}

- (void)setSourceAudioVolume:(double)sourceAudioVolume
{
    if (self.muteSourceAudioVolume) {
        sourceAudioVolume = 0;
    }
    _sourceAudioVolume = sourceAudioVolume;
    self.content.sourceAudioVolume = sourceAudioVolume;
}

- (void)setBackgroundMusicVolume:(double)backgroundMusicVolume
{
    _backgroundMusicVolume = backgroundMusicVolume;
    MLBackgroundMusicEffect *backgroundMusicEffect = self.content.backgroundMusicEffects.firstObject;
    if (backgroundMusicEffect) {
        MLBackgroundMusicEffect *updatedEffect = [backgroundMusicEffect backgroundMusicEffectByUpdatingVolume:backgroundMusicVolume];
        self.content.backgroundMusicEffects = @[updatedEffect];
    }
}

#pragma mark - 反转视频

- (BOOL)hasPictureSpecialEffects {
    return self.adapter.hasSpecialFilter;
}

//是否使用了特效滤镜
- (BOOL)hasSpecialEffects {
    //使用了画面滤镜
    if ([self hasPictureSpecialEffects]) {
        return YES;
    }
    //使用了快慢动作
    if (self.timeEffectsItem) {
        return YES;
    }
    //使用了反复
    if (!CMTIMERANGE_IS_INVALID(self.mediaSourceRepeatRange)) {
        return YES;
    }
    //使用了时光倒流
    if (self.reserve) {
        return YES;
    }
    return NO;
}

- (void)setPresentRepeatRange:(CMTimeRange)presentRepeatRange {
    _presentRepeatRange = presentRepeatRange;
    
    if (CMTIMERANGE_IS_INVALID(presentRepeatRange)) {
        _mediaSourceRepeatRange = kCMTimeRangeInvalid;
    }else {
        CMTime start = presentRepeatRange.start;
        CMTime convertStart = CMTimeMakeWithSeconds(CMTimeGetSeconds(start) + CMTimeGetSeconds(self.videoInsertTimeRange.start), presentRepeatRange.duration.timescale);
        _mediaSourceRepeatRange = CMTimeRangeMake(convertStart, presentRepeatRange.duration);
    }
}

- (CMTimeRange)videoReserveInsertTimeRange {
    return CMTimeRangeMake(CMTimeSubtract(self.asset.duration, CMTimeRangeGetEnd(self.videoInsertTimeRange)), self.videoInsertTimeRange.duration);
}
- (CMTimeRange)videoReserveExportTimeRange {
    return CMTimeRangeMake(CMTimeSubtract(self.asset.duration, CMTimeRangeGetEnd(self.videoExportTimeRange)), self.videoExportTimeRange.duration);
}

//- (MDVideoAssetProcessBuilder *)builder {
//    _builder.range = self.videoInsertTimeRange;
//    _builder.videoPreferredTransform = self.videoPreferredTransform;
//    _builder.sourcePitchShiftURL = self.sourcePitchShiftURL;
//    _builder.mediaSourceRepeatRange = self.mediaSourceRepeatRange;
//
//    if (self.timeEffectsItem) {
//        _builder.timeRangeMappingEffects = @[self.timeEffectsItem];
//    } else if (self.timeRangeMappingEffects.count > 0) {
//        _builder.timeRangeMappingEffects = MLTimeRangeMappingEffectSquenceGetMappedSquence(self.timeRangeMappingEffects);
//    } else {
//        _builder.timeRangeMappingEffects = @[];
//    }
//
//    _builder.backgroundMusicURL = self.backgroundMusicURL;
//    _builder.backgroundMusicRange = self.backgroundMusicTimeRange;
//
//    _builder.sourceVolume = self.sourceAudioVolume;
//    _builder.backgroundMusicVolume = self.backgroundMusicVolume;
//
//    return _builder;
//}

- (AVAsset *)assetToBeProcessed {
    if (self.reserve) {
        return self.reserveAsset;
    } else {
        return self.asset;
    }
}

@end
