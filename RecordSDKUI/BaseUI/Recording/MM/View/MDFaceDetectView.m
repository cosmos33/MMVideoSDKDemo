//
//  MDFaceDetectView.m
//  MDChat
//
//  Created by xindong on 2017/11/17.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDFaceDetectView.h"
#import "MDRecordHeader.h"

@interface MDFaceDetectView ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UILabel *label;

@end

@implementation MDFaceDetectView

+ (instancetype)new {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame = CGRectMake(103.5, 175.5, 168, 168);
    }
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.label];
//        self.hidden = YES;
        self.alpha = 0.0f;
    }
    return self;
}

#pragma mark - Public

- (void)showWithText:(NSString * _Nullable)text
      hideShapeLayer:(BOOL)isHidden
           animation:(BOOL)animation
{
    if (self.width <= self.lineLength || self.height <= self.lineLength) {
        NSAssert(0, @"The lineLength property is invalid.");
        return;
    }
    
    if (![text isNotEmpty] && isHidden) {
//        self.hidden = YES;
        self.alpha = 0.0f;
    } else {
//        self.hidden = NO;
        self.alpha = 1.0f;
    }
    
    if ([text isEqualToString:self.label.text] && (isHidden == self.shapeLayer.hidden)) {
        return;
    }
    
    if (self.superview) {
        self.centerX = self.superview.width / 2.0;
    }
    
    self.label.hidden = (text ? NO : YES);
    self.text = text;
    
    self.shapeLayer.hidden = isHidden;
    
    if (animation) {
        [self presentAnimationForLayer];
    }
}

- (void)hideRectangleView {
//    self.hidden = YES;
    self.alpha = 0.0f;
}

#pragma mark - Private

- (void)presentAnimationForLayer {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.fromValue = @(0.0);
    anim.toValue = @(1.0);
    anim.duration = 0.8;
    [self.layer addAnimation:anim forKey:@"opacitAnimation"];
}

- (void)createRectangleLayer {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, self.lineLength)];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.lineLength, 0)];
    
    [path moveToPoint:CGPointMake(self.width - self.lineLength, 0)];
    [path addLineToPoint:CGPointMake(self.width, 0)];
    [path addLineToPoint:CGPointMake(self.width, self.lineLength)];
    
    [path moveToPoint:CGPointMake(self.width, self.height - self.lineLength)];
    [path addLineToPoint:CGPointMake(self.width, self.height)];
    [path addLineToPoint:CGPointMake(self.width - self.lineLength, self.height)];
    
    [path moveToPoint:CGPointMake(self.lineLength, self.height)];
    [path addLineToPoint:CGPointMake(0, self.height)];
    [path addLineToPoint:CGPointMake(0, self.height - self.lineLength)];
    
    _shapeLayer.path = path.CGPath;
    [self.layer addSublayer:_shapeLayer];
}

- (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:fontName size:size];
    if (font) {
        return font;
    }
    return [UIFont systemFontOfSize:size];
}

#pragma mark - Property

- (void)setText:(NSString *)text {
    if ([_text isEqualToString:text]) return;
    _text = text;
    self.label.text = text;
}

#pragma mark - Lazy Loading

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.lineWidth = self.lineWidth;
        _shapeLayer.strokeColor = self.lineColor.CGColor;
        _shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self createRectangleLayer];
    }
    return _shapeLayer;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 25)];
        _label.centerX = self.width / 2.0; _label.centerY = self.height / 2.0;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [self fontWithName:@"PingFangSC-Medium" size:18];
        _label.textColor = [UIColor whiteColor];
    }
    return _label;
}

- (UIColor *)lineColor {
    if (!_lineColor) {
        _lineColor = [UIColor whiteColor];
    }
    return _lineColor;
}

- (CGFloat)lineLength {
    if (_lineLength <= 0.0) {
        _lineLength = 14.0;
    }
    return _lineLength;
}

- (CGFloat)lineWidth {
    if (_lineWidth <= 0.0) {
        _lineWidth = 2.0;
    }
    return _lineWidth;
}

@end
