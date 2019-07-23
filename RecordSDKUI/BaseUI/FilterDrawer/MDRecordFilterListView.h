//
//  MDRecordFilterListView.h
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/4.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDRecordFilterListView : UICollectionView

@property (nonatomic,strong)NSArray* dataArray;

@property (nonatomic, strong) UIColor   *selectedColor;

@property (nonatomic, copy) BOOL (^shouldHandleSelectedBlock)(); //允许选中

@property (nonatomic,copy)void(^setselectedItemBlock)(NSInteger index); //已选中

- (void)selectedAndReloadCollectionView:(NSUInteger)row;

@end
