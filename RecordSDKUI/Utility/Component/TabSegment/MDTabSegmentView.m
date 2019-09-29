//
//  MDTabSegmentView.m
//  RecordSDK
//
//  Created by YZK on 2018/6/19.
//  Copyright © 2018年 RecordSDK. All rights reserved.
//

#import "MDTabSegmentView.h"
//#import <MDBadgeView.h>
#import "UIImage+MDUtility.h"
#import "MDRecordHeader.h"
#import <UIKit/UIKit.h>

const CGFloat kMDTabSegmentViewDefaultHeight = 50.0f;
#define kMDTabSegmentViewDefaultFontWeight UIFontWeightRegular

@interface MDTabSegmentView () <MDTabSegmentScrollHandlerDelegate>

@property (nonatomic, strong) NSArray<MDTabSegmentLabel *>                  *segmentViews;
@property (nonatomic, strong) UIScrollView                                  *contentScrollView;
@property (nonatomic, strong) UIImageView                                   *bottomPointView;

@property (nonatomic, assign) NSInteger                                     currentIndex;
@property (nonatomic, assign) NSInteger                                     toIndex;
@property (nonatomic, assign) CGFloat                                       animationProgress;
@property (nonatomic, strong) CADisplayLink                                 *animationLink;//动画定时器

@property (nonatomic, strong) MDTabSegmentViewConfiguration                 *configuration;
@property (nonatomic, strong) MDTabSegmentScrollHandler                     *scrollHandler;

@property (nonatomic, copy) MDTabSegmentViewTapActionBlock                  tapBlock;
@property (nonatomic, copy) MDTabSegmentViewTapActionBlock                  scrollEndBlock;
@property (nonatomic, copy) void (^arrowTapBlock)(NSInteger index);

@end


@implementation MDTabSegmentView

- (id)initWithPoint:(CGPoint)point
      segmentTitles:(NSArray<NSString*> *)segmentTitles
           tapBlock:(MDTabSegmentViewTapActionBlock)block
     scrollEndBlock:(MDTabSegmentViewTapActionBlock)scrollEndBlock {
    return [self initWithFrame:CGRectMake(point.x, point.y, MDScreenWidth, kMDTabSegmentViewDefaultHeight)
                 segmentTitles:segmentTitles
                 configuration:[MDTabSegmentViewConfiguration defaultConfiguration]
                      tapBlock:block
                scrollEndBlock:scrollEndBlock];
}

- (id)initWithFrame:(CGRect)frame
      segmentTitles:(NSArray<NSString*> *)segmentTitles
           tapBlock:(MDTabSegmentViewTapActionBlock)block
     scrollEndBlock:(MDTabSegmentViewTapActionBlock)scrollEndBlock {
    return [self initWithFrame:frame
                 segmentTitles:segmentTitles
                 configuration:[MDTabSegmentViewConfiguration defaultConfiguration]
                      tapBlock:block
                scrollEndBlock:scrollEndBlock];
}

- (id)initWithFrame:(CGRect)frame
      segmentTitles:(NSArray<NSString*> *)segmentTitles
      configuration:(MDTabSegmentViewConfiguration *)configuration
           tapBlock:(MDTabSegmentViewTapActionBlock)block
     scrollEndBlock:(MDTabSegmentViewTapActionBlock)scrollEndBlock {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        NSAssert(configuration != nil , @"MDTabSegmentView configuration can't nil，you can use [MDTabSegmentViewConfiguration defaultConfiguration]" );
        
        self.tapBlock = block;
        self.scrollEndBlock = scrollEndBlock;
        self.backgroundColor = [UIColor whiteColor];

        self.scrollHandler = [[MDTabSegmentScrollHandler alloc] init];
        self.scrollHandler.delegate = self;
        
        self.configuration = configuration;
        
        [self setupContentScrollView];
        [self refreshSegmentTitles:segmentTitles];
    }
    return self;
}

