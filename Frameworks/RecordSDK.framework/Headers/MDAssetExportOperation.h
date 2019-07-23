//
//  MDAssetExportOperation.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/17.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDCancellable.h"

@class MLAVAssetExportSession;

NS_ASSUME_NONNULL_BEGIN

@protocol MDAssetExportSession <NSObject>

@property (nonatomic, copy) void(^ _Nullable completionHandler)(NSURL *);
@property (nonatomic, copy) void(^ _Nullable failureHandler)(NSError *);
@property (nonatomic, copy) void(^ _Nullable progressHandler)(double progress);
- (NSOperation *)operation;

@end

@interface MDAssetExportOperation : NSOperation <MDAssetExportSession, MDCancellable>

@property (nonatomic, readonly) MLAVAssetExportSession *session;

- (instancetype)initWithExportSession:(MLAVAssetExportSession *)session;

@end

NS_ASSUME_NONNULL_END
