//
//  MDSpecialEffectsView.m
//  BlockTest
//
//  Created by litianpeng on 2018/8/6.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import "MDSpecialEffectsProgressView.h"
#import "MDSpecialEffectsManager.h"
#import "MDSpecialEffectsLayer.h"
#import "MDSpecialEffectsSliderView.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "UIView+RoundCorner.h"
#import "MDRecordHeader.h"

#define kImageViewTop 5
#define kConerRadius 5.0

@interface MDSpecialEffectsProgressView()
@property (nonatomic, strong) MDSpecialEffectsSliderView *progressSlider;
@property (nonatomic, strong) MDSpecialEffectsManager *manager;
@property (nonatomic, assign) CGFloat tapViewCenterX;
@property (nonatomic, assign) MDRecordSpecialType type;
@property (nonatomic, strong) MDSpecialEffectsSliderView *timeSlider;///<时间动效
@property (nonatomic, strong) NSMutableArray *imageSource;
@property (nonatomic, strong) MDSpecialEffectsLayer *progressLayer;
@property (nonatomic, assign) BOOL isStart;
@property (nonatomic, strong) UIView *bgImageView;
@property (nonatomic, strong) CALayer *reverseLayer;///<时光倒流的layer
@end
@implementation MDSpecialEffectsProgressView

- (id)initWithFrame:(CGRect)frame type:(MDRecordSpecialType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        self.currentTime = kCMTimeZero;
        [self configImageView];
        [self configSubViews];
    }
    return self;
}
- (void)configImageView{
    [self addSubview:self.bgImageView];
    CGFloat w =  self.bgImageView.width/15.0;
    for (int i = 0; i<15; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(w*i, 0, w,self.bgImageView.height)];
        
        imageView.clipsToBounds = YES;
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.imageSource addObjectSafe:imageView];
        [self.bgImageView addSubview:imageView];
    }
}
- (void)configSubViews{
    [self.layer addSublayer:self.progressLayer];
    if (self.type == MDRecordSpecialTypeFilter) {
        [self addSubview:self.progressSlider];
        
    }
    else if (self.type == MDRecordSpecialTypeTime){
        [self.layer addSublayer:self.reverseLayer];
        [self addSubview:self.progressSlider];
        [self addSubview:self.timeSlider];
    }
}
- (void)updateImageWithDataSource:(NSArray *)dataSource{
    for (int i = 0; i<dataSource.count; i++) {
        UIImageView *imageView = [self.imageSource objectAtIndex:i defaultValue:nil];
        if (imageView) {
            [imageView setImage:[dataSource objectAtIndex:i defaultValue:nil]];
        }
    }
    //图片不够用第一帧图片占位
    if (dataSource.count < self.imageSource.count && dataSource.count >0) {
        for (int i = dataSource.count; i < self.imageSource.count; i++) {
            UIImageView *imageView = [self.imageSource objectAtIndex:i defaultValue:nil];
            if (imageView) {
                [imageView setImage:[dataSource objectAtIndex:0 defaultValue:nil]];
            }
        }
    }
}
#pragma mark -- SliderAction
- (void)progressAction:(CGFloat)left{
    
    if (self.sendMoveBtnProgress) {
        
        CGFloat progres = left/self.width;
        progres = MAX(0, MIN(1, progres));
        if (self.currentTimeEffectsModel.type == MDRecordSpecialEffectsTypeReverse) {
            progres = 1- progres;
        }

        CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.allTime)*progres, NSEC_PER_SEC);
        self.currentTime = time;
        self.sendMoveBtnProgress(time);
    }
}

//时间动效停止
- (void)timeSpecialEnd:(CGFloat )endX{
    if (self.sendTimeBtnProgress) {
        CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.allTime)*(endX/self.width), NSEC_PER_SEC);
        self.sendTimeBtnProgress(time);
        [self updateTimeSpecialSliderState:NO];
    }
}
#pragma mark -- public
- (void)updateTimeSpecialSliderState:(BOOL)isEnable{
    self.progressSlider.enable = isEnable;
}
- (void)updateTimeSpecialSliderProgress:(CMTime)currentTime isHidden:(BOOL)isHidden{
    if (isHidden) {
        self.timeSlider.hidden = isHidden;
    }
    else{
        Float64 x = 0;
        if (CMTimeGetSeconds(self.allTime) != 0) {
            x = CMTimeGetSeconds(currentTime)/CMTimeGetSeconds(self.allTime);
        }
        self.timeSlider.centerX = MIN(ceil(x*self.width), self.width);
        self.timeSlider.hidden = isHidden;
    }
}
- (void)updateCurrentTime:(CMTime)currentTime{
    self.currentTime = currentTime;
    
    CGFloat progress = 0;
    if (CMTimeCompare(self.allTime, kCMTimeZero) > 0) {
        progress = CMTimeGetSeconds(currentTime)/CMTimeGetSeconds(self.allTime);
    }
    progress = MAX(0, MIN(1, progress));
    if (self.currentTimeEffectsModel.type == MDRecordSpecialEffectsTypeReverse) {
        progress = 1-progress;
    }
    
    //只有滤镜特效才修改动效图层
    CGFloat progressSliderX = progress*self.width;
    if (self.isStart) {
        //这里需要判断是否是反转动效
        if (self.currentTimeEffectsModel.type == MDRecordSpecialEffectsTypeReverse) {
            self.currentPictureEffectsModel.colorRect = CGRectMake(progressSliderX, 0, MAX( self.tapViewCenterX-progressSliderX ,0),self.progressLayer.frame.size.height);
        } else {
            self.currentPictureEffectsModel.colorRect = CGRectMake(self.tapViewCenterX, 0, MAX( progressSliderX-self.tapViewCenterX ,0),self.progressLayer.frame.size.height);
        }
        [self.progressLayer setNeedsDisplay];
    }
    self.progressSlider.centerX = progressSliderX;
}

