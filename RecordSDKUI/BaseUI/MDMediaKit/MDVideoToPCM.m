//
//  MDVideoToPCM.m
//  MDChat
//
//  Created by jichuan on 2017/7/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDVideoToPCM.h"
#import "MDMediaCommandQueue.h"

@implementation MDVideoToPCMDescriptor

- (id)copyWithZone:(NSZone *)zone
{
    MDVideoToPCMDescriptor *descriptor = [[MDVideoToPCMDescriptor allocWithZone:zone] init];
    descriptor.asset = self.asset;
    descriptor.destinationURL = self.destinationURL;
    return descriptor;
}

@end

@interface MDVideoToPCMCommand ()
@property (nonatomic, copy) MDVideoToPCMDescriptor *descriptor;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, assign) Float64 sampleRate;
@property (nonatomic, assign) UInt32 bitsPerChannel;
@property (nonatomic, assign) UInt32 numberOfChannels;
@end

@implementation MDVideoToPCMCommand

- (instancetype)initWithDescriptor:(MDVideoToPCMDescriptor *)descriptor
{
    self = [super init];
    if (self) {
        self.descriptor = descriptor;
        AVAssetTrack *audioTrack = [[self.descriptor.asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        if (audioTrack) {
            CMFormatDescriptionRef desc = (__bridge CMFormatDescriptionRef)audioTrack.formatDescriptions.firstObject;
            const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(desc);
            self.sampleRate = asbd->mSampleRate;
            self.bitsPerChannel = 16; //asbd->mBitsPerChannel; default or convert to int_16
            self.numberOfChannels = asbd->mChannelsPerFrame;
            if (self.sampleRate && self.bitsPerChannel && self.numberOfChannels) {
                self.available = YES;
            }
        }
    }
    return self;
}

- (void)commit
{
    if (self.available) {
        self.available = NO;
        dispatch_async(MediaCommandQueue(), ^{
            NSDictionary *outputSettings = @{AVFormatIDKey : @(kAudioFormatLinearPCM),
                                             AVLinearPCMBitDepthKey : @(self.bitsPerChannel),
                                             AVLinearPCMIsBigEndianKey : @(NO),
                                             AVLinearPCMIsFloatKey : @(NO),
                                             AVSampleRateKey : @(self.sampleRate),
                                             AVNumberOfChannelsKey : @(self.numberOfChannels)};
            
            NSError *error;
            AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:self.descriptor.asset error:&error];
            NSAssert(!error, error.description);
            
            AVAssetTrack *audioTrack = [[self.descriptor.asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            
            AVAssetReaderTrackOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:outputSettings];
            
            if ([reader canAddOutput:output]) {
                [reader addOutput:output];
                [reader startReading];
                NSMutableData *data = [[NSMutableData alloc] init];
                while (reader.status == AVAssetReaderStatusReading) {
                    CMSampleBufferRef samplerBuffer = [output copyNextSampleBuffer];
                    if (samplerBuffer) {
                        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(samplerBuffer);
                        size_t length = CMBlockBufferGetDataLength(blockBuffer);
                        SInt16 *sampleBytes = malloc(length * sizeof(SInt16));
                        CMBlockBufferCopyDataBytes(blockBuffer, 0, length, sampleBytes);
                        [data appendBytes:sampleBytes length:length];
                        CMSampleBufferInvalidate(samplerBuffer);
                        CFRelease(samplerBuffer);
                        free(sampleBytes);
                    }
                }
                
                NSAssert(!reader.error, reader.error.description);
                if (reader.status == AVAssetReaderStatusCompleted) {
                    if (self.descriptor.destinationURL) {
                        BOOL ret = [data writeToURL:self.descriptor.destinationURL atomically:YES];
                        NSAssert(ret, @"write pcm file failed");
                    }
                    if (self.completionHandler) {
                        AudioStreamBasicDescription asbd;
                        asbd.mSampleRate = self.sampleRate;
                        asbd.mBytesPerFrame = self.bitsPerChannel / 8;
                        asbd.mChannelsPerFrame = self.numberOfChannels;
                        asbd.mBitsPerChannel = self.bitsPerChannel;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.completionHandler(data.copy, &asbd, nil);
                        });
                    }
                } else {
                    if (self.completionHandler) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.completionHandler(nil, NULL, reader.error);
                        });
                    }
                }
            }
        });
    } else {
        if (self.completionHandler) {
            NSErrorDomain errorDomain = @"com.sdk.video_to_pcm";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"command is not available"};
            NSError *error = [NSError errorWithDomain:errorDomain code:-1 userInfo:userInfo];
            if ([NSThread isMainThread]) {
                self.completionHandler(nil, NULL, error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.completionHandler(nil, NULL, error);
                });
            }
        }
    }
}

@end
