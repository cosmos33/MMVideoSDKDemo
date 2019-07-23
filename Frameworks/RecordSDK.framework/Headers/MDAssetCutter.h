//
//  MDAssetCutter.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/14.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "MDAssetProcessProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetCutter : NSObject <MDAssetProcessProtocol>

- (instancetype)initWithCutRange:(CMTimeRange)range;

@property (nonatomic, readonly) CMTimeRange cutRange;

@end

NS_ASSUME_NONNULL_END
