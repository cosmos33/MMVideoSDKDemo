//
//  MFInetAddress.h
//  MomoChat
//
//  Created by Latermoon on 12-9-11.
//  Copyright (c) 2012年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 把Host和Port包装起来，便于传递和存储
 */
@interface MFInetAddress : NSObject
{
    NSString *host;
    NSInteger port;
}

#pragma mark
#pragma mark Host and Port
@property (retain, nonatomic) NSString *host;
@property (nonatomic) NSInteger port;

#pragma mark
#pragma mark Init
+ (MFInetAddress *)addressWithHost:(NSString *)aHost andPort:(NSInteger)aPort;
- (MFInetAddress *)initWithHost:(NSString *)aHost andPort:(NSInteger)aPort;

@end
