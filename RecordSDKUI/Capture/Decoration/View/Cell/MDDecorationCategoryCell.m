//
//  MDDecorationCategoryCell.m
//  MomoChat
//
//  Created by YZK on 2019/4/12.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "MDDecorationCategoryCell.h"
#import "UIView+Utils.h"

@interface MDDecorationCategoryCell ()
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UILabel *titleLabel;
@end


@implementation MDDecorationCategoryCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.bgView.layer.cornerRadius = self.bgView.height/2.0;
        self.bgView.backgroundColor = [UIColor whiteColor];
        self.bgView.alpha = 0.1;
        self.bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.bgView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)bindModel:(MDDecorationCategoryItem *)item {
    self.bgView.hidden = !item.selected;
    self.titleLabel.textColor = item.selected ? [UIColor whiteColor] : [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    self.titleLabel.text = item.classItem.name;
}

@end



@implementation MDDecorationCategoryItem

@end
