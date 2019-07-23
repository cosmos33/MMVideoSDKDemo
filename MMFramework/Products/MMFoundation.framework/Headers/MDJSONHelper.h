//
//  MDJSONHelper.h
//  MomoChat
//
//  Created by yupengzhang on 15/3/6.
//  Copyright (c) 2015年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDJSONHelper : NSObject

@end


@interface NSArray (MDJSONHelper)
- (NSString *)MDJSON2String;
- (NSString *)MDJSON2StringNilOptions;
@end

@interface NSDictionary (MDJSONHelper)
- (NSString *)MDJSON2String;
- (NSString *)MDJSON2StringNilOptions;
@end

@interface NSString (MDJSONHelper)
- (id)objectFromJSONString;
@end