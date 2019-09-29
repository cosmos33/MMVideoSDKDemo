//
//  MDRecordVideoNewSpeedSlider.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/19.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordVideoNewSpeedSlider.h"
#import "MDRecordSpeedSlider.h"

@interface MDRecordVideoNewSpeedSlider ()

@property (nonatomic, weak) UISlider *slider;
@property (nonatomic, weak) UILabel *leftLabel;
@property (nonatomic, weak) UILabel *rightLabel;

@end

@implementation MDRecordVideoNewSpeedSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)setValue:(CGFloat)value {
    self.slider.value = value;
}

- (CGFloat)value {
    return self.slider.value;
}

- (void)configUI {
    UISlider *slider = [[MDRecordSpeedSlider alloc] init];
    slider.translatesAutoresizingMaskIntoConstraints = NO;
    slider.continuous = NO;
    slider.minimumValue = 0.2;
    slider.maximumValue = 4.0;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];
    self.slider = slider;
    
    UILabel *leftLabel = [[UILabel alloc] init];
    leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    leftLabel.font = [UIFont systemFontOfSize:11];
    leftLabel.textColor = UIColor.whiteColor;
    leftLabel.textAlignment = NSTextAlignmentLeft;
    leftLabel.text = @"0.2x";
    [self addSubview:leftLabel];
    self.leftLabel = leftLabel;
    
    UILabel *rightLabel = [[UILabel alloc] init];
    rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    rightLabel.font = [UIFont systemFontOfSize:11];
    rightLabel.textColor = UIColor.whiteColor;
    rightLabel.textAlignment = NSTextAlignmentLeft;
    rightLabel.text = @"4.0x";
    [self addSubview:rightLabel];
    self.rightLabel = rightLabel;
    
    [slider.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [slider.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [slider.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    
    [leftLabel.leftAnchor constraintEqualToAnchor:slider.leftAnchor].active = YES;
    [leftLabel.topAnchor constraintEqualToAnchor:slider.bottomAnchor constant:8].active = YES;
    
    [rightLabel.rightAnchor constraintEqualToAnchor:slider.rightAnchor].active = YES;
    [rightLabel.centerYAnchor constraintEqualToAnchor:leftLabel.centerYAnchor].active = YES;
}

- (void)sliderValueChanged:(UISlider *)slider {
    self.valueChanged ? self.valueChanged(self, slider.value) : nil;
}

@end
