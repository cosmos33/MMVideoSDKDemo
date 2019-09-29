//
//  MDNavigationHelper.m
//  RecordSDK
//
//  Created by 杜林 on 16/9/8.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MDNavigationHelper.h"
#import "MDViewControllerAnimatedTransitioning.h"
#import "UINavigationController_PrivateHelper.h"
#import "MDNavigationTransitionUtility.h"
#import "MDNavigationTransitionDelegate.h"
#import "UIViewController+MDTransitionType.h"
#import "UIPanGestureRecognizer+GestureTag.h"
#import <objc/message.h>
#import <CommonCrypto/CommonDigest.h>
#import "UIConst.h"


static const NSInteger responseWidth  = 50;
#define responseHeight MDStatusBarAndNavigationBarHeight

@interface MDNavigationHelper ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate, NSCacheDelegate>

@property (nonatomic, weak  ) UINavigationController                *navigationController;
@property (nonatomic, weak  ) UIPanGestureRecognizer                *popGestureRecognizer;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition  *interactivePopTransition;
@property (nonatomic, strong) NSMutableDictionary                   *snapShotCache;
@property (nonatomic, assign) BOOL                                  canResponse;

@property (nonatomic, strong) NSMutableDictionary                   *pushCache;
@property (nonatomic, strong) NSCache                               *popCache;

@property (nonatomic, assign) MDPopGestureOrientation               popGestureOrientation;
@property (nonatomic, assign) NSInteger                             currentOrientation;

@property (nonatomic, assign) BOOL                                  isSecondoryCacheEnable;
@end


@implementation MDNavigationHelper

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
}

- (NSString *)MD5HexDigest:(NSData *)input
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input.bytes, (unsigned int)input.length, result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self) {
        self.navigationController = (UINavigationController *)vc;
        self.navigationController.delegate = self;
        self.canResponse = NO;
        self.snapShotCache = [[NSMutableDictionary alloc] init];
        
        
        self.pushCache = [[NSMutableDictionary alloc] init];
        
        self.popCache = [[NSCache alloc] init];
        self.popCache.countLimit = 10;
#if defined(DEBUG)
        self.popCache.delegate = self;
#endif
        [self addPanGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecome:) name:UIWindowDidBecomeKeyNotification object:nil];
        //由于添加了帐号切换逻辑,所以在切换用户时需要清理原有缓存图片
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(clearNavigationBarImageCacheAfterLogin) name:@"NTF_LOGIN_REMOVE_HUD" object:nil];
    }
    return self;
}

- (void)setSnapshotSecondoryCacheEnable:(BOOL)en;
{
    self.isSecondoryCacheEnable = en;
}

