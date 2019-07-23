//
//  MDSpecialEffectsSliderView.m
//  MDChat
//
//  Created by litianpeng on 2018/8/13.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDSpecialEffectsSliderView.h"
#import "MDSpecialEffectsManager.h"
#import "MDRecordHeader.h"

@interface MDSpecialEffectsSliderView()
@property (nonatomic, strong) UIImageView *bgImageView;
@end

@implementation MDSpecialEffectsSliderView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bgImageView = [[UIImageView alloc]init];
        [self.bgImageView setFrame:self.bounds];
        [self addSubview:self.bgImageView];
    }
    return self;
}

//扩大点击区域
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    //获取当前button的实际大小
    CGRect bounds = self.bounds;

    //扩大bounds
    
    bounds = CGRectInset(bounds, -20, -20);
    
    //如果点击的点 在 新的bounds里，就返回YES
    
    return CGRectContainsPoint(bounds, point);
}
//当开始触摸屏幕的时候调用
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    self.transform = CGAffineTransformScale(self.transform, 1.0, 1.2);
}

//触摸时开始移动时调用(移动时会持续调用)
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    UITouch *touch = [touches anyObject];
    
    //求偏移量 = 手指当前点的X - 手指上一个点的X
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint prePoint = [touch previousLocationInView:self];

    
    CGFloat offSetX = currentPoint.x - prePoint.x;
    if(offSetX+self.left < -self.width/2.0){
        self.left = -self.width/2.0;
    }
    else if (offSetX+self.left+self.width/2.0 > (MDScreenWidth-2*[MDSpecialEffectsManager getMargin])){
        self.left = (MDScreenWidth-2*[MDSpecialEffectsManager getMargin]) - self.width/2.0;
    }
    else{
        //平移
        self.transform = CGAffineTransformTranslate(self.transform, offSetX, 0);
    }
 
    if (self.sendSliderValueChange) {
        self.sendSliderValueChange(MAX(self.left+self.width/2.0,0));
    }
}

//当手指离开屏幕时调用
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGFloat centerX = self.left+self.width/2.0;
    self.transform = CGAffineTransformIdentity;
    self.centerX = centerX;
    if (self.sendSliderValueEnd) {
        self.sendSliderValueEnd(centerX);
    }
}

- (void)setEnable:(BOOL)enable{
    _enable = enable;
    if (enable) {
        self.userInteractionEnabled = YES;
        self.alpha = 1;
    }
    else{
        self.alpha = 0.5;
        self.userInteractionEnabled = NO;
    }
}
- (void)setBgImage:(UIImage *)bgImage{
    _bgImage = bgImage;
    [self.bgImageView setImage:bgImage];
}
@end
