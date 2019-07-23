//
//  MDVideoRenderPipline.h
//  MomoChat
//
//  Created by sunfei on 2018/12/28.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDProcessImageProtocol.h"
#import "MDVideoRenderFilter.h"
#import "MDVideoDetectorPipline.h"

@class FDKDecoration, FDKBeautySettings;

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoRenderPipline : NSObject <MDProcessImageProtocol>

@property (nonatomic, readonly) MDVideoRenderFilter *renderFilter;
@property (nonatomic, readonly) MDVideoDetectorPipline *detector;

@property (nonatomic, assign) BOOL canUseAIBeautySetting;

- (void)updateDecoration:(FDKDecoration * _Nullable)decoration;
- (void)updateBeautySetting:(FDKBeautySettings *)beautySetting;

@end

NS_ASSUME_NONNULL_END
