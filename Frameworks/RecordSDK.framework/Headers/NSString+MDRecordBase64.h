//
//  NSString+MoPushBase64.h
//  Gurpartap Singh
//
//  Created by Gurpartap Singh on 06/05/12.
//  Copyright (c) 2012 Gurpartap Singh. All rights reserved.
//

#import <Foundation/NSString.h>

@interface NSString (MDRecordPushBase64Additions)

+ (NSString *)mdr_base64StringFromData:(NSData *)data length:(NSUInteger)length;
+ (NSString *)mdr_stringWithFromDict:(NSDictionary *)dict;
- (BOOL)mdr_RecordIsIPAddress;
@end
