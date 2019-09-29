//
//  MDSpecialEffectsManager.m
//  MDChat
//
//  Created by YZK on 2018/8/8.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDRecordSpecialEffectsManager.h"
#import "MDRecordHeader.h"
@import RecordSDK;
@import GPUImage;
@import FaceDecorationKitSceneEffects;

@implementation MDRecordSpecialEffectsManager

+ (GPUImageOutput<GPUImageInput,MDRSpecialFilterLifeStyleProtocol> *)getFilterWithSpecialEffectsType:(MDRecordSpecialEffectsType)type
{
    switch (type) {
        case MDRecordSpecialEffectsTypeMirrImage:
        {
            MDRecordMirrImageFrameFilter *filter = [[MDRecordMirrImageFrameFilter alloc] init];
            return filter;
        }
            break;
        case MDRecordSpecialEffectsTypeRainWindow:
        {
            MDRecordRainWindowFilter *filter = [[MDRecordRainWindowFilter alloc] init];
            return filter;
        }
            break;
        case MDRecordSpecialEffectsTypeShake:
        {
            MDRecordShakeFilter *filter = [[MDRecordShakeFilter alloc] init];
            return filter;
        }
            break;
        case MDRecordSpecialEffectsTypeSoulOut:
        {
            MDRecordSoulOutFilter *filter = [[MDRecordSoulOutFilter alloc] init];
            return filter;
        }
            break;
        case MDRecordSpecialEffectsTypeTVArtifact:
        {
            MDRecordTVArtifactFilter *filter = [[MDRecordTVArtifactFilter alloc] init];
            return filter;
        }
            break;
        case MDRecordSpecialEffectsTypeDazzling:
        {
            FDKDazzlingFilter *filter = [[FDKDazzlingFilter alloc] init];
            return filter;
        }
            break;
        case MDRecordSpecialEffectsTypeShadowing:
        {
            FDKShadowingFilter *filter = [[FDKShadowingFilter alloc] init];
            return filter;
        }
            break;
        case MDRecordSpecialEffectsTypeHeartBeat:
        {
            FDKHeartbeatFilter *filter = [[FDKHeartbeatFilter alloc] init];
            return filter;
        }
            break;
        case MDRecordSpecialEffectsTypeBlack3:
        {
            FDKBlack3FilterGroup *filter = [[FDKBlack3FilterGroup alloc] init];
            return filter;
        }
            break;
        default:
            break;
    }
    return nil;
}

+ (MDRecordSpecialEffectsType)getSpecialEffectsTypeWithFilter:(GPUImageOutput<GPUImageInput,MDRSpecialFilterLifeStyleProtocol> *)filter
{
    if ([filter isKindOfClass:[MDRecordMirrImageFrameFilter class]]) {
        return MDRecordSpecialEffectsTypeMirrImage;
    }
    else if ([filter isKindOfClass:[MDRecordRainWindowFilter class]]) {
        return MDRecordSpecialEffectsTypeRainWindow;
    }
    else if ([filter isKindOfClass:[MDRecordShakeFilter class]]) {
        return MDRecordSpecialEffectsTypeShake;
    }
    else if ([filter isKindOfClass:[MDRecordSoulOutFilter class]]) {
        return MDRecordSpecialEffectsTypeSoulOut;
    }
    else if ([filter isKindOfClass:[MDRecordTVArtifactFilter class]]) {
        return MDRecordSpecialEffectsTypeTVArtifact;
    }
    else if ([filter isKindOfClass:[FDKDazzlingFilter class]]) {
        return MDRecordSpecialEffectsTypeDazzling;
    }
    else if ([filter isKindOfClass:[FDKShadowingFilter class]]) {
        return MDRecordSpecialEffectsTypeShadowing;
    }
    else if ([filter isKindOfClass:[FDKHeartbeatFilter class]]) {
        return MDRecordSpecialEffectsTypeHeartBeat;
    }
    else if ([filter isKindOfClass:[FDKBlack3FilterGroup class]]) {
        return MDRecordSpecialEffectsTypeBlack3;
    }
    return 0;
}


