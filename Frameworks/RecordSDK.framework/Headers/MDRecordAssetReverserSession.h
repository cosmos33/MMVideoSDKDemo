//
//  MDAssetReverserSession.h
//  testGPU
//
//  Created by YZK on 2018/8/1.
//  Copyright © 2018年 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MDRecordAssetReverserSession : NSObject

- (instancetype)initWithAsset:(AVAsset *)asset outputURL:(NSURL *)outputURL;

@property (nonatomic,copy) void (^progressUpdateHandler)(float progress); //在非主线程调用

- (void)reverseWithReverseAudio:(BOOL)reverseAudio completion:(void(^)(NSError *error))completion; //在非主线程调用

- (void)cancel;

@end

