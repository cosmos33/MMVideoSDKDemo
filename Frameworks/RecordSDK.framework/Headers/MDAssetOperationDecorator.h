//
//  MDAssetOperationDecorator.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/14.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MDAssetProcessProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetOperationDecorator : NSObject <MDAssetProcessProtocol>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithProcedure:(id<MDAssetProcessProtocol>)procedure NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) id<MDAssetProcessProtocol> procedure;

@end

NS_ASSUME_NONNULL_END
