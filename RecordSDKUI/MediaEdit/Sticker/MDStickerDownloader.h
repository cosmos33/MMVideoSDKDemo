//
//  MDStickerDownloader.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/18.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDownLoaderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDStickerDownloader : NSObject

+ (instancetype)shared;

- (void)downloadSticker:(MDDownLoaderModel *)sticker completion:(void(^)(MDDownLoaderModel * _Nullable, NSError * _Nullable))completion;
- (void)cancelSticker:(MDDownLoaderModel *)sticker;

@end

NS_ASSUME_NONNULL_END
