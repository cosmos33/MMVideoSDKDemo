//
//  MDRDebugHandler.h
//  MMVideoSDK
//
//  Created by 符吉胜 on 2019/11/6.
//

#import <Foundation/Foundation.h>
#import "MDRDebugCellModel.h"

typedef void(^MDRDebugStateChageBlock)(MDDebugCellType debugType, BOOL isOn);

NS_ASSUME_NONNULL_BEGIN

@interface MDRDebugHandler : NSObject

@property (nonatomic, strong) NSArray *debugArray;
@property (nonatomic, copy) MDRDebugStateChageBlock stateChangeBlock;

+ (instancetype)shareInstance;

- (void)changeState:(BOOL)isOn
               type:(MDDebugCellType)type;

- (BOOL)isOnWithDebugType:(MDDebugCellType)debugType;

@end

NS_ASSUME_NONNULL_END
