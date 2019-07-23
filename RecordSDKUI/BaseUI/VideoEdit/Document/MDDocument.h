//
//  MDDocument.h
//  MDChat
//
//  Created by Jc on 17/2/16.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLMediaEditingModel/MLMediaEditingContent.h"
#import <RecordSDK/MDVideoEditorAdapter.h>
@class MDRecordPiplineManager;

@interface MDDocument : NSObject

#pragma mark - init
- (instancetype)initWithAsset:(AVAsset *)asset documentContent:(MLMediaEditingDocumentContent *)documentContent;

#pragma mark - source video
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, assign) CGAffineTransform videoPreferredTransform;
@property (nonatomic, assign) BOOL useOriginalBitRate;

#pragma mark - time range
@property (nonatomic, assign) CMTimeRange videoInsertTimeRange;
@property (nonatomic, assign) CMTimeRange videoExportTimeRange;
@property (nonatomic, assign) CMTimeRange backgroundMusicTimeRange;
@property (nonatomic, assign) CMTimeRange watermarkTimeRange; //the time range of exporting composition

#pragma mark - time scale
- (NSArray<id<MLTimeRangeMappingEffect>> *)timeRangeMappingEffects;;
- (void)addTimeRangeMappingEffect:(id<MLTimeRangeMappingEffect>)effect;
- (void)removeTimeRangeMappingEffect:(id<MLTimeRangeMappingEffect>)effect;

- (CMTime)convertToMediaSouceTimeFromPresentationTime:(CMTime)presentationTime;
- (CMTime)convertToPresentationTimeFromMediaSourceTime:(CMTime)mediaSourceTime;

#pragma mark - audio mix
@property (nonatomic, strong) NSURL *sourcePitchShiftURL;
@property (nonatomic, strong) NSURL *backgroundMusicURL;
@property (nonatomic, assign) double sourceAudioVolume;
@property (nonatomic, assign) BOOL muteSourceAudioVolume;
@property (nonatomic, assign) double backgroundMusicVolume;
//@property (nonatomic, assign) MDAudioBeatType audioBeatType;

#pragma mark - overlay && watermark
@property (nonatomic, strong) UIImage *customOverlay;
@property (nonatomic, strong) UIImage *watermark;


#pragma mark - 画面特效 & 时间特效
- (BOOL)hasSpecialEffects; //是否使用了特效滤镜
//画面特效相关
- (BOOL)hasPictureSpecialEffects; //是否使用了画面特效
//@property (nonatomic, weak) MDRecordPiplineManager *specialPipline;
//时间特效相关
@property (nonatomic, strong) id<MLTimeRangeMappingEffect> timeEffectsItem;

- (void)setPresentRepeatRange:(CMTimeRange)presentRepeatRange;
@property (nonatomic, assign, readonly) CMTimeRange mediaSourceRepeatRange;

@property (nonatomic, assign) BOOL reserve;
@property (nonatomic, strong) AVAsset *reserveAsset;
@property (nonatomic, assign, readonly) CMTimeRange videoReserveInsertTimeRange;
@property (nonatomic, assign, readonly) CMTimeRange videoReserveExportTimeRange;

//@property (nonatomic, readonly) MDVideoAssetProcessBuilder *builder;
@property (nonatomic, readonly) AVAsset *assetToBeProcessed;
@property (nonatomic, strong) MDVideoEditorAdapter *adapter;

@end
