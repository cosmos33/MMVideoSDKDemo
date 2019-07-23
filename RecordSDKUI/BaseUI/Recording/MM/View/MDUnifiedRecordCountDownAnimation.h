//
//  MDUnifiedRecordCountDownAnimation.h
//  MDChat
//
//  Created by 符吉胜 on 2017/6/20.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MDUnifiedRecordCountDownAnimation : NSObject

- (instancetype)initWithContainer:(UIView *)container;
@property (nonatomic,assign) NSInteger count;

- (void)showPrepareAnimationWithString:(NSString *)string;

@property (nonatomic,assign) BOOL isAnimating;
- (void)startAnimationWithCompletionHandler:(void(^)(BOOL finished))completionHandler;
- (void)cancelAnimation;

@end
