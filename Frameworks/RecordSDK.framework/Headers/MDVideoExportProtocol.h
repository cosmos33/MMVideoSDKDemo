//
//  MDVideoExportProtocol.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/16.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDCancellable.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDVideoExportProtocol <NSObject>

- (id<MDCancellable> _Nullable)exportToURL:(NSURL *)url
                           progressHandler:(void(^ _Nullable)(double progress))progressHandler
                                completion:(void(^ _Nullable)(NSURL *url))completion
                                   failure:(void(^ _Nullable)(NSError * _Nullable error))failure;

@end

NS_ASSUME_NONNULL_END