- (void)addPanGesture
{

    UIView *gestureView = self.navigationController.view;
    UIGestureRecognizer *gesture = self.navigationController.interactivePopGestureRecognizer;
    gesture.enabled = NO;
    UIPanGestureRecognizer *popRecognizer = [[UIPanGestureRecognizer alloc] init];
    popRecognizer.delegate = self;
    popRecognizer.maximumNumberOfTouches = 1;
    [popRecognizer setGestureTag:1602];
    [gestureView addGestureRecognizer:popRecognizer];
    
    [popRecognizer addTarget:self action:@selector(handleControllerPop:)];
    
    self.popGestureRecognizer = popRecognizer;
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //    不允许手势执行，
    //    1、当前控制器为根控制器；
    //    2、如果这个push、pop动画正在执行（私有属性）
    //    3、不在侧滑响应范围，或者左滑，就向下传递
    //    4、手势被业务层控制关闭了
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        if (![self enabledPopGestureRecognizer]) {
            return NO;
        }
        
        UIPanGestureRecognizer * recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        
        CGFloat dx = [recognizer locationInView:recognizer.view].x;
        CGFloat dy = [recognizer locationInView:recognizer.view].y;
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        
        _currentOrientation = MDPopGestureOrientationDefault - 1;
        // 点击在侧滑区域，且右滑，事件不向下传递
        // 用户手欠，老喜欢向右侧滑点击返回按钮，导致下面会触发逻辑，所以和系统原生一样，屏蔽开始就是右滑的情况
        if (dx < responseWidth && velocity.x > 0) {
            _currentOrientation = MDPopGestureOrientationDefault;
        }
        // 点击在下滑区域，且下滑，事件不向下传递，屏蔽开始就是上滑的情况
        else if (dy > responseHeight && velocity.y > 0 && fabs(velocity.x) < velocity.y) {
            _currentOrientation = MDPopGestureOrientationTopToBottom;
        }
        
        _popGestureOrientation = [self popGestureOrientation];
        // 手势类型是否被支持
        if (!(_popGestureOrientation & _currentOrientation)) {
            return NO;
        }
        
        /*
        if (_popGestureOrientation == MDPopGestureOrientationDefault) {
            
            CGFloat dx = [recognizer locationInView:recognizer.view].x;
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            
            if (dx > responseWidth || velocity.x <= 0) {
                //点击不在侧滑区域，或者左滑，事件向下传递
                //用户手欠，老喜欢向右侧滑点击返回按钮，导致下面会触发逻辑，所以和系统原生一样，屏蔽开始就是右滑的情况
                return NO;
            }
        }
        else if (_popGestureOrientation == MDPopGestureOrientationTopToBottom) {
            
            CGFloat dy = [recognizer locationInView:recognizer.view].y;
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            
            if (dy < responseHeight || velocity.y <= 0) {
                //点击不在下滑区域，或者上滑，事件向下传递
                //用户手欠，老喜欢向右侧滑点击返回按钮，导致下面会触发逻辑，所以和系统原生一样，屏蔽开始就是右滑的情况
                return NO;
            }
        } else {
            return NO;
        }*/
        
        
        return self.navigationController.viewControllers.count != 1 && ![[self.navigationController valueForKey:@"_isTransitioning"] boolValue];
    }
    
    return YES;
}

- (void)handleControllerPop:(UIPanGestureRecognizer *)recognizer {
    
    MDPopGestureOrientation pgo = _currentOrientation;
    //触摸点位置
    CGFloat dx = [recognizer locationInView:recognizer.view].x;
    CGFloat dy = [recognizer locationInView:recognizer.view].y;
    
    //横向位移量
    CGFloat dtx = [recognizer translationInView:recognizer.view].x;
    CGFloat dty = [recognizer translationInView:recognizer.view].y;
    
    CGFloat progress = 0;
    if (pgo == MDPopGestureOrientationDefault) {
        progress = dtx / recognizer.view.bounds.size.width;
    } else {
        progress = dty / recognizer.view.bounds.size.height;
    }
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        //设置手势响应区域
        self.canResponse = YES;
        if ((pgo == MDPopGestureOrientationDefault && dx > responseWidth) ||
            (pgo == MDPopGestureOrientationTopToBottom && dy < responseHeight))
        {
            self.canResponse = NO;
            return;
        }
        
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        if (!self.canResponse) {
            return;
        }
        
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        
        if (!self.canResponse) {
            return;
        }
        
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        
        if ((pgo == MDPopGestureOrientationDefault && velocity.x >= 700 && dtx >= responseWidth) ||
            (pgo == MDPopGestureOrientationTopToBottom && velocity.y >=700 && dty >= responseHeight)) {
            //快速侧滑，并且侧滑距离超过50，直接pop页面
            //防止有时虽然是快速侧滑，但是距离很短的误操作
            [self.interactivePopTransition finishInteractiveTransition];
        }else{
            //缓慢侧滑，根据位置选择是否pop页面
            if (progress > 0.5) {
                [self.interactivePopTransition finishInteractiveTransition];
            }
            else {
                [self.interactivePopTransition cancelInteractiveTransition];
            }
        }
        
        self.interactivePopTransition = nil;
        
        self.canResponse = NO;
        
        self.popGestureOrientation = 0;
        self.currentOrientation    = 0;
    }
}

#pragma mark - UINavigationControllerDelegate

