//
//  MDSoundPitchShift.h
//  MDChat
//
//  Created by jichuan on 2017/7/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDSoundPitchShiftDescriptor : NSObject <NSCopying>

@property (nonatomic, copy) NSData *pcm;

@property (nonatomic) AudioStreamBasicDescription asbd; // only support 16 bit depth

@property (nonatomic) NSInteger pitch;

@property (nonatomic, copy, nullable) NSURL *destinationURL;

@end

@interface MDSoundPitchShiftCommand : NSObject

@property (readonly) BOOL available;

@property (nonatomic, copy) void (^completionHandler)(NSData * _Nullable, NSError * _Nullable);

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDescriptor:(MDSoundPitchShiftDescriptor *)descriptor NS_DESIGNATED_INITIALIZER;

- (void)commit;

@end

NS_ASSUME_NONNULL_END
