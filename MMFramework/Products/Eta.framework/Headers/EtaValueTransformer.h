//
//  EtaValueTransformer.h
//  MomoChat
//
//  Created by momo783 on 15/12/19.
//  Copyright © 2015年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  special value transform protocol
 *
 *  if json value transform to model value can‘t be completed , 
 *  implementing this protocol to transform this value into model value.
 */

NS_ASSUME_NONNULL_BEGIN

@protocol EtaValueTransformer <NSObject>

/**
 *  transform json value into model value.
 *
 *  @param jsonValue value form json object
 *  @return model value , if jsonValue is nil or decode failed , return nil.
 */
- (nullable id)decodeValue:(nullable id)jsonValue;

/**
 *  transform model value into json value.
 *
 *  @param modelValue value from model property.
 *  @return json value , if modelValue is nil or encode failed, return nil.
 */
- (nullable id)encodeValue:(nullable id)modelValue;

@end

NS_ASSUME_NONNULL_END
