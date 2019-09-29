//
//  MDBluredProgressView.h
//  MDChat
//
//  Created by 王璇 on 2017/4/13.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDBluredProgressView : UIView

@property (nonatomic,assign) CGFloat progress;
@property (nonatomic, copy) void (^viewCloseHandler)(void);

- (instancetype)initWithBlurView:(UIView *)blurView descText:(NSString *)desc needClose:(BOOL)need;

@end
