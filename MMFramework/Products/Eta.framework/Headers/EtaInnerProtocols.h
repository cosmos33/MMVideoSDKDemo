//
//  EtaInnerProtocols.h
//  Eta
//
//  Created by momo783 on 2017/6/23.
//  Copyright © 2017年 momo783. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EtaClassInfo;
@class EtaProPertyInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Proctcol for Eta extention
 */

@protocol EtaInnerProtocol <NSObject>

+ (EtaClassInfo *)eta_classInfo;

+ (NSCache *)propertyDictInfoCache;
+ (NSDictionary *)propertyDictInfoWithClass:(Class)modelClass;

- (nullable id)eta_valueForInfo:(EtaProPertyInfo *)info;
- (void)eta_setValue:(id)value forInfo:(EtaProPertyInfo *)info;

@end

/**
 *  Protocol for Eta flag object
 */

@protocol EtaBitArray <NSObject>

@required

- (BOOL)bitAt:(NSInteger)index;
- (void)setBitAt:(NSInteger)index;

- (void)minus:(id <EtaBitArray>)bitArray;

- (BOOL)lost;

- (NSInteger)count;

@end

/**
 *  Protocol for EtaStorage ， Framework internal call.
 */

@protocol EtaValueTransformer;

@protocol EtaTransformInfo <NSObject>

@property (assign ,readonly) BOOL longKey;
@property (strong ,readonly) NSArray *keyPaths;

@property (strong ,readonly) EtaProPertyInfo *property;

@property (assign) BOOL customTransform;
@property (strong) id <EtaValueTransformer> valueTransformer;

@end

NS_ASSUME_NONNULL_END


