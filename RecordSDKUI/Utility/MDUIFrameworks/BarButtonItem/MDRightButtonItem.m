//
//  MDRightButtonItem.m
//  CocoaLumberjack
//
//  Created by tamer on 02/04/2018.
//

#import "MDRightButtonItem.h"
@interface MDRightButtonItem()

@property (nonatomic, strong) UIColor *activityBgColor;
@property (nonatomic, strong) UIColor *inactivityBgColor;
@property (nonatomic, strong) UIColor *activityTitleColor;
@property (nonatomic, strong) UIColor *inactivityTitleColor;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic) CGRect bounds;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) BOOL activity;

@end
@implementation MDRightButtonItem

+ (instancetype)blueCornerRadiusItemWithTitle:(NSString *)title activity:(BOOL)activity
{
    return [self blueCornerRadiusItemWithBounds:CGRectZero title:title titleColor:nil backgroundColor:nil activity:activity];
}

+ (instancetype)blueCornerRadiusItemWithBounds:(CGRect)bounds title:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)bgColor activity:(BOOL)activity
{
    if (CGRectIsNull(bounds) || CGRectEqualToRect(bounds, CGRectZero)) {
        bounds = CGRectMake(0.f, 0.f, 60.f, 30.f);
    }
    MDRightButtonItem *item = [[MDRightButtonItem alloc] initWithBounds:bounds.size];
    activity?(item.activityBgColor = bgColor):(item.inactivityBgColor = bgColor);
    activity?(item.activityTitleColor = titleColor):(item.inactivityTitleColor = titleColor);
    item.navButton.titleLabel.font = [UIFont systemFontOfSize:item.fontSize];
    item.shapeLayer.frame = bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:bounds.size.height *0.5f];
    item.shapeLayer.fillColor = activity?item.activityBgColor.CGColor:item.inactivityBgColor.CGColor;
    item.shapeLayer.path = [path CGPath];
    item.activity = activity;
    [item.navButton.layer insertSublayer:item.shapeLayer atIndex:0];
    [item setTitleColor:(activity?item.activityTitleColor:item.inactivityTitleColor) forState:UIControlStateNormal];
    title = (title && title.length>0)? title:@"发布";
    [item setTitle:title forState:UIControlStateNormal];
    return item;
}

- (void)updateState:(BOOL)activity
{
    if (_activity == activity) {
        return;
    }
    _activity = activity;
    if (activity) {
        self.shapeLayer.fillColor = self.activityBgColor.CGColor;
        [self setTitleColor:self.activityTitleColor forState:UIControlStateNormal];
    } else {
        self.shapeLayer.fillColor = self.inactivityBgColor.CGColor;
        [self setTitleColor:self.inactivityTitleColor forState:UIControlStateNormal];
    }
}

- (void)updateFontSize:(CGFloat)size
{
    if (_fontSize == size) {
        return;
    }
    _fontSize = size;
    self.navButton.titleLabel.font = [UIFont systemFontOfSize:_fontSize];
}

#pragma mark - Getter
- (UIColor *)activityBgColor
{
    if (!_activityBgColor) {
        _activityBgColor = [UIColor  colorWithRed:34.f/255.f green:164.f/255.f blue:1.f alpha:1.f];
    }
    return _activityBgColor;
}

- (UIColor *)inactivityBgColor
{
    if (!_inactivityBgColor) {
        _inactivityBgColor = [UIColor  colorWithRed:243.f/255.f green:243.f/255.f blue:243.f/255.f alpha:1.f];
    }
    return _inactivityBgColor;
}

- (UIColor *)activityTitleColor
{
    if (!_activityTitleColor) {
        _activityTitleColor = [UIColor whiteColor];
    }
    return _activityTitleColor;
}

- (UIColor *)inactivityTitleColor
{
    if (!_inactivityTitleColor) {
        _inactivityTitleColor = [UIColor  colorWithRed:170.f/255.f green:170.f/255.f blue:170.f/255.f alpha:1.f];
    }
    return _inactivityTitleColor;
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
    }
    return _shapeLayer;
}

- (CGFloat)fontSize
{
    if (_fontSize <= 0) {
        _fontSize = 14.f;
    }
    return _fontSize;
}

@end
