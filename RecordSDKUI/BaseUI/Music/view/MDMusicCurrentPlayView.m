//
//  MDMusicCurrentPlayView.m
//  MDChat
//
//  Created by YZK on 2018/11/9.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicCurrentPlayView.h"
#import "MDRecordHeader.h"

@interface MDMusicCurrentPlayView ()
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) MDMusicBVO *item;
@end

@implementation MDMusicCurrentPlayView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.borderLayer = [CAShapeLayer layer];
        self.borderLayer.frame = CGRectMake(0, 0, self.width, 37);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.borderLayer.bounds cornerRadius:18.5];
        self.borderLayer.path = path.CGPath;
        self.borderLayer.strokeColor = RGBACOLOR(255, 255, 255, 0.1).CGColor;
        self.borderLayer.fillColor = [UIColor clearColor].CGColor;
        self.borderLayer.lineWidth = 0.5;
        self.borderLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:self.borderLayer];

        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 11, 16, 16)];
        [self.iconView setImage:[UIImage imageNamed:@"recordsdk-icon_moment_music_play"]];
        [self addSubview:self.iconView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconView.right+5, 11, self.width-(self.iconView.right+5)-70, 16)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        
        self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width-62, 11, 46, 16)];
        self.subTitleLabel.textColor = [UIColor whiteColor];
        self.subTitleLabel.font = [UIFont systemFontOfSize:11];
        self.subTitleLabel.backgroundColor = [UIColor clearColor];
        self.subTitleLabel.alpha = 0.9;
        self.subTitleLabel.text = @"取消使用";
        [self addSubview:self.subTitleLabel];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(self.subTitleLabel.left, 0, self.subTitleLabel.width, self.height);
        cancelButton.backgroundColor = [UIColor clearColor];
        [cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
    }
    return self;
}

- (void)bindModel:(MDMusicBVO *)item {
    self.item = item;
    self.titleLabel.text = self.item.title;
}

- (void)cancelButtonClicked {
    if ([self.delegate respondsToSelector:@selector(currentPlayViewDidCancel)]) {
        [self.delegate currentPlayViewDidCancel];
    }
}

@end
