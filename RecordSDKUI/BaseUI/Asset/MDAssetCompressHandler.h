//
//  MDAssetCompressHandler.h
//  MDChat
//
//  Created by YZK on 2018/11/1.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDAssetCompressHandler : NSObject

- (void)applicationWillResignActive;

- (void)compressorVideoWithPHAsset:(PHAsset *)phAsset
                             asset:(AVAsset *)asset
                          mediaURL:(NSURL *)mediaURL
                         timeRange:(CMTimeRange)timeRange
                       hasCutVideo:(BOOL)hasCutVideo
                 progressSuperView:(UIView *)view
                 completionHandler:(void (^) (NSURL *))completionHandler
                     cancelHandler:(void (^) (void))cancelHandler;

- (BOOL)needCompressWithAsset:(AVAsset *)asset
                     mediaURL:(NSURL *)mediaURL;

@end

NS_ASSUME_NONNULL_END
