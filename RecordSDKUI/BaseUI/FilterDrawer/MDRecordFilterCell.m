//
//  MDRecordFilterCell.m
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/4.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDRecordFilterCell.h"
#import "MDRecordFilterModel.h"
#import "UIImage+MDUtility.h"
#import <MMFoundation/MMFoundation.h>
#import "UIConst.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import <Masonry/Masonry.h>
#import "UIView+Utils.h"

@interface MDRecordFilterCell()

@property (strong, nonatomic)  UILabel              *titleLabel;
@property (strong, nonatomic)  UILabel              *tagLabel;
@property (strong, nonatomic)  UIView               *iconBgView;
@property (strong, nonatomic)  UIImageView          *iconImageView;
@end

@implementation MDRecordFilterCell

-(void)refreshCellWithFilterModel:(MDRecordFilterModel*)model{
    
    //优先取本地配置图标
    if ([model.iconPath isNotEmpty]) {
        UIImage *localImage = [UIImage imageNamed:model.iconPath];
        UIImage *clipImage = [localImage clipImageWithFinalSize:self.iconImageView.size cornerRadius:self.iconImageView.width/2.0];
        self.iconImageView.image = clipImage;
        
    } else {
#warning sunfei image
//        [self.iconImageView setImageWithURL:[NSURL URLWithString:model.iconUrlString] effect:SDWebImageEffectCircle];
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.iconUrlString]];
    }
    [self borderTypeSelected:model.isSelected];
    self.titleLabel.text = model.title;
    self.tagLabel.text   = model.tag;
    self.tagLabel.hidden = ![model.tag isNotEmpty];
}


- (void)borderTypeSelected:(BOOL)selected
{
    self.iconBgView.layer.borderColor = selected && self.selectedColor ? self.selectedColor.CGColor: [UIColor clearColor].CGColor;
    self.iconBgView.layer.borderWidth = selected? 2.0f: 0;
    
    self.titleLabel.textColor = selected? RGBACOLOR(255.f, 255.f, 255.f, 0.8f): RGBACOLOR(255.f, 255.f, 255.f, .4f);
}



#pragma mark --lazy

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(8);
            make.centerX.mas_equalTo(self);
        }];
    }
    return _titleLabel;
}


- (UILabel *)tagLabel{
    if(!_tagLabel){
        _tagLabel = [UILabel new];
        _tagLabel.font = [UIFont boldSystemFontOfSize:8];
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.backgroundColor = RGBCOLOR(0, 192, 255);
        _tagLabel.layer.cornerRadius = 2.0;
        _tagLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:_tagLabel];
        [_tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iconImageView).offset(2);
            make.top.mas_equalTo(self.iconImageView);
            make.width.mas_equalTo(@24);
            make.height.mas_equalTo(@12);
        }];
    }
    return _tagLabel;
}

- (UIView *)iconBgView{
    if(!_iconBgView){
        _iconBgView = [UIView new];
        [self.contentView addSubview:_iconBgView];
        [_iconBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.iconImageView).multipliedBy(1.1);
            make.center.mas_equalTo(self.iconImageView);
        }];
        
        [_iconBgView layoutIfNeeded];
        _iconBgView.layer.cornerRadius = _iconBgView.bounds.size.width*0.5;
        _iconBgView.layer.masksToBounds = YES;
    }
    return _iconBgView;
}

- (UIImageView *)iconImageView{
    if(!_iconImageView){
        _iconImageView = [UIImageView new];
        _iconImageView.layer.cornerRadius = 30;
        _iconImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.iconImageView.superview);
            make.top.mas_equalTo(self.iconImageView.superview).offset(15);
            make.size.mas_equalTo(CGSizeMake(60, 60));
        }];
        [_iconImageView layoutIfNeeded];
    }
    return _iconImageView;
}


#pragma mark --prepareForReuse

- (void)prepareForReuse{
    [super prepareForReuse];
    
    self.titleLabel.text = nil;
    self.tagLabel.text = nil;
    self.iconImageView.image = nil;
}

@end
