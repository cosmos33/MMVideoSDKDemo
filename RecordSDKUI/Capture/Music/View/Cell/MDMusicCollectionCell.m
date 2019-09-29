//
//  MDMusicCollectionCell.m
//  MDChat
//
//  Created by YZK on 2018/11/7.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicCollectionCell.h"
#import "MDRecordHeader.h"

@interface MDMusicCollectionCell ()

@property (nonatomic, strong) UIImageView   *iconView;
@property (nonatomic, strong) CAShapeLayer  *selectBorderLayer;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UILabel       *subTitleLabel;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIView        *loadBgView;
@property (nonatomic, strong) UIImageView   *loadingView;

@property (nonatomic, strong) MDMusicCollectionItem *item;

@end

@implementation MDMusicCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];
        self.iconView.backgroundColor = RGBCOLOR(73, 73, 73);
        self.iconView.layer.cornerRadius = 10;
        self.iconView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.iconView];
        
        self.selectBorderLayer = [CAShapeLayer layer];
        self.selectBorderLayer.frame = self.iconView.bounds;
        self.selectBorderLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.selectBorderLayer.bounds cornerRadius:10].CGPath;
        self.selectBorderLayer.lineWidth = 3;
        self.selectBorderLayer.strokeColor = RGBCOLOR(0, 156, 255).CGColor;
        self.selectBorderLayer.fillColor = [UIColor clearColor].CGColor;
        [self.contentView.layer addSublayer:self.selectBorderLayer];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.iconView.bottom+5, self.iconView.width, 15)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleLabel];
        
        self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom, self.iconView.width, 15)];
        self.subTitleLabel.textColor = [UIColor whiteColor];
        self.subTitleLabel.font = [UIFont systemFontOfSize:11];
        self.subTitleLabel.backgroundColor = [UIColor clearColor];
        self.subTitleLabel.alpha = 0.6;
        [self.contentView addSubview:self.subTitleLabel];
        
        
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
    self.subTitleLabel.text = self.item.musicVo.author;
    
    if (self.item.downLoading) {
        self.loadBgView.hidden = NO;
        self.displayLink.paused = NO;
    }else {
        self.loadBgView.hidden = YES;
        self.displayLink.paused = YES;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.selectBorderLayer.hidden = !self.item.selected;
    [CATransaction commit];
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
