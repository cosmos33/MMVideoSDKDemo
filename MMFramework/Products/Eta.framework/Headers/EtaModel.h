//
//  EtaModel.h
//  MomoChat
//
//  Created by momo783 on 15/12/19.
//  Copyright © 2015年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EtaSerializing.h"
#import "EtaInnerProtocols.h"

/**
 *  JSON Transformation Base Model Class
 */

NS_ASSUME_NONNULL_BEGIN

@interface EtaModel : NSObject <EtaSerializing>

/**
 current class property bitarray，bit count depend on property count.
 */
@property (readonly) id<EtaBitArray> bits;

/** 
 merge property value from anthor object
 *
 *  @param model same kind class model.(super class or sub class is be allowed)
 */
- (void)mergeFrom:(EtaModel*)model;

/**
 transform json dictionary into EtaModel object automatically
 *
 *  @param dictionary json dictionary object
 *  @return EtaModel object，if dictionary is empty or nil，return nil.
 */
+ (instancetype)eta_modelFromDictionary:(NSDictionary *)dictionary;

/**
 transform EtaModel object into json dictionary automatically
 *
 *  @param model EtaModel object
 *  @return JSON dictionary
 */
+ (NSDictionary *)eta_dictionaryFromModel:(id <EtaSerializing>)model;


/**
 transform json dictionary array into EtaModel object array automatically.
 *
 *  @param list JSON array
 *  @return models EtaModel objects.
 */
+ (NSArray *)eta_modelsFromDictArray:(NSArray *)list;

/**
 transform EtaModel object array into json dictionary array automatically.
 *
 *  @param models EtaModel objects
 *  @return models JSON array
 */
+ (NSArray *)eta_dictArrayFromModels:(NSArray *)models;

@end

NS_ASSUME_NONNULL_END
