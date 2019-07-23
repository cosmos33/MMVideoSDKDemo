 //
//  MDViewController.m
//  RecordSDK
//
//  Created by lly on 13-10-7.
//  Copyright (c) 2013年 RecordSDK. All rights reserved.
//

#import "MDViewController.h"
#import "UIPublic.h"
#import "MFBarButtonItem.h"
#import "MDUIBaseConfiguration.h"
#import "UINavigationBar+Adapter_11.h"
#import "UINavigationBar+AppearenceEx.h"

@interface MDViewController ()

@property (nonatomic, strong) UIBarButtonItem *leftItem;
@property (nonatomic, strong) UIBarButtonItem *rightItem;
@property (nonatomic, strong) NSArray *rightItems;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, assign) BOOL showCustomNavigationBar;
@property (nonatomic, strong) UINavigationBar *customNavigationBar;
@property (nonatomic, strong) UINavigationItem *customNavigationItem;

@end

@implementation MDViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _viewActionRecord = NO;
        _anInitTime = [NSDate date];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([MDUIBaseConfiguration uibaseConfiguration].deallocHandler) {
        [MDUIBaseConfiguration uibaseConfiguration].deallocHandler(self);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.didLoadTime = [NSDate date];
    self.view.backgroundColor = RGBCOLOR(245, 245, 245);
    
    [self resetShowCustomNavigationBar:NO];
}

#pragma mark - title & back title set selector
- (void)setTitle:(NSString *)title
{
    self.titleString = title;
    
    //尝试修复bug
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        return;
    }
    
    if (self.customNavigationItem) {
        [self.customNavigationItem setTitle:title];
    } else {
        [super setTitle:title];
    }
}

- (void)refreshViewControllerTitle
{
    [self setTitle:self.titleString];
}

- (void)setTitleView:(UIView *)titleView
{
    self.currentNavigationItem.titleView = titleView;
}

- (void)backTo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)refererSource
{
    if (_refererSource.length > 0) {
        return _refererSource;
    } else {
        return self.title;
    }
}

- (NSString *)viewControllerAlias
{
    if (_viewControllerAlias.length == 0) {
        _viewControllerAlias = NSStringFromClass([self class]);
    }
    return _viewControllerAlias;
}

- (CGFloat)getFitNavBarMaxY
{
    if (self.customNavigationBar) {
        return CGRectGetMaxY(self.customNavigationBar.frame);
    }
    return CGRectGetMaxY(self.navigationController.navigationBar.frame);
}

- (UINavigationBar *)currentNavigationBar
{
    if (self.customNavigationBar) {
        return self.customNavigationBar;
    }
    return self.navigationController.navigationBar;
}

- (CGFloat)originYOfNavBar
{
    return CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
}

- (UINavigationItem *)currentNavigationItem
{
    if (self.customNavigationItem) {
        return self.customNavigationItem;
    }
    return self.navigationItem;
}

- (UIBarButtonItem *)getLeftItem
{
    return self.leftItem;
}

- (UIBarButtonItem *)getRightItem
{
    return self.rightItem;
}

- (NSString *)getTitleString
{
    return self.titleString;
}

#pragma mark - barItem set selector
- (void)setBackTitle:(NSString *)backTitle
{
    if (backTitle.length <= 0) {
        self.currentNavigationItem.backBarButtonItem.title = backTitle;
    }
}

- (void)setLeftBarItem:(MFBarButtonItem *)leftBarItem
{
    leftBarItem.navButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    if (leftBarItem == nil) {
        self.currentNavigationItem.leftBarButtonItems = nil;
    } else {
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) { // @NOTE: iOS 11 之后不需要调整位置，之前的调整方式会使得返回按钮出现问题
            self.currentNavigationItem.leftBarButtonItems = @[leftBarItem];
        } else
#endif
        {
            self.currentNavigationItem.leftBarButtonItems = @[[MFBarButtonItem leftSpace], leftBarItem];
        }
    }
    self.leftItem = leftBarItem;
}

- (void)setRightBarItem:(MFBarButtonItem *)rightBarItem
{
    if (rightBarItem == nil) {
        self.currentNavigationItem.rightBarButtonItems = nil;
    } else {
        self.currentNavigationItem.rightBarButtonItems = @[[MFBarButtonItem rightSpace], rightBarItem];
    }
    self.rightItem = rightBarItem;
    self.rightItems = nil;
}

- (void)setRightBarItems:(NSArray *)rightBarItems
{
    if (rightBarItems && [rightBarItems isKindOfClass:[NSArray class]] && rightBarItems.count) {
        NSMutableArray *items = [NSMutableArray arrayWithObject:[MFBarButtonItem rightSpace]];
        [items addObjectsFromArray:rightBarItems];
        self.currentNavigationItem.rightBarButtonItems = items;
    } else {
        self.currentNavigationItem.rightBarButtonItems = nil;
    }
    self.rightItem = nil;
    self.rightItems = rightBarItems;
}

- (void)setCustomRightItem:(UIBarButtonItem *)item
{
    if (item == nil) {
        self.currentNavigationItem.rightBarButtonItems = nil;
    } else {
        self.currentNavigationItem.rightBarButtonItems = @[[MFBarButtonItem rightSpace], item];
    }
    self.rightItem = item;
}

- (void)setRightBarItemEnabled:(BOOL)enabled
{
    ((MFBarButtonItem *)self.currentNavigationItem.rightBarButtonItem).navButton.enabled = enabled;
    
    [self setRightBarItemHighLight:enabled];
}

