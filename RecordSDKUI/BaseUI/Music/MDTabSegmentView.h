//
//  MDTabSegmentView.h
//  RecordSDK
//
//  Created by YZK on 2018/6/19.
//  Copyright © 2018年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDTabSegmentScrollHandler.h"

@class MDTabSegmentView,MDTabSegmentViewConfiguration,MDTabSegmentLabel;

typedef void (^MDTabSegmentViewTapActionBlock) (MDTabSegmentView *tapView, NSInteger index);

FOUNDATION_EXPORT const CGFloat kMDTabSegmentViewDefaultHeight;
#define kTabSegmentViewContentInset    (MDStatusBarAndNavigationBarHeight + kMDTabSegmentViewDefaultHeight)

@protocol MDTabSegmentViewDelegate <NSObject>
@optional
- (BOOL)segmentView:(MDTabSegmentView *)segmentView shouldScrollToIndex:(NSInteger)toIndex;
@end
/**
 通用tab分类栏Bar
 */
@interface MDTabSegmentView : UIView
@property (nonatomic, weak) id<MDTabSegmentViewDelegate> delegate;

@property (nonatomic, assign, readonly) NSInteger currentIndex;
@property (nonatomic, strong, readonly) MDTabSegmentViewConfiguration *configuration;

@property (nonatomic, strong, readonly) UIScrollView      *contentScrollView;
@property (nonatomic, strong, readonly) NSArray<MDTabSegmentLabel *> *segmentViews;
@property (nonatomic, strong, readonly) UIImageView       *bottomPointView;

/**
 如果需要和scrollView联动，要调用scrollHandler里面对应的scrollView的回调
 */
@property (nonatomic, strong, readonly) MDTabSegmentScrollHandler *scrollHandler;


- (id)initWithPoint:(CGPoint)point
      segmentTitles:(NSArray<NSString*> *)segmentTitles
           tapBlock:(MDTabSegmentViewTapActionBlock)block
     scrollEndBlock:(MDTabSegmentViewTapActionBlock)scrollEndBlock;

- (id)initWithFrame:(CGRect)frame
      segmentTitles:(NSArray<NSString*> *)segmentTitles
           tapBlock:(MDTabSegmentViewTapActionBlock)block
     scrollEndBlock:(MDTabSegmentViewTapActionBlock)scrollEndBlock;


/**
 初始化方法

 @param frame bar的坐标
 @param segmentTitles 选项卡标题数组
 @param configuration 显示配置，不能为nil
 @param block 选中的回调，如果调用了scrollHandler，会在手拖scrollView滑动停止时也回调
 @return 选项卡view
 */
- (id)initWithFrame:(CGRect)frame
      segmentTitles:(NSArray<NSString*> *)segmentTitles
      configuration:(MDTabSegmentViewConfiguration *)configuration
           tapBlock:(MDTabSegmentViewTapActionBlock)tapBlock
     scrollEndBlock:(MDTabSegmentViewTapActionBlock)scrollEndBlock;

- (void)refreshSegmentTitles:(NSArray<NSString*> *)segmentTitles;
- (void)setCurrentLabelIndex:(NSInteger)currentIndex animated:(BOOL)animated;

- (void)setTapTitle:(NSString *)title atIndex:(NSInteger)index;
- (void)setTapBadgeNum:(NSInteger)num atIndex:(NSInteger)index;
- (void)setRedDotHidden:(BOOL)hidden adIndex:(NSInteger)index;
- (void)setTabSegmentHidden:(BOOL)hidden adIndex:(NSInteger)index;

- (void)setShowArrowActionWithBlock:(void(^)(NSInteger index))block atIndexs:(NSArray *)indexs;
- (void)resumeCurrentLabelArrowWithAnimated:(BOOL)animated;

- (void)animtionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

- (void)refreshSegmentTitles:(NSArray<NSString*> *)segmentTitles;
@end


@interface MDTabSegmentViewConfiguration : NSObject

//均为没选中放大情况下计算
@property (nonatomic, assign) CGFloat leftPadding;
@property (nonatomic, assign) CGFloat rightPadding;
@property (nonatomic, assign) CGFloat itemPadding;

@property (nonatomic, assign) CGFloat normalFontSize;
@property (nonatomic, assign) CGFloat selectScale;

@property (nonatomic, strong) UIColor *customTiniColor;
@property (nonatomic, assign) CGFloat pointInsetBottom;
@property (nonatomic, assign) CGSize pointSize;
@property (nonatomic, assign) CGSize redDotSize;

+ (instancetype)defaultConfiguration;

+ (UIFontWeight)getFontWeightWithProgress:(CGFloat)progress;

@end



@interface MDTabSegmentLabel : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) BOOL enableShowArrow;

- (instancetype)initWithFrame:(CGRect)frame fontSize:(CGFloat)fontSize;

- (void)setLabelScale:(CGFloat)scale fontWeight:(UIFontWeight)fontWeight;
- (void)reLayoutLabel;

- (void)setText:(NSString *)text;
- (void)setBadgeNum:(NSInteger)num;
- (void)setRedDotHidden:(BOOL)hidden;
- (void)resetRedDotSize:(CGSize)size;

- (void)showArrowWithUp:(BOOL)isUp animated:(BOOL)animated;
- (void)setArrowViewHidden:(BOOL)hidden;

@end
