//
//  MDAssetSpeedVary.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/14.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "MDAssetOperationDecorator.h"

@protocol MLTimeRangeMappingEffect;

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetScale : MDAssetOperationDecorator

- (instancetype)initWithProcedure:(id<MDAssetProcessProtocol>)procedure rangeMappingEffect:(id<MLTimeRangeMappingEffect>)rangeMappingEffect;

@end

NS_ASSUME_NONNULL_END
