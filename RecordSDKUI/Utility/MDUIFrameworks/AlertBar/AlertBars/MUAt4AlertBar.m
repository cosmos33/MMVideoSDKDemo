//
//  MUAt4AlertBar.m
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/15.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAt4AlertBar.h"

@interface MUAt4AlertBar()

@end

@implementation MUAt4AlertBar

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
}

-(void)clickBtn {
    if (self.funcBlock) {
        self.funcBlock();
    }
}

-(UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc]init];
        [self addSubview:_headerView];
    }
    return _headerView;
}

-(UIImageView *)arrorView {
    if (!_arrorView) {
        UIImage *image = [UIImage imageNamed:@"UIBundle.bundle/At2_icon_arrow"];
        _arrorView = [[UIImageView alloc]initWithImage:image];
        _arrorView.centerY = self.height/2.0;
        [self addSubview:_arrorView];
    }
    return _arrorView;
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
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
        UIImage *image = [UIImage imageNamed:@"UIBundle.bundle/At3_icon_close"];
        _closeButton.height = self.height;
        _closeButton.width = kAt6AlertAccessoryOffset2+image.size.width+kAt6AlertAccessoryOffset3;
        _closeButton.right = self.width;
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.left = kAt3AlertAccessoryOffset2;
        imageView.centerY = _closeButton.centerY;
        [_closeButton addSubview:imageView];
        [_closeButton addTarget:self action:@selector(closeBar) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
    }
    return _closeButton;
}

-(UIButton *)funcButton {
    if (!_funcButton) {
        _funcButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"UIBundle.bundle/At6_icon_join"];
        _funcButton.width = image.size.width;
        _funcButton.height = image.size.height;
        [_funcButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _funcButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_funcButton setBackgroundImage:image forState:UIControlStateNormal];
        _funcButton.right = self.lineView.left-kAt6AlertAccessoryOffset1;
        _funcButton.centerY = self.height/2.0;
        [_funcButton addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_funcButton];
    }
    return _funcButton;
}

-(UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(self.closeButton.left-1, (self.height-40)/2.0, 1, 40)];
        _lineView.backgroundColor = kAt3AlertLineColor;
        [self addSubview:_lineView];
    }
    return _lineView;
}

@end
