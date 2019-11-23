//
//  MDRecordVideoSettingManager.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/5/31.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordVideoSettingManager : NSObject

@property (nonatomic, assign, class) NSInteger exportFrameRate;
@property (nonatomic, assign, class) NSInteger exportBitRate;
@property (nonatomic, assign, class) BOOL enableBlur;

@end

NS_ASSUME_NONNULL_END
