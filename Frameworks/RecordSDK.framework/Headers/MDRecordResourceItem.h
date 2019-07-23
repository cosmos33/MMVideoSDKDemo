//
//  MDRecordResourceItem.h
//  CXBeautyKit
//
//  Created by sunfei on 2019/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordResourceItem : NSObject <NSCopying>

@property (nonatomic, copy) NSString    *resourceName;
@property (nonatomic, copy) NSString    *md5;
@property (nonatomic, copy) NSString    *guid;
@property (nonatomic, copy) NSString    *suffix;
//rsa sign
@property (nonatomic, copy) NSString    *sign;

@property (nonatomic, readonly) NSURL *remoteURL;
@property (nonatomic, readonly) NSString *localFileName;

- (instancetype)initWithResourceName:(NSString *)name itemDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