- (void)refreshSegmentTitles:(NSArray<NSString*> *)segmentTitles {
    self.toIndex = -1;
    [self removeAnimation];
    
    for (MDTabSegmentLabel *segmentLabel in self.segmentViews) {
        [segmentLabel removeFromSuperview];
    }
    self.segmentViews = nil;
    self.currentIndex = 0;

    CGFloat left = self.configuration.leftPadding;

    NSMutableArray *marr = [NSMutableArray array];
    for (int i=0; i<segmentTitles.count; i++) {
        NSString *title = [segmentTitles stringAtIndex:i defaultValue:nil];

        CGSize size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.configuration.normalFontSize weight:[MDTabSegmentViewConfiguration getFontWeightWithProgress:1.0]]} context:nil].size;
        CGFloat width = ceil(size.width) + 2;
        CGFloat height = ceil(size.height);

        MDTabSegmentLabel *segmentLabel = [[MDTabSegmentLabel alloc] initWithFrame:CGRectMake(left, (self.height-height)/2.0+5, width, height) fontSize:self.configuration.normalFontSize];
        segmentLabel.titleLabel.text = title;
        segmentLabel.titleLabel.textColor = self.configuration.customTiniColor ? self.configuration.customTiniColor : RGBCOLOR(50, 51, 51);
        segmentLabel.tag = i;
        segmentLabel.exclusiveTouch = YES;

        if (i == self.currentIndex) {
            [segmentLabel setLabelScale:self.configuration.selectScale fontWeight:[MDTabSegmentViewConfiguration getFontWeightWithProgress:1.0]];
            self.bottomPointView.centerX = CGRectGetMidX(segmentLabel.frame);
            self.bottomPointView.left = [[self class] adjustToPixelWithPoint:self.bottomPointView.left];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSegmentLabel:)];
        [segmentLabel addGestureRecognizer:tap];
        
        [self.contentScrollView addSubview:segmentLabel];
        [marr addObject:segmentLabel];

        left = left + segmentLabel.width + self.configuration.itemPadding;
    }
    self.segmentViews = marr;
    
    CGFloat width = left-self.configuration.itemPadding+self.configuration.rightPadding;
    if (segmentTitles.count == 0) {
        width = 0;
    }
    self.bottomPointView.backgroundColor = self.configuration.customTiniColor;
    self.contentScrollView.contentSize = CGSizeMake(width, 1);
}

#pragma mark - public

- (void)setTapTitle:(NSString *)title atIndex:(NSInteger)index {
    if (index >= 0 && index < self.segmentViews.count) {
        MDTabSegmentLabel *label = [self.segmentViews objectAtIndex:index defaultValue:nil];
        [label setText:title];
        
        CGSize size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.configuration.normalFontSize weight:[MDTabSegmentViewConfiguration getFontWeightWithProgress:1.0]]} context:nil].size;
        
        CGRect bounds = label.bounds;
        bounds.size = CGSizeMake( ceil(size.width)+2, ceil(size.height) );
        label.bounds = bounds;
        [label reLayoutLabel];
        
        [self resetAllSegmentViewWithCurrentIndex:self.currentIndex];
    }
}

- (void)setTapBadgeNum:(NSInteger)num atIndex:(NSInteger)index {
    if (index >= 0 && index < self.segmentViews.count && num >=0 ) {
        MDTabSegmentLabel *label = [self.segmentViews objectAtIndex:index defaultValue:nil];
        [label setBadgeNum:num];
    }
}

- (void)setRedDotHidden:(BOOL)hidden adIndex:(NSInteger)index {
    if (index >= 0 && index < self.segmentViews.count) {
        MDTabSegmentLabel *label = [self.segmentViews objectAtIndex:index defaultValue:nil];
        if (!CGSizeEqualToSize(self.configuration.redDotSize, CGSizeZero) && !hidden) {
            [label resetRedDotSize:self.configuration.redDotSize];
        }
        [label setRedDotHidden:hidden];
    }
}

- (void)setTabSegmentHidden:(BOOL)hidden adIndex:(NSInteger)index {
    if (index >= 0 && index < self.segmentViews.count) {
        MDTabSegmentLabel *label = [self.segmentViews objectAtIndex:index defaultValue:nil];
        if(label) {
            label.hidden = hidden;
        }
    }
}

