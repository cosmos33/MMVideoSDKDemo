//
//  MDMomentTextAdjustmentView.m
//  MDChat
//
//  Created by wangxuan on 17/2/6.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMomentTextAdjustmentView.h"
#import <objc/runtime.h>

@interface MDMomentTextSticker ()

@property (nonatomic,copy) UIImage *image;

@end

@implementation MDMomentTextSticker

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        self.image = image;
    }
    return self;
}

- (instancetype)initWithLabel:(UILabel *)label
{
    if (self = [super init]) {
        self.label = label;
        self.text = label.text;
    }
    return self;
}

@end

NSString * const MDMomentUIImageViewTextStickerAssocationKey = @"MDMomentUIImageViewTextStickerAssocationKey";

CGFloat const MDMomentTextAdjustmentViewSubviewMinimumControlHeight = 50;
CGFloat constMDMomentTextAdjustmentViewSubviewMaxmumControlHeight = 100;
CGFloat const MDMomentTextAdjustmentViewSubviewDefaultInset = -30;

@interface MDMomentTextAdjustmentView () <UIGestureRecognizerDelegate>

@property (nonatomic,weak) UIPanGestureRecognizer       *panGestureRecognizer;
@property (nonatomic,weak) UIPinchGestureRecognizer     *pinchGestureRecognizer;
@property (nonatomic,weak) UIRotationGestureRecognizer  *rotationGesutreRecognizer;

@property (nonatomic,weak) UIView *currentStickerView;

@end

@implementation MDMomentTextAdjustmentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupStickerAdjustmentView];
    }
    return self;
}

- (void)setupStickerAdjustmentView {
    self.backgroundColor = [UIColor clearColor];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.maximumNumberOfTouches = 2;
    [self addGestureRecognizer:panGestureRecognizer];
    self.panGestureRecognizer = panGestureRecognizer;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.delegate = self;
    [tapGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    UIRotationGestureRecognizer *rotationGesutreRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
    rotationGesutreRecognizer.delegate = self;
    [self addGestureRecognizer:rotationGesutreRecognizer];
    self.rotationGesutreRecognizer = rotationGesutreRecognizer;
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinchGestureRecognizer.delegate = self;
    [self addGestureRecognizer:pinchGestureRecognizer];
    self.pinchGestureRecognizer = pinchGestureRecognizer;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *touchView = [self findToundViewWithPoint:point];
    self.currentStickerView = touchView;
    
    return touchView;
}

- (UIView*)findToundViewWithPoint:(CGPoint)point {
    
    __block UIView *touchView = nil;
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        
        CGFloat inset = MDMomentTextAdjustmentViewSubviewDefaultInset;
        UIEdgeInsets insets = UIEdgeInsetsMake(inset, inset, inset, inset);
        
        if(CGRectContainsPoint(UIEdgeInsetsInsetRect(subview.frame, insets), point)) {
            //            NSLog(@"found subview :%@",subview);
            touchView = subview;
            *stop = YES;
        }
    }];
    
    return touchView;
}

