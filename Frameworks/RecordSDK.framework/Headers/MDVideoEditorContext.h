//
//  MDVideoEditorContext.h
//  MDRecordSDK
//
//  Created by sunfei on 2018/10/30.
//

#import "MDMediaEditorContext.h"
#import "MDAssetPorcessBuilder.h"
#import "MDVideoExportProtocol.h"
#import <AVFoundation/AVFoundation.h>

@class MDRecordPlayerViewController;

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoEditorContext : MDMediaEditorContext


@property (nonatomic, strong) id<MDProcessImageProtocol> filter;
// preview video
@property (nonatomic, readonly) MDRecordPlayerViewController *playerViewController;

// updating asset
@property (nonatomic, strong, readonly) AVAsset *composition;

- (void)updateAssetUsingAsset:(AVAsset *)processedAsset audioMix:(AVAudioMix * _Nullable)audioMix;
- (void)udpateAudioMix:(AVAudioMix *)audioMix;

@property (nonatomic, copy) void(^ _Nullable playToEndTime)(AVPlayer *player);
@property (nonatomic, copy) void(^ _Nullable playerPeriodicTimeCallback)(CMTime time);

- (void)play;
- (void)pause;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