- (void)updateReverseLayerState:(BOOL)isHidden bgColor:(UIColor *)bgColor{
    self.reverseLayer.hidden = isHidden;
    if (!isHidden) {
        [self.reverseLayer setBackgroundColor:bgColor.CGColor];
    }
}

- (void)startPressStateWithCurrentTime:(CMTime)currentTime currentModel:(MDSpecialEffectsModel *)model{
    
    self.isStart = YES;
    //开始滑动,
    if (model) {
        MDSpecialEffectsProgressModel *progressModel = [[MDSpecialEffectsProgressModel alloc]init];
        [progressModel configDataWithModel:model timeModel:self.currentTimeEffectsModel];
        self.currentPictureEffectsModel = progressModel;
    }
    
    //这些是为了求整, 防止小数点, layer在渲染的时候小数点会渲染出渐变色
    if (self.currentTimeEffectsModel.type == MDRecordSpecialEffectsTypeReverse) {
        self.tapViewCenterX = ceil(self.progressSlider.centerX);
    }
    else{
        self.tapViewCenterX = floor(self.progressSlider.centerX);
    }
    self.currentPictureEffectsModel.startTime = currentTime;
    self.currentPictureEffectsModel.colorRect = CGRectMake(self.tapViewCenterX, 0, 0,self.height);
    NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:self.progressLayer.transparentArr];
    [arr addObject:self.currentPictureEffectsModel];
    self.progressLayer.transparentArr = arr;
    
    [self.progressLayer setNeedsDisplay];
}

- (BOOL)endPressStateWithCurrentTime:(CMTime)currentTime{
    self.isStart = NO;
    //差距小于0.1 不在存储, 不能用CMTimeCompare, 精确达不到
    if (CMTimeGetSeconds(CMTimeSubtract(currentTime,self.currentPictureEffectsModel.startTime))<=0.01) {
        return NO;
    }
    if (!self.currentPictureEffectsModel) {
        return NO;
    }
    self.currentPictureEffectsModel.endTime = currentTime;
    //这些是为了求整, 防止小数点, layer在渲染的时候小数点会渲染出渐变色
    
    if (self.currentTimeEffectsModel.type == MDRecordSpecialEffectsTypeReverse) {
        
        self.currentPictureEffectsModel.colorRect = CGRectMake(ceil(CGRectGetMinX(self.currentPictureEffectsModel.colorRect)), CGRectGetMinY(self.currentPictureEffectsModel.colorRect), floor(CGRectGetWidth(self.currentPictureEffectsModel.colorRect)),  CGRectGetHeight(self.currentPictureEffectsModel.colorRect));
    }
    else{
        
        self.currentPictureEffectsModel.colorRect = CGRectMake(CGRectGetMinX(self.currentPictureEffectsModel.colorRect),  CGRectGetMinY(self.currentPictureEffectsModel.colorRect), floor(CGRectGetWidth(self.currentPictureEffectsModel.colorRect)),  CGRectGetHeight(self.currentPictureEffectsModel.colorRect));
    }
    self.progressLayer.transparentArr = [self.manager getProgressArrWithModel:self.currentPictureEffectsModel];
    [self.progressLayer setNeedsDisplay];
    
    [self.manager saveModel:[self.currentPictureEffectsModel copy] withProgressArr:self.progressLayer.transparentArr];

    self.currentPictureEffectsModel = nil;
    
    return YES;
}


