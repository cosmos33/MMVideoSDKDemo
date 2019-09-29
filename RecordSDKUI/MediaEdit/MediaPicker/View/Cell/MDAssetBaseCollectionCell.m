//
//  MDAssetBaseCollectionCell.m
//  MDChat
//
//  Created by YZK on 2018/12/12.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDAssetBaseCollectionCell.h"



@implementation MDAssetBaseCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

- (void)bindModel:(MDPhotoItem *)item {
    self.item = item;
    
    self.imageView.image = nil;
    if (item.editedImage) {
        self.imageView.image = item.editedImage;
    } else if (item.nailImage) {
        self.imageView.image = item.nailImage;
    } else {
        [[MDAssetUtility sharedInstance] fetchLowQualityImageWithPhotoItem:item complete:^(UIImage *image, NSString *identifer) {
            if ([item.asset.localIdentifier isEqualToString:identifer]) {
                self.imageView.image = image; // 120*120pixels缩略图暂不缓存
            }
        }];
    }
}

- (void)displayTargetSizeImageWithBindedItem {
    if (self.item.editedImage) {
        self.imageView.image = self.item.editedImage;
    } else if (self.item.nailImage) {
        self.imageView.image = self.item.nailImage;
    } else {
        [[MDAssetUtility sharedInstance] fetchThumbImageFromPhotoItem:self.item completeBlock:^(UIImage *image, NSString *identifer) {
            if ([self.item.asset.localIdentifier isEqualToString:identifer]) {
                [UIView performWithoutAnimation:^{
                    self.item.nailImage = image;
                    self.imageView.image = image;
                }];
            }
        }];
    }
}


- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.cornerRadius = 4.0;
    }
    return _imageView;
}

@end
