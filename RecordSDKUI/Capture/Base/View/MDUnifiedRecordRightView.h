//
//  MDUnifiedRecordRightView.h
//  MDChat
//
//  Created by YZK on 2018/3/12.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDUnifiedRecordIconView.h"
#import <RecordSDK/MDRecordFilter.h>

@class MDRecordGuideTipsManager,MDUnifiedRecordIconView;

FOUNDATION_EXTERN const CGFloat kMDUnifiedRecordRightViewIconWidth;
FOUNDATION_EXTERN const CGFloat kMDUnifiedRecordRightViewRightMargin;

@protocol MDUnifiedRecordRightViewDelegate <NSObject>

@optional
- (void)didTapFaceDecorationView:(MDUnifiedRecordIconView *)view;
- (void)didTapFilterView:(MDUnifiedRecordIconView *)view;
- (void)didTapMusicView:(MDUnifiedRecordIconView *)view;
- (void)didTapThinView:(MDUnifiedRecordIconView *)view;
- (void)didTapSpeedView:(MDUnifiedRecordIconView *)view;
- (void)didTapDelayView:(MDUnifiedRecordIconView *)view;
- (void)didTapMakeUpView:(MDUnifiedRecordIconView *)view;
- (NSString *)musicIDFromOperation;
@end

@interface MDUnifiedRecordRightView : UIView

- (instancetype)initWithFrame:(CGRect)frame andGuideTipsManager:(MDRecordGuideTipsManager *)guideManager;

@property (nonatomic,weak) id<MDUnifiedRecordRightViewDelegate> delegate;

@property (nonatomic,strong,readonly) MDUnifiedRecordIconView    *delayView;
@property (nonatomic,strong,readonly) MDUnifiedRecordIconView    *speedView;
@property (nonatomic,strong,readonly) MDUnifiedRecordIconView    *filterView;
@property (nonatomic,strong,readonly) MDUnifiedRecordIconView    *faceDecorationView;
@property (nonatomic,strong,readonly) MDUnifiedRecordIconView    *musicView;
@property (nonatomic,strong,readonly) MDUnifiedRecordIconView    *thinView;

//@property (nonatomic,assign,readonly) BOOL hasRedPointOfFilterView;
//@property (nonatomic,assign,readonly) BOOL hasRedPointOfFaceDecorationView;
//@property (nonatomic,assign,readonly) BOOL hasRedPointOfMusicView;
//@property (nonatomic,assign,readonly) BOOL hasRedPointOfThinView;

//- (CGRect)absoluteFrameOfFilterView;
//- (CGRect)absoluteFrameOfFaceDecorationView;
//- (CGRect)absoluteFrameOfMusicView;
//- (CGRect)absoluteFrameOfThinView;

//- (void)removeRedPointOfFilterView;
//- (void)removeRedPointOfFaceDecorationView;
//- (void)removeRedPointOfMusicView;
//- (void)removeRedPointOfThinView;

- (void)handleRotateWithTransform:(CGAffineTransform)transform;

- (void)didShowFilter:(MDRecordFilter *)filter;
- (MDRecordFilter *)currentShowFilter;

- (void)didSelectMusicTitle:(NSString *)title;
- (void)enableMusicSelected:(BOOL)enable;

@end
