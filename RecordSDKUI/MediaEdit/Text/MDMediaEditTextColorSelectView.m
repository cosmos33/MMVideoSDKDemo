//
//  MDMediaEditTextColorSelectView.m
//  MDChat
//
//  Created by wangxuan on 17/3/4.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMediaEditTextColorSelectView.h"
#import "MDRecordHeader.h"
#import <POP/POP.h>

static CGFloat colorButtonWidth = 25;
static CGFloat colorViewLeftRightMargin = 32;
static NSInteger kButtonStartTag = 100011;

@interface MDMediaEditTextColorSelectView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *colorBottons;
@property (nonatomic, strong) NSArray *buttonColors;
@property (nonatomic, strong) NSArray *textColors;
@property (nonatomic, assign) NSInteger colorIndex;

@end

@implementation MDMediaEditTextColorSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addColorButtons];
    }
    
    return self;
}

- (void)addColorButtons
{
    UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:containerView];
    self.containerView = containerView;
    
    self.colorBottons = [NSMutableArray array];
    NSArray *backgroundColors = self.buttonColors;
    
    __block CGFloat originX = colorViewLeftRightMargin;
    CGFloat betweenMargin = (containerView.width - 2*colorViewLeftRightMargin - colorButtonWidth *backgroundColors.count) / (backgroundColors.count - 1);
    
    [backgroundColors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIColor *color = obj;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(originX, 0, colorButtonWidth, colorButtonWidth)];
        btn.backgroundColor = color;
        btn.clipsToBounds = YES;
        btn.layer.cornerRadius = colorButtonWidth *0.5f;
        btn.tag = kButtonStartTag +idx;
        
        [btn addTarget:self action:@selector(didSelectedTextColorButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:btn];
        [self.colorBottons addObjectSafe:btn];
        
        if (!_circleView) {
            CGFloat scaleWidth = 1.3f *btn.width;
            CGRect rect = CGRectMake(btn.left-scaleWidth *0.5f, btn.top-scaleWidth *0.5f, scaleWidth, scaleWidth);

            UIView *circle = [[UIView alloc] initWithFrame:rect];
            circle.layer.frame = rect;
            circle.layer.cornerRadius = rect.size.width *0.5f;
            circle.layer.borderColor = btn.backgroundColor.CGColor;
            circle.layer.borderWidth = 2.0f;
            circle.center = btn.center;
            self.circleView = circle;
            
            [self.containerView addSubview:circle];
        }
        
        originX += betweenMargin +colorButtonWidth;
    }];
}

- (NSArray *)colorsForButton:(BOOL)forButton
{
    CGSize size = forButton ? CGSizeMake(colorButtonWidth, colorButtonWidth) : CGSizeMake(MDScreenWidth, MDScreenHeight);
    //UI provided
    NSArray *purpleGradient = @[(__bridge id)RGBCOLOR(48, 35, 174).CGColor, (__bridge id)RGBCOLOR(201, 109, 216).CGColor];
    UIColor *purpleGradientColor = [self gradientColorWithColors:purpleGradient size:size];
    
    NSArray *redGradient = @[(__bridge id)RGBCOLOR(251, 218, 97).CGColor, (__bridge id)RGBCOLOR(247, 107, 28).CGColor];
    UIColor *redGradientColor = [self gradientColorWithColors:redGradient size:size];
    
    NSArray *colors = @[[UIColor whiteColor],
                        RGBCOLOR(245, 40, 36),  //red
                        RGBCOLOR(255, 190, 0),  //yellow
                        RGBCOLOR(136, 52, 255), //purple
                        RGBCOLOR(0, 192, 255),  //blue
                        RGBCOLOR(16, 223, 122), //green
                        purpleGradientColor,
                        redGradientColor];
    
    return colors;
}

