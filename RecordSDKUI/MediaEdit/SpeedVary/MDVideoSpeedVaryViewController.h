//
//  MDVideoSpeedVaryViewController.h
//  MDChat
//
//  Created by wangxuan on 17/2/21.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MDVideoSpeedVaryHandler.h"
@class MDDocument;

@protocol MDVideoSpeedVaryDelegate <NSObject>

- (void)speedEffectWillChanged;
- (void)speedEffectDidStartChanged;
- (void)speedEffectDidEndChanged:(CMTimeRange)targetTimeRange;
- (void)videoSpeedVarydidFinishedEditing;

@end

@interface MDVideoSpeedVaryViewController : UIViewController

@property (nonatomic, strong) AVPlayer *player;

- (instancetype)initWithAsset:(AVAsset *)asset
                     document:(MDDocument *)document
                     delegate:(id<MDVideoSpeedVaryDelegate>)delegate;

- (void)synchronizeWithPlayer:(AVPlayer *)player;
- (void)synchronizePlayerTime;
- (BOOL)isViewVisible;

@end
