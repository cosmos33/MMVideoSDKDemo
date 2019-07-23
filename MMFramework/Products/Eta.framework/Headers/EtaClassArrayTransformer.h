//
//  EtaClassArrayTransformValue.h
//  MomoChat
//
//  Created by momo783 on 15/12/23.
//  Copyright © 2015年 wemomo.com. All rights reserved.
//

#import "EtaValueTransformer.h"

/**
 *  special transformation for EtaModel array value
 */

@protocol EtaSerializing;

NS_ASSUME_NONNULL_BEGIN

@interface EtaClassArrayTransformer : NSObject <EtaValueTransformer>

- (instancetype)initWithClass:(Class <EtaSerializing>)modelClass;

@end

NS_ASSUME_NONNULL_END
