//
//  EtaBlockTransformer.h
//  MomoChat
//
//  Created by Dai Dongpeng on 16/01/2017.
//  Copyright © 2017 wemomo.com. All rights reserved.
//

#import <Eta/EtaValueTransformer.h>

/**
 *  special transformation with block.
 */

NS_ASSUME_NONNULL_BEGIN

@interface EtaBlockTransformer : NSObject <EtaValueTransformer>

+ (instancetype)transformerWithDecodeBlock:(id (^)(id from))decode encodeBlock:(id (^)(id from))encode;

@end

NS_ASSUME_NONNULL_END
