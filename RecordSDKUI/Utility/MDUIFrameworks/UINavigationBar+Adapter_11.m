//
//  UINavigationBar+Adapter_11.m
//  RecordSDK
//
//  Created by tamer on 2017/10/27.
//  Copyright © 2017年 RecordSDK. All rights reserved.
//

#import "UINavigationBar+Adapter_11.h"
#import "UIConst.h"
#import "NSObject+Swizzle.h"
#import <objc/runtime.h>

static const void * kResetSubviewsFrame4IOS11 = &kResetSubviewsFrame4IOS11;
static const void * kMD_BackgroundView = &kMD_BackgroundView;

@implementation UINavigationBar (Adapter_11)

#ifdef __IPHONE_11_0
+ (void)load
{
    if (@available(iOS 11.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self swizzleInstanceSelector:@selector(layoutSubviews) withNewSelector:@selector(md_layoutSubviews)];
        });
    }
}
#endif

- (void)md_layoutSubviews
{
    [self md_layoutSubviews];
    
    if (!self.resetSubviewsFrame4IOS11) {
        return;
    }
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass([subview class]) containsString:@"BarBackground"]) {
            CGRect subViewFrame = subview.frame;
            subViewFrame.origin.y = 0.f;
            subViewFrame.size.height = MDStatusBarHeight + MDNavigationBarHeight;
            [subview setFrame: subViewFrame];
        }
        if ([NSStringFromClass([subview class]) containsString:@"BarContentView"]) {
            CGRect subViewFrame = subview.frame;
            subViewFrame.origin.y = MDStatusBarHeight;
            subViewFrame.size.height = MDNavigationBarHeight;
            [subview setFrame: subViewFrame];
        }
    }
    
    if (self.md_backgroundView) {
        [self insertSubview:self.md_backgroundView atIndex:0];
    }
}

#pragma mark - getter & setter

- (BOOL)resetSubviewsFrame4IOS11
{
    return [objc_getAssociatedObject(self, kResetSubviewsFrame4IOS11) boolValue];
}

- (void)setResetSubviewsFrame4IOS11:(BOOL)resetSubviewsFrame4IOS11
{
    objc_setAssociatedObject(self, kResetSubviewsFrame4IOS11, [NSNumber numberWithBool:resetSubviewsFrame4IOS11], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)md_backgroundView
{
    return objc_getAssociatedObject(self, kMD_BackgroundView);
}

- (void)setMd_backgroundView:(UIView *)md_backgroundView
{
    objc_setAssociatedObject(self, kMD_BackgroundView, md_backgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
