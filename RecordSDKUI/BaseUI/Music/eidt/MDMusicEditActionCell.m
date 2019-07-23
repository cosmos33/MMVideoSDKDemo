//
//  MDMusicEditActionCell.m
//  MDChat
//
//  Created by YZK on 2018/11/20.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicEditActionCell.h"
#import "MDMusicEditActionItem.h"
#import "MDRecordHeader.h"

@interface MDMusicEditActionCell ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) MDMusicEditActionItem *item;

@end

@implementation MDMusicEditActionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];
        self.bgView.layer.cornerRadius = 10;
        self.bgView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.bgView];

        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.iconView.center = CGPointMake(self.bgView.width/2.0, self.bgView.height/2.0);
        [self.contentView addSubview:self.iconView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bgView.bottom+10, self.bgView.width, 15)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)bindModel:(MDMusicBaseCollectionItem *)item {
    self.item = (MDMusicEditActionItem *)item;
    
    self.bgView.backgroundColor = self.item.bgColor;
    self.iconView.image = [UIImage imageNamed:self.item.iconString];
    self.titleLabel.text = self.item.title;
}

@end
