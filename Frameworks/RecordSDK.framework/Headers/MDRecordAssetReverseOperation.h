//
//  MDAssetReverseOperation.h
//  testGPU
//
//  Created by YZK on 2018/8/1.
//  Copyright © 2018年 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDRecordVideoSegment.h"

@interface MDRecordAssetReverseOperation : NSOperation

- (instancetype)initWithVideoSegment:(MDRecordVideoSegment *)segment;

//在非主线程调用
@property (nonatomic, copy) void (^completionHandler)(NSURL *outputURL);
@property (nonatomic, copy) void (^failureHandler)(NSError *error);
@property (nonatomic, copy) void (^progressHandler)(float progress);

@end
