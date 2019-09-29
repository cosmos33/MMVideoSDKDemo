//
//  SDDownloadProgressView.m
//  RecordSDK
//
//  Created by yanghonglin on 15/9/21.
//  Copyright (c) 2015年 RecordSDK. All rights reserved.
//

#import "SDDownloadProgressView.h"

@implementation SDDownloadProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = 3;
        self.backgroundColor = SDColorMaker(0, 0, 0, 0.1);
        self.userInteractionEnabled = NO;
    }
    
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    [self.color set];
    
    CGFloat radius = 15;
    
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1. green:1. blue:1. alpha:0.2].CGColor);
    CGFloat to = 1.5 * M_PI + 0.05; // 初始值0.05
    
    CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, self.direction);
    CGContextStrokePath(ctx);
    
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1. green:1. blue:1. alpha:0.8].CGColor);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGFloat to1 = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.05; // 初始值0.05
    CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to1, self.direction);
    CGContextStrokePath(ctx);
}


@end
