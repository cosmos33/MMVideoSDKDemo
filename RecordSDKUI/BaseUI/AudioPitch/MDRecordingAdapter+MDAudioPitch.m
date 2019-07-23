//
//  MDCameraEditorContext+MDAudioPitch.m
//  MDChat
//
//  Created by sunfei on 2019/1/29.
//  Copyright © 2019 sdk.com. All rights reserved.
//

#import "MDRecordingAdapter+MDAudioPitch.h"
#import "MDMediaKit.h"

@implementation MDRecordingAdapter (MDAudioPitch)

- (NSURL *)tempPCMUrlForSourceAudio {
    NSString *sourcePCMPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"sourceAudio.pcm"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePCMPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:sourcePCMPath error:nil];
    }
    return [NSURL fileURLWithPath:sourcePCMPath];
}

- (NSURL *)tempPCMUrlForShiftedPitchAudio {
    NSString *shiftedPitchPCMPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"shitedPitchAudio.pcm"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:shiftedPitchPCMPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:shiftedPitchPCMPath error:nil];
    }
    return [NSURL fileURLWithPath:shiftedPitchPCMPath];
}

- (NSURL *)tempWavURL {
    NSString *destinationAudioPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"destinationAudio.wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationAudioPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:destinationAudioPath error:nil];
    }
    return [NSURL fileURLWithPath:destinationAudioPath];
}

- (void)cleanTempPCMUrl:(NSURL *)pcmUrl {
    NSFileManager *defaultManager = [NSFileManager defaultManager];

    if (pcmUrl && [defaultManager fileExistsAtPath:pcmUrl.path]) {
        [defaultManager removeItemAtPath:pcmUrl.path error:nil];
    }
}

- (void)handleSoundPitchWithAssert:(AVAsset *)videoAsset
                    andPitchNumber:(NSInteger)pitchNumber
                 completionHandler:(void (^) (NSURL *))completionHandler {
    if (pitchNumber == 0 || videoAsset == nil) { //pitch值为0，默认不变声
        completionHandler(nil);
        return;
    };

    NSURL *tempPCMUrlForSourceAudio = [self tempPCMUrlForSourceAudio];
    NSURL *tempPCMUrlForShiftedPitchAudio = [self tempPCMUrlForShiftedPitchAudio];

    //1.将视频中的音频PCM取出来
    MDVideoToPCMDescriptor *videoToPCMDes = [[MDVideoToPCMDescriptor alloc] init];
    videoToPCMDes.asset = videoAsset;
    videoToPCMDes.destinationURL = tempPCMUrlForSourceAudio;
    MDVideoToPCMCommand *videoToPCMCommand = [[MDVideoToPCMCommand alloc] initWithDescriptor:videoToPCMDes];
    videoToPCMCommand.completionHandler = ^(NSData * _Nullable videoPcm,const AudioStreamBasicDescription * _Nullable asbd,NSError * _Nullable error) {

        if (error) {
            [self cleanTempPCMUrl:tempPCMUrlForSourceAudio];
            if (completionHandler) {
                completionHandler(nil);
            }
            return;
        }

        //2.对原始音频PCM进行变声
        MDSoundPitchShiftDescriptor *soundPitchShiftDes = [[MDSoundPitchShiftDescriptor alloc] init];
        soundPitchShiftDes.pcm = videoPcm;
        soundPitchShiftDes.asbd = *asbd;
        soundPitchShiftDes.pitch = pitchNumber;
        soundPitchShiftDes.destinationURL = tempPCMUrlForShiftedPitchAudio;

        MDSoundPitchShiftCommand *soundPitchShiftCommand = [[MDSoundPitchShiftCommand alloc] initWithDescriptor:soundPitchShiftDes];
        soundPitchShiftCommand.completionHandler = ^(NSData * _Nullable pitchShiftPcm,NSError * _Nullable error) {

            if (error) {
                [self cleanTempPCMUrl:tempPCMUrlForSourceAudio];
                [self cleanTempPCMUrl:tempPCMUrlForShiftedPitchAudio];
                if (completionHandler) {
                    completionHandler(nil);
                }
                return;
            }

            //3.将变声后的PCM文件转成WAV文件
            MDPCMToWavDescriptor *pcmToWavDes = [[MDPCMToWavDescriptor alloc] init];
            pcmToWavDes.sourceURL = soundPitchShiftDes.destinationURL;
            pcmToWavDes.destinationURL = [self tempWavURL];
            pcmToWavDes.asbd = soundPitchShiftDes.asbd;

            MDPCMToWavCommand *pcmToWavCommand = [[MDPCMToWavCommand alloc] initWithDescriptor:pcmToWavDes];
            pcmToWavCommand.completionHandler = ^(NSError * _Nullable error) {
                //4.回传WAV文件路径
                if (!error) {
                    if (completionHandler) {
                        completionHandler(pcmToWavDes.destinationURL);
                    }

                } else {
                    if (completionHandler) {
                        completionHandler(nil);
                    }
                }

                //清理PCM文件
                [self cleanTempPCMUrl:tempPCMUrlForSourceAudio];
                [self cleanTempPCMUrl:tempPCMUrlForShiftedPitchAudio];
            };
            [pcmToWavCommand commit];
        };
        [soundPitchShiftCommand commit];
    };
    [videoToPCMCommand commit];
}

@end
