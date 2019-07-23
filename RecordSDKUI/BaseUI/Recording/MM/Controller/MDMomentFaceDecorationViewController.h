//
//  MDMomentFaceDecorationController.h
//  MDChat
//
//  Created by wangxuan on 16/8/19.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDViewController.h"
#import "MDFaceDecorationDataHandle.h"

@class MDFaceDecorationView;

@interface MDMomentFaceDecorationViewController : MDViewController

@property (nonatomic, strong) MDFaceDecorationDataHandle *dataHandle; //由外部传入的数据处理类

@property (nonatomic, assign, getter=isShowed)    BOOL    show;
@property (nonatomic, assign, getter=isAnimating) BOOL    animating;

//- (MDFaceDecorationView *)decorationView;
- (void)setSelectedClassWithIdentifier:(NSString *)identifer;
- (void)setSelectedClassWithIndex:(NSInteger)index;

@property (nonatomic, copy) void (^ __nullable recordHandler)(void);

//列表弹出动画
- (BOOL)showAnimate;
- (void)hideAnimateWithCompleteBlock:(void(^)(void))completeBlock;

@end
