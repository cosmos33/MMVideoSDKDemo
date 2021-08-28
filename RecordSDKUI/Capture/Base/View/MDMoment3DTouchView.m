//
//  MDMoment3DTouchView.m
//  MDChat
//
//  Created by sdk on 17/03/2018.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMoment3DTouchView.h"


@implementation MDMoment3DTouchView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.touchLevelHandle && self.touchLevelHandle()) {
        _acceptTouct = NO;
        return nil;
    } else if ([self.delegate respondsToSelector:@selector(touchView:hitTestTouch:withView:)] && [self.delegate touchView:self hitTestTouch:point withView:self]) {   // [[FDKX3DEngine shareInstance] hitTestTouch:point withView:self]
        _acceptTouct = YES;
        return self;
    }
    _acceptTouct = NO;
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![self.delegate respondsToSelector:@selector(touchView:touchesBegan:withEvent:)]) {
        return;
    }
    [self.delegate touchView:self touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![self.delegate respondsToSelector:@selector(touchView:touchesMoved:withEvent:)]) {
        return;
    }
    [self.delegate touchView:self touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.acceptTouct = NO;
    if (![self.delegate respondsToSelector:@selector(touchView:touchesEnded:withEvent:)]) {
        return;
    }
    [self.delegate touchView:self touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.acceptTouct = NO;
    if (![self.delegate respondsToSelector:@selector(touchView:touchesCancelled:withEvent:)]) {
        return;
    }
    [self.delegate touchView:self touchesCancelled:touches withEvent:event];
}

@end
