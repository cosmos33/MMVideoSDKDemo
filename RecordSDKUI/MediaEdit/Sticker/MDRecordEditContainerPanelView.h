//
//  MDRecordEditContainerPanelView.h
//  MomoChat
//
//  Created by RFeng on 2019/4/8.
//  Copyright © 2019年 wemomo.com. All rights reserved.
//


#import <UIKit/UIKit.h>
// 贴纸
#import "MDRecordEditStickersView.h"
// 涂鸦
#import "MDMomentPainterToolView.h"
NS_ASSUME_NONNULL_BEGIN




@interface MDRecordEditContainerPanelView : UIView

+ (MDRecordEditContainerPanelView *)editPanelView;

@property (nonatomic, weak) id<MDRecordEditContainerPanelActionDelegate> delegate;
@property (nonatomic, weak) id<MDRecordEditContainerPanelAnimationDelegate> animationDelegate;


/**
 合并收起来
 */
- (void)funtionConsolidate;

@end

NS_ASSUME_NONNULL_END
