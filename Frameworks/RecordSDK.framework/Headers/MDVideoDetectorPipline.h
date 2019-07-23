//
//  MDVideoDetectorPipline.h
//  RecordSDK
//
//  Created by sunfei on 2018/11/30.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDImageDetectorProtocol.h"

@class FDKDecoration, FDKDecorationFilterUpdateRequest, FDKBeautySettings;

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoDetectorPipline : NSObject <MDImageDetectorProtocol>

- (instancetype)init;

- (void)thinBodyConfiguration:(FDKBeautySettings *)beautySettings;

@property (nonatomic, assign) BOOL canUseBodyThinSetting;
@property (nonatomic, assign) BOOL canUseAIBeautySetting;

@property (nonatomic, readonly) FDKDecorationFilterUpdateRequest *result;

@end

NS_ASSUME_NONNULL_END
