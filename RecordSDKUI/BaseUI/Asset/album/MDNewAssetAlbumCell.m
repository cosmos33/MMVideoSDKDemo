//
//  MDNewAssetAlbumCell.m
//  MDChat
//
//  Created by YZK on 2018/10/26.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDNewAssetAlbumCell.h"
#import "MDRecordHeader.h"

const CGFloat kMDNewAssetAlbumCellHeight = 75.0f;

@interface MDNewAssetAlbumCell ()

@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@end


@implementation MDNewAssetAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        self.titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 60, 60)];
        self.titleImageView.layer.cornerRadius = 4;
        self.titleImageView.clipsToBounds = YES;
        self.titleImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.titleImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(87, 17.5, MDScreenWidth-87-20, 22.5)];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textColor = RGBCOLOR(50, 51, 51);
        [self.contentView addSubview:self.titleLabel];
        
        self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(87, 40, MDScreenWidth-87-20, 18.5)];
        self.subTitleLabel.font = [UIFont systemFontOfSize:13];
        self.subTitleLabel.textColor = RGBCOLOR(170, 170, 170);
        [self.contentView addSubview:self.subTitleLabel];
    }
    return self;
}

- (void)bindModel:(MDAssetAlbumItem *)item {
    self.item = item;
    self.titleImageView.image = item.image;
    self.titleLabel.text = item.name;
    self.subTitleLabel.text = [@(item.count) stringValue];
}


@end
