//
//  BBMediaEditorSlidingOverlayView.h
//  BiBi
//
//  Created by YuAo on 12/10/15.
//  Copyright © 2015 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RecordSDK/MDRecordFilter.h>

@class BBMediaEditorSlidingOverlayView;

@protocol BBMediaEditorSlidingOverlayViewDelegate <NSObject>

- (BOOL)mediaEditorSlidingOverlayView:(BBMediaEditorSlidingOverlayView *)overlayView shouldHandleTouchAtPoint:(CGPoint)point withEvent:(UIEvent *)event defaultValue:(BOOL)defaultValue;

- (void)mediaEditorSlidingOverlayView:(BBMediaEditorSlidingOverlayView *)overlayView
                filterOffsetDidChange:(double)filterOffset
                              filterA:(MDRecordFilter *)filterA
                              filterB:(MDRecordFilter *)filterB;

- (void)mediaEditorSlidingOverlayViewDidEndDecelerating:(BBMediaEditorSlidingOverlayView *)overlayView fromPageIndex:(NSInteger)pageIndex;

@end

typedef NS_ENUM(NSUInteger, BBMediaEditorSlidingOverlayViewType) {
    BBMediaEditorSlidingOverlayViewTypeHorizontal,                  //横向切换滤镜
    BBMediaEditorSlidingOverlayViewTypeVertical,                    //垂直切换滤镜
};

typedef NS_ENUM(NSUInteger, BBMediaEditorSlidingOverlayViewSceneType) {
    BBMediaEditorSlidingOverlayViewTypeQuickChat,                   //快聊
    BBMediaEditorSlidingOverlayViewTypeRecord,                      //视频录制
};



@interface BBMediaEditorSlidingOverlayView : UIView

@property (nonatomic,weak) id<BBMediaEditorSlidingOverlayViewDelegate> delegate;

@property (nonatomic) NSInteger currentPageIndex;

@property (nonatomic, assign) CGFloat currentOffset;

@property (nonatomic, assign, readonly) NSInteger currentFilterIndex;

@property (nonatomic, assign) BOOL scrollEnabled;


- (instancetype)initWithSlidingOverlayViewType:(BBMediaEditorSlidingOverlayViewType)slidingOverlayViewType
                                     sceneType:(BBMediaEditorSlidingOverlayViewSceneType)sceneType
                                         frame:(CGRect)frame;

- (void)setFilters:(NSArray<MDRecordFilter *> *)filters;

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex animated:(BOOL)animated;

- (MDRecordFilter *)filterAtPageIndex:(NSInteger)pageIndex;


- (void)scrollToNextPage;

@end
