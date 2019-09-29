//
//  MDRecordSpeedSlider.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/19.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordSpeedSlider.h"

@interface MDRecordSpeedSlider ()

@property (nonatomic, weak) UILabel *label;

@end

@implementation MDRecordSpeedSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    
}

- (void)configUI {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    label.text = @"0";
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    self.label = label;
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect rect = [super trackRectForBounds:bounds];
    
    CGFloat offsetY = 56.0 - (56.0 + 31.0) / 2.0;
    return (CGRect) {
        .origin = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + offsetY),
        .size = rect.size
    };
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect originRect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    
    CGFloat centerX = CGRectGetMinX(rect) + originRect.size.width / 2.0;
    self.label.frame = (CGRect) {
        .origin = CGPointMake(centerX - 30.0 / 2.0, CGRectGetMinY(originRect) - 25.0),
        .size = CGSizeMake(30, 20)
    };
    self.label.text = [NSString stringWithFormat:@"%.1fx", value];
    return originRect;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(0, 56);
}

@end
