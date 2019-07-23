//
//  MDAssetProcessProtocol.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/14.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MDAssetProcessProtocol <NSObject>

- (__kindof AVAsset *)processAsset:(AVMutableComposition *)asset error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
