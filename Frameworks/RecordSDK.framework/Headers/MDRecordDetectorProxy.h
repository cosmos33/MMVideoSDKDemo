//
//  MDRecordDetectorBuilder.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/24.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDRecordDetectorCreator.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordDetectorProxy : NSObject <MDRecordDetectorCreator>

+ (instancetype)sharedInstance;

@property (nonatomic, strong) id<MDRecordDetectorCreator> creator;

@end

NS_ASSUME_NONNULL_END
