//
//  MDMediaEditorRightView.h
//  MDChat
//
//  Created by YZK on 2018/8/1.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDUnifiedRecordIconView.h"

@class MDRecordGuideTipsManager;

@protocol MDMediaEditorRightViewDelegate <NSObject>

@optional
- (void)didTapThinView:(MDUnifiedRecordIconView *)view;
- (void)didTapSpecialEffectsView:(MDUnifiedRecordIconView *)view;

@end

@interface MDMediaEditorRightView : UIView

- (instancetype)initWithFrame:(CGRect)frame andGuideTipsManager:(MDRecordGuideTipsManager *)guideManager;

@property (nonatomic,weak) id<MDMediaEditorRightViewDelegate> delegate;

@property (nonatomic, strong, readonly) MDUnifiedRecordIconView *thinView;
@property (nonatomic, strong, readonly) MDUnifiedRecordIconView *specialEffectsView;

- (CGRect)absoluteFrameOfThinView;
- (CGRect)absoluteFrameOfSpecialEffectsView;

@end
