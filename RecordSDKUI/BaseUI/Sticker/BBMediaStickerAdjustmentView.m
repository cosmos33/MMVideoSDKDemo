//
//  BBMediaStickerAdjustmentView.m
//  BiBi
//
//  Created by YuAo on 12/11/15.
//  Copyright © 2015 sdk.com. All rights reserved.
//

#import "BBMediaStickerAdjustmentView.h"
#import <objc/runtime.h>
#import <MMFoundation/MMFoundation.h>
#import "UIView+Utils.h"
#import "SDWebImage/UIImageView+WebCache.h"

NSString * const BBUIImageViewStickerAssocationKey = @"BBUIImageViewStickerAssocationKey";

CGFloat const BBMediaStickerAdjustmentViewSubviewMinimumControlSize = 160;

@interface BBMediaStickerAdjustmentView () <UIGestureRecognizerDelegate>

@property (nonatomic,weak) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic,weak) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic,weak) UIRotationGestureRecognizer *rotationGesutreRecognizer;

@property (nonatomic,weak) UIView *currentStickerView;

@end

@implementation BBMediaStickerAdjustmentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupStickerAdjustmentView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
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
    /*
    if ((gestureRecognizer == self.pinchGestureRecognizer && otherGestureRecognizer == self.rotationGesutreRecognizer)
        || (gestureRecognizer == self.rotationGesutreRecognizer && otherGestureRecognizer == self.pinchGestureRecognizer)
        ) {
        return YES;
    } else {
        return NO;
    }
    */
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    if (![super pointInside:point withEvent:event]) return NO;
    
    __block BOOL subviewContainsPoint = NO;
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        UIEdgeInsets insets = UIEdgeInsetsZero;
        if (subview.frame.size.width < BBMediaStickerAdjustmentViewSubviewMinimumControlSize) {
            CGFloat inset = (subview.frame.size.width - BBMediaStickerAdjustmentViewSubviewMinimumControlSize)/2.0;
            insets = UIEdgeInsetsMake(inset, inset, inset, inset);
        }
        if(CGRectContainsPoint(UIEdgeInsetsInsetRect(subview.frame, insets), point)) {
            subviewContainsPoint = YES;
            *stop = YES;
        }
    }];
    if (subviewContainsPoint) return YES;
    else return NO;
}

