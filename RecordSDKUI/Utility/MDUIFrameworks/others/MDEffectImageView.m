//
//  MDEffectImageView.m
//  RecordSDK
//
//  Created by lm on 15/10/27.
//  Copyright (c) 2015年 RecordSDK. All rights reserved.
//

#import "MDEffectImageView.h"
#import "UIImage+ImageEffects.h"

@interface MDEffectImageView()

@property (nonatomic, strong) UIImageView *blurImageView;

@end

@implementation MDEffectImageView


-(void)setImage:(UIImage *)image {
    
    UIImage *blurImage = [image applyDarkEffect];
    self.blurImageView.image = blurImage;
}

-(UIImageView *)blurImageView {

    if (!_blurImageView) {
        _blurImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_blurImageView];
        [self sendSubviewToBack:_blurImageView];
    }
    
    return _blurImageView;
}

@end