- (void)resetAllEffects{
    self.progressLayer.transparentArr = nil;
    [self.progressLayer setNeedsDisplay];
    self.currentTime = kCMTimeZero;
    self.reverseLayer.hidden = YES;
    [self.manager resetSpecialModel];
    self.progressSlider.centerX = 0;
    self.timeSlider.hidden = YES;
    self.currentPictureEffectsModel = nil;
    self.currentTimeEffectsModel = nil;
}
- (CMTime)revocationLastSpecialEffects{
    
    
    MDSpecialEffectsProgressModel *lastModel = nil;
    NSArray *transparentArr = nil;
    [self.manager revocationEffects:&lastModel withProgressArr:&transparentArr];

    if (lastModel) {
        self.progressLayer.transparentArr = transparentArr;
        [self.progressLayer setNeedsDisplay];
        //这里需要重置时间
        self.currentTime = lastModel.startTime;
        //这里需要判断是否是反转
        if (self.currentTimeEffectsModel.type == MDRecordSpecialEffectsTypeReverse) {
            self.progressSlider.centerX = lastModel.colorRect.origin.x+lastModel.colorRect.size.width;
        }
        else{
            self.progressSlider.centerX = lastModel.colorRect.origin.x;
        }
        //如果要撤销的mode 不是在"反转"时间特效添加的, 要在"反转"时间特效点击撤销, 需要特殊处理,  反之也要处理
        if (lastModel.timeType != MDRecordSpecialEffectsTypeReverse  && self.currentTimeEffectsModel.type == MDRecordSpecialEffectsTypeReverse) {
            self.currentTime = CMTimeSubtract(self.allTime, lastModel.endTime);
        }
        else if (lastModel.timeType == MDRecordSpecialEffectsTypeReverse && self.currentTimeEffectsModel.type  != MDRecordSpecialEffectsTypeReverse){
            self.currentTime = CMTimeSubtract(self.allTime, lastModel.endTime);
        }
        
        return self.currentTime;
    }
    return kCMTimeZero;

}

- (BOOL)existSpecialModel{
    return [self.manager existSpecialModel];
}

//扩大触控范围
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -[MDSpecialEffectsManager getMargin], -10);
    return CGRectContainsPoint(bounds, point);
}
#pragma mark -- Lazy
- (MDSpecialEffectsLayer *)progressLayer{
    if (!_progressLayer) {
        _progressLayer = [[MDSpecialEffectsLayer alloc]init];
        _progressLayer.masksToBounds = YES;
        _progressLayer.cornerRadius = kConerRadius;
        _progressLayer.contentsScale = UIScreen.mainScreen.scale;
        [_progressLayer setFrame:CGRectMake(0, kImageViewTop, self.width, self.height-2*kImageViewTop)];
    }
    return _progressLayer;
}
- (MDSpecialEffectsManager *)manager{
    if (!_manager) {
        _manager = [[MDSpecialEffectsManager alloc]init];
    }
    return _manager;
}
- (MDSpecialEffectsSliderView *)progressSlider{
    if (!_progressSlider) {
        _progressSlider = [[MDSpecialEffectsSliderView alloc]initWithFrame:CGRectMake(-3, 0, 6, self.height)];
        [_progressSlider setBgImage:[UIImage imageNamed:@"specialEffects_progress_small_line"]];
        @weakify(self);
        [_progressSlider setSendSliderValueChange:^(CGFloat value) {
            @strongify(self);
            [self progressAction:value];
        }];
    }
    return _progressSlider;
}
- (MDSpecialEffectsSliderView *)timeSlider{
    if (!_timeSlider) {
        _timeSlider = [[MDSpecialEffectsSliderView alloc]initWithFrame:CGRectMake(0, 0, 18, self.height)];
        [_timeSlider setBgImage:[UIImage imageNamed:@"specialEffects_progress_time_small"]];
        _timeSlider.hidden = YES;
        @weakify(self);
        [_timeSlider setSendSliderValueEnd:^(CGFloat endX) {
            @strongify(self);
            [self timeSpecialEnd:endX];
        }];
    }
    return _timeSlider;
}
- (CALayer *)reverseLayer{
    if (!_reverseLayer) {
        _reverseLayer = [[CALayer alloc]init];
        [_reverseLayer setFrame:self.bgImageView.frame];
        _reverseLayer.masksToBounds = YES;
        _reverseLayer.cornerRadius = kConerRadius;
        _reverseLayer.hidden = YES;
    }
    return _reverseLayer;
}
- (UIView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIView alloc]initWithFrame:CGRectMake(0, kImageViewTop, self.width, self.height-2*kImageViewTop)];
        _bgImageView.clipsToBounds = YES;
        [_bgImageView.layer setCornerRadius:kConerRadius];
    }
    return _bgImageView;
}
- (NSMutableArray *)imageSource{
    if (!_imageSource) {
        _imageSource = [[NSMutableArray alloc]init];
    }
    return _imageSource;
}
@end
