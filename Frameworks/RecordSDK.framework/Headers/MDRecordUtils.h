//
//  MDRecordUtils.h
//  CXBeautyKit
//
//  Created by sunfei on 2019/2/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordUtils : NSObject

+ (void)putObj:(id)obj forKey:(NSString *)key;

+ (NSString *)getObjForKey:(NSString *)key;

+ (void)deleteValue:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
