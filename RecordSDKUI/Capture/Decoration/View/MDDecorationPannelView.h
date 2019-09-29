//
//  MDDecorationPannelView.h
//  MomoChat
//
//  Created by YZK on 2019/4/12.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDRecordMacro.h"

NS_ASSUME_NONNULL_BEGIN

@class MDFaceDecorationDataHandle;

@interface MDDecorationPannelView : UIView

@property (nonatomic, weak) UIViewController *vc;

@property (nonatomic, strong) MDFaceDecorationDataHandle *dataHandle; //由外部传入的数据处理类
@property (nonatomic, copy)   void (^ __nullable recordHandler)(void);

@property (nonatomic, assign, getter=isShowed)    BOOL    show;
@property (nonatomic, assign, getter=isAnimating) BOOL    animating;

- (void)setSelectedClassWithIdentifier:(NSString *)identifer;
- (void)setSelectedClassWithIndex:(NSInteger)index;

//列表弹出动画
- (BOOL)showAnimate;
- (void)hideAnimateWithCompleteBlock:(void(^ __nullable)())completeBlock;

- (void)setRecordLevelType:(MDUnifiedRecordLevelType)levelType;

@end

NS_ASSUME_NONNULL_END
