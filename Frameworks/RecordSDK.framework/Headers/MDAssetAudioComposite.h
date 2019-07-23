//
//  MDAssetAudioComposite.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/14.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "MDAssetOperationDecorator.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetAudioComposite : MDAssetOperationDecorator

- (instancetype)initWithProcedure:(id<MDAssetProcessProtocol>)procedure audioAsset:(AVAsset *)audioAsset;

@property (nonatomic, strong) AVAssetTrack *audioTrack;

@end

NS_ASSUME_NONNULL_END
