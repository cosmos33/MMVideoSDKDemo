//
//  MDRCameraEngine+MDAudioPitch.h
//  MDRecordSDK
//
//  Created by 符吉胜 on 2019/11/7.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <RecordSDK/MDRCameraEngine.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRCameraEngine (MDAudioPitch)

- (void)handleSoundPitchWithAssert:(AVAsset *)videoAsset
   andPitchNumber:(NSInteger)pitchNumber
completionHandler:(void (^) (NSURL *))completionHandler;

@end

NS_ASSUME_NONNULL_END
