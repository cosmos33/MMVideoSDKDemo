//
//  MDMediaCommandQueue.m
//  MDChat
//
//  Created by jichuan on 2017/7/17.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMediaCommandQueue.h"

dispatch_queue_t MediaCommandQueue()
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.sdk.media-command.queue", NULL);
    });
    return queue;
}
