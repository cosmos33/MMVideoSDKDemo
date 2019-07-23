//
//  UINavigationBar+AppearenceEx.m
//  RecordSDK
//
//  Created by 杜林 on 15/8/10.
//  Copyright (c) 2015年 RecordSDK. All rights reserved.
//

#import "UINavigationBar+AppearenceEx.h"
#import "UIPublic.h"
#import <objc/runtime.h>

static char bottomLineKey;
static char gradientMaskKey;
static char blurKey;
static char scrollTransitionKey;

#define kTagRootBlurImageView               100
#define kTagBlurImageView                   101

@implementation UINavigationBar (AppearenceEx)

- (void)setBarDefault
{
    //还原状态栏 及 导航条样式
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [self setBarStyle:UIBarStyleBlack];
    
    //去除背景图片及颜色
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self setBarTintColor:nil];
    
    //去除黑色半透明渐变遮罩
    [self showGradientMask:NO];
    
    //去除个人帧 高斯模糊动态主页的 遮罩
    [self setBlurImage:nil originImage:nil];
    
    [self setBottomLineColor:RGBACOLOR(0, 0, 0, 0.04f)];
}


//设置导航条透明
- (void)setBarClear
{
    //透明
    UIImage *image = [[UIImage alloc] init];
    [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    //去除黑色半透明渐变遮罩
    [self showGradientMask:NO];
    
    //去除个人帧 高斯模糊动态主页的 遮罩
    [self setBlurImage:nil originImage:nil];
    
    [self setBottomLineColor:[UIColor clearColor]];
}

//设置导航条颜色
- (void)setBarCustomColor:(UIColor *)color
{
    
    [self setBarTintColor:color];
}

#pragma mark - 底部的线
- (void)setBottomLineColor:(UIColor *)color
{
    if (!self.bottomLineView) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.height -0.5f, MDScreenWidth, 0.5)];
        self.bottomLineView = line;
    }
    
    [self.bottomLineView removeFromSuperview];
    [self addSubview:self.bottomLineView];
    
    self.bottomLineView.backgroundColor = color;
}

#pragma mark - Gradient

//设置导航条 半透明黑色从上到下渐变遮罩 是否显示
- (void)showGradientMask:(BOOL)show
{
    if (show) {
        
        if (!self.gradientMask) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -20, MDScreenWidth, MDStatusBarAndNavigationBarHeight)];
            [self insertSubview:view atIndex:0];
            
            view.userInteractionEnabled = NO;
            view.backgroundColor = RGBACOLOR(29, 29, 29, 0.95f);
            
            CAGradientLayer * maskLayer = [[CAGradientLayer alloc] init];
            view.layer.mask = maskLayer;
            
            maskLayer.frame = view.bounds;
            maskLayer.startPoint = CGPointMake(0, 0);
            maskLayer.endPoint = CGPointMake(0, 1);
            maskLayer.colors = @[(__bridge id)[UIColor whiteColor].CGColor,
                                 (__bridge id)[UIColor clearColor].CGColor];
            
            
            self.gradientMask = view;
        }
        
        [self sendSubviewToBack:self.gradientMask];
        
    }else {
        [self.gradientMask removeFromSuperview];
        self.gradientMask = nil;
    }
}


#pragma mark - Blur

//设置导航条 高斯模糊图片
- (void)setBlurImage:(UIImage *)image originImage:(UIImage *)originImage
{
    if (image) {
        
        if (!self.blurView) {
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDStatusBarAndNavigationBarHeight)];
            [self insertSubview:view atIndex:0];
            
            view.userInteractionEnabled = NO;
            view.clipsToBounds = YES;
            view.backgroundColor = [UIColor clearColor];
            
            self.blurView = view;
            
            
            UIImageView *rootImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenWidth)];
            [view addSubview:rootImageView];
            
            rootImageView.tag = kTagRootBlurImageView;
            rootImageView.userInteractionEnabled = NO;
            
            UIImage *shadowImage = [UIImage imageNamed:@"bg_personal_profile_shadow"];
            CGRect shadowFrame = CGRectMake(0, 0, rootImageView.width, shadowImage.size.height);
            UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:shadowFrame];
            shadowImageView.bottom = CGRectGetMaxY(rootImageView.bounds) + 1;
            shadowImageView.image = shadowImage;
            [rootImageView addSubview:shadowImageView];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenWidth)];
            [view addSubview:imageView];
            
            imageView.tag = kTagBlurImageView;
            imageView.userInteractionEnabled = NO;
        }
        
        self.blurImageView.image = image;
        self.rootBlurImageView.image = originImage;
        
    }else{
        [self.blurView removeFromSuperview];
        self.blurView = nil;
    }
}

