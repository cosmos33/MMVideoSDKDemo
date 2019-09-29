//
//  MDRecordFilterDrawerSliderPanel.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/18.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordFilterDrawerSliderPanel.h"
#import "MDRecordFilterDrawerSlider.h"

@interface MDRecordFilterDrawerSliderPanel ()

@property (nonatomic, weak) MDRecordFilterDrawerSlider *slider1;
@property (nonatomic, weak) MDRecordFilterDrawerSlider *slider2;

@end

@implementation MDRecordFilterDrawerSliderPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        [self configUI];
    }
    return self;
}

- (void)dealloc {
    
}

- (void)setTitle1:(NSString *)title1 {
    _title1 = title1.copy;
    
    self.slider1.title = _title1;
}

- (void)setTitle2:(NSString *)title2 {
    _title2 = title2.copy;
    
    self.slider2.title = _title2;
}

- (void)configUI {
    __weak typeof(self) weakself = self;
    
    MDRecordFilterDrawerSlider *slider1 = [self createSlider];
    slider1.valueChanged = ^(MDRecordFilterDrawerSlider * _Nonnull slider, CGFloat value) {
        __strong typeof(self) strongself = weakself;
        [strongself.delegate sliderValueChanged:strongself value:value position:MDRecordFilterDrawerSliderPanelSliderPositionTop];
    };
    slider1.title = self.title1;
    [self addSubview:slider1];
    self.slider1 = slider1;
    
    MDRecordFilterDrawerSlider *slider2 = [self createSlider];
    slider2.valueChanged = ^(MDRecordFilterDrawerSlider * _Nonnull slider, CGFloat value) {
        __strong typeof(self) strongself = weakself;
        [strongself.delegate sliderValueChanged:strongself value:value position:MDRecordFilterDrawerSliderPanelSliderPositionBottom];
    };
    slider2.title = self.title2;
    [self addSubview:slider2];
    self.slider2 = slider2;
    
    [slider1.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [slider1.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [slider1.bottomAnchor constraintEqualToAnchor:slider2.topAnchor constant:-10].active = YES;
    [slider1.heightAnchor constraintEqualToConstant:56].active = YES;
    
    [slider2.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [slider2.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [slider2.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8].active = YES;
    [slider2.heightAnchor constraintEqualToAnchor:slider1.heightAnchor].active = YES;
}

- (MDRecordFilterDrawerSlider *)createSlider {
    MDRecordFilterDrawerSlider *slider = [[MDRecordFilterDrawerSlider alloc] init];
    slider.translatesAutoresizingMaskIntoConstraints = NO;
    return slider;
}

@end
