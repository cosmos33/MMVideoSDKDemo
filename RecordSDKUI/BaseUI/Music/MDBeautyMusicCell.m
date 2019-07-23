//
//  MDBeautyMusicCell.m
//  MDChat
//
//  Created by Leery on 2018/5/13.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDBeautyMusicCell.h"
#import "MDRecordHeader.h"
#import "UIUtility+View.h"

@implementation MDMomentMusicListCellModel

- (instancetype)initWithMusicID:(NSString *)musicID {
    if(self = [super init]) {
        self.identifier = musicID;
        self.musicStartPercent = 0;
        self.musicEndPercent = 1.0;
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
}


@end

@interface MDBeautyMusicCell ()
@property (nonatomic ,strong) UIView            *topLine;
@property (nonatomic ,strong) UIView            *bottomLine;
@property (nonatomic ,strong) UIImageView       *arrawImageView;
@end

@implementation MDBeautyMusicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)bindDelegate:(id)target {
}


- (void)bindModel:(id)model {
    if(![model isKindOfClass:[MDMomentMusicListCellModel class]]) {
        return;
    }
    MDMomentMusicListCellModel *cellModel = (MDMomentMusicListCellModel *)model;
    MDBeautyMusic *musicItem = [MDBeautyMusicManager localMusic:cellModel.identifier];
    if(!musicItem) {
        musicItem = cellModel.dataObj;
    }
    [self updateCellWithModel:cellModel musicItem:musicItem];
}

- (void)updateCellWithModel:(MDMomentMusicListCellModel *)cellModel musicItem:(MDBeautyMusic *)musicItem {
    self.titleLabel.text = cellModel.celltitle;
    self.topLine.hidden = !cellModel.showTopLine;
    self.bottomLine.hidden = !cellModel.showBottomLine;
    self.arrawImageView.hidden = !cellModel.showArrow;
    if(!self.arrawImageView.hidden) {
        [self.arrawImageView setImage:[UIImage imageNamed:@"recordSDK_iconTopBarBack"]];
    }
}

#pragma mark - lazy
- (UIView *)topLine {
    if(!_topLine) {
        _topLine = [UIUtility addLineToView:self.contentView color:RGBACOLOR(255, 255, 255, 0.05) withFrame:CGRectMake(15, 0, MDScreenWidth - 30, 1)];
    }
    return _topLine;
}

- (UIView *)bottomLine {
    if(!_bottomLine) {
        _bottomLine = [UIUtility addLineToView:self.contentView color:RGBACOLOR(255, 255, 255, 0.05) withFrame:CGRectMake(15, kBeautyMusicCellHeight-1, MDScreenWidth - 30, 1)];
    }
    return _bottomLine;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, MDScreenWidth, kBeautyMusicCellHeight)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 1;
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIImageView *)arrawImageView {
    if(!_arrawImageView) {
        _arrawImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        _arrawImageView.right = MDScreenWidth - 15;
        _arrawImageView.centerY = kBeautyMusicCellHeight / 2.0;
        _arrawImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_arrawImageView];
    }
    return _arrawImageView;
}

@end
