//
//  MDViewController.h
//  RecordSDK
//
//  Created by lly on 13-10-7.
//  Copyright (c) 2013年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFBarButtonItem;

typedef NS_ENUM(NSInteger, MDStatusBarStyle) {
    MDStatusBarStyleNone,
    MDStatusBarStyleBlack,
    MDStatusBarStyleLight,
};

/*
 此类主要目的为适配iOS7,建议如无特殊寻求全部使用MDViewController而不是UIViewController
 
 优点：外部使用的时候不需要考虑适配问题，适配的地方已经在此viewController中完成了。
 
 适配内容和使用方法
 1.title｜和以前一样，直接viewController.title = string;
 2.rightBarItem和leftBarItem｜左右item的set方法。
 3.backTitle｜返回按钮的文字，直接调用setBackTitle方法即可。
 */

@interface MDViewController : UIViewController

@property (nonatomic, strong) NSString *refererSource;
//V6.2 以后尝试使用枚举来记录来源
@property (nonatomic, strong) NSDictionary *refererSourceMap;

@property (nonatomic, assign) MDStatusBarStyle statusBarStyle;

@property (nonatomic, assign) BOOL recordOpen;
//页面进出统计开关
@property (nonatomic, assign) BOOL viewActionRecord;
//页面进出统计匹配id
@property (nonatomic, strong) NSString *actionSid;
//页面别名
@property (nonatomic, strong) NSString *viewControllerAlias;

//用于页面加载性能打点
@property (nonatomic, strong) NSDate *anInitTime;
@property (nonatomic, strong) NSDate *didLoadTime;
@property (nonatomic, strong) NSDate *willAppearTime;
@property (nonatomic, strong) NSDate *didAppearTime;
@property (nonatomic, assign) BOOL hasReportAppearTime;

//设置返回按钮的文字,backTitle为nil的时候，backTitle会被hidden
- (void)setBackTitle:(NSString *)backTitle;

- (CGFloat)getFitNavBarMaxY;
/*
 现在使用的navigation bar origin y
 */
- (CGFloat)originYOfNavBar;

- (UIBarButtonItem *)getLeftItem;
- (UIBarButtonItem *)getRightItem;
- (NSString *)getTitleString;

- (void)setLeftBarItem:(MFBarButtonItem *)leftBarItem;

- (void)setRightBarItem:(MFBarButtonItem *)rightBarItem;
- (void)setRightBarItems:(NSArray *)rightBarItems;

- (void)setCustomRightItem:(UIBarButtonItem *)item;
//- (CGRect)subViewFrameMake:(CGPoint)aPoint size:(CGSize)aSize;

/*
 返回现在使用的navigation bar, ios6 是自定义MDNavigationBar， ios7是navigation controller navigation bar
 */
- (UINavigationBar *)currentNavigationBar;

/**
 *iOS 6.0返回的是每个页面自己添加的navigationBar中的topItem；7.0返回的时viewController的navigationItem
 */
- (UINavigationItem *)currentNavigationItem;

/*
 禁止、使能 right bar item
 */
- (void)setRightBarItemEnabled:(BOOL)enabled;

- (void)setRightBarItemHighLight:(BOOL)highlighted;
//选中、未选中状态
- (void)setRightBarItemSelected:(BOOL)selected;

//采用这种方式设置viewController的titleView
- (void)setTitleView:(UIView *)titleView;

//刷新title（消息title这种变化频繁，进入后台被拦截，所以进入前台时需要刷新重置）
- (void)refreshViewControllerTitle;

/*
 @method setNavigatinBarHidden:animation:
 @abstract 隐藏/显示navigation bar
 @param hidden YES:隐藏navigation bar NO:显示navigation bar
 @param animation YES:有动画 NO:无动画
 */
- (void)setNavigatinBarHidden:(BOOL)hidden animation:(BOOL)animation;

/*
 @method viewIsShowing
 @abstract 判断view是否当前显示
 @return YES:显示 NO:不显示
 */
- (BOOL)viewIsShowing;

//在push过程中，使用自定义导航条
- (void)resetShowCustomNavigationBar:(BOOL)showBar;

@end
