//
//  MDMomentPainterToolView.m
//  MDChat
//
//  Created by wangxuan on 16/7/25.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDMomentPainterToolView.h"
#import <POP/POP.h>
#import "UIImage+MDUtility.h"
#import "UIImage+ClipScaleCircle.h"
#import "UIConst.h"
#import <MMFoundation/MMFoundation.h>
#import "UIView+Utils.h"

#if !__has_feature(objc_arc)
#error MDMomentPainterToolView must be built with ARC.
#endif

static const NSInteger kMDMomentPainterToolViewButtonTag = 10001;
static CGFloat colorButtonWidth = 25;
static CGFloat colorViewLeftRightMargin = 32;

@interface MDMomentPainterToolView ()

@property (nonatomic, strong) UIImageView    *mosaicBrush;
@property (nonatomic, strong) UIImageView    *imgMosaicBrush;
@property (nonatomic, strong) NSMutableArray *brushes;
@property (nonatomic, strong) NSArray        *colors;
@property (nonatomic, strong) UIView         *circleView;

@end


@implementation MDMomentPainterToolView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _brushes = [[NSMutableArray alloc] init];
        _colors =  @[[UIColor whiteColor],
                     RGBCOLOR(245, 40, 36),  //red
                     RGBCOLOR(255, 190, 0),  //yellow
                     RGBCOLOR(136, 52, 255), //purple
                     RGBCOLOR(0, 192, 255),  //blue
                     RGBCOLOR(16, 223, 122)]; //green
        [self configureSubViews];
    }
    
    return self;
}

- (void)configureSubViews
{
    __block CGFloat originX = colorViewLeftRightMargin;
    //colors + mosasic
    CGFloat betweenMargin = (self.width - 2*colorViewLeftRightMargin - colorButtonWidth *(_colors.count +2)) / (_colors.count - 1 +2);
    
    [_colors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIColor *color = obj;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(originX, (self.height -colorButtonWidth) *0.5f, colorButtonWidth, colorButtonWidth)];
        btn.backgroundColor = color;
        btn.clipsToBounds = YES;
        btn.layer.cornerRadius = colorButtonWidth *0.5f;
        btn.tag = kMDMomentPainterToolViewButtonTag +idx;
        
        [btn addTarget:self action:@selector(didSelectedTextColorButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [self.brushes addObjectSafe:btn];
        
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
            
            [self addSubview:circle];
        }
        
        originX += betweenMargin +colorButtonWidth;
    }];

    [self addSubview:self.imgMosaicBrush];
    
    _imgMosaicBrush.left = originX;
    originX += betweenMargin +colorButtonWidth;

    
    [self addSubview:self.mosaicBrushButton];
    _mosaicBrush.tag = kMDMomentPainterToolViewButtonTag +_brushes.count -1;
    _mosaicBrush.left = originX;
}

#pragma mark - UI

- (UIImageView *)mosaicBrushButton
{
    if (!_mosaicBrush) {
        _mosaicBrush = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.height -colorButtonWidth) *0.5f, colorButtonWidth, colorButtonWidth)];
        UIImage *img = [UIImage imageNamed:@"btn_moment_painter_masic"];

        _mosaicBrush.image = img;
        _mosaicBrush.userInteractionEnabled = YES;
        UITapGestureRecognizer *recognizer  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mosaicButtonClicked:)];
        [_mosaicBrush addGestureRecognizer:recognizer];

        [_brushes addObjectSafe:_mosaicBrush];
    }
    
    return _mosaicBrush;
}

- (UIImageView *)imgMosaicBrush
{
    if (!_imgMosaicBrush) {
        _imgMosaicBrush = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.height -colorButtonWidth) *0.5f, colorButtonWidth, colorButtonWidth)];
        
        UIImage *img = [UIImage imageNamed:@"painter_img_mosaic"];
        
        [_imgMosaicBrush setImage:img];
        _imgMosaicBrush.layer.cornerRadius = colorButtonWidth *0.5f;
        _imgMosaicBrush.clipsToBounds = YES;
        _imgMosaicBrush.userInteractionEnabled = YES;
        _imgMosaicBrush.contentMode = UIViewContentModeCenter;
        UITapGestureRecognizer *recognizer  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgmosaicButtonClicked:)];
        [_imgMosaicBrush addGestureRecognizer:recognizer];
        
        [_brushes addObjectSafe:_imgMosaicBrush];
    }
    
    return _imgMosaicBrush;
}


- (UIImage *)renderPainterImageWithSize:(CGSize)size image:(UIImage *)img
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);

    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
 
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [[UIColor clearColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark -control

- (void)didSelectedTextColorButton:(UIButton *)sender
{
    [self startSelectedAnimation:sender borderColor:sender.backgroundColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(brushButtonTapped:)]) {
        NSInteger index = sender.tag - kMDMomentPainterToolViewButtonTag;
        UIColor * color = [_colors objectAtIndex:index defaultValue:nil];
        [self.delegate brushButtonTapped:color];
    }
}

- (void)mosaicButtonClicked:(UIGestureRecognizer *)sender
{
    [self startSelectedAnimation:sender.view borderColor:[UIColor whiteColor]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mosaicButtonTapped)]) {
        [self.delegate mosaicButtonTapped];
    }
}
- (void)imgmosaicButtonClicked:(UIGestureRecognizer *)sender
{
    [self startSelectedAnimation:sender.view borderColor:RGBCOLOR(59, 179, 250)];
    
    UIImage *drawImg = [self renderPainterImageWithSize:CGSizeMake(MDScreenWidth, MDScreenHeight) image:[UIImage imageNamed:@"painter_image_color"]];
    UIColor *cosutmColor = [UIColor colorWithPatternImage:drawImg];

    if (self.delegate && [self.delegate respondsToSelector:@selector(brushButtonTapped:)]) {
        [self.delegate imageMosaicButtonTapped:cosutmColor];
    }
}

//选中画笔的动画
- (void)startSelectedAnimation:(UIView *)view borderColor:(UIColor *)borderColor
{
    [view pop_removeAllAnimations];
    [self.circleView pop_removeAllAnimations];
    CGRect frame = view.frame;
    self.circleView.layer.frame = frame;
    self.circleView.layer.cornerRadius = frame.size.width *0.5f;
    self.circleView.layer.borderColor = borderColor.CGColor;
    
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
- (void)showAnimation
{
    for (int i = 0; i <_brushes.count; i++) {
        UIButton *brushBtn = [_brushes objectAtIndex:i];
        
        [UIView animateWithDuration:0.1f
                              delay:0.1f *i
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                                brushBtn.alpha = 1;
                                brushBtn.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.0);
                            }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.3f
                                              animations:^{
                                                  brushBtn.layer.transform = CATransform3DIdentity;}];
                            }];
    }
 
}

- (void)setMosaicBrushButtonHidden:(BOOL)isHidden {

    self.mosaicBrush.hidden = isHidden;
    
    //隐藏马赛克后, 需要重新布局各种涂鸦按钮
    CGFloat finalToolViewRight = self.imgMosaicBrush.right;
    self.width = finalToolViewRight + colorViewLeftRightMargin;
    self.centerX = MDScreenWidth/2;
    
    self.mosaicBrush.frame = CGRectZero;
}

@end
