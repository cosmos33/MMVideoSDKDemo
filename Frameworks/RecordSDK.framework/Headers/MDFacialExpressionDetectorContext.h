//
//  MMFacialExpressionDetectorContext.h
//  CXBeautyKit
//
//  Created by sunfei on 2018/11/27.
//

#import <Foundation/Foundation.h>
#import "MDImageDetectorProtocol.h"

@class MMFacialExpression;

NS_ASSUME_NONNULL_BEGIN

@interface MDFacialExpressionDetectorContext : NSObject <MDImageDetectorProtocol>

- (instancetype)init;

@property (nonatomic, readonly) NSArray<MMFacialExpression *> *result;

@end

NS_ASSUME_NONNULL_END
