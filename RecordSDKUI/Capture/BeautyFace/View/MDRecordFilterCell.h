//
//  MDRecordFilterCell.h
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/4.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MDRecordFilterModel;
@interface MDRecordFilterCell : UICollectionViewCell

@property (nonatomic, strong) UIColor   *selectedColor;

-(void)refreshCellWithFilterModel:(MDRecordFilterModel*)model;

@end
