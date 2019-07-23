//
//  MDWeakProxy.h
//  MomoChat
//
//  Created by yupengzhang on 14-12-11.
//  Copyright (c) 2014年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDWeakProxy : NSObject

@property (nonatomic, weak) id mdTargetObj;

+ (instancetype)weakProxyForObject:(id)targetObject;

- (id)assignWeakToStrong;
@end
