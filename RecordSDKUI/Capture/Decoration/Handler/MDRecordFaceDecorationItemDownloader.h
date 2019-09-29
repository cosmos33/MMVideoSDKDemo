//
//  MDRecordFaceDecorationItemDownloader.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/18.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDFaceDecorationItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordFaceDecorationItemDownloader : NSObject

+ (instancetype)shared;

- (void)downloadItem:(MDFaceDecorationItem *)item completion:(void(^)(MDFaceDecorationItem * _Nullable, NSError * _Nullable))completion;

- (void)cancelWithItem:(MDFaceDecorationItem *)item;

@end

NS_ASSUME_NONNULL_END
