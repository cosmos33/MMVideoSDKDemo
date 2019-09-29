//
//  MDMomentFaceDecorationController.h
//  MDChat
//
//  Created by wangxuan on 16/8/19.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDViewController.h"
#import "MDMomentMakeupItem.h"

@class MDMomentMakeUpViewController;

@protocol MDMomentMakeUpViewControllerDelegate <NSObject>

- (void)clickWithVC:(MDMomentMakeUpViewController *)vc item:(MDMomentMakeupItem *)item;
- (void)clearWithVC:(MDMomentMakeUpViewController *)vc;

@end

@interface MDMomentMakeUpViewController : MDViewController

@property (nonatomic, weak) id<MDMomentMakeUpViewControllerDelegate> delegate;

@property (nonatomic, assign, getter=isShowed)    BOOL    show;
@property (nonatomic, assign, getter=isAnimating) BOOL    animating;

//列表弹出动画
- (BOOL)showAnimate;
- (void)hideAnimateWithCompleteBlock:(void(^)(void))completeBlock;

@end
