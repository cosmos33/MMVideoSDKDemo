//
//  MDVideoBackgroundMusicManager.h
//  RecordSDK
//
//  Created by wangxuan on 17/2/20.
//  Copyright © 2017年 RecordSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDBeautyMusicManager.h"
#import "MDRecordHeader.h"



@interface MDVideoBackgroundMusicManager : NSObject

+ (NSString *)getLocalMusicResourcePathWithItem:(MDBeautyMusic *)musicItem;

@end
