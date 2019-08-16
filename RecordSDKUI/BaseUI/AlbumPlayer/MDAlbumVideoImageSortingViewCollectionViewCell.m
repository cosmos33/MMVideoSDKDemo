//
//  MDAlbumVideoImageSortingViewCollectionViewCell.m
//  MomoChat
//
//  Created by sunfei on 2018/9/5.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MDAlbumVideoImageSortingViewCollectionViewCell.h"

@interface MDAlbumVideoImageSortingViewCollectionViewCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation MDAlbumVideoImageSortingViewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews {
    
    _imageView = [[UIImageView alloc] init];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.layer.cornerRadius = 12.0f;
    [self.contentView addSubview:_imageView];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_closeButton setBackgroundImage:[UIImage imageNamed:@"deletePicture"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_closeButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_imageView, _closeButton);
    NSArray<NSLayoutConstraint *> *constrainsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_imageView(60)]-10-[_closeButton(19)]-26-|"
                                                                                         options:NSLayoutFormatAlignAllCenterX
                                                                                         metrics:nil
                                                                                           views:views];
    [NSLayoutConstraint activateConstraints:constrainsV];
    
    [_imageView.widthAnchor constraintEqualToAnchor:_imageView.heightAnchor].active = YES;
    [_imageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [_closeButton.widthAnchor constraintEqualToAnchor:_closeButton.heightAnchor].active = YES;
}

- (void)setImage:(UIImage *)image {
    if (image == _image) {
        return;
    }
    
    _image = image;
    self.imageView.image = image;
}

- (void)setCloseButtonHidden:(BOOL)closeButtonHidden {
    self.closeButton.hidden = closeButtonHidden;
}

- (BOOL)closeButtonHidden {
    return self.closeButton.hidden;
}

- (void)closeButtonClicked {
    self.closeButtonTapped ? self.closeButtonTapped(self) : nil;
}

- (void)dealloc {
    
}

@end