//在viewWillAppear之前执行,第一个执行的回调
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    //return nil时，执行系统默认动画
    
    //无论是push还是pop，都把当前的vc的导航条闪烁动画去除,防止其他无导航条闪烁动画的界面导航条显示不正常
    UINavigationBar *navigationBar = fromVC.navigationController.navigationBar;
    if (operation == UINavigationControllerOperationPush || operation == UINavigationControllerOperationPop) {
        [navigationBar.layer removeAnimationForKey:@"title-twinkle"];
    }
    
    MDNavigationTransitionType type = (operation == UINavigationControllerOperationPush) ? toVC.transitionType : fromVC.transitionType;
    
    [self resetNavigationBarAlphaOperation:operation fromViewController:fromVC toViewController:toVC];
    //缓存截图
    [self snapShot:navigationController operation:operation fromViewController:fromVC toViewController:toVC];
    
    //Pop兼容两个手势动画
    if (_currentOrientation && operation == UINavigationControllerOperationPop) {
        type = [self popTransitionType:fromVC];
    }
    
    MDViewControllerAnimatedTransitioning *transitioning = [MDViewControllerAnimatedTransitioning transitioningWithType:type operation:operation];
    return transitioning;
}

- (void)resetNavigationBarAlphaOperation:(UINavigationControllerOperation)operation
                      fromViewController:(UIViewController *)fromVC
                        toViewController:(UIViewController *)toVC
{
    //如果从一个隐藏导航条的界面，推入一个不隐藏导航条的界面
    //如果不将导航条显示出来，会导致推入的界面的tableview的contentInset变为0，不会自动设置64
    //所以如果推入的界面是一个不隐藏导航条的界面，则将导航条的alpha先设置0.1f，保证该页面加载时，依赖automaticallyAdjustsScrollViewInsets默认YES的属性，可以正常将offset设置在导航条下方
    BOOL fromCustomed = [MDNavigationTransitionUtility isBarCustomed:fromVC];
    BOOL toCustomed = [MDNavigationTransitionUtility isBarCustomed:toVC];
    
    if (operation == UINavigationControllerOperationPush) {
        UINavigationBar *navigationBar = fromVC.navigationController.navigationBar;
        navigationBar.alpha = toCustomed ? 0 : 0.1f;
    } else if (operation == UINavigationControllerOperationPop) {
        UINavigationBar *navigationBar = toVC.navigationController.navigationBar;
        if (fromCustomed && !toCustomed) {
            navigationBar.alpha = 0.1f;
        }
    }
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:[MDViewControllerAnimatedTransitioning class]]){
        return self.interactivePopTransition;
    }
    
    return nil;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //执行顺序： viewWillAppear -> 该回调-> push/pop动画
    
    [navigationController setTransitioning:YES];
    BOOL isCustomed = [MDNavigationTransitionUtility isBarCustomed:viewController];
    [navigationController setNavigationBarHidden:NO animated:NO];
    navigationController.navigationBar.hidden = NO;
    navigationController.navigationBar.alpha = isCustomed ? 0 : 1;
    
    //    // 应用重新安装第一次启动，推出一个模态时会导致时didshow方法不会被调到
    //    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    //        if (navigationController.interactivePopGestureRecognizer.state == UIGestureRecognizerStatePossible){
    //            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    //
    //            double delayInSeconds = 1.0;
    //            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    //            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //
    //                if ([UIApplication sharedApplication].isIgnoringInteractionEvents) {
    //                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    //                }
    //
    //            });
    //        }
    //    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //执行顺序： push/pop动画 -> viewDidAppear -> 该回调
    //push和pop成功都会调用
    //侧滑pop失败不会调用该回调
    
    BOOL isCustomed = [MDNavigationTransitionUtility isBarCustomed:viewController];
    navigationController.navigationBar.alpha = isCustomed ? 0 : 1;
    
    //当进行qq语音时，statusBar高度变为40，整体下沉，导致主帧tabbar显示有问题，重设view的frame解决该显示问题
    CGRect frame = viewController.view.frame;
    
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    if (statusBarFrame.size.height == 20 || statusBarFrame.size.height == 0 || statusBarFrame.size.height == 44) {
        if (!CGRectEqualToRect(frame, screenBounds)) {
            viewController.view.frame = screenBounds;
        }
    }else{
        screenBounds.size.height -= statusBarFrame.size.height -20;
        viewController.view.frame = screenBounds;
    }
    
    
    if ([UIApplication sharedApplication].isIgnoringInteractionEvents) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    
    [self enabledPop:viewController];
    
    [navigationController setTransitioning:NO];
}

