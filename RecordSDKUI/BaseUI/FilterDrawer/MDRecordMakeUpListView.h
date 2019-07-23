//
//  MDRecordChangeFaceListView.h
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/4.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MDRecordFaceMakeUpCell;
@interface MDRecordMakeUpListView : UICollectionView
@property(nonatomic,strong)NSArray* dataArray;
@property(nonatomic,copy)void(^selectedIndexBlock)(NSInteger index);
- (void)selectedAndReloadCollectionView:(NSUInteger)row;
@end
