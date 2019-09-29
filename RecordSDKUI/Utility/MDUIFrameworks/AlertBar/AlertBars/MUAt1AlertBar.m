//
//  MUAt1AlertBar.m
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/12.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAt1AlertBar.h"

@interface MUAt1AlertBar()



@end

@implementation MUAt1AlertBar

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

-(UIImageView *)iconView {
    if (!_iconView) {
        UIImage *image = [UIImage imageNamed:@"UIBundle.bundle/At1_icon"];
        _iconView = [[UIImageView alloc]initWithImage:image];
        _iconView.centerY = self.height/2.0;
        [self addSubview:_iconView];
    }
    return _iconView;
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

-(UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [self addSubview:_infoLabel];
    }
    return _infoLabel;
}

-(UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"UIBundle.bundle/At3_icon_close"];
        _closeButton.height = self.height;
        _closeButton.width = kAt3AlertAccessoryOffset2+image.size.width+kAt3AlertAccessoryOffset3;
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

-(UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(self.closeButton.left-1, 10, 1, self.height-20)];
        _lineView.backgroundColor = kAt3AlertLineColor;
        [self addSubview:_lineView];
    }
    return _lineView;
}


@end
