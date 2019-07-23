//
//  MDMusicActionCell.m
//  MDChat
//
//  Created by YZK on 2018/11/19.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicActionCell.h"
#import "MDMusicActionItem.h"
#import "MDRecordHeader.h"

@interface MDMusicActionCell ()

@property (nonatomic, strong) UIImageView   *iconBgView;
@property (nonatomic, strong) UIImageView   *iconView;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UILabel       *subTitleLabel;

@property (nonatomic, strong) MDMusicActionItem *item;

@end

@implementation MDMusicActionCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.iconBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];
        self.iconBgView.backgroundColor = RGBCOLOR(30, 30, 30);
        self.iconBgView.layer.cornerRadius = 10;
        self.iconBgView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.iconBgView];
        
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.iconView.center = CGPointMake(self.iconBgView.width/2.0, self.iconBgView.height/2.0);
        [self.iconBgView addSubview:self.iconView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.iconBgView.bottom+5, self.iconBgView.width, 15)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleLabel];
        
        self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom, self.iconBgView.width, 15)];
        self.subTitleLabel.textColor = [UIColor whiteColor];
        self.subTitleLabel.font = [UIFont systemFontOfSize:11];
        self.subTitleLabel.backgroundColor = [UIColor clearColor];
        self.subTitleLabel.alpha = 0.6;
        [self.contentView addSubview:self.subTitleLabel];
    }
    return self;
}

- (void)bindModel:(MDMusicBaseCollectionItem *)item {
    self.item = (MDMusicActionItem *)item;

    self.iconView.image = [UIImage imageNamed:self.item.iconString] ;
    self.titleLabel.text = self.item.title;
    self.subTitleLabel.text = self.item.subTitle;
}


@end
