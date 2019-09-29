//
//  MDNavigationController.m
//  RecordSDK
//
//  Created by lly on 13-10-7.
//  Copyright (c) 2013年 RecordSDK. All rights reserved.
//

#import "MDNavigationController.h"
#import "UIImage+Utility.h"
#import "UIImage+MDUtility.h"
#import "UINavigationBar+AppearenceEx.h"
#import "MDNavigationTransitionExtra.h"
#import "UIUtility.h"
#import "UIPublic.h"

@interface MDNavigationController ()
{
    BOOL isJustBecomeAcive;
}

@end

@implementation MDNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //移除导航条最下面的阴影线条
    //先设置shadowimage，再遍历子视图，才能成功删除阴影线，否则，删不掉阴影线条
    [self.navigationBar setShadowImage:[UIImage imageWithColor:RGBACOLOR(29, 29, 29, 0.0) finalSize:CGSizeMake(MDScreenWidth, 1)]];
    [self removeImageViewForShadow:self.navigationBar];
    
    //设置自定义的线颜色
    [self.navigationBar setBottomLineColor:RGBACOLOR(0, 0, 0, 0.04f)];
    //设置导航栏自定义颜色
    [self.navigationBar setBarCustomColor:RGBACOLOR(255, 255, 255, 0.95)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetNavigationBar) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self addObserver:self forKeyPath:@"navigationBar.alpha" options:NSKeyValueObservingOptionNew context:NULL];
    //用xocde8之后打的包，navigationController的delegate即使被重置了，再次设置interactivePopGestureRecognizer的enabled，也会导致让系统侧滑手势生效，
    //所以在底层屏蔽
    [self addObserver:self forKeyPath:@"interactivePopGestureRecognizer.enabled" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController) {
        self.navigationController.navigationBar.alpha = 0;
    }
}

- (BOOL)shouldAutorotate{
    return self.topViewController.shouldAutorotate;
}

//返回最上层的子Controller的supportedInterfaceOrientations
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return self.topViewController.supportedInterfaceOrientations;
}

- (void)removeImageViewForShadow:(UIView *)view
{
    for (UIView * subView in view.subviews) {
        
        if ([subView isMemberOfClass:[UIImageView class]] && subView.height <= 1.f) {
            subView.alpha = 0;
            return;
        }
        
        [self removeImageViewForShadow:subView];
    }
}

#pragma mark -
- (void)resetNavigationBar
{
    if ([UIUtility isLessThanVersion:8.0]) {
        //针对IOS7的特殊逻辑，当从后台推入前台，隐藏的导航条alpha会被自动重置
        //此时alpha还是0，所以需要配合监听一起做处理
        isJustBecomeAcive = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isJustBecomeAcive = NO;
        });
        
    }else{
        //非访客模式从后台直接切回来的时候需要处理一下导航栏
        UIViewController *vc = [MDNavigationTransitionUtility realController:self.topViewController];
        if (vc && [MDNavigationTransitionUtility isBarCustomed:vc] && self.navigationBar.alpha != 0) {
            self.navigationBar.alpha = 0;
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"navigationBar.alpha"]) {
        if ([UIUtility isLessThanVersion:8.0]) {
            //针对IOS7的特殊逻辑，当从后台推入前台，隐藏的导航条alpha会被自动重置
            NSInteger newAlpha = [[change objectForKey:@"new"] integerValue];
            
            if (isJustBecomeAcive && newAlpha == 1) {
                UIViewController *vc = [MDNavigationTransitionUtility navShowRealController:self.topViewController];
                if (vc && [MDNavigationTransitionUtility isBarNavShowCustomed:vc]){
                    self.navigationBar.alpha = 0;
                    isJustBecomeAcive = NO;
                }
            }
        }
        
        NSInteger newAlpha = [[change objectForKey:@"new"] integerValue];
        if (newAlpha == 1) {
            UIViewController *vc = [MDNavigationTransitionUtility navShowRealController:self.topViewController];
            if (vc && [MDNavigationTransitionUtility isBarNavShowCustomed:vc]) {
                self.navigationBar.alpha = 0;
            }
        }
    }if ([keyPath isEqualToString:@"interactivePopGestureRecognizer.enabled"]) {
        NSInteger newAlpha = [[change objectForKey:@"new"] integerValue];
        if (newAlpha == 1) {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"navigationBar.alpha"];
    [self removeObserver:self forKeyPath:@"interactivePopGestureRecognizer.enabled"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
