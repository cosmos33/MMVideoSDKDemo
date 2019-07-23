//
//  MDFaceDecorationScrollCell.m
//  MDChat
//
//  Created by YZK on 2017/7/25.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDFaceDecorationScrollCell.h"
#import "MDFaceDecorationImageView.h"
#import "MDRecordHeader.h"

@interface MDFaceDecorationScrollCell ()
@property (nonatomic, strong) MDFaceDecorationItem *item;

@property (nonatomic, strong) MDFaceDecorationImageView *iconView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIView *loadingView;

@end

@implementation MDFaceDecorationScrollCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.iconView];
        [self addSubview:self.loadingView];
    }
    return self;
}

+ (NSString *)identifier {
    return @"MDFaceDecorationScrollCell";
}

- (void)updateWithModel:(MDFaceDecorationItem *)item{
    if(![item isKindOfClass:[MDFaceDecorationItem class]]){
        return;
    }
    self.item = item;
    
    if (item.isPlaceholdItem) {
        self.iconView.hidden = YES;
        self.loadingView.hidden = YES;
        return;
    }
    
    self.iconView.hidden = NO;
#warning sunfei image
//    [self.iconView.iconView setImageWithURL:[NSURL URLWithString:item.imgUrlStr] effect:SDWebImageEffectCircle];
    [self.iconView.iconView sd_setImageWithURL:[NSURL URLWithString:item.imgUrlStr]];
    
    if (item.isDownloading) {
        self.loadingView.hidden = NO;
        self.displayLink.paused = NO;
    }else {
        self.loadingView.hidden = YES;
        self.displayLink.paused = YES;
    }
}


- (MDFaceDecorationImageView *)iconView {
    if (!_iconView) {
        _iconView = [[MDFaceDecorationImageView alloc] initWithFrame:self.bounds];
    }
    return _iconView;
}

- (UIView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:self.bounds];
        _loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _loadingView.layer.cornerRadius = self.width/2;
        _loadingView.layer.masksToBounds = YES;
        _loadingView.hidden = YES;
        
        UIImageView *loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 19)];
        loadingImageView.image = [UIImage imageNamed:@"moment_play_bar_loading"];
        loadingImageView.center = CGPointMake(_loadingView.width/2, _loadingView.height/2);
        [_loadingView addSubview:loadingImageView];
    }
    return _loadingView;
}

-(CADisplayLink *)displayLink {
    
    if (!_displayLink) {
        MDWeakProxy *weakProxy = [MDWeakProxy weakProxyForObject:self];
        _displayLink = [CADisplayLink displayLinkWithTarget:weakProxy selector:@selector(displayDidRefresh:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
    }
    
    return _displayLink;
}

- (void)displayDidRefresh:(CADisplayLink *)displayLink {
    
    CGAffineTransform transform = self.loadingView.transform;
    NSTimeInterval duration = 1;
    CGFloat rotationAnglePerRefresh = (2*M_PI)/(duration*60.0);
    self.loadingView.transform = CGAffineTransformRotate(transform, rotationAnglePerRefresh);
}

@end
