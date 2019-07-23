//
//  EtaClassTransformValue.h
//  MomoChat
//
//  Created by momo783 on 15/12/20.
//  Copyright © 2015年 wemomo.com. All rights reserved.
//

#import "EtaValueTransformer.h"

/**
 *  special tansformation for Class Object
 */

@protocol EtaSerializing;

NS_ASSUME_NONNULL_BEGIN

@interface EtaClassTransformer : NSObject <EtaValueTransformer>

- (instancetype)initWithClass:(Class <EtaSerializing>)modelClass;

@end

NS_ASSUME_NONNULL_END
