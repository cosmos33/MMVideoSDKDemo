//
//  MDSMSelectIntervalProgressView.m
//  animation
//
//  Created by RFeng on 2018/5/15.
//  Copyright © 2018年 RFeng. All rights reserved.
//

#import "MDSMSelectIntervalProgressView.h"

@interface MDSMSelectIntervalProgressView() <UIGestureRecognizerDelegate>

@property (nonatomic,assign) BOOL touchBeginRect;
@property (nonatomic,strong) UIPanGestureRecognizer *pan;


@end

@implementation MDSMSelectIntervalProgressView


-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
        self.pan = pan;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    CGRect frame = CGRectInset(self.bounds, -10, -10);
    return CGRectContainsPoint(frame, point);
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat offSetX = [gestureRecognizer translationInView:self].x;
        if (self.touchBeginRect) {
            self.beginValue = self.beginValue + offSetX / self.frame.size.width;
            if (self.marginLineHightColor) {
                self.beginLineColor = self.marginLineHightColor;
            }
            if (self.valueHandleBlock) {
                self.valueHandleBlock(self.beginValue, ChangeValueTypeBegin, TouchStatusMove);
            }
        }else {
            self.endValue = self.endValue + offSetX / self.frame.size.width;
            if (self.marginLineHightColor) {
                self.endLineCloror = self.marginLineHightColor;
            }
            if(self.valueHandleBlock){
                self.valueHandleBlock(self.endValue, ChangeValueTypeEnd, TouchStatusMove);
            }
        }
        [gestureRecognizer setTranslation:CGPointZero inView:self];
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
              gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
              gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        if (self.touchBeginRect) {
            if (self.marginLineColor) {
                self.beginLineColor = self.marginLineColor;
            }
            if (self.valueHandleBlock) {
                self.valueHandleBlock(self.beginValue, ChangeValueTypeBegin, TouchStatusEnd);
            }
        }else {
            if (self.marginLineColor) {
                self.endLineCloror = self.marginLineColor;
            }
            if(self.valueHandleBlock){
                self.valueHandleBlock(self.endValue, ChangeValueTypeEnd, TouchStatusEnd);
            }
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.pan) {
        CGPoint point = [gestureRecognizer locationInView:self];
        if( CGRectContainsPoint(CGRectInset(self.beginLineRect, 0, -10), point) ) {
            self.touchBeginRect = YES;
            return YES;
        } else if ( CGRectContainsPoint(CGRectInset(self.endLineRect, 0, -10), point)) {
            self.touchBeginRect = NO;
            return YES;
        }
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.pan) {
        return YES;
    }
    return NO;
}


-(void)setMarginLineColor:(UIColor *)marginLineColor
{
    _marginLineColor = marginLineColor;
    self.beginLineColor = marginLineColor;
    self.endLineCloror = marginLineColor;
}


@end