+ (CGFloat)adjustToPixelWithPoint:(CGFloat)point {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat pixel = point * scale;
    pixel = round(pixel);
    return pixel / scale;
}

- (void)setCurrentLabelIndex:(NSInteger)currentIndex animated:(BOOL)animated {
    if (self.currentIndex != currentIndex) {
        
        if (animated) {
            [self startAnimationWithIndex:currentIndex];
        }else {
            [self removeAnimation];
            NSInteger oldIndex = self.currentIndex;
            [self animtionFromIndex:self.currentIndex toIndex:currentIndex progress:1];
            self.currentIndex = currentIndex;
            
            //调整底部小黑点对齐像素
            self.bottomPointView.left = [[self class] adjustToPixelWithPoint:self.bottomPointView.left];

            //隐藏其他箭头视图
            MDTabSegmentLabel *oldLabel = [self.segmentViews objectAtIndex:oldIndex defaultValue:nil];
            MDTabSegmentLabel *currentLabel = [self.segmentViews objectAtIndex:self.currentIndex defaultValue:nil];
            [oldLabel setArrowViewHidden:YES];
            [currentLabel setArrowViewHidden:NO];
            [currentLabel showArrowWithUp:NO animated:NO];
            
            //滚动到当前tab使其显示
            CGRect frame = [self.contentScrollView convertRect:currentLabel.bounds fromView:currentLabel];
            frame.origin.y = 0;
            frame.size.height = 1;
            frame.origin.x -= self.configuration.leftPadding;
            frame.size.width += self.configuration.leftPadding+10;
            [self.contentScrollView scrollRectToVisible:frame animated:YES];
        }
    }
}

- (void)setShowArrowActionWithBlock:(void(^)(NSInteger index))block atIndexs:(NSArray *)indexs {
    if (indexs && indexs.count) {
        _arrowTapBlock = block;
        for (NSNumber *num in indexs) {
            if ([num integerValue] < self.segmentViews.count) {
                MDTabSegmentLabel *label = [self.segmentViews objectAtIndex:[num integerValue] defaultValue:nil];
                [label setEnableShowArrow:YES];
                [label setArrowViewHidden:[num integerValue] != self.currentIndex];
            }
        }
    }
}

- (void)resumeCurrentLabelArrowWithAnimated:(BOOL)animated {
    MDTabSegmentLabel *label = [self.segmentViews objectAtIndex:self.currentIndex defaultValue:nil];
    [label showArrowWithUp:NO animated:animated];
}


#pragma mark - event

- (void)didTapSegmentLabel:(UITapGestureRecognizer *)recognizer {
    MDTabSegmentLabel *tapLabel = (MDTabSegmentLabel *)recognizer.view;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentView:shouldScrollToIndex:)]) {
        if (![self.delegate segmentView:self shouldScrollToIndex:tapLabel.tag]) {
            return;
        }
    }
    if (tapLabel.tag == self.currentIndex) {
        MDTabSegmentLabel *label = [self.segmentViews objectAtIndex:self.currentIndex defaultValue:nil];
        if (label.enableShowArrow && self.arrowTapBlock) {
            self.arrowTapBlock(self.currentIndex);
            [label showArrowWithUp:YES animated:YES];
        }
        return;
    }
    if (self.tapBlock) self.tapBlock(self, tapLabel.tag);
    [self setCurrentLabelIndex:tapLabel.tag animated:YES];
}

#pragma mark - animation

- (void)removeAnimation {
    if (self.animationLink) {
        [self.animationLink invalidate];
        self.animationLink = nil;
        self.toIndex = -1;
    }
}

- (void)resetAllSegmentViewWithCurrentIndex:(NSInteger)currentIndex {
    MDTabSegmentLabel *currentLabel = nil;
    for (int i=0; i<self.segmentViews.count; i++) {
        MDTabSegmentLabel *segmentLabel = [self.segmentViews objectAtIndex:i defaultValue:nil];
        if (i == currentIndex) {
            currentLabel = segmentLabel;
            [segmentLabel setLabelScale:self.configuration.selectScale fontWeight:[MDTabSegmentViewConfiguration getFontWeightWithProgress:1.0]];
        }else {
            [segmentLabel setLabelScale:1.0 fontWeight:[MDTabSegmentViewConfiguration getFontWeightWithProgress:0.0]];
        }
    }
    [self layoutSegmentTitle];
    
    self.bottomPointView.width = self.configuration.pointSize.width > 0 ? self.configuration.pointSize.width : 5.5;
    self.bottomPointView.centerX = CGRectGetMidX(currentLabel.frame);
}

