//
//  MDAssetBGMAudioComposite.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/14.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "MDAssetOperationDecorator.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetBGMAudioComposite : MDAssetOperationDecorator

- (instancetype)initWithProcedure:(id<MDAssetProcessProtocol>)procedure backgroundMusicAsset:(AVAsset *)musicAsset range:(CMTimeRange)range;

@property (nonatomic, strong) AVAsset *musicAsset;

@property (nonatomic, strong) AVAssetTrack *musicTrack;

@end

NS_ASSUME_NONNULL_END
