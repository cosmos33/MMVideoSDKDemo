//
//  MDRecordTipItem.h
//  MDChat
//
//  Created by nanjibingshuang on 2017/6/23.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDRecordTipItem : NSObject

@property (nonatomic, strong) NSString          *identifier;
@property (nonatomic, assign) double            serverUpdateTimestamp;
@property (nonatomic, assign) BOOL              showTip;
@property (nonatomic, strong) NSString          *tipText;

@end
