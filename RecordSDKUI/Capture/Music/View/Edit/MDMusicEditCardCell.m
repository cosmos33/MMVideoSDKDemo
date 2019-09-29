//
//  MDMusicEditCardCell.m
//  MDChat
//
//  Created by YZK on 2018/11/20.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicEditCardCell.h"
#import "MDMusicCollectionItem.h"
#import "MDRecordHeader.h"

@interface MDMusicEditCardCell ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *maskBgView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIView        *loadBgView;
@property (nonatomic, strong) UIImageView   *loadingView;

@property (nonatomic, strong) MDMusicCollectionItem *item;

@end

@implementation MDMusicEditCardCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];
        self.iconView.layer.cornerRadius = 10;
        self.iconView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.iconView];
        
        self.maskBgView = [[UIView alloc] initWithFrame:self.iconView.bounds];
        self.maskBgView.backgroundColor = RGBACOLOR(0, 156, 255, 0.8);
        self.maskBgView.hidden = YES;
        [self.iconView addSubview:self.maskBgView];
        
        UILabel *maskLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 30)];
        maskLabel.center = CGPointMake(self.maskBgView.width/2.0, self.maskBgView.height/2.0);
        maskLabel.textColor = [UIColor whiteColor];
        maskLabel.font = [UIFont systemFontOfSize:11];
        maskLabel.backgroundColor = [UIColor clearColor];
        maskLabel.textAlignment = NSTextAlignmentCenter;
        maskLabel.numberOfLines = 2;
        maskLabel.text = @"截取音乐";
        [self.maskBgView addSubview:maskLabel];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.iconView.bottom+10, self.iconView.width, 15)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
        
        self.loadBgView = [[UIView alloc] initWithFrame:self.iconView.bounds];
        self.loadBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.loadBgView.hidden = YES;
        [self.iconView addSubview:self.loadBgView];
        
        self.loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 19)];
        self.loadingView.image = [UIImage imageNamed:@"moment_play_bar_loading"];
        self.loadingView.center = CGPointMake(self.loadBgView.width/2, self.loadBgView.height/2);
        [self.loadBgView addSubview:self.loadingView];
    }
    return self;
}

- (void)dealloc {
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)bindModel:(MDMusicBaseCollectionItem *)item {
    self.item = (MDMusicCollectionItem *)item;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:self.item.musicVo.cover]];
    self.titleLabel.text = self.item.musicVo.title;
    
    if (self.item.downLoading) {
        self.loadBgView.hidden = NO;
        self.displayLink.paused = NO;
    }else {
        self.loadBgView.hidden = YES;
        self.displayLink.paused = YES;
    }
    
    self.maskBgView.hidden = !self.item.selected;
}

- (CADisplayLink *)displayLink {
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
