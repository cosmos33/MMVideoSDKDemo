//
//  MDVideoSegment.h
//  testGPU
//
//  Created by YZK on 2018/8/1.
//  Copyright © 2018年 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MDRecordVideoSegment : NSObject

@property (nonatomic, assign) BOOL reverseAudio;
@property (nonatomic, assign) CMTimeRange timeRange;
@property (nonatomic, copy) NSURL *URL;

@end