- (void)startAnimationWithIndex:(NSInteger)toIndex {
    if (toIndex == self.toIndex) {
        return;
    }
    
    [self removeAnimation];
    [self resetAllSegmentViewWithCurrentIndex:self.currentIndex];
    
    self.toIndex = toIndex;
    self.animationProgress = 0;

    MDWeakProxy *weakSelf = [MDWeakProxy weakProxyForObject:self];
    self.animationLink = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(performAnimation)];
    [self.animationLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)performAnimation{
    if (self.animationProgress >= 1.0) {
        [self showAnimationCompleted];
    }else {
        self.animationProgress +=0.07;
        self.animationProgress = MAX(0.0, MIN(self.animationProgress, 1.0));
        [self animtionFromIndex:self.currentIndex toIndex:self.toIndex progress:self.animationProgress];
    }
}

- (void)animtionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    MDTabSegmentLabel *oldLable = [self.segmentViews objectAtIndex:fromIndex defaultValue:nil];
    MDTabSegmentLabel *newLabel = [self.segmentViews objectAtIndex:toIndex defaultValue:nil];

    CGFloat fromScale = self.configuration.selectScale + (1-self.configuration.selectScale) * progress;
    CGFloat toScale = 1 + (self.configuration.selectScale-1) * progress;

    [oldLable setLabelScale:fromScale fontWeight:[MDTabSegmentViewConfiguration getFontWeightWithProgress:(1-progress)]];
    [newLabel setLabelScale:toScale fontWeight:[MDTabSegmentViewConfiguration getFontWeightWithProgress:progress]];

    [self layoutSegmentTitle];
    
    
    CGFloat startPointX = CGRectGetMidX(oldLable.frame);
    CGFloat endPointX = CGRectGetMidX(newLabel.frame);
    
    CGFloat scale = fabsf(1 - progress*2);
    CGFloat offset = 0;
    if (toIndex!=fromIndex) {
        offset = fabs((endPointX-startPointX))/(fabs(toIndex-fromIndex)+2) ;
    }
    CGFloat baseWidth = self.configuration.pointSize.width > 0 ? self.configuration.pointSize.width : 5;
    CGFloat width = baseWidth + offset * (1 - scale);
    self.bottomPointView.width = width;
    
    CGFloat centenX = startPointX + (endPointX-startPointX) * progress;
    self.bottomPointView.centerX = centenX;
}

- (void)layoutSegmentTitle {
    CGFloat left = self.configuration.leftPadding;
    for (int i=0; i<self.segmentViews.count; i++) {
        MDTabSegmentLabel *afterLabel = [self.segmentViews objectAtIndex:i defaultValue:nil];
        
        afterLabel.left = left;
        left += afterLabel.width + self.configuration.itemPadding;
    }
    CGFloat width = left-self.configuration.itemPadding+self.configuration.rightPadding;
    self.contentScrollView.contentSize = CGSizeMake(width, 1);
}

- (void)showAnimationCompleted{
    [self setCurrentLabelIndex:self.toIndex animated:NO];
    [self removeAnimation];
}


- (void)scrollWithOldIndex:(NSInteger)index toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    
    if ( toIndex < 0 || toIndex >= self.segmentViews.count) {
        return ;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentView:shouldScrollToIndex:)]) {
        if (![self.delegate segmentView:self shouldScrollToIndex:toIndex]) {
            return;
        }
    }
    if (index == toIndex) { //此时说明滑动结束
        if (toIndex == self.currentIndex) {
            return;
        }
        if (self.scrollEndBlock) self.scrollEndBlock(self, toIndex);
        [self setCurrentLabelIndex:toIndex animated:NO];
    }
    else {
        if (self.animationLink) {
            [self removeAnimation];
            [self resetAllSegmentViewWithCurrentIndex:index];
        }
        [self animtionFromIndex:index toIndex:toIndex progress:progress];
    }
}

