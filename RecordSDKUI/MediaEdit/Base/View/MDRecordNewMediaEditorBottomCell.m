//
//  MDRecordNewMediaEditorBottomCell.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/19.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordNewMediaEditorBottomCell.h"

@interface MDRecordNewMediaEditorBottomCell ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *contentImageView;

@end

@implementation MDRecordNewMediaEditorBottomCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setContentImage:(UIImage *)contentImage {
    self.contentImageView.image = contentImage;
}

- (UIImage *)contentImage {
    return self.contentImageView.image;
}

- (void)configUI {
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.userInteractionEnabled = YES;
    [self addSubview:bgImageView];
    
    UIImageView *contentImageView = [[UIImageView alloc] init];
    contentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    contentImageView.userInteractionEnabled = YES;
    [bgImageView addSubview:contentImageView];
    self.contentImageView = contentImageView;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont systemFontOfSize:11];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.userInteractionEnabled = YES;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    [bgImageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [bgImageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [bgImageView.widthAnchor constraintEqualToConstant:58.5].active = YES;
    [bgImageView.heightAnchor constraintEqualToAnchor:bgImageView.widthAnchor].active = YES;
    
    [contentImageView.centerXAnchor constraintEqualToAnchor:bgImageView.centerXAnchor].active = YES;
    [contentImageView.centerYAnchor constraintEqualToAnchor:bgImageView.centerYAnchor].active = YES;
    [contentImageView.widthAnchor constraintEqualToConstant:34].active = YES;
    [contentImageView.heightAnchor constraintEqualToAnchor:contentImageView.heightAnchor].active = YES;
    
    [titleLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [titleLabel.topAnchor constraintEqualToAnchor:bgImageView.bottomAnchor constant:8].active = YES;

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:gesture];
}

- (void)tapAction:(UITapGestureRecognizer *)gesture {
    self.tapCallBack ? self.tapCallBack(self) : nil;
}

@end
