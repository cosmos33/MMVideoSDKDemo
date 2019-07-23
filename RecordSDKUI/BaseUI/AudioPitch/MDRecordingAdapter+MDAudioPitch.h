//
//  MDCameraEditorContext+MDAudioPitch.h
//  MDChat
//
//  Created by sunfei on 2019/1/29.
//  Copyright © 2019 sdk.com. All rights reserved.
//

#import <RecordSDK/MDRecordingAdapter.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordingAdapter (MDAudioPitch)

- (void)handleSoundPitchWithAssert:(AVAsset *)videoAsset
                    andPitchNumber:(NSInteger)pitchNumber
                 completionHandler:(void (^) (NSURL *))completionHandler;

@end

NS_ASSUME_NONNULL_END