#pragma mark - setup UI

- (void)setupContentScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:scrollView];
    self.contentScrollView = scrollView;
    
    self.bottomPointView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.bottomPointView.width = self.configuration.pointSize.width;
    self.bottomPointView.height = self.configuration.pointSize.height;
    self.bottomPointView.top = self.height - self.configuration.pointInsetBottom;
    self.bottomPointView.layer.cornerRadius = self.configuration.pointSize.height/2.0;
    self.bottomPointView.backgroundColor = self.configuration.customTiniColor;
    self.bottomPointView.layer.masksToBounds = YES;
    [self.contentScrollView addSubview:self.bottomPointView];
}


@end



    
@implementation MDTabSegmentViewConfiguration

+ (instancetype)defaultConfiguration {
    MDTabSegmentViewConfiguration *configuration = [[MDTabSegmentViewConfiguration alloc] init];

    configuration.leftPadding = 17;
    configuration.rightPadding = 17;
    configuration.itemPadding = 20;
    
    configuration.normalFontSize = 15;
    configuration.selectScale = 1.6;
    
    configuration.customTiniColor = RGBCOLOR(50, 51, 51);
    configuration.pointSize = CGSizeMake(6, 4);
    configuration.pointInsetBottom = 8;
    
    return configuration;
}


+ (UIFontWeight)getFontWeightWithProgress:(CGFloat)progress {
    progress = MIN(1.0, MAX(0.0, progress));
    CGFloat weight = kMDTabSegmentViewDefaultFontWeight + (UIFontWeightHeavy - kMDTabSegmentViewDefaultFontWeight) * progress;
    
    UIFontWeight fontWeight = kMDTabSegmentViewDefaultFontWeight;
    if (weight >= UIFontWeightRegular && weight < middleWeight(UIFontWeightRegular, UIFontWeightMedium)) {
        fontWeight = UIFontWeightRegular;
    }
    else if (weight >= middleWeight(UIFontWeightRegular, UIFontWeightMedium) &&
             weight < middleWeight(UIFontWeightMedium, UIFontWeightSemibold)) {
        fontWeight = UIFontWeightMedium;
    }
    else if (weight >= middleWeight(UIFontWeightMedium, UIFontWeightSemibold) &&
             weight < middleWeight(UIFontWeightSemibold, UIFontWeightBold)) {
        fontWeight = UIFontWeightSemibold;
    }
    else if (weight >= middleWeight(UIFontWeightSemibold, UIFontWeightBold) &&
             weight < middleWeight(UIFontWeightBold, UIFontWeightHeavy)) {
        fontWeight = UIFontWeightBold;
    }
    else if (weight >= middleWeight(UIFontWeightBold, UIFontWeightHeavy)) {
        fontWeight = UIFontWeightHeavy;
    }
    return fontWeight;
}

static inline CGFloat middleWeight(CGFloat weightA, CGFloat weightB) {
    return (weightA + weightB) / 2.0;
}

@end





@interface MDTabSegmentLabel ()
@property (nonatomic, strong) UIImageView *redDotView;
//@property (nonatomic, strong) MDBadgeView *badgeView;
@property (nonatomic, assign) CGRect originRect;
@property (nonatomic, assign) CGFloat originFontSize;
@property (nonatomic, strong) UIImageView *arrowView;
@end

@implementation MDTabSegmentLabel

- (instancetype)initWithFrame:(CGRect)frame fontSize:(CGFloat)fontSize {
    self = [super initWithFrame:frame];
    if (self) {
        self.originRect = self.bounds;
        self.originFontSize = fontSize;
        
        CGRect frame = self.frame;
        self.layer.anchorPoint = CGPointMake(0, 1);
        self.frame = frame;
        
        [self addSubview:self.titleLabel];
        self.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:kMDTabSegmentViewDefaultFontWeight];
    }
    return self;
}

- (void)reLayoutLabel {
    self.originRect = self.bounds;
    self.titleLabel.frame = self.bounds;
    [self layoutBadge];
}