- (void)setRightBarItemHighLight:(BOOL)highlighted
{
    [((MFBarButtonItem *)self.currentNavigationItem.rightBarButtonItem) setTitleHighLight:highlighted];
}

- (void)setRightBarItemSelected:(BOOL)selected
{
    [((MFBarButtonItem *)self.currentNavigationItem.rightBarButtonItem).navButton setSelected:selected];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.willAppearTime) {
        self.willAppearTime = [NSDate date];
    }
    
    [self.view bringSubviewToFront:[self currentNavigationBar]];
    //目前已知的是 imagePicker页面会重置statsBar样式
    if (_statusBarStyle == MDStatusBarStyleLight) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else if (_statusBarStyle == MDStatusBarStyleBlack) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else if (_statusBarStyle == MDStatusBarStyleNone) {
        //when statusBarStyle is default, do nothing
    }
    if ([MDUIBaseConfiguration uibaseConfiguration].viewWillAppearHandler) {
        [MDUIBaseConfiguration uibaseConfiguration].viewWillAppearHandler(self);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.didAppearTime) {
        self.didAppearTime = [NSDate date];
    }
    
#ifdef DEBUG
    NSLog(@"加载时间=========%f %@", [self.didAppearTime timeIntervalSinceDate:self.didLoadTime], self.viewControllerAlias);
#endif
    
    if ([MDUIBaseConfiguration uibaseConfiguration].viewDidAppearHandler) {
        [MDUIBaseConfiguration uibaseConfiguration].viewDidAppearHandler(self);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([MDUIBaseConfiguration uibaseConfiguration].viewWillDisappearHandler) {
        [MDUIBaseConfiguration uibaseConfiguration].viewWillDisappearHandler(self);
    }
}

#pragma mark - color navigation bar when pushing
- (void)resetShowCustomNavigationBar:(BOOL)showBar
{
    //防止重复迁移item数据，首次迁移完，会置空前一个navigationbar的topitem上所有item数据
    if (self.showCustomNavigationBar == showBar) {
        return;
    }
    
    self.showCustomNavigationBar = showBar;
    
    if (showBar) {
        if (!self.customNavigationBar) {
            UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDStatusBarAndNavigationBarHeight)];
            UIImage *image = [[UIImage alloc] init];
            [bar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
            [bar setShadowImage:image];
            [self.view addSubview:bar];
            self.customNavigationBar = bar;
            
            UIView *transView = [[UIView alloc] initWithFrame:bar.bounds];
            
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *bView = [[UIVisualEffectView alloc] initWithEffect:effect];
            bView.frame = transView.bounds;
            [transView addSubview:bView];
            
            UIView *view = [[UIView alloc] initWithFrame:transView.bounds];
            view.backgroundColor = RGBACOLOR(255, 255, 255, 0.9);
            [transView addSubview:view];
            
            bar.md_backgroundView = transView;
            
#ifdef __IPHONE_11_0
            if (@available(iOS 11.0, *)) {
                bar.resetSubviewsFrame4IOS11 = YES;
            } else
#endif
            {
                bar.resetSubviewsFrame4IOS11 = NO;
            }
            
            [bar showScrollTransition:NO withCustomTransitionView:transView];
            
            UINavigationItem *baritem = [[UINavigationItem alloc] initWithTitle:@""];
            [self.customNavigationBar pushNavigationItem:baritem animated:NO];
            self.customNavigationItem = baritem;
        }
        
        [self transItemFrom:self.navigationItem to:self.customNavigationItem];
    } else {
        UINavigationItem *fromItem = self.customNavigationItem;
        [self.customNavigationBar removeFromSuperview];
        self.customNavigationBar = nil;
        self.customNavigationItem = nil;
        
        [self transItemFrom:fromItem to:self.navigationItem];
    }
}

//系统navigationbar上的item数据 与 自定义的navigationbar上的数据 相互迁移
- (void)transItemFrom:(UINavigationItem *)fromItem to:(UINavigationItem *)toItem
{
    NSString *title = fromItem.title;
    fromItem.title = nil;
    [self setTitle:title];
    
    UIView *titleView = fromItem.titleView;
    fromItem.titleView = nil;
    [self setTitleView:titleView];
    
    NSString *backTitle = fromItem.backBarButtonItem.title;
    fromItem.backBarButtonItem.title = nil;
    [self setBackTitle:backTitle];
    
    fromItem.leftBarButtonItem = nil;
    fromItem.leftBarButtonItems = nil;
    [self setLeftBarItem:(MFBarButtonItem *)self.leftItem];
    fromItem.rightBarButtonItem = nil;
    fromItem.rightBarButtonItems = nil;
    if (self.rightItem) {
        [self setRightBarItem:(MFBarButtonItem *)self.rightItem];
        [self setCustomRightItem:(MFBarButtonItem *)self.rightItem];
    } else if (self.rightItems) {
        [self setRightBarItems:self.rightItems];
    }
    
    //直接迁移同一个left或者rightitem对象，不用管enable和select
//    BOOL enabled = ((MFBarButtonItem *)fromItem.rightBarButtonItem).navButton.enabled;
//    [self setRightBarItemEnabled:enabled];
//
//    BOOL isSelected = ((MFBarButtonItem *)fromItem.rightBarButtonItem).navButton.isSelected;
//    [self setRightBarItemSelected:isSelected];
}

- (void)setNavigatinBarHidden:(BOOL)hidden animation:(BOOL)animation
{
    [self.navigationController setNavigationBarHidden:hidden animated:animation];
}

- (BOOL)viewIsShowing
{
    return self.isViewLoaded && self.view.window;
}

@end
