//
//  MDMomentDownloadMaskView.h
//  MDChat
//
//  Created by 符吉胜 on 2017/4/7.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DismissDownloadMaskViewFinish)();

@class MDMomentDownloadMaskView;

@protocol MDMomentDownloadMaskViewDelegate <NSObject>

@optional
- (void)momentDownloadMaskView:(MDMomentDownloadMaskView *)maskView didClickCloseView:(UIView *)closeView;

@end


@interface MDMomentDownloadMaskView : UIView

@property (nonatomic,weak) id<MDMomentDownloadMaskViewDelegate> delegate;

@property (nonatomic,assign) CGFloat                progress;

+ (instancetype)showDownloadMaskViewWithBlurView:(UIView *)blurView infoStr:(NSString *)str;
+ (instancetype)showDownloadMaskViewWithBlurView:(UIView *)blurView;

- (void)dismissDownloadMaskViewCompletion:(DismissDownloadMaskViewFinish)finishBlock;

@end
