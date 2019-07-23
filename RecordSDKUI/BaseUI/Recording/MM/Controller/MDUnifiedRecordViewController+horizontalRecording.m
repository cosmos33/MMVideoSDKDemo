//
//  MDUnifiedRecordViewController+horizontalRecording.m
//  MDChat
//
//  Created by 符吉胜 on 2017/6/23.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordViewController+horizontalRecording.h"
#import "MDUnifiedRecordModuleAggregate.h"

@import CoreMotion;

static char motionManagerKey;

@implementation MDUnifiedRecordViewController (horizontalRecording)


- (void)startMotionManager
{
    [self setMotionManager];
}

- (void)stopMotionManager
{
    CMMotionManager *motionManager = [self getMotionManager];
    if (motionManager && [motionManager isKindOfClass:[CMMotionManager class]]) {
        [motionManager stopDeviceMotionUpdates];
    }
}

#pragma mark - event handle
- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    
    if (self.moduleAggregate.savedSegmentCount > 0 || self.moduleAggregate.isRecording) {
        return;
    }
    BOOL needResponse = NO;
    UIDeviceOrientation orientation = UIDeviceOrientationPortrait;
    
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    
    if (ABS(deviceMotion.gravity.z) >0.5) {
        return;
    }
    
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            orientation = UIDeviceOrientationPortraitUpsideDown;
            needResponse = YES;
        }
        else{
            orientation = UIDeviceOrientationPortrait;
            needResponse = YES;
        }
    }
    else
    {
        if (x >= 0){
            orientation = UIDeviceOrientationLandscapeRight;
            needResponse = YES;
            
        }
        else {
            orientation = UIDeviceOrientationLandscapeLeft;
            needResponse = YES;
            
        }
    }
    
    [self handleRotate:orientation needResponse:needResponse];
}


#pragma mark - getter & setter
- (void)setMotionManager
{
    CMMotionManager *motionManager = [self getMotionManager];
    
    if (motionManager.deviceMotionAvailable) {
        motionManager.deviceMotionUpdateInterval = 0.5f;
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler: ^(CMDeviceMotion *motion, NSError *error){
                                                [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
                                                
                                            }];
    } else {
        motionManager = nil;
    }
    
    objc_setAssociatedObject(self, &motionManagerKey, motionManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CMMotionManager *)getMotionManager
{
    CMMotionManager *motionManager = objc_getAssociatedObject(self, &motionManagerKey);
    if (!motionManager) {
        motionManager = [[CMMotionManager alloc] init];
    }
    return motionManager;
}

@end