- (void)enabledPop:(UIViewController *)viewController
{
    BOOL conform = [viewController conformsToProtocol:@protocol(MDPopGestureRecognizerDelegate)];
    id<MDPopGestureRecognizerDelegate> vc = (id)viewController;
    
    // 指定手势方向就忽略手势禁用（TODO:BOZ 处理方式不太合理）
    conform = conform && ![vc respondsToSelector:@selector(md_popGestureOrientation)];
    
    if (conform && [vc respondsToSelector:@selector(md_popGestureRecognizerEnabled)]) {
        BOOL enabled = [vc md_popGestureRecognizerEnabled];
        self.popGestureRecognizer.enabled = enabled;
    }else{
        if (self.popGestureRecognizer.enabled != YES) {
            self.popGestureRecognizer.enabled = YES;
        }
    }
}

- (BOOL)enabledPopGestureRecognizer
{
    BOOL enabled = YES;
    id<MDPopGestureRecognizerDelegate> vc = (id)self.navigationController.topViewController;
    
    BOOL conform = [vc conformsToProtocol:@protocol(MDPopGestureRecognizerDelegate)];
    if (conform && [vc respondsToSelector:@selector(md_popGestureRecognizerEnabled)]) {
        enabled = [vc md_popGestureRecognizerEnabled];
    }
    
    return enabled;
}

- (BOOL)conformPopGestureOrientation
{
    id<MDPopGestureRecognizerDelegate> vc = (id)self.navigationController.topViewController;
    
    BOOL conform = [vc conformsToProtocol:@protocol(MDPopGestureRecognizerDelegate)];
    if (conform && [vc respondsToSelector:@selector(md_popGestureOrientation)]) {
        return YES;
    }
    return NO;
}

- (MDPopGestureOrientation)popGestureOrientation
{
    MDPopGestureOrientation orientation = MDPopGestureOrientationDefault;
    id<MDPopGestureRecognizerDelegate> vc = (id)self.navigationController.topViewController;
    
    BOOL conform = [vc conformsToProtocol:@protocol(MDPopGestureRecognizerDelegate)];
    if (conform && [vc respondsToSelector:@selector(md_popGestureOrientation)]) {
        orientation = [vc md_popGestureOrientation];
    }
    
    return orientation;
}

- (MDNavigationTransitionType)popTransitionType:(UIViewController *)fromVC
{
    MDNavigationTransitionType type = MDNavigationTransitionTypeDefault;
    id<MDPopGestureRecognizerDelegate> vc = (id)fromVC;
    
    BOOL conform = [vc conformsToProtocol:@protocol(MDPopGestureRecognizerDelegate)];
    if (conform && [vc respondsToSelector:@selector(md_popNavigationTransitionType)]) {
        type = [[[vc md_popNavigationTransitionType] objectForKey:@(_currentOrientation)] integerValue];
    }
    
    return type;
}

#pragma mark - 截图处理

- (BOOL)snapShotSwitch
{
    return NO;
}

- (void)snapShot:(UINavigationController *)navigationController
       operation:(UINavigationControllerOperation)operation
fromViewController:(UIViewController *)fromVC
toViewController:(UIViewController *)toVC
{
    UIViewController *fromRealVC = [MDNavigationTransitionUtility realController:fromVC];
    UIViewController *toRealVC = [MDNavigationTransitionUtility realController:toVC];
    
    BOOL fromCustomed = [MDNavigationTransitionUtility isBarCustomed:fromRealVC];
    BOOL toCustomed = [MDNavigationTransitionUtility isBarCustomed:toRealVC];
    
    if (!fromCustomed && toCustomed){
        UIImage *image = [self navigationBarSnapShot:navigationController operation:operation];
        [self setSnap:image forViewController:fromRealVC];
    }
}

