//
//  MDRSimpleHttpFetcher.h
//  MDRPlayer
//
//  Created by sunfei on 2019/5/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MDRCancellable <NSObject>

- (void)cancel;

@end

@interface NSURLSessionTask (MDRResourceLoading) <MDRCancellable>

@end

@interface MDRRemoteResouce<ObjectType>: NSObject

@property (nonatomic, copy) NSURL *remoteURL;
@property (nonatomic, copy) NSDictionary<NSString *, id> *customParams;
@property (nonatomic, copy) ObjectType(^parser)(id, NSError **error);

@end

@interface MDRSimpleHttpFetcher<ObjectType> : NSObject

+ (MDRSimpleHttpFetcher *)GET;
+ (MDRSimpleHttpFetcher *)POST;

@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *headers;

- (id<MDRCancellable>)loadResource:(MDRRemoteResouce<ObjectType> *)resouce
                             queue:(dispatch_queue_t _Nullable)queue
                        completion:(void(^)(id data, NSData *rawData, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
