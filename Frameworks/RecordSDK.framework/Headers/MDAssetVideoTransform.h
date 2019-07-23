//
//  MDAssetVideoTransform.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/14.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "MDAssetOperationDecorator.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetVideoTransform : MDAssetOperationDecorator

- (instancetype)initWithProcedure:(id<MDAssetProcessProtocol>)procedure
           withPreferredTransform:(CGAffineTransform)transform;

@property (nonatomic, assign) CGAffineTransform preferredTransform;

@end

NS_ASSUME_NONNULL_END
