//
//  MDSoundTracker.h
//  MDChat
//
//  Created by jichuan on 2017/9/1.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

// Not thread-safe
@interface MDSoundTracker : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithModelPath:(nullable NSString *)path error:(NSError * __autoreleasing *)error NS_DESIGNATED_INITIALIZER;

- (void)inputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (BOOL)getCurrentTrackerStatus;
- (NSInteger)getCurrentTrackerEnergyRank;

- (void)insertLastSegment;
- (void)deleteLastSegment;

- (void)reset;
@end

@interface MDSoundTracker (PCM)

+ (BOOL)inputPCM:(NSData *)data
            asbd:(const AudioStreamBasicDescription *)asbd
       modelPath:(nullable NSString *)path
           error:(NSError * __autoreleasing *)error;
@end

NS_ASSUME_NONNULL_END
