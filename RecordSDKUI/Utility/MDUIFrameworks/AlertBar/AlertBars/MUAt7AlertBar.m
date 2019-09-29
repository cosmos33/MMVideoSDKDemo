//
//  MUAt7AlertBar.m
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/15.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAt7AlertBar.h"

@implementation MUAt7AlertBar


-(instancetype)init {
    self = [super init];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickBar)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)clickBar {
    if (self.clickBlock) {
        self.clickBlock();
    }
}

-(void)closeBar {
    if (self.closeBlock) {
        self.closeBlock();
    }
    [self removeFromSuperview];
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

-(UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_subtitleLabel];
    }
    return _subtitleLabel;
}

-(UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];

        UILabel *label = [[UILabel alloc]init];
        label.textColor = kAt7AlertButtonFontColor;
        label.font = kAt7AlertButtonFont;
        label.text = @"退出";
        CGSize size = [label sizeThatFits:CGSizeMake(100, 30)];
        label.height = self.height;
        label.width = size.width;
        label.left = kAt7AlertAccessoryOffset2;
        [_closeButton addSubview:label];
        
        _closeButton.height = self.height;
        _closeButton.width = kAt6AlertAccessoryOffset2+label.size.width+kAt6AlertAccessoryOffset3;
        _closeButton.right = self.width;

        [_closeButton addTarget:self action:@selector(closeBar) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
    }
    return _closeButton;
}

-(UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(self.closeButton.left-1, 10, 1, self.height-20)];
        _lineView.backgroundColor = kAt3AlertLineColor;
        [self addSubview:_lineView];
    }
    return _lineView;
}

@end