- (void)setCurrentStickerView:(UIView *)currentStickerView {
    
    MDMomentTextSticker *sticker;
    CGRect frame;
    if (_currentStickerView != nil && currentStickerView == nil) {
        sticker = objc_getAssociatedObject(_currentStickerView, &MDMomentUIImageViewTextStickerAssocationKey);
        frame = _currentStickerView.frame;
    } else {
        sticker = objc_getAssociatedObject(currentStickerView, &MDMomentUIImageViewTextStickerAssocationKey);
        frame = currentStickerView.frame;
    }
    
    _currentStickerView = currentStickerView;
    if (currentStickerView) {
        [self bringSubviewToFront:currentStickerView];
        if (self.delegate && [self.delegate respondsToSelector:@selector(momentTextAdjustmentView:stickerWillBeginChange:frame:)]) {
            [self.delegate momentTextAdjustmentView:self stickerWillBeginChange:sticker frame:frame];
        }
    } else {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(momentTextAdjustmentView:stickerDidEndChange:frame:)]) {
            [self.delegate momentTextAdjustmentView:self stickerDidEndChange:sticker frame:frame];
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if(!self.currentStickerView) {
        self.currentStickerView = [self findToundViewWithPoint:[sender locationInView:self]];
    }
    
    if (self.currentStickerView && self.delegate && [self.delegate respondsToSelector:@selector(momentTextAdjustmentView:stickerDidTap:frame:)]) {
        MDMomentTextSticker *subviewSticker = objc_getAssociatedObject(self.currentStickerView, &MDMomentUIImageViewTextStickerAssocationKey);
        subviewSticker.center = self.currentStickerView.center;
        subviewSticker.transform = self.currentStickerView.transform;

        [self.delegate momentTextAdjustmentView:self stickerDidTap:subviewSticker frame:self.currentStickerView.frame];
    }

   self.currentStickerView = nil;
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if(!self.currentStickerView) {
                self.currentStickerView = [self findToundViewWithPoint:[sender locationInView:self]];
            }
        } break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = self.currentStickerView.center;
            center.x = center.x + [sender translationInView:self].x;
            center.y = center.y + [sender translationInView:self].y;
            self.currentStickerView.center = center;
            [sender setTranslation:CGPointZero inView:self];
            [self notifyCurrentStickerViewMovement:sender];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            self.currentStickerView = nil;
        } break;
        default:
            break;
    }
}

- (void)handleRotate:(UIRotationGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if(!self.currentStickerView) {
                self.currentStickerView = [self findToundViewWithPoint:[sender locationInView:self]];
            }
        } break;
            
        case UIGestureRecognizerStateChanged: {
            self.currentStickerView.transform = CGAffineTransformRotate(self.currentStickerView.transform, sender.rotation);
            [sender setRotation:0];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            self.currentStickerView = nil;
        } break;
        default:
            break;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if(!self.currentStickerView) {
                self.currentStickerView = [self findToundViewWithPoint:[sender locationInView:self]];
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            CGAffineTransform t = self.currentStickerView.transform;
            CGFloat xScale = sqrt(t.a * t.a + t.c * t.c);
            CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
            if ((xScale > 6.0 || yScale > 6.0) && sender.scale > 1.0) {
                //dont scale
            } else {
                self.currentStickerView.transform = CGAffineTransformScale(self.currentStickerView.transform, sender.scale, sender.scale);
            }
            [sender setScale:1.0];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            self.currentStickerView = nil;
        } break;
        default:
            break;
    }
}

- (void)notifyCurrentStickerViewMovement:(UIGestureRecognizer *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(momentTextAdjustmentView:stickerDidMove:frame:touchPoint:)]) {
        MDMomentTextSticker *subviewSticker = objc_getAssociatedObject(self.currentStickerView, &MDMomentUIImageViewTextStickerAssocationKey);
        [self.delegate momentTextAdjustmentView:self stickerDidMove:subviewSticker frame:self.currentStickerView.frame touchPoint:[sender locationInView:self]];
    }
}

- (void)addSticker:(MDMomentTextSticker *)sticker center:(CGPoint)center transform:(CGAffineTransform)transform
{
    UIView *view = sticker.label;
    
    view.userInteractionEnabled = YES;
    if (center.x > 0 && center.y > 0) {
        view.center = center;
    }else {
        view.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    }

    view.transform = transform;
    objc_setAssociatedObject(view, &MDMomentUIImageViewTextStickerAssocationKey, sticker, OBJC_ASSOCIATION_RETAIN);
    [self addSubview:view];
}

- (void)removeSticker:(MDMomentTextSticker *)sticker {
    for (UIView *subview in self.subviews) {
        MDMomentTextSticker *subviewSticker = objc_getAssociatedObject(subview, &MDMomentUIImageViewTextStickerAssocationKey);
        if (subviewSticker == sticker) {
            [subview removeFromSuperview];
        }
    }
}

@end