- (UIColor *)gradientColorWithColors:(NSArray *)colors size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    maskLayer.colors = colors;
    maskLayer.anchorPoint = CGPointZero;
    
    maskLayer.startPoint = CGPointMake(0, 0);
    maskLayer.endPoint = CGPointMake(1, 0);
    
    maskLayer.position = CGPointMake(0, 0.5);
    maskLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    [maskLayer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *layerImage = UIGraphicsGetImageFromCurrentImageContext();
    UIColor *gradientColor = [UIColor colorWithPatternImage:layerImage];
    
    return gradientColor;
}

- (NSArray *)buttonColors
{
    if (!_buttonColors) {
        _buttonColors = [self colorsForButton:YES];
    }
    
    return _buttonColors;
}

- (NSArray *)textColors
{
    if (!_textColors) {
        _textColors = [self colorsForButton:NO];
    }
    
    return _textColors;
}

- (void)didSelectedTextColorButton:(UIButton *)button
{
    [self startSelectedAnimation:button];
    NSInteger index = button.tag -kButtonStartTag;
    [self confirmTextColor:index];
}

- (void)confirmTextColor:(NSInteger)index
{
    self.colorIndex = index;
    UIColor *textColor = [self.textColors objectAtIndex:index defaultValue:nil];
    if (!textColor) {
        textColor = self.textColors.firstObject;
    }
    if (self.colorSelectHandler) {
        self.colorSelectHandler(textColor);
    }
}

- (void)configSelectedColor:(NSInteger)index
{
    _colorIndex = index;
    UIButton *btn = [self.colorBottons objectAtIndex:index defaultValue:nil];
    if (!btn) {
        btn = self.colorBottons.firstObject;
    }
    self.circleView.center = btn.center;
    self.circleView.layer.borderColor = btn.backgroundColor.CGColor;

    [self confirmTextColor:index];
}

- (void)startSelectedAnimation:(UIView *)view
{
    [view pop_removeAllAnimations];
    [self.circleView pop_removeAllAnimations];
    CGRect frame = view.frame;
    self.circleView.layer.frame = frame;
    self.circleView.layer.cornerRadius = frame.size.width *0.5f;
    self.circleView.layer.borderColor = view.backgroundColor.CGColor;
    
    POPBasicAnimation *resetAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    resetAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.7f, 0.7f)];
    resetAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
    resetAnimation.duration = 0.1f;
    
    POPBasicAnimation *shrinkAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    shrinkAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.f)];
    shrinkAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.7f, 0.7f)];
    shrinkAnimation.duration = 0.2f;
    [shrinkAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [view pop_addAnimation:resetAnimation forKey:nil];
        
    }];
    
    [view pop_addAnimation:shrinkAnimation forKey:nil];
    
    CGFloat scaleWidth = 1.3f *frame.size.width;
    CGRect rect = CGRectMake(frame.origin.x-scaleWidth/2, frame.origin.y-scaleWidth/2, scaleWidth, scaleWidth);
    
    POPSpringAnimation *expandAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    expandAnimation.fromValue = [NSValue valueWithCGRect:view.bounds];
    expandAnimation.toValue = [NSValue valueWithCGRect:rect];
    expandAnimation.springBounciness = 15;
    expandAnimation.springSpeed = 10;
    expandAnimation.beginTime = CACurrentMediaTime() + 0.2f;
    
    //圆角扩展动画
    POPSpringAnimation *cornerAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
    cornerAnimation.fromValue = @(frame.size.width/2);
    cornerAnimation.toValue = @(scaleWidth *0.5f);
    cornerAnimation.springBounciness = 15;
    cornerAnimation.springSpeed = 10;
    cornerAnimation.beginTime = CACurrentMediaTime() + 0.2f;
    
    [self.circleView.layer pop_addAnimation:expandAnimation forKey:nil];
    [self.circleView.layer pop_addAnimation:cornerAnimation forKey:nil];
}

//出现画笔的动画
- (void)showPainterAnimation
{
    [self.colorBottons enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
        [UIView animateWithDuration:0.15f
                              delay:0.05f *idx
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             obj.alpha = 1;
                             obj.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.3f
                                              animations:^{
                                                  obj.layer.transform = CATransform3DIdentity;}];
                         }];
        
    }];
}


@end
