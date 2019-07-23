//
//  MDRecordFaceMakeUpCell.m
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/4.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDRecordFaceMakeUpCell.h"
#import "MDRecordFilterModel.h"
#import "UIConst.h"
#import <Masonry/Masonry.h>

@interface MDRecordFaceMakeUpCell()
@property (nonatomic,strong) UIButton       *makeUpButton;
@property (nonatomic,strong) UIImageView    *revokeIcon;
@end
@implementation MDRecordFaceMakeUpCell

-(void)refreshCellWithMakeUpModel:(MDRecordMakeUpModel*)model{
    BOOL isremoveCell = [model.makeUpId isEqualToString:revoke_Id];
   
    [self.makeUpButton setTitle:isremoveCell?nil:model.makeUpId forState:UIControlStateNormal];
    [self.makeUpButton setTitle:isremoveCell?nil:model.makeUpId forState:UIControlStateHighlighted];

    self.makeUpButton.backgroundColor = model.isSelected ? RGBACOLOR(0, 192, 255, 1.0) : RGBACOLOR(216,  216, 216, 0.1);
    if(isremoveCell) {
        self.revokeIcon.image = (model.isSelected)? [UIImage imageNamed:@"icon_moment_revoke_select"] : [UIImage imageNamed:@"icon_moment_revoke_uselect"];
    }else{
        self.revokeIcon.image = nil;
    }
}

- (void)prepareForReuse{
    [super prepareForReuse];
    
    [self.makeUpButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    [self.makeUpButton setTitle:nil forState:UIControlStateNormal];
    [self.makeUpButton setTitle:nil forState:UIControlStateHighlighted];
}


#pragma mark --lazy

- (UIButton *)makeUpButton{
    if(!_makeUpButton){
        _makeUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _makeUpButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_makeUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _makeUpButton.enabled = NO;

        [self.contentView addSubview:_makeUpButton];
        [_makeUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_makeUpButton.superview);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        
        [_makeUpButton layoutIfNeeded];
        _makeUpButton.layer.cornerRadius  = _makeUpButton.frame.size.width*0.5;
        _makeUpButton.layer.masksToBounds = YES;
        
        _revokeIcon = [[UIImageView alloc] init];
        _revokeIcon.backgroundColor = [UIColor clearColor];
        _revokeIcon.center = _makeUpButton.center;
        _revokeIcon.contentMode = UIViewContentModeCenter;
        [_makeUpButton addSubview:_revokeIcon];
        [_revokeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_makeUpButton);
            make.size.mas_equalTo(_makeUpButton);
        }];
        
    }
    return _makeUpButton;
}


@end
