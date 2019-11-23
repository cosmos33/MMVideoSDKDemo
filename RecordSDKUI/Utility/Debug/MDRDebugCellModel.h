//
//  MDRDebugCellModel.h
//  MMVideoSDK
//
//  Created by 符吉胜 on 2019/11/6.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MDDebugCellType){
    MDDebugCellTypeNone = 0,
    MDDebugCellTypeReverseVideo,
    MDDebugCellTypeDisableAudio,
    MDDebugCellTypeUseAIBeauty,    // 使用AI滤镜
    MDDebugCellTypeRecordDisableAllEffects //录制过程中屏蔽所有特效（原始视频）
};

NS_ASSUME_NONNULL_BEGIN

@interface MDRDebugCellModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, assign) MDDebugCellType type;

@end

NS_ASSUME_NONNULL_END
