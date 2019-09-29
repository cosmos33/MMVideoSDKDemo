//
//  MDAlbumVideoImageSortingViewCollectionViewCell.h
//  MomoChat
//
//  Created by sunfei on 2018/9/5.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

@import UIKit;

@interface MDAlbumVideoImageSortingViewCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL closeButtonHidden;

@property (nonatomic, copy) void(^closeButtonTapped)(MDAlbumVideoImageSortingViewCollectionViewCell *cell);

@end
