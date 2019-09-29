//
//  MDVideoTrimmerView.h
//  MDChat
//
//  Created by Jc on 17/2/7.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
@class MDVideoTrimmerView;
@class MDVideoTrimmerRangeView;

typedef struct MDLRRange {
    CGFloat left;
    CGFloat right;
} MDLRRange;

static inline MDLRRange
MDLRRangeMake(CGFloat left, CGFloat right)
{
    MDLRRange range;
    range.left = left;
    range.right = right;
    return range;
}

#pragma mark - Protocol

@protocol MDVideoTrimmerViewDelegate <NSObject>
@required
- (CMTime)videoTrimmerView:(MDVideoTrimmerView *)trimmerView mediaSouceTimeFromPresentationTime:(CMTime)presentationTime;
- (CMTime)videoTrimmerView:(MDVideoTrimmerView *)trimmerView presentationTimeFromMediaSourceTime:(CMTime)mediaSourceTime;

@optional
- (void)videoTrimmerViewDidChangeSelected:(MDVideoTrimmerView *)trimmerView;
- (void)videoTrimmerViewDidStartChange:(MDVideoTrimmerView *)trimmerView;
- (void)videoTrimmerViewDidChanged:(MDVideoTrimmerView *)trimmerView;
- (void)videoTrimmerViewDidEndChange:(MDVideoTrimmerView *)trimmerView;
- (void)videoTrimmerViewDidScroll:(MDVideoTrimmerView *)trimmerView;
@end

@protocol MDVideoTrimmerRangeViewDelegate <NSObject>
- (CGFloat)trimmerRangeView:(MDVideoTrimmerRangeView *)rangeView shouldMoved:(CGFloat)offsetX;
- (void)trimmerRangeViewWillChangeRange:(MDVideoTrimmerRangeView *)rangeView;
- (void)trimmerRangeViewIsChangingRange:(MDVideoTrimmerRangeView *)rangeView;
- (void)trimmerRangeViewDidChangeRange:(MDVideoTrimmerRangeView *)rangeView;
- (void)trimmerRangeViewDidChangeSelected:(MDVideoTrimmerRangeView *)rangeView;
@end

#pragma mark - Trimmer View

@interface MDVideoTrimmerView : UIView

@property (nonatomic, weak) id<MDVideoTrimmerViewDelegate> delegate;
@property (nonatomic, assign) BOOL borderTimeLabelHidden;
@property (nonatomic, assign) NSTimeInterval maxVideoSesonds;

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset;
- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset imageTimeInterval:(NSTimeInterval)timeInterval;

- (void)scrollToTime:(CMTime)time animated:(BOOL)animated;
- (BOOL)insertTimeRange:(CMTimeRange)timeRange;
- (void)deleteSelectedTimeRange;
- (void)deleteTimeRangeAtIndex:(NSInteger)index;
- (void)deleteAllTimeRange;
- (BOOL)isCurrentPointerInSelectedRange;

- (NSArray<NSValue*> *)trimmerTimeRanges;
- (NSUInteger)selectedTrimmerRangeIndex;
- (CMTimeRange)selectedTrimmerTimeRange;
- (CMTime)currentPointerTime;

@end

@interface MDVideoTrimmerView (Synchronize)
- (void)synchronizeWithPlayer:(AVPlayer *)player;
@end

#pragma mark - Range View

@interface MDVideoTrimmerRangeView : UIView
@property (nonatomic, weak) id<MDVideoTrimmerRangeViewDelegate> delegate;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign, readonly) MDLRRange trimmerRange;
@property (nonatomic, assign) MDLRRange limitRange;
@property (nonatomic, strong, readonly) UIView *leftOverLayView;
@property (nonatomic, strong, readonly) UIView *rightOverLayView;
- (instancetype)initWithFrame:(CGRect)frame trimmerRange:(MDLRRange)trimmerRange limitRange:(MDLRRange)limitRange minimum:(CGFloat)minimum maximum:(CGFloat)maximum timeInterval:(NSTimeInterval)timeInterval color:(UIColor *)color hiddenTimeLabel:(BOOL)isHidden;
- (void)showInsertAnimation;
@end

#pragma mark - Thumb View

@interface MDVideoTrimmerThumbView : UIView
- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color rightFlag:(BOOL)rightFlag;
@end

