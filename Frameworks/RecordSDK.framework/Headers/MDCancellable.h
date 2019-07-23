//
//  MDCancellable.h
//  RecordSDK
//
//  Created by sunfei on 2018/12/16.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MDCancellable <NSObject>

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