- (UIImage *)navigationBarSnapShot:(UINavigationController *)navigationController operation:(UINavigationControllerOperation)operation
{
    if ([self snapShotSwitch]) {
        UIView *targetView = navigationController.view;
        CGSize targetSize = targetView.frame.size;
        if (targetView &&
            targetSize.width > 10.f &&
            targetSize.height > 10.f) {
            //view size 小于1，在IOS7和IOS8会有crash
            
            CGFloat scale = [UIScreen mainScreen].scale;
            UIGraphicsBeginImageContextWithOptions(targetSize, NO, scale);
            [targetView drawViewHierarchyInRect:targetView.bounds afterScreenUpdates:NO];
            UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImage *cropImage = [self cropImage:image inRect:CGRectMake(0, 0, targetSize.width, MDStatusBarAndNavigationBarHeight)];
            
            return cropImage;
        }
    }else{
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        UINavigationBar *bar = navigationController.navigationBar;
        CGSize windowSize = window.frame.size;
        if (window && bar &&
            windowSize.width > 10.f &&
            windowSize.height >10.f) {
            
            //window size 小于1，在IOS7和IOS8会有crash
            
            NSData *data;
            NSString *key;
            if (self.isSecondoryCacheEnable)
            {
                data = [NSKeyedArchiver archivedDataWithRootObject:bar];
                key = [self MD5HexDigest:data];
                
                if (data && key)
                {
                    UIImage *cacheImage = [self.pushCache objectForKey:key];
                    if (cacheImage) {
                        return cacheImage;
                    }
                    
                    cacheImage = [self.popCache objectForKey:key];
                    if (cacheImage) {
                        return cacheImage;
                    }
                }
            }
            
            CGFloat scale = 2.f; // 7P机型为3，内存占用大，易出现creash，尝试fix
            
            UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, scale);
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
            UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImage *cropImage = [self cropImage:image inRect:CGRectMake(0, 0, window.bounds.size.width, MDStatusBarAndNavigationBarHeight)];
            if (cropImage && data && key)
            {
                if (UINavigationControllerOperationPush == operation) {
                    [self.pushCache setObject:cropImage forKey:key];
                } else {
                    [self.popCache setObject:cropImage forKey:key];
                }
            }
            return cropImage;
        }
    }
    
    return nil;
}

- (void)clearNavigationBarImageCacheAfterLogin {
    [self.pushCache removeAllObjects];
    [self.popCache removeAllObjects];
}

- (UIImage *)cropImage:(UIImage *)image inRect:(CGRect)rect
{
    CGFloat (^rad)(CGFloat) = ^CGFloat(CGFloat deg) {
        return deg / 180.0f * (CGFloat) M_PI;
    };
    
    
    CGAffineTransform rectTransform;
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, transformedCropSquare);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return result;
}

#pragma mark - 导航条截图cache

- (void)setSnap:(UIImage *)image forViewController:(UIViewController *)viewController
{
    if (image && viewController) {
        [self.snapShotCache setObject:image forKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(viewController)]];
    }
}

- (UIImage *)snapForViewController:(UIViewController *)viewcontroller
{
    if (!viewcontroller) return nil;
    
    UIImage *image = [self.snapShotCache objectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(viewcontroller)]];
    return image;
}

- (void)removeSnapForViewController:(UIViewController *)viewController
{
    if (viewController) {
        [self.snapShotCache removeObjectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(viewController)]];
    }
}

#pragma mark - notification

- (void)windowDidBecome:(NSNotification *)nofi
{
    //保护，防止切换keywindow后，导航条alpha错误显示，正常下面判断的逻辑进不去
    UIWindow *window = nofi.object;
    UIViewController *vc = [MDNavigationTransitionUtility realController:self.navigationController.topViewController];
    
    if (window && [window isEqual:[UIApplication sharedApplication].delegate.window] &&
        vc && [MDNavigationTransitionUtility isBarCustomed:vc] &&
        self.navigationController.navigationBar.alpha != 0) {
        self.navigationController.navigationBar.alpha = 0;
    }
}

@end
