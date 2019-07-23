//
//  MDAssetRepeat.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/14.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "MDAssetOperationDecorator.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetRepeat : MDAssetOperationDecorator

- (instancetype)initWithProcedure:(id<MDAssetProcessProtocol>)procedure repeatRange:(CMTimeRange)repeatRange times:(NSInteger)times;

@end

NS_ASSUME_NONNULL_END
