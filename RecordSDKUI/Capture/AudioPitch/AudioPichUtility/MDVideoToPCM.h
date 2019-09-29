//
//  MDVideoToPCM.h
//  MDChat
//
//  Created by jichuan on 2017/7/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoToPCMDescriptor : NSObject <NSCopying>

@property (nonatomic, copy) AVAsset *asset;

@property (nonatomic, copy, nullable) NSURL *destinationURL;

@end

@interface MDVideoToPCMCommand : NSObject

@property (readonly) BOOL available;

@property (nonatomic, copy) void (^completionHandler)(NSData * _Nullable, const AudioStreamBasicDescription * CM_NULLABLE, NSError * _Nullable);

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDescriptor:(MDVideoToPCMDescriptor *)descriptor NS_DESIGNATED_INITIALIZER;

- (void)commit;

@end

NS_ASSUME_NONNULL_END
