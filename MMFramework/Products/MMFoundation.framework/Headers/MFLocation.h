//
//  MFLocation.h
//  MomoChat
//
//  Created by Hanx on 12-11-1.
//  Copyright (c) 2012年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFLocation : NSObject
{
    float distance;
    double time;
}

@property(nonatomic, assign) float distance;
@property(nonatomic, assign) double time;

+ (MFLocation *)location:(float)aDistance time:(double)aTime;
- (id)init:(float)aDistance time:(double)aTime;

@end
