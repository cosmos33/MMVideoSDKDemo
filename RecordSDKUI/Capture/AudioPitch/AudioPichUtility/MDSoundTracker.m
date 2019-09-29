//
//  MDSoundTracker.m
//  MDChat
//
//  Created by jichuan on 2017/9/1.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDSoundTracker.h"
#import <MMFoundation/MMFoundation.h>
@import MomoCV;

#define MMSoundTrackerClass (NSClassFromString(@"MMSoundTracker"))
#define MMSoundTrackOptionsClass (NSClassFromString(@"MMSoundTrackOptions"))

static void MomoCVFramewrokCheckInitializeLoaded()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *momoCVBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"MomoCV" withExtension:@"framework" subdirectory:@"Frameworks"]];
        if (!momoCVBundle.isLoaded) {
            NSError *error;
            [momoCVBundle loadAndReturnError:&error];
            NSCAssert(!error, @"Load CVFramework Failed: %@", error);
        }
    });
}

@interface MDSoundTracker ()
@property (nonatomic, strong) id soundTracker;
@end

@implementation MDSoundTracker {
    NSInteger segmentIndex;
}

- (instancetype)initWithModelPath:(nullable NSString *)path error:(NSError * _Nullable __autoreleasing *)error
{
    MomoCVFramewrokCheckInitializeLoaded();
    self = [super init];
    if (self) {
        NSError *outError = nil;
        if ([path isNotEmpty]) {
            NSBundle *bundle = [NSBundle bundleWithPath:path];
            if (bundle) {
                if ([MMSoundTrackerClass validateModelBundle:bundle]) {
                    id soundTracker = [[MMSoundTrackerClass alloc] initWithModelBundle:bundle error:&outError];
                    if (soundTracker) {
                        self.soundTracker = soundTracker;
                    } else {
                        if (!outError) {
                            outError = [NSError errorWithDomain:@"com.sdk.sound-tracker" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"SoundTracker inner initialize failed"}];
                        }
                    }
                } else {
                    outError = [NSError errorWithDomain:@"com.sdk.sound-tracker" code:-2 userInfo:@{NSLocalizedDescriptionKey : @"SoundTracker validateModelBundle failed"}];
                }
            } else {
                outError = [NSError errorWithDomain:@"com.sdk.sound-tracker" code:-3 userInfo:@{NSLocalizedDescriptionKey : @"SoundTracker getBundleWithPath failed"}];
            }
        } else {
            id soundTracker = [[MMSoundTrackerClass alloc] initWithModelBundle:nil error:&outError];
            if (soundTracker) {
                self.soundTracker = soundTracker;
            } else {
                if (!outError) {
                    outError = [NSError errorWithDomain:@"com.sdk.sound-tracker" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"SoundTracker inner initialize failed"}];
                }
            }
        }
        
        if (outError) {
            NSAssert(NO, @"SoundTracker initialize failed, %@", outError);
            if (error) {
                *error = outError;
            }
            return nil;
        }
        
        segmentIndex = 0;
    }
    return self;
}

- (void)inputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
{
    NSParameterAssert(sampleBuffer);
    if (segmentIndex >= 0) {
        CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
        if (formatDescription) {
            CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDescription);
            if (mediaType == kCMMediaType_Audio) {
                const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription);
                if (asbd && asbd->mSampleRate == 44100 && asbd->mBitsPerChannel == 16 && (asbd->mChannelsPerFrame == 1 || asbd->mChannelsPerFrame == 2)) {
                    id options = [[MMSoundTrackOptionsClass alloc] initWithRate:asbd->mSampleRate channels:asbd->mChannelsPerFrame reserved:@[]];
                    
                    AudioBufferList audioBufferList;
                    CMBlockBufferRef blockFuffer = NULL;
                    OSStatus status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer,
                                                                                              NULL,
                                                                                              &audioBufferList,
                                                                                              sizeof(audioBufferList),
                                                                                              NULL,
                                                                                              NULL,
                                                                                              0,
                                                                                              &blockFuffer);
                    if (status == noErr && audioBufferList.mNumberBuffers) {
                        /* 和图像音频组约定:只传单个声道的数据
                         for (int i = 0; i < audioBufferList.mNumberBuffers; i++) {
                         AudioBuffer audioBuffer = audioBufferList.mBuffers[i];
                         NSData *data = [NSData dataWithBytes:audioBuffer.mData length:audioBuffer.mDataByteSize];
                         BOOL ret = [self.soundTracker processSoundData:data segmentIndex:segmentIndex options:options];
                         NSAssert(ret, @"Error: Sound Tracker process return failed");
                         }
                         */
                        AudioBuffer audioBuffer = audioBufferList.mBuffers[0];
                        NSData *data = [NSData dataWithBytes:audioBuffer.mData length:audioBuffer.mDataByteSize];
                        [self.soundTracker processSoundData:data segmentIndex:segmentIndex options:options];
                        
                    } else {
                        NSAssert(NO, @"Error: CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer failed (%@)", @(status));
                    }
                    
                    if (blockFuffer) {
                        CFRelease(blockFuffer);
                    }
                    
                } else {
                    NSAssert(NO, @"Error: Check the asbd of input audio buffer ");
                }
            } else {
                NSAssert(NO, @"Error: Must input audio buffer");
            }
        } else {
            NSAssert(NO, @"Error: CMSampleBufferGetFormatDescription Failed");
        }
    } else {
        NSAssert(NO, @"Error: Insert segment first");
    }
}

- (BOOL)getCurrentTrackerStatus
{
    return [self.soundTracker getTrackResult].label;
}

- (NSInteger)getCurrentTrackerEnergyRank
{
    return [self.soundTracker getTrackResult].energyRank;
}

- (void)insertLastSegment
{
    segmentIndex++;
}

- (void)deleteLastSegment
{
    if (segmentIndex >= 0) {
        segmentIndex--;
        [self.soundTracker deleteSegment:segmentIndex];
    }
}

- (void)reset
{
    segmentIndex = 0;
    [self.soundTracker reset];
}

@end

@implementation MDSoundTracker (PCM)

+ (BOOL)inputPCM:(NSData *)data asbd:(nonnull const AudioStreamBasicDescription *)asbd modelPath:(nullable NSString *)path error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    MDSoundTracker *st = [[MDSoundTracker alloc] initWithModelPath:path error:error];
    if (st && data && asbd) {
        if (asbd->mSampleRate == 44100 && asbd->mBitsPerChannel == 16 && (asbd->mChannelsPerFrame == 1 || asbd->mChannelsPerFrame == 2)) {
            id options = [[MMSoundTrackOptionsClass alloc] initWithRate:asbd->mSampleRate channels:asbd->mChannelsPerFrame reserved:@[]];
            
            NSUInteger loc = 0;
            NSUInteger len = 1024 * sizeof(int16_t);
            
            while (loc + len < data.length) {
                NSData *subdata = [data subdataWithRange:NSMakeRange(loc, len)];
                if (subdata) {
                    [st.soundTracker processSoundData:subdata segmentIndex:0 options:options];
                    loc += len;
                } else {
                    break;
                }
            }
            
            return [st getCurrentTrackerStatus];
        } else {
            NSAssert(NO, @"Error: Check the asbd of input audio buffer ");
        }
    }
    return NO;
}

@end
