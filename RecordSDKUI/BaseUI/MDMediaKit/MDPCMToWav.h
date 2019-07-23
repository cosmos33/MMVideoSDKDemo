//
//  MDPCMToWav.h
//  MDChat
//
//  Created by jichuan on 2017/7/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDPCMToWavDescriptor : NSObject <NSCopying>

@property (nonatomic, copy) NSURL *sourceURL;

@property (nonatomic, copy) NSURL *destinationURL;

@property (nonatomic) AudioStreamBasicDescription asbd;

@end

@interface MDPCMToWavCommand : NSObject

@property (readonly) BOOL available;
@property (nonatomic, copy) void (^completionHandler)(NSError * _Nullable);

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDescriptor:(MDPCMToWavDescriptor *)descriptor NS_DESIGNATED_INITIALIZER;

- (void)commit;

@end

NS_ASSUME_NONNULL_END
