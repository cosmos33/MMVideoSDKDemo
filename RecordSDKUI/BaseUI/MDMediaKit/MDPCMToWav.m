//
//  MDPCMToWav.m
//  MDChat
//
//  Created by jichuan on 2017/7/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDPCMToWav.h"
#import "MDMediaCommandQueue.h"

typedef struct {
    char         fccID[4];
    int32_t      dwSize;
    char         fccType[4];
} WAV_HEADER;

typedef struct {
    char         fccID[4];
    int32_t      dwSize;
    int16_t      wFormatTag;
    int16_t      wChannels;
    int32_t      dwSamplesPerSec;
    int32_t      dwAvgBytesPerSec;
    int16_t      wBlockAlign;
    int16_t      uiBitsPerSample;
} WAV_FMT;

typedef  struct  {
    char         fccID[4];
    int32_t      dwSize;
} WAV_DATA;

@implementation MDPCMToWavDescriptor

- (id)copyWithZone:(NSZone *)zone
{
    MDPCMToWavDescriptor *descriptor = [[MDPCMToWavDescriptor allocWithZone:zone] init];
    descriptor.sourceURL = self.sourceURL;
    descriptor.destinationURL = self.destinationURL;
    descriptor.asbd = self.asbd;
    return descriptor;
}

@end

@interface MDPCMToWavCommand ()
@property (nonatomic, copy) MDPCMToWavDescriptor *descriptor;
@property (nonatomic, assign) BOOL available;
@end

@implementation MDPCMToWavCommand

- (instancetype)initWithDescriptor:(MDPCMToWavDescriptor *)descriptor
{
    self = [super init];
    if (self) {
        self.descriptor = descriptor;
        if (descriptor.sourceURL && descriptor.destinationURL && descriptor.asbd.mChannelsPerFrame && descriptor.asbd.mSampleRate && descriptor.asbd.mBitsPerChannel && descriptor.asbd.mBytesPerFrame) {
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
            
            WAV_HEADER wav_header;
            WAV_FMT wav_fmt;
            WAV_DATA wav_data;
            
            FILE *pcm_fp;
            FILE *wav_fp;
            
            pcm_fp = fopen(self.descriptor.sourceURL.path.UTF8String, "rb");
            wav_fp = fopen(self.descriptor.destinationURL.path.UTF8String, "wb+");
            NSAssert(pcm_fp && wav_fp, @"cannot open file");
            
            if (pcm_fp && wav_fp) {
                strncpy(wav_header.fccID, "RIFF", 4);
                strncpy(wav_header.fccType, "WAVE", 4);
                fseek(wav_fp, sizeof(WAV_HEADER), 1);
                
                NSAssert(!ferror(wav_fp), @"ferror");
                
                wav_fmt.dwSamplesPerSec = self.descriptor.asbd.mSampleRate;
                wav_fmt.dwAvgBytesPerSec = wav_fmt.dwSamplesPerSec * self.descriptor.asbd.mBytesPerFrame;
                wav_fmt.uiBitsPerSample = self.descriptor.asbd.mBitsPerChannel;
                
                strncpy(wav_fmt.fccID, "fmt  ", 4);
                wav_fmt.dwSize = self.descriptor.asbd.mBitsPerChannel;
                wav_fmt.wBlockAlign = self.descriptor.asbd.mBytesPerFrame;
                wav_fmt.wChannels = self.descriptor.asbd.mChannelsPerFrame;
                wav_fmt.wFormatTag = 1;
                fwrite(&wav_fmt, sizeof(WAV_FMT), 1, wav_fp);
                
                strncpy(wav_data.fccID, "data", 4);
                wav_data.dwSize = 0;
                fseek(wav_fp, sizeof(WAV_DATA), 1);
                
                void *read = malloc(self.descriptor.asbd.mBytesPerFrame);
                fread(read, self.descriptor.asbd.mBytesPerFrame, 1, pcm_fp);
                while (!feof(pcm_fp)) {
                    wav_data.dwSize += self.descriptor.asbd.mBytesPerFrame;
                    fwrite(read, self.descriptor.asbd.mBytesPerFrame, 1, wav_fp);
                    fread(read, self.descriptor.asbd.mBytesPerFrame, 1, pcm_fp);
                }
                free(read);
                fclose(pcm_fp);
                
                wav_header.dwSize = wav_data.dwSize;
                rewind(wav_fp);
                fwrite(&wav_header, sizeof(WAV_HEADER), 1, wav_fp);
                fseek(wav_fp, sizeof(WAV_FMT), 1);
                fwrite(&wav_data, sizeof(WAV_DATA), 1, wav_fp);
                fclose(wav_fp);
                if (self.completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.completionHandler(nil);
                    });
                }
            } else {
                if (self.completionHandler) {
                    NSErrorDomain errorDomain = @"com.sdk.pcm_to_wav";
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"command is not available"};
                    NSError *error = [NSError errorWithDomain:errorDomain code:-1 userInfo:userInfo];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.completionHandler(error);
                    });
                }
            }
        });
    } else {
        if (self.completionHandler) {
            NSErrorDomain errorDomain = @"com.sdk.pcm_to_wav";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"command is not available"};
            NSError *error = [NSError errorWithDomain:errorDomain code:-1 userInfo:userInfo];
            if ([NSThread isMainThread]) {
                self.completionHandler(error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.completionHandler(error);
                });
            }
        }
    }
}

@end
