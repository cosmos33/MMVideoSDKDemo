//
//  MDAssetReversedManager.h
//  testGPU
//
//  Created by YZK on 2018/8/1.
//  Copyright © 2018年 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MDRecordVideoSegment.h"

@interface MDRecordAssetReversedManager : NSObject

+ (NSString *)reversedAssetCacheKeyForSegment:(MDRecordVideoSegment *)segment;

+ (NSURL *)cacheDirectoryURL;

+ (NSURL *)reversedAssetTempURLForSegment:(MDRecordVideoSegment *)segment;

+ (NSURL *)reversedAssetCacheURLForURL:(NSURL *)URL;
+ (NSURL *)reversedAssetCacheURLForSegment:(MDRecordVideoSegment *)segment;


+ (void)clearCachedReversedAssets;
+ (AVAsset *)cachedReversedAssetForURL:(NSURL *)URL;
+ (AVAsset *)cachedReversedAssetForSegment:(MDRecordVideoSegment *)segment;

//在非主线程回调
+ (NSOperation *)assetReverseOperationForURL:(NSURL *)URL
                                  completion:(void (^)(NSURL *outputURL))completion
                                     failure:(void (^)(NSError *error))failure
                                    progress:(void (^)(float progress))progress;
+ (NSOperation *)assetReverseOperationForSegment:(MDRecordVideoSegment *)segment
                                      completion:(void (^)(NSURL *outputURL))completion
                                         failure:(void (^)(NSError *error))failure
                                        progress:(void (^)(float progress))progress;
+ (void)cancelReverseOperation;

@end