+ (NSArray<MDSpecialEffectsModel*> *)getSpecialEffectsFilterModelArray {
    
    
    MDSpecialEffectsModel *shakeModel = [[MDSpecialEffectsModel alloc]init];
    shakeModel.effectsTitle = @"抖动";
    shakeModel.effectsImageName = @"";
    shakeModel.type = MDRecordSpecialEffectsTypeShake;
    shakeModel.bgColor = RGBACOLOR(71, 169, 238, 0.9);
    
    MDSpecialEffectsModel *soulOutModel = [[MDSpecialEffectsModel alloc]init];
    soulOutModel.effectsTitle = @"灵魂出窍";
    soulOutModel.effectsImageName = @"";
    soulOutModel.type = MDRecordSpecialEffectsTypeSoulOut;
    soulOutModel.bgColor = RGBACOLOR(243, 118, 138, 0.9);
    
    MDSpecialEffectsModel *tvModel = [[MDSpecialEffectsModel alloc]init];
    tvModel.effectsTitle = @"故障";
    tvModel.effectsImageName = @"";
    tvModel.type = MDRecordSpecialEffectsTypeTVArtifact;
    tvModel.bgColor = RGBACOLOR(71, 71 ,71, 0.9);
    
    MDSpecialEffectsModel *mirrModel = [[MDSpecialEffectsModel alloc]init];
    mirrModel.effectsTitle = @"四格子";
    mirrModel.effectsImageName = @"";
    mirrModel.type = MDRecordSpecialEffectsTypeMirrImage;
    mirrModel.bgColor = RGBACOLOR(107,240,226, 0.9);
    
    MDSpecialEffectsModel *rainModel = [[MDSpecialEffectsModel alloc]init];
    rainModel.effectsTitle = @"雨窗";
    rainModel.effectsImageName = @"";
    rainModel.type = MDRecordSpecialEffectsTypeRainWindow;
    rainModel.bgColor = RGBACOLOR(252, 238, 125, 0.9);
    
    MDSpecialEffectsModel *dazzlingModel = [[MDSpecialEffectsModel alloc]init];
    dazzlingModel.effectsTitle = @"闪烁";
    dazzlingModel.effectsImageName = @"";
    dazzlingModel.type = MDRecordSpecialEffectsTypeDazzling;
    dazzlingModel.bgColor = RGBACOLOR(252, 38, 125, 0.9);
    
    MDSpecialEffectsModel *heartBeatModel = [[MDSpecialEffectsModel alloc]init];
    heartBeatModel.effectsTitle = @"心跳";
    heartBeatModel.effectsImageName = @"";
    heartBeatModel.type = MDRecordSpecialEffectsTypeHeartBeat;
    heartBeatModel.bgColor = RGBACOLOR(0, 0, 125, 0.9);
    
    MDSpecialEffectsModel *shadowingModel = [[MDSpecialEffectsModel alloc]init];
    shadowingModel.effectsTitle = @"VHS晃动";
    shadowingModel.effectsImageName = @"";
    shadowingModel.type = MDRecordSpecialEffectsTypeShadowing;
    shadowingModel.bgColor = RGBACOLOR(0, 238, 0, 0.9);
    
    MDSpecialEffectsModel *black3Model = [[MDSpecialEffectsModel alloc]init];
    black3Model.effectsTitle = @"黑胶3格";
    black3Model.effectsImageName = @"";
    black3Model.type = MDRecordSpecialEffectsTypeBlack3;
    black3Model.bgColor = RGBACOLOR(252, 0, 0, 0.9);
    
   
    NSMutableArray *marr = [NSMutableArray array];
    [marr addObjectSafe:shakeModel];
    [marr addObjectSafe:soulOutModel];
    [marr addObjectSafe:tvModel];
    [marr addObjectSafe:rainModel];
    [marr addObjectSafe:mirrModel];
    [marr addObjectSafe:dazzlingModel];
    [marr addObjectSafe:heartBeatModel];
    [marr addObjectSafe:shadowingModel];
    [marr addObjectSafe:black3Model];

    return marr;
}


+ (NSArray<MDSpecialEffectsModel*> *)getSpecialEffectsTimeModelArray {
    MDSpecialEffectsModel *noneModel = [[MDSpecialEffectsModel alloc]init];
    noneModel.effectsTitle = @"无";
    noneModel.effectsImageName = @"";
    noneModel.type = MDRecordSpecialEffectsTypeTimeNone;
    noneModel.isSelect = YES;
    
    MDSpecialEffectsModel *slowModel = [[MDSpecialEffectsModel alloc]init];
    slowModel.effectsTitle = @"慢动作";
    slowModel.effectsImageName = @"";
    slowModel.type = MDRecordSpecialEffectsTypeSlowMotion;
    slowModel.isSelect = NO;
    
    MDSpecialEffectsModel *quickModel = [[MDSpecialEffectsModel alloc]init];
    quickModel.effectsTitle = @"快动作";
    quickModel.effectsImageName = @"";
    quickModel.type = MDRecordSpecialEffectsTypeQuickMotion;
    quickModel.isSelect = NO;
    
    MDSpecialEffectsModel *repeatModel = [[MDSpecialEffectsModel alloc]init];
    repeatModel.effectsTitle = @"反复";
    repeatModel.effectsImageName = @"";
    repeatModel.type = MDRecordSpecialEffectsTypeRepeat;
    repeatModel.bgColor = RGBACOLOR(127, 255, 212, 0.3);
    repeatModel.isSelect = NO;
    
    
    MDSpecialEffectsModel *reverseModel = [[MDSpecialEffectsModel alloc]init];
    reverseModel.effectsTitle = @"倒放";
    reverseModel.effectsImageName = @"";
    reverseModel.type = MDRecordSpecialEffectsTypeReverse;
    reverseModel.bgColor = RGBACOLOR(71,169,238, 0.8);
    reverseModel.isSelect = NO;

    NSMutableArray *marr = [NSMutableArray array];
    [marr addObjectSafe:noneModel];
    [marr addObjectSafe:slowModel];
    [marr addObjectSafe:quickModel];
    [marr addObjectSafe:repeatModel];
    [marr addObjectSafe:reverseModel];

    return marr;
}



@end
