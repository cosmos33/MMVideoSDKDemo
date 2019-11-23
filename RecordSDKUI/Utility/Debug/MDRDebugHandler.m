//
//  MDRDebugHandler.m
//  MMVideoSDK
//
//  Created by 符吉胜 on 2019/11/6.
//

#import "MDRDebugHandler.h"

@implementation MDRDebugHandler

+ (instancetype)shareInstance {
    static MDRDebugHandler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MDRDebugHandler alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        MDRDebugCellModel *reverseVideoModel = [self modelWithTitle:@"视频镜像输出" type:MDDebugCellTypeReverseVideo];
        MDRDebugCellModel *disableAudiooModel = [self modelWithTitle:@"屏蔽音频" type:MDDebugCellTypeDisableAudio];
        MDRDebugCellModel *useAIBeautyModel = [self modelWithTitle:@"使用AI美颜" type:MDDebugCellTypeUseAIBeauty];
        MDRDebugCellModel *disableAllEffectsModel = [self modelWithTitle:@"输出无特效视频（原始视频）" type:MDDebugCellTypeRecordDisableAllEffects];
        
        self.debugArray = @[reverseVideoModel,disableAudiooModel, useAIBeautyModel, disableAllEffectsModel];
    }
    return self;
}

- (MDRDebugCellModel*)modelWithTitle:(NSString *)title
                               type:(MDDebugCellType)type {
    MDRDebugCellModel *model = [[MDRDebugCellModel alloc] init];
    model.title = title;
    model.isOn = NO;
    model.type = type;
    return model;
}

- (void)changeState:(BOOL)isOn
               type:(MDDebugCellType)type {
    if (_stateChangeBlock) {
        _stateChangeBlock(type, isOn);
    }
}

- (BOOL)isOnWithDebugType:(MDDebugCellType)debugType {
    for (MDRDebugCellModel *model in _debugArray) {
        if (model.type == debugType) {
            return model.isOn;
        }
    }
    return NO;
}

@end
