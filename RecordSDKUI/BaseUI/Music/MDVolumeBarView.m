//
//  MDVolumeBarView.m
//  MDChat
//
//  Created by Fu.Chen on 2018/3/9.
//  Copyright © 2018年 Fu.Chen. All rights reserved.
//

#import "MDVolumeBarView.h"
#import "MDRecordHeader.h"

#define DEGREES_TO_RADINAS(degrees) ((M_PI * degrees)/180)
#define koffset         20
@interface MDVolumeBarView()

@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) UIView *controlView;

@end

@implementation MDVolumeBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        [self addSubview:self.backgroundView];
        [self addSubview:self.controlView];
        _progress = 0.5;
        [self drawWithProgress:_progress];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(controlMove:)];
        [self.controlView addGestureRecognizer:pan];
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}

- (void)layoutSubviews {

    [self removeAllLayer:self.backgroundView];
    [self drawWithProgress:_progress];
}


- (void)setProgress:(CGFloat)progress {
    if(progress < 0) {
        progress = 0;
    }else if(progress > 1.0){
        progress = 1.0;
    }
    if(_progress != progress) {
        _progress = progress;
        self.controlView.centerX = koffset + (self.width-2*koffset)*_progress;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

-(void)controlMove:(UIPanGestureRecognizer *)sender{

    CGPoint centerPoint = [sender locationInView:self];
    if (centerPoint.x < koffset){
        self.controlView.center = CGPointMake(koffset, self.controlView.center.y);
    }else if (centerPoint.x > self.frame.size.width - koffset){
        self.controlView.center = CGPointMake(self.frame.size.width - koffset, self.controlView.center.y);
    }else{
        self.controlView.center = CGPointMake(centerPoint.x, self.controlView.center.y);
    }
    _progress = ((self.controlView.center.x - koffset)/(self.frame.size.width - (koffset * 2)));
    [self setNeedsLayout];
    [self layoutIfNeeded];
    if ([self.delegate respondsToSelector:@selector(progressDidChange:)]){
        [self.delegate progressDidChange:_progress];
    }
}
-(void)removeAllLayer:(UIView*) subView
{
    for(NSInteger index = 0 ;index < subView.layer.sublayers.count ;index++) {
        CALayer *layer = [subView.layer.sublayers objectAtIndex:index defaultValue:nil];
        [layer removeFromSuperlayer];
    }
    subView.layer.sublayers = nil;
}
-(void)drawWithProgress:(CGFloat)progress
{

    int offset = 7;
    UIBezierPath *path = [[UIBezierPath alloc] init];

    
    CGPoint point1;
    point1 = CGPointMake(offset,8 * progress);
    CGPoint point2;
    point2 = CGPointMake(self.backgroundView.bounds.size.width - offset, 8 * (1 - progress));
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:CGPointMake(self.backgroundView.bounds.size.width - offset, self.backgroundView.bounds.size.height)];
    [path addLineToPoint:CGPointMake(offset, self.backgroundView.bounds.size.height)];
    [path addLineToPoint:point1];
    [path addArcWithCenter:CGPointMake(self.backgroundView.bounds.size.width - offset, (point2.y + self.backgroundView.bounds.size.height)/2) radius:(self.backgroundView.bounds.size.height-point2.y)/2 startAngle:DEGREES_TO_RADINAS(-90) endAngle:DEGREES_TO_RADINAS(90) clockwise:YES];
    [path addArcWithCenter:CGPointMake(offset, (point1.y + self.backgroundView.bounds.size.height)/2) radius:(self.backgroundView.bounds.size.height-point1.y)/2 startAngle:0 endAngle:DEGREES_TO_RADINAS(90) clockwise:NO];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    shapeLayer.fillMode = kCAFillModeBoth;
    shapeLayer.path = path.CGPath;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.allowsEdgeAntialiasing = YES;
    [self.backgroundView.layer addSublayer:shapeLayer];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.backgroundView.bounds;
    gradientLayer.colors = @[(__bridge id)[[UIColor alloc]initWithRed:0.0f/255.0f green:255.0f/255.0f blue:207.0f/255.0f alpha:1].CGColor,(__bridge id)[[UIColor alloc]initWithRed:0.0f/255.0f green:153.0f/255.0f blue:255.0f/255.0f alpha:1].CGColor];
    gradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
    gradientLayer.endPoint = CGPointMake(1.0f, 0.0f);
//    gradientLayer.locations = @[@(0.33f),@(0.66f),@(1.0f)];
    gradientLayer.type = kCAGradientLayerAxial;
    [self.backgroundView.layer addSublayer:gradientLayer];
    
    self.backgroundView.layer.mask = shapeLayer;
}
-(void)drawControllLayer:(UIView *)pointView{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(0,5)];
    [path addLineToPoint:CGPointMake(10,5)];
    [path addLineToPoint:CGPointMake(10,12)];
    [path addLineToPoint:CGPointMake(0, 12)];
    [path addLineToPoint:CGPointMake(0, 5)];
    [path addArcWithCenter:CGPointMake(5, 5) radius:5 startAngle:DEGREES_TO_RADINAS(180) endAngle:DEGREES_TO_RADINAS(0) clockwise:YES];
    [path addArcWithCenter:CGPointMake(5, 12) radius:5 startAngle:DEGREES_TO_RADINAS(0) endAngle:DEGREES_TO_RADINAS(180) clockwise:YES];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillMode = kCAFillModeBoth;
    [pointView.layer addSublayer:shapeLayer];
    pointView.layer.mask = shapeLayer;
}
- (UIView*)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(15, 3, self.bounds.size.width - 30, self.bounds.size.height - 6)];
        _backgroundView.center = CGPointMake(_backgroundView.center.x, self.bounds.size.height/2);
        _backgroundView.backgroundColor = [UIColor greenColor];
        _backgroundView.clipsToBounds = NO;
    }
    return _backgroundView;
}
- (UIView*)controlView
{
    if (!_controlView) {
        _controlView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 40, 20)];
        _controlView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height/2);
        UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 18)];
        pointView.center = CGPointMake(_controlView.bounds.size.width/2, _controlView.bounds.size.height/2);
        pointView.backgroundColor = UIColor.whiteColor;
        [_controlView addSubview:pointView];
        [self drawControllLayer:pointView];
    }
    return _controlView;
}

@end