//设置导航条 高斯模糊图片 的位置及透明度
- (void)setBlurOffsetY:(CGFloat)dy alpha:(CGFloat)alpha show:(BOOL)show
{
    if (!self.blurImageView) {
        return;
    }
    float delta = MDStatusBarAndNavigationBarHeight;
    self.blurImageView.top = -MDStatusBarAndNavigationBarHeight + (-delta - dy);
    
    self.blurImageView.alpha = alpha;
    
    self.rootBlurImageView.top = self.blurImageView.top;
    alpha = show ? 1.f : 0.f;
    self.rootBlurImageView.alpha = alpha;

    
    [self sendSubviewToBack:self.blurView];
}

#pragma mark - scroll transition

- (void)showScrollTransition:(BOOL)show
{
    if (!self.scrollTransitionView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDStatusBarAndNavigationBarHeight)];
        [self insertSubview:view atIndex:0];
        
        view.userInteractionEnabled = NO;
        view.clipsToBounds = YES;
        view.backgroundColor = [UIColor whiteColor];
        
        //add bottom line
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, view.height -0.5f, view.width, 0.5f)];
        line.backgroundColor = RGBACOLOR(0, 0, 0, 0.04f);
        [view addSubview:line];
        
        self.scrollTransitionView = view;
    }
    
    self.scrollTransitionView.alpha = show;
    
}

- (void)showScrollTransition:(BOOL)show withCustomTransitionView:(UIView *)view
{
    view.frame = CGRectMake(0, 0, MDScreenWidth, MDStatusBarAndNavigationBarHeight);
    
    [self insertSubview:view atIndex:0];
    self.scrollTransitionView = view;
    
    [self showScrollTransition:show];
}

- (void)setScrollTransitionAlpha:(CGFloat)alpha
{
    if (!self.scrollTransitionView) {
        return;
    }
    
    self.scrollTransitionView.alpha = alpha;
    [self sendSubviewToBack:self.scrollTransitionView];
}

- (void)setScrollTransitionColor:(UIColor *)color
{
    if (!self.scrollTransitionView) {
        return;
    }
    
    self.scrollTransitionView.backgroundColor = color;
}

#pragma mark - getters & setters
- (UIView *)bottomLineView
{
    return objc_getAssociatedObject(self, &bottomLineKey);
}

- (void)setBottomLineView:(UIView *)view
{
    objc_setAssociatedObject(self, &bottomLineKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)gradientMask
{
    return objc_getAssociatedObject(self, &gradientMaskKey);
}

- (void)setGradientMask:(UIView *)view
{
    objc_setAssociatedObject(self, &gradientMaskKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)blurView
{
    return objc_getAssociatedObject(self, &blurKey);
}

- (void)setBlurView:(UIView *)view
{
    objc_setAssociatedObject(self, &blurKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageView *)blurImageView
{
    UIImageView * imageView = (UIImageView *)[self.blurView viewWithTag:kTagBlurImageView];
    return imageView;
}

- (UIImageView *)rootBlurImageView
{
    UIImageView * imageView = (UIImageView *)[self.blurView viewWithTag:kTagRootBlurImageView];
    return imageView;
}

- (UIView *)scrollTransitionView
{
    return objc_getAssociatedObject(self, &scrollTransitionKey);
}

- (void)setScrollTransitionView:(UIView *)view
{
    objc_setAssociatedObject(self, &scrollTransitionKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
