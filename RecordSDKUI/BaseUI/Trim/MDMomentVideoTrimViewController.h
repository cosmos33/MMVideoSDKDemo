//
//  MDMomentVideoTrimViewController.h
//  MDChat
//
//  Created by wangxuan on 17/2/15.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MDRecordHeader.h"
#import "MDViewController.h"

typedef void(^videoTrimClosedHandler)(UIViewController*controller, AVAsset *asset, CMTimeRange timeRange);

@interface MDMomentVideoTrimViewController : MDViewController

@property (nonatomic, strong) NSURL *originVideoURL;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, assign) BOOL needShowConfirm;
@property (nonatomic, assign) NSTimeInterval insertDuration;

- (instancetype)initWithMaxDuration:(NSTimeInterval)maxDuration CloseHandler:(videoTrimClosedHandler)closeHandler;

@end
