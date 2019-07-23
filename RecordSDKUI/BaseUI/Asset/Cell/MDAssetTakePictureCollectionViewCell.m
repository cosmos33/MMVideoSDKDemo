//
//  MDAssetTakePictureCollectionViewCell.m
//  MDChat
//
//  Created by SDK on 2018/9/4.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDAssetTakePictureCollectionViewCell.h"
#import "UIImage+MDUtility.h"
#import "MDRecordHeader.h"

@interface MDAssetTakePictureCollectionViewCell()
@end

@implementation MDAssetTakePictureCollectionViewCell
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        bgImageView.backgroundColor = RGBCOLOR(246, 246, 246);
        bgImageView.layer.cornerRadius = 4.0;
        bgImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:bgImageView];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 20.5)];
        icon.image = [UIImage imageNamed:@"album_take_picture_icon"];
        icon.centerX = self.width/2.0;
        icon.centerY = self.height/2.0 - 3.0;
        [self.contentView addSubview:icon];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, icon.bottom + 3, 50, 18.5)];
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = RGBCOLOR(170, 170, 170);
        title.font = [UIFont systemFontOfSize:13.0];
        title.text = @"拍摄";
        title.centerX = self.width/2.0;
        [self.contentView addSubview:title];
    }
    
    return self;
}

@end

@implementation MDAssetTakePictureItem

@end
