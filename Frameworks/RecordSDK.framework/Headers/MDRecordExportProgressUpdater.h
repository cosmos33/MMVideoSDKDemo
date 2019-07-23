//
//  MDDocumentExportOperation.h
//  MomoChat
//
//  Created by Jc on 17/2/22.
//  Copyright © 2017年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - MDExportProgressUpdater

@interface MDRecordExportProgressUpdater : NSObject
@property (nonatomic, copy) void (^updateHandler)(NSDate *startDate);
- (void)start;
- (void)stop;

@end
