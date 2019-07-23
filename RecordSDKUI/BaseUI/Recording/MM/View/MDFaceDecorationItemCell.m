//
//  ItemCell.m
//  MDChat
//
//  Created by 姜自佳 on 2017/5/16.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDFaceDecorationItemCell.h"
#import "MDFaceDecorationItem.h"

@interface MDFaceDecorationItemCell()
@property(nonatomic,strong)MDMomentFaceDecorationItem* itemView;
@property(nonatomic,strong)MDFaceDecorationItem *item;

@end

@implementation MDFaceDecorationItemCell{
    MDFaceDecorationItem * _item;
    
}
- (void)updateWithModel:(MDFaceDecorationItem *)item{
    if(![item isKindOfClass:[MDFaceDecorationItem class]]){
        return;
    }
    
    _item = item;
    [self.itemView updateViewWithModel:item];
}

- (void)setIsSelected:(BOOL)isSelected{
    
    [self.itemView setIsSelected:!isSelected];
    self.item.isSelected = isSelected;
}

- (void)startDownLoadAnimate:(MDFaceDecorationItem *)item{
    [self.itemView startDownLoadAnimate:item];
}

- (void)showResourceSelectedAnimate{
    [self.itemView showResourceSelectedAnimate];
}


- (MDFaceDecorationItem *)item{
    return _item;
}

- (MDMomentFaceDecorationItem *)itemView{
    if(!_itemView){
        _itemView = [[MDMomentFaceDecorationItem alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_itemView];
    }
    return _itemView;
}

@end
