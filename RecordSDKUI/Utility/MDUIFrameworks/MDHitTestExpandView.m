//
//  MDHitTestExpandView.m
//  MDChat
//
//  Created by wangxuan on 17/2/21.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDHitTestExpandView.h"

@implementation MDHitTestExpandView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(MDHitTestingBounds(self.bounds, self.minHitTestWidth, self.minHitTestHeight), point);
}

CGRect MDHitTestingBounds(CGRect bounds, CGFloat minimumHitTestWidth, CGFloat minimumHitTestHeight) {
    
    CGRect hitTestingBounds = bounds;
    
    if (minimumHitTestWidth > bounds.size.width) {
        hitTestingBounds.size.width = minimumHitTestWidth;
        hitTestingBounds.origin.x -= (hitTestingBounds.size.width - bounds.size.width)/2;
    }
    
    if (minimumHitTestHeight > bounds.size.height) {
        hitTestingBounds.size.height = minimumHitTestHeight;
        hitTestingBounds.origin.y -= (hitTestingBounds.size.height - bounds.size.height)/2;
    }
    
    return hitTestingBounds;
}

@end
