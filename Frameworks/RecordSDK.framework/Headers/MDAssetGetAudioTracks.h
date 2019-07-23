//
//  MDAssetGetAudioTracks.h
//  MomoChat
//
//  Created by sunfei on 2019/1/2.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "MDAssetOperationDecorator.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetGetAudioTracks : MDAssetOperationDecorator

@property (nonatomic, readonly) NSArray<AVAssetTrack *> *audioTracks;

@end

NS_ASSUME_NONNULL_END
