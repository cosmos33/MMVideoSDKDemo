//
//  EtaClassInfo.h
//  MantleDemo
//
//  Created by momo783 on 16/1/13.
//  Copyright © 2016年 momo783. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/**
 *  come from YYModel
 */
NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, EtaEncodingType) {
    EtaEncodingTypeMask       = 0xFF,   // mask of type value
    EtaEncodingTypeUnknown    = 0,      // unknown
    EtaEncodingTypeVoid       = 1,      // void
    EtaEncodingTypeBool       = 2,      // bool
    EtaEncodingTypeInt8       = 3,      // char / BOOL
    EtaEncodingTypeUInt8      = 4,      // unsigned char
    EtaEncodingTypeInt16      = 5,      // short
    EtaEncodingTypeUInt16     = 6,      // unsigned short
    EtaEncodingTypeInt32      = 7,      // int
    EtaEncodingTypeUInt32     = 8,      // unsigned int
    EtaEncodingTypeInt64      = 9,      // long long
    EtaEncodingTypeUInt64     = 10,     // unsigned long long
    EtaEncodingTypeFloat      = 11,     // float
    EtaEncodingTypeDouble     = 12,     // double
    EtaEncodingTypeLongDouble = 13,     // long double
    EtaEncodingTypeObject     = 14,     // id
    EtaEncodingTypeClass      = 15,     // Class
    EtaEncodingTypeSEL        = 16,     // SEL
    EtaEncodingTypeBlock      = 17,     // block
    EtaEncodingTypePointer    = 18,     // void*
    EtaEncodingTypeStruct     = 19,     // struct
    EtaEncodingTypeUnion      = 20,     // union
    EtaEncodingTypeCString    = 21,     // char*
    EtaEncodingTypeCArray     = 22,     // char[10] (for example)
    
    EtaEncodingTypeQualifierMask   = 0xFF00,    // mask of qualifier
    EtaEncodingTypeQualifierConst  = 1 << 8,    // const
    EtaEncodingTypeQualifierIn     = 1 << 9,    // in
    EtaEncodingTypeQualifierInout  = 1 << 10,   // inout
    EtaEncodingTypeQualifierOut    = 1 << 11,   // out
    EtaEncodingTypeQualifierBycopy = 1 << 12,   // bycopy
    EtaEncodingTypeQualifierByref  = 1 << 13,   // byref
    EtaEncodingTypeQualifierOneway = 1 << 14,   // oneway
    
    EtaEncodingTypePropertyMask         = 0xFF0000,     // mask of property
    EtaEncodingTypePropertyReadonly     = 1 << 16,      // readonly
    EtaEncodingTypePropertyCopy         = 1 << 17,      // copy
    EtaEncodingTypePropertyRetain       = 1 << 18,      // retain
    EtaEncodingTypePropertyNonatomic    = 1 << 19,      // nonatomic
    EtaEncodingTypePropertyWeak         = 1 << 20,      // weak
    EtaEncodingTypePropertyCustomGetter = 1 << 21,      // getter=
    EtaEncodingTypePropertyCustomSetter = 1 << 22,      // setter=
    EtaEncodingTypePropertyDynamic      = 1 << 23,      // @dynamic
};

EtaEncodingType EtaEncodingGetType(const char *typeEncoding);

@interface EtaProPertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property;
@property (nonatomic, assign, readonly) EtaEncodingType type;       // property ecoding type
@property (nonatomic, strong, readonly) NSString        *name;      // property name

@property (nonatomic, assign, readonly) Class   cls;                // property depend on class
@property (nonatomic, assign, readonly) SEL     getter;             // getter SEL
@property (nonatomic, assign, readonly) SEL     setter;             // setter SEL
@property (nonatomic, assign, readonly) SEL     trueSetter;         // real setter SEL

@property (nonatomic, assign) NSInteger mergeIndex;                 // proprty custom index

- (instancetype)initWithProperty:(objc_property_t)property andClass:(Class)modelClass;

@end

@interface EtaProPertyInfo (DEPRECATED)

@property (nonatomic, assign, readonly) IMP     setterImp DEPRECATED_ATTRIBUTE; // setter IMP
@property (nonatomic, assign, readonly) IMP     emptyImp DEPRECATED_ATTRIBUTE;  // empty  IMP

@end


@interface EtaClassInfo : NSObject

@property (nonatomic, assign, readonly) NSInteger       propCount;  // property count of class and super class
@property (nonatomic, strong, readonly) NSDictionary    *propDict;  // key is property name, value is EtaProPertyInfo

@property (nonatomic, assign, readonly) Class   cls;    // current class
@property (nonatomic, assign, readonly) Class   scls;   // super class

- (instancetype)initWithClass:(Class)cls;

@end

@interface EtaClassInfo (DEPRECATED)

@property (nonatomic, strong, readonly) NSDictionary    *setSelDict DEPRECATED_ATTRIBUTE;// key is property setter name, value is EtaProPertyInfo

@end

NS_ASSUME_NONNULL_END