- (void)setCurrentStickerView:(UIView *)currentStickerView {
    
    MDRecordBaseSticker *sticker;
    CGRect frame;
    if (_currentStickerView != nil && currentStickerView == nil) {
        sticker = objc_getAssociatedObject(_currentStickerView, &BBUIImageViewStickerAssocationKey);
        frame = _currentStickerView.frame;
    } else {
        sticker = objc_getAssociatedObject(currentStickerView, &BBUIImageViewStickerAssocationKey);
        frame = currentStickerView.frame;
    }
    
    _currentStickerView = currentStickerView;
    if (currentStickerView) {
        [self bringSubviewToFront:currentStickerView];
        [self.delegate mediaStickerAdjustmentView:self stickerWillBeginChange:sticker frame:frame];
    } else {
        [self.delegate mediaStickerAdjustmentView:self stickerDidEndChange:sticker frame:frame];   
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            for (UIView *subview in self.subviews.reverseObjectEnumerator.allObjects) {
                UIEdgeInsets insets = UIEdgeInsetsZero;
                if (subview.frame.size.width < BBMediaStickerAdjustmentViewSubviewMinimumControlSize) {
                    CGFloat inset = (subview.frame.size.width - BBMediaStickerAdjustmentViewSubviewMinimumControlSize)/2.0;
                    insets = UIEdgeInsetsMake(inset, inset, inset, inset);
                }
                if (CGRectContainsPoint(UIEdgeInsetsInsetRect(subview.frame, insets), [sender locationInView:self])) {
                    self.currentStickerView = subview;
                    break;
                }
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
            
            if (!self.currentStickerView) {
                for (UIView *subview in self.subviews.reverseObjectEnumerator.allObjects) {
                    UIEdgeInsets insets = UIEdgeInsetsZero;
                    if (subview.frame.size.width < BBMediaStickerAdjustmentViewSubviewMinimumControlSize) {
                        CGFloat inset = (subview.frame.size.width - BBMediaStickerAdjustmentViewSubviewMinimumControlSize)/2.0;
                        insets = UIEdgeInsetsMake(inset, inset, inset, inset);
                    }
                    if (CGRectContainsPoint(UIEdgeInsetsInsetRect(subview.frame, insets), [sender locationInView:self])) {
                        self.currentStickerView = subview;
                        break;
                    }
                }
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            self.currentStickerView.transform = CGAffineTransformRotate(self.currentStickerView.transform, sender.rotation);

            if ([_delegate respondsToSelector:@selector(mediaStickerAdjustmentView:stickerDidRotate:angle:)]) {
                
                MDRecordBaseSticker *subviewSticker = objc_getAssociatedObject(self.currentStickerView, &BBUIImageViewStickerAssocationKey);
                [_delegate mediaStickerAdjustmentView:self stickerDidRotate:subviewSticker angle:sender.rotation];
            }
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
            if (!self.currentStickerView) {
                for (UIView *subview in self.subviews.reverseObjectEnumerator.allObjects) {
                    UIEdgeInsets insets = UIEdgeInsetsZero;
                    if (subview.frame.size.width < BBMediaStickerAdjustmentViewSubviewMinimumControlSize) {
                        CGFloat inset = (subview.frame.size.width - BBMediaStickerAdjustmentViewSubviewMinimumControlSize)/2.0;
                        insets = UIEdgeInsetsMake(inset, inset, inset, inset);
                    }
                    if (CGRectContainsPoint(UIEdgeInsetsInsetRect(subview.frame, insets), [sender locationInView:self])) {
                        self.currentStickerView = subview;
                        break;
                    }
                }
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
                
                if ([_delegate respondsToSelector:@selector(mediaStickerAdjustmentView:stickerDidPinch:frame:)]) {
                    
                    MDRecordBaseSticker *subviewSticker = objc_getAssociatedObject(self.currentStickerView, &BBUIImageViewStickerAssocationKey);
                    [_delegate mediaStickerAdjustmentView:self stickerDidPinch:subviewSticker frame:self.currentStickerView.frame];
                }
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

- (void)addSticker:(MDRecordBaseSticker *)sticker center:(CGPoint)center
{
    UIImageView *imageView = [[UIImageView alloc] init];
    
    if ([sticker isKindOfClass:[MDRecordSticker class]]) {
        
        //静态帖子处理
        MDRecordSticker *imageSticker = (MDRecordSticker*)sticker;
        if (imageSticker.image) {
            imageView.image = imageSticker.image;
            imageView.size = imageSticker.image.size;
        } else if ([imageSticker.imageUrl isNotEmpty]) {
            
            UIImageView * weakProxy = (id)[MDWeakProxy weakProxyForObject:imageView];
#warning sunfei image
//            imageView.modifyBlock = ^UIImage *(UIImage *image){
//
//                weakProxy.size = image.size;
//                return image;
//            };
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageSticker.imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                weakProxy.size = image.size;
            }];
        }
        
    } else if([sticker isKindOfClass:[MDRecordDynamicSticker class]]) {
        
        //动态帖子处理
        MDRecordDynamicSticker *vedioSticker = (MDRecordDynamicSticker*)sticker;
        imageView.size = vedioSticker.bounds.size;
    }
    
    imageView.userInteractionEnabled = YES;

    /*
    if (imageView.size.width < 120) {
        imageView.transform = CGAffineTransformMakeScale(120/imageView.size.width, 120/imageView.size.width);
    }
    if (imageView.size.width > 240) {
        imageView.transform = CGAffineTransformMakeScale(240/imageView.size.width, 240/imageView.size.width);
    }
    */
    float ratio = 130/imageView.frame.size.width;
    if (!CGSizeEqualToSize(imageView.frame.size, CGSizeZero)) {
        imageView.transform = CGAffineTransformMakeScale(130/imageView.frame.size.width, 130/imageView.frame.size.width);
    }
    
    if (center.x > 0 && center.y > 0 && CGRectContainsRect(self.bounds, CGRectMake(center.x -imageView.width *ratio *0.5f, center.y -imageView.height *ratio *0.5f, imageView.width *ratio, imageView.height *ratio))) {
        imageView.center = center;
    }else {
        imageView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    }
    
    objc_setAssociatedObject(imageView, &BBUIImageViewStickerAssocationKey, sticker, OBJC_ASSOCIATION_RETAIN);
    [self addSubview:imageView];
    
    if ([_delegate respondsToSelector:@selector(mediaStickerAdjustmentView:stickerDidAfterAdjust:frame:)]) {
        [_delegate mediaStickerAdjustmentView:self stickerDidAfterAdjust:sticker frame:imageView.frame];
    }
}

- (void)removeSticker:(MDRecordBaseSticker *)sticker {
    for (UIImageView *subview in self.subviews) {
        MDRecordBaseSticker *subviewSticker = objc_getAssociatedObject(subview, &BBUIImageViewStickerAssocationKey);
        if (subviewSticker == sticker) {
            [subview removeFromSuperview];
        }
    }
}

- (void)notifyCurrentStickerViewMovement:(UIGestureRecognizer *)sender {
    MDRecordBaseSticker *subviewSticker = objc_getAssociatedObject(self.currentStickerView, &BBUIImageViewStickerAssocationKey);
    [self.delegate mediaStickerAdjustmentView:self stickerDidMove:subviewSticker frame:self.currentStickerView.frame touchPoint:[sender locationInView:self]];
}

@end
