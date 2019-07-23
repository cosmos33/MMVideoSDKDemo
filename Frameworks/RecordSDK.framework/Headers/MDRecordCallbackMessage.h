//
//  MDRecordCallbackMessage.h
//  pushsdk-ios
//
//  Created by wangduanqing on 2018/12/6.
//  Copyright © 2018年 momo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordCallbackMessage : NSObject

@property (nonatomic,assign) int command;
@property (nonatomic,assign) int resultCode;
@property (nonatomic,copy) NSString * message;

@end

NS_ASSUME_NONNULL_END
