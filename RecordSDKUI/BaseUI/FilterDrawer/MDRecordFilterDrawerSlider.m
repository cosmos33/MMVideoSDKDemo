//
//  MDRecordFilterDrawerSlider.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/20.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordFilterDrawerSlider.h"
#import "MDRecordHeader.h"

@interface MDRecordFilterDrawerSlider()

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *valueLabel;

@property (nonatomic, weak) NSLayoutConstraint *centerXConstraint;

@end

@implementation MDRecordFilterDrawerSlider

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.translatesAutoresizingMaskIntoConstraints = NO;
        _slider.minimumValue = 0;
        _slider.maximumValue = 100;
        _slider.continuous = YES;
        _slider.minimumTrackTintColor = RGBCOLOR(0, 192, 255);
        _slider.maximumTrackTintColor = UIColor.whiteColor;
        [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.textColor = UIColor.whiteColor;
        _label.font = [UIFont systemFontOfSize:14];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _valueLabel.textColor = UIColor.whiteColor;
        _valueLabel.font = [UIFont systemFontOfSize:14];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.text = 0;
    }
    return _valueLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    
    [self addSubview:self.slider];
    [self addSubview:self.label];
    [self addSubview:self.valueLabel];
    
    [self.label.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:28].active = YES;
    [self.label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.label.widthAnchor constraintEqualToConstant:32].active = YES;
    
    [self.slider.centerYAnchor constraintEqualToAnchor:self.label.centerYAnchor].active = YES;
    [self.slider.leftAnchor constraintEqualToAnchor:self.label.rightAnchor constant:15.5].active = YES;
    [self.slider.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-33.5].active = YES;
    
    self.centerXConstraint = [self.valueLabel.centerXAnchor constraintEqualToAnchor:self.slider.leftAnchor constant:self.slider.currentThumbImage.size.width / 2.0];
    self.centerXConstraint.active = YES;
    [self.valueLabel.bottomAnchor constraintEqualToAnchor:self.slider.topAnchor constant:-12].active = YES;
}

- (void)valueChanged:(UISlider *)slider {
    
    CGRect trackRect = [self.slider trackRectForBounds:self.slider.bounds];
    CGRect thumbRect = [self.slider thumbRectForBounds:self.slider.bounds
                                             trackRect:trackRect
                                                 value:self.slider.value];
    self.centerXConstraint.active = NO;
    self.centerXConstraint = [self.valueLabel.centerXAnchor constraintEqualToAnchor:self.slider.leftAnchor constant:thumbRect.origin.x + thumbRect.size.width / 2 - 2];
    self.centerXConstraint.active = YES;
    
    self.valueLabel.text = [@(self.sliderValue) stringValue];
    self.valueChanged ? self.valueChanged(self, self.sliderValue) : nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self valueChanged:self.slider];
}

- (void)setTitle:(NSString *)title {
    self.label.text = title;
}

- (NSInteger)sliderValue {
    return (int)self.slider.value;
}

- (void)setSliderValue:(NSInteger)sliderValue {
    self.slider.value = sliderValue;
}

@end
