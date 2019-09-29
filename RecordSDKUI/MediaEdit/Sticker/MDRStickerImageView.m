//
//  MDRStickerImageView.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/7/3.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRStickerImageView.h"

@interface MDRStickerImageView ()

@property (nonatomic, strong) CALayer *sublayer;

@end

@implementation MDRStickerImageView

- (void)setSelected:(BOOL)selected {
    if (selected) {
        if (self.sublayer) return;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = path.CGPath;
        layer.fillColor = UIColor.clearColor.CGColor;
        layer.strokeColor = UIColor.whiteColor.CGColor;
        layer.lineWidth = 3;
        layer.lineDashPattern = @[@10, @5];
        [self.layer addSublayer:layer];
        self.sublayer = layer;
    } else {
        [self.sublayer removeFromSuperlayer];
        self.sublayer = nil;
    }
}

@end
