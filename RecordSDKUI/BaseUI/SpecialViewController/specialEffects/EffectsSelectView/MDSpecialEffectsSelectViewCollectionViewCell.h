//
//  MDSpecialEffectsSelectViewCollectionViewCell.h
//  BlockTest
//
//  Created by litianpeng on 2018/8/7.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDSpecialEffectsModel.h"
@interface MDSpecialEffectsSelectViewCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) void (^previewPress)(BOOL state, MDSpecialEffectsModel *model);
@property (nonatomic, strong) void (^previewTap)(MDSpecialEffectsModel *model);
- (void)updateCellWithModel:(MDSpecialEffectsModel *)model;
@end
