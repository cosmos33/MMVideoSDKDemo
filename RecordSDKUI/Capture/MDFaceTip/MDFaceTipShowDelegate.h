//
//  MDFaceTipShowDelegate.h
//  MDChat
//
//  Created by sdk on 2017/6/22.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    MDFaceTipSignalNone,        // None
    MDFaceTipSignalFaceTrack,   // faceTrack
    MDFaceTipSignalFaceNoTrack, // No Track
    MDFaceTipSignalCameraRotate,// Camera Rotate
}MDFaceTipSignal;

@protocol MDFaceTipShowDelegate <NSObject>

- (void)faceTipDidFinishAllTask;

- (void)showFaceTipText:(NSString *)text;

@property (nonatomic, assign) BOOL              shouldContinue;

@property (nonatomic, assign)NSUInteger         currentSignal;

@end