- (void)setLabelScale:(CGFloat)scale fontWeight:(UIFontWeight)fontWeight {
    CGRect scaleRect = CGRectApplyAffineTransform(self.originRect, CGAffineTransformMakeScale(scale, scale));
    CGFloat scaleFontSize = self.originFontSize * scale;
    
    self.bounds = scaleRect;
    self.titleLabel.frame = self.bounds;
    self.titleLabel.font = [UIFont systemFontOfSize:scaleFontSize weight:fontWeight];
    
    if ((_redDotView && !_redDotView.hidden) || (_arrowView && !_arrowView.hidden)) {
        [self layoutBadge];
    }
}


- (void)setText:(NSString *)text {
    [_titleLabel setText:text];
    [self layoutBadge];
}

- (void)setBadgeNum:(NSInteger)num {
    if (num != 0) {
        [self layoutBadge];
    } else {
    }
}

- (void)resetRedDotSize:(CGSize)size{
    if (_redDotView) {
        _redDotView.size = size;
    }
}

- (void)setRedDotHidden:(BOOL)hidden {
    if (hidden) {
        _redDotView.hidden = YES;
    }else {
        [self createRedDotView];
        self.redDotView.hidden = NO;
        [self bringSubviewToFront:self.redDotView];
        [self layoutBadge];
    }
}

- (void)showArrowWithUp:(BOOL)isUp animated:(BOOL)animated {
    if (!self.enableShowArrow) {
        return;
    }
    
    if (!animated) {
        self.arrowView.layer.transform = isUp ? CATransform3DMakeRotation(-M_PI, 0, 0, 1) : CATransform3DIdentity;
    }else {
        CABasicAnimation *rotationAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        rotationAnimation.duration = 0.3;
        if (isUp) {
            rotationAnimation.fromValue= [NSNumber numberWithFloat:0];
            rotationAnimation.toValue = [NSNumber numberWithFloat:-M_PI];
            self.arrowView.layer.transform = CATransform3DMakeRotation(-M_PI, 0, 0, 1);
        } else {
            rotationAnimation.fromValue= [NSNumber numberWithFloat:-M_PI];
            rotationAnimation.toValue = [NSNumber numberWithFloat:0];
            self.arrowView.layer.transform = CATransform3DIdentity;
        }
        [self.arrowView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
}

- (void)setEnableShowArrow:(BOOL)enableShowArrow {
    _enableShowArrow = enableShowArrow;
    if (enableShowArrow) {
        [self createArrowView];
        self.arrowView.hidden = NO;
        [self layoutBadge];
    } else {
        self.arrowView.hidden = YES;
    }
}

- (void)setArrowViewHidden:(BOOL)hidden {
    if (!self.enableShowArrow || hidden) {
        self.arrowView.hidden = YES;
    } else {
        [self createArrowView];
        self.arrowView.hidden = NO;
        [self layoutBadge];
    }
}


- (void)layoutBadge {

    if (_redDotView) {
        CGPoint redDotCenter = CGPointMake(self.width+3, 0);
        _redDotView.center = redDotCenter;
    }
    
    if (_arrowView) {
        CGPoint arrowCenter = CGPointMake(self.width+6, self.height/2.0);
        _arrowView.center = arrowCenter;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.arrowView) {
        CGRect rect = CGRectInset(self.bounds, 0, -20);
        rect.size.width += 12;
        return CGRectContainsPoint(rect, point);
    }
    return CGRectContainsPoint(CGRectInset(self.bounds, 0, -20), point);
}

#pragma mark - lazy UI

- (UIImageView *)createRedDotView {
    if (!_redDotView) {
        _redDotView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIBundle.bundle/E10_icon"]];
        _redDotView.size = CGSizeMake(8, 8);
        _redDotView.backgroundColor = [UIColor clearColor];
        _redDotView.hidden = YES;
        [self addSubview:_redDotView];
    }
    return _redDotView;
}

- (UIImageView *)createArrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_contact_unselect"]];
        _arrowView.backgroundColor = [UIColor clearColor];
        _arrowView.hidden = YES;
        [self addSubview:_arrowView];
    }
    return _arrowView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _titleLabel;
}





@end


