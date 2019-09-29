//
//  MDSoundPitchShift.m
//  MDChat
//
//  Created by jichuan on 2017/7/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDSoundPitchShift.h"
#import "MDMediaCommandQueue.h"
#import <MOMOPitchShift/MomoAudioEf.h>

@implementation MDSoundPitchShiftDescriptor

- (id)copyWithZone:(NSZone *)zone
{
    MDSoundPitchShiftDescriptor *descriptor = [[MDSoundPitchShiftDescriptor allocWithZone:zone] init];
    descriptor.pcm = self.pcm;
    descriptor.pitch = self.pitch;
    descriptor.asbd = self.asbd;
    descriptor.destinationURL = self.destinationURL;
    return descriptor;
}

@end

@interface MDSoundPitchShiftCommand ()
@property (nonatomic, copy) MDSoundPitchShiftDescriptor *descriptor;
@property (nonatomic, assign) BOOL available;
@end

@implementation MDSoundPitchShiftCommand

- (instancetype)initWithDescriptor:(MDSoundPitchShiftDescriptor *)descriptor
{
    self = [super init];
    if (self) {
        self.descriptor = descriptor;
        if (descriptor.pcm && descriptor.asbd.mSampleRate && descriptor.asbd.mChannelsPerFrame && descriptor.asbd.mBitsPerChannel == sizeof(int16_t)*8 && descriptor.asbd.mBytesPerFrame == sizeof(int16_t)) {
            self.available = YES;
        }
    }
    return self;
}

- (void)commit
{
    if (self.available) {
        self.available = NO;
        dispatch_async(MediaCommandQueue(), ^{
            Ctrl_Params_Tune params;
            params.nChannels = self.descriptor.asbd.mChannelsPerFrame;
            params.rate = self.descriptor.asbd.mSampleRate;
            params.pitch = self.descriptor.pitch;
            
            PitchShift pitchShift;
            pitchShift.Init(params);
            
            int16_t *outpcm = (int16_t *)malloc(self.descriptor.pcm.length);
            memset(outpcm, 0, self.descriptor.pcm.length);
            int outLength;
            
            pitchShift.ProcessSound((int16_t *)self.descriptor.pcm.bytes, self.descriptor.pcm.length/sizeof(int16_t), params, outpcm, &outLength);
            
            NSData *data = nil;
            NSError *error = nil;
            if (outLength > 0) {
                data = [NSData dataWithBytes:outpcm length:outLength*sizeof(int16_t)];
                if (self.descriptor.destinationURL) {
                    BOOL ret = [data writeToURL:self.descriptor.destinationURL atomically:YES];
                    NSAssert(ret, @"write pcm file failed");
                }
            } else {
                NSErrorDomain errorDomain = @"com.sdk.sound-pitch-shift";
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"pitch shift failed"};
                error = [NSError errorWithDomain:errorDomain code:-1 userInfo:userInfo];
            }
            
            if (self.completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.completionHandler(data, error);
                });
            }
            
            free(outpcm);
        });
    } else {
        if (self.completionHandler) {
            NSErrorDomain errorDomain = @"com.sdk.sound-pitch-shift";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"command is not available"};
            NSError *error = [NSError errorWithDomain:errorDomain code:-1 userInfo:userInfo];
            if ([NSThread isMainThread]) {
                self.completionHandler(nil, error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.completionHandler(nil, error);
                });
            }
        }
    }
}

@end
