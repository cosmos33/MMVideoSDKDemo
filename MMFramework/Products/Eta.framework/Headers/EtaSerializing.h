//
//  EtaSerializing.h
//  Eta
//
//  Created by momo783 on 2017/6/23.
//  Copyright © 2017年 momo783. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EtaSerializing <NSObject, NSCopying>

@required

/**
 Obtain a JSON dictionary data of key path and the proprty attribute name mapping.
 *
 *  @return dictionary , key is proprty attribute name,value is json value key.
 */
+ (NSDictionary *)eta_jsonKeyPathsByProperty;

@optional

/**
 Special Transfromation for special JSON value.
 *
 *  @return dictionary, key is proprty attribute name, value is a object that implementing the protocol ’EtaValueTransformer'.
 */
+ (NSDictionary *)eta_valueTransform;

/**
special treatment after JSON object transformation , 
as far as possible avoid don't call this interface,even want to use, also can't call the EtaStorage interface, avoid recursive infinite loop
 *
 *  @param model EtaModel object from dict
 *  @param dict JSON Dictionary
 */
+ (void)etafinishedModel:(id)model withDict:(NSDictionary *)dict;


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


@end

NS_ASSUME_NONNULL_END

