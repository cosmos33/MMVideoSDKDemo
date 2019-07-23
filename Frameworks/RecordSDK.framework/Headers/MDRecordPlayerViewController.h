//
//  MDPlayerViewController.h
//  RecordSDK
//
//  Created by sunfei on 2018/11/30.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MLMediaFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface MDRecordPlayerViewController : MLPlayerViewController <MLPlayerViewControllerDelegate>

//- (void)play;
//- (void)pause;

- (CGRect)videoRenderFrame;

@end

NS_ASSUME_NONNULL_END
