//
//  MDFaceDecorationImageView.m
//  MDChat
//
//  Created by YZK on 2017/8/1.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDFaceDecorationImageView.h"
#import "MDRecordHeader.h"


@implementation MDFaceDecorationImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIBezierPath *whitePath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.width/2.0];
        CAShapeLayer *whiteLayer = [CAShapeLayer layer];
        whiteLayer.frame = self.bounds;
        whiteLayer.fillColor = [UIColor whiteColor].CGColor;
        whiteLayer.path = whitePath.CGPath;
        [self.layer addSublayer:whiteLayer];
        
        CGRect backgroundRect = CGRectInset(self.bounds, 3, 3);
        CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
        backgroundLayer.frame = backgroundRect;
        backgroundLayer.fillColor = RGBCOLOR(216, 216, 216).CGColor;
        
        UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRoundedRect:backgroundLayer.bounds cornerRadius:backgroundRect.size.width/2.0];
        backgroundLayer.path = backgroundPath.CGPath;
        [self.layer addSublayer:backgroundLayer];
        
        CGRect iconRect = CGRectInset(self.bounds, 3,3);
        _iconView = [[UIImageView alloc] initWithFrame:iconRect];
        _iconView.backgroundColor = [UIColor clearColor];
        [self addSubview:_iconView];
    }
    return self;
}

@end
