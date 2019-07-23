//
//  MDMoment3DTouchView.m
//  MDChat
//
//  Created by sdk on 17/03/2018.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMoment3DTouchView.h"
@import FaceDecorationKitX3D;
@import GPUImage;

@implementation MDMoment3DTouchView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.touchLevelHandle && self.touchLevelHandle()) {
        _acceptTouct = NO;
        return nil;
    } else if ([[FDKX3DEngine shareInstance] hitTestTouch:point withView:self]) {
        _acceptTouct = YES;
        return self;
    }
    _acceptTouct = NO;
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    runSynchronouslyOnVideoProcessingQueue(^{
        [[FDKX3DEngine shareInstance] touchesBegan:touches withEvent:event];
    });
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    runSynchronouslyOnVideoProcessingQueue(^{
        [[FDKX3DEngine shareInstance] touchesMoved:touches withEvent:event];
    });
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.acceptTouct = NO;
    runSynchronouslyOnVideoProcessingQueue(^{
        [[FDKX3DEngine shareInstance] touchesEnded:touches withEvent:event];
    });
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.acceptTouct = NO;
    runSynchronouslyOnVideoProcessingQueue(^{
        [[FDKX3DEngine shareInstance] touchesCancelled:touches withEvent:event];
    });
}

@end
