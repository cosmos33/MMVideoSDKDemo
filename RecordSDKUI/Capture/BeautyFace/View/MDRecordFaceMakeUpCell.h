//
//  MDRecordFaceMakeUpCell.h
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/4.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MDRecordMakeUpModel;
@interface MDRecordFaceMakeUpCell : UICollectionViewCell
-(void)refreshCellWithMakeUpModel:(MDRecordMakeUpModel*)model;
@end
