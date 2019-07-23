//
//  MDAssetPorcessBuilder.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/14.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MDAssetProcessProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDAssetPorcessBuilder <NSObject>

- (id<MDAssetProcessProtocol> _Nonnull)buildAssetProcess;

@end

NS_ASSUME_NONNULL_END
