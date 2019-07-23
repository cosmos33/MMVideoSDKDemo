//
//  MDCameraButtomView.h
//  RecordScrollerViewTest
//
//  Created by lm on 2017/6/9.
//  Copyright © 2017年 lm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDRecordHeader.h"

@protocol MDCameraBottomViewDelegate <NSObject>

- (void)didClicButtonWithType:(MDUnifiedRecordLevelType)levelType;

@end

@interface MDCameraBottomView : UIView

@property (nonatomic, weak) id<MDCameraBottomViewDelegate>  delegate;

//底部视频滚动 比例
-(void)viewDidScroll:(CGFloat)scaleValue;

//构建更新相关视图
- (void)setAvailableTapList:(NSArray*)availableTaps;

//选中tap后更新frame
- (void)updateLayoutWithSelectedTap:(MDUnifiedRecordLevelType)aTapType;

- (MDUnifiedRecordLevelType)getPreLevelType;
- (MDUnifiedRecordLevelType)getNextLevelType;
- (MDUnifiedRecordLevelType)getCurrentLevelType;
@end
