//
//  MDTimeEffectsManager.m
//  MDChat
//
//  Created by litianpeng on 2018/8/13.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDEffectsTimeManager.h"

@implementation MDEffectsTimeManager
- (void)setAssetDuration:(CMTime)assetDuration{
    _assetDuration = assetDuration;
}
- (void)configDefaultValue:(CMTime )duration{
    self.assetDuration = duration;
    self.repeatTime =  CMTimeMakeWithSeconds(CMTimeGetSeconds(duration)*0.5, NSEC_PER_SEC);
    self.slowTime =  CMTimeMakeWithSeconds(CMTimeGetSeconds(duration)*0.5, NSEC_PER_SEC);
    self.quickTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(duration)*0.5, NSEC_PER_SEC);
    self.reverseTime = kCMTimeZero;
    self.currentTimeEffect = MDRecordSpecialEffectsTypeTimeNone;
}
- (void)resetDefultTime{
    self.repeatTime =  CMTimeMakeWithSeconds(CMTimeGetSeconds(self.assetDuration)*0.5, NSEC_PER_SEC);
    self.slowTime =  CMTimeMakeWithSeconds(CMTimeGetSeconds(self.assetDuration)*0.5, NSEC_PER_SEC);
    self.quickTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.assetDuration)*0.5, NSEC_PER_SEC);
    self.reverseTime = kCMTimeZero;
    self.currentTimeEffect = MDRecordSpecialEffectsTypeTimeNone;
}
- (CMTime)getTimeWithType:(MDRecordSpecialEffectsType )type{
    if (type == MDRecordSpecialEffectsTypeTimeNone) {
        return kCMTimeZero;
    }
    else if (type == MDRecordSpecialEffectsTypeSlowMotion){
        return self.slowTime;
    }
    else if (type == MDRecordSpecialEffectsTypeQuickMotion){
        return self.quickTime;
    }
    else if (type == MDRecordSpecialEffectsTypeRepeat){
        return self.repeatTime;
    }
    else if (type == MDRecordSpecialEffectsTypeReverse){
        return self.reverseTime;
    }
    return kCMTimeZero;

}
- (void)saveTimeWithType:(MDRecordSpecialEffectsType )type date:(CMTime)date{
    if (type == MDRecordSpecialEffectsTypeTimeNone) {
        
    }
    else if (type == MDRecordSpecialEffectsTypeSlowMotion){
        self.slowTime = date;
    }
    else if (type == MDRecordSpecialEffectsTypeQuickMotion){
        self.quickTime = date;
    }
    else if (type == MDRecordSpecialEffectsTypeRepeat){
        self.repeatTime = date;
    }
    else if (type == MDRecordSpecialEffectsTypeReverse){
        self.reverseTime = date;
    }
}
@end
