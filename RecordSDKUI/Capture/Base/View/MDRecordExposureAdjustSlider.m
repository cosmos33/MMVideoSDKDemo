//
//  MDRecordExposureAdjustView.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/5.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordExposureAdjustSlider.h"
#import <RecordSDK/UIView+MDSnapshot.h>

@interface MDRecordSlider : UISlider

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation MDRecordSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.maximumTrackTintColor = UIColor.clearColor;
        self.minimumTrackTintColor = UIColor.clearColor;
        
        [self setThumbImage:[UIImage imageNamed:@"ml_camera_focus_exposure"] forState:UIControlStateNormal];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        topLine.backgroundColor = UIColor.yellowColor;
        [self addSubview:topLine];
        self.topLine = topLine;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        bottomLine.backgroundColor = UIColor.yellowColor;
        [self addSubview:bottomLine];
        self.bottomLine = bottomLine;
    }
    return self;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    
    CGRect thumbFrame = [super thumbRectForBounds:bounds trackRect:rect value:value];
    CGFloat centerX = CGRectGetMidX(thumbFrame);
    CGFloat centerY = CGRectGetMidY(thumbFrame);
    
    CGFloat lineHeight = 1;
    CGFloat lineRap = 15;
    CGFloat lineY = centerY - lineHeight / 2;
    CGFloat topLineWidth = centerX - lineRap - rect.origin.x;
    CGFloat bottomLineWidht = rect.size.width - rect.origin.x - centerX - lineRap;
    
    self.topLine.frame = CGRectMake(rect.origin.x, lineY, topLineWidth < 0 ? 0 : topLineWidth, lineHeight);
    self.bottomLine.frame = CGRectMake(centerX + lineRap, lineY, bottomLineWidht < 0 ? 0 : bottomLineWidht, lineHeight);
    
    return thumbFrame;
}

@end

@interface MDRecordExposureAdjustSliderThumbView : UIView

@end

@implementation MDRecordExposureAdjustSliderThumbView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.backgroundColor = UIColor.blueColor;
        
        self.layer.cornerRadius = self.bounds.size.width / 2;
        
        CGFloat centerX = CGRectGetMidX(self.bounds);
        CGFloat centerY = CGRectGetMidY(self.bounds);
        
        CGFloat centerDotDiameter = self.bounds.size.width / 2;
        UIView *centerDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, centerDotDiameter, centerDotDiameter)];
        centerDot.center = CGPointMake(centerX, centerY);
        centerDot.backgroundColor = UIColor.redColor;
        centerDot.layer.cornerRadius = centerDotDiameter / 2.0f;
        [self addSubview:centerDot];
        
        for (int i = 0; i < 8; i ++) {
            UIView *edgeLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
            edgeLine.center = CGPointMake(centerX, centerY);
            edgeLine.backgroundColor = UIColor.redColor;
            // 左乘关系，中心点坐标会先rotate,然后translate, 因此transform = rotate_matrix * translate_matrix
            // rotate 是顺时针旋转，当传入45度时候顺时针旋转45度
            edgeLine.transform = CGAffineTransformRotate(CGAffineTransformTranslate(CGAffineTransformIdentity, cos(M_PI_4 * i) * 10, sin(M_PI_4 * i) * 10), M_PI_4 * i);
            [self addSubview:edgeLine];
        }
        
    }
    return self;
}

@end

@interface MDRecordExposureAdjustSlider ()

@end

@implementation MDRecordExposureAdjustSlider

- (instancetype)initWithFrame:(CGRect)frame {
    NSAssert(NO, nil);
    return [super initWithFrame:frame];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSAssert(NO, nil);
    return [super initWithCoder:coder];
}

- (instancetype)init {
    CGRect frame = CGRectMake(0, 0, 120, 200);
    self = [super initWithFrame:frame];
    if (self) {
        
        MDRecordSlider *slider = [[MDRecordSlider alloc] init];
        slider.tag = 1001;
        slider.translatesAutoresizingMaskIntoConstraints = NO;
        slider.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(-(10 + 10 + 13), 0), -M_PI_2);
        slider.minimumValue = 0;
        slider.maximumValue = 1;
        slider.value = 0.5;
        slider.continuous = YES;
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider];
        
        [slider.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [slider.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [slider.heightAnchor constraintEqualToConstant:26].active = YES;
        [slider.widthAnchor constraintEqualToConstant:180].active = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ml_camera_focus"]];
        imageView.center = CGPointMake(frame.size.width / 2 + 20, frame.size.height / 2);
        [self addSubview:imageView];
    }
    return self;
}

- (void)sliderValueChanged:(MDRecordSlider *)slider {
    [self.delegate slider:self value:slider.value];
}

- (void)reset {
    UISlider *slider = [self viewWithTag:1001];
    slider.value = 0.5;
    [self.delegate slider:self value:0.5];
}

+ (MDRecordExposureAdjustSlider *)showSlider:(BOOL)animated onView:(UIView *)superView {
    
    MDRecordExposureAdjustSlider *slider = [[MDRecordExposureAdjustSlider alloc] init];
    slider.hidden = YES;
    slider.transform = CGAffineTransformMakeScale(1.1, 1.1);
    [superView addSubview:slider];
    [UIView animateWithDuration:animated ? 0.05 : 0.01 animations:^{
        slider.hidden = NO;
        slider.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
    
    return slider;
}

- (void)dismiss:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.05 : 0.01 animations:^{
        self.hidden = YES;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
