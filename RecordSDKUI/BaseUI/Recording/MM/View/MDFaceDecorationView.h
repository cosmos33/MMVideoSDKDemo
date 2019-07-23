//
//  ExpressionEecorationController.h
//  DEMo
//
//  Created by 姜自佳 on 2017/5/11.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDFaceDecorationItem.h"

@class MDFaceDecorationPageView,MDFaceDecorationView;
@protocol MDFaceDecorationViewDelegate <NSObject>

- (void)faceDecorationPageView:(MDFaceDecorationPageView *)pageView
                     indexPath:(NSIndexPath *)indexPath
                     withModel:(MDFaceDecorationItem *)cellModel;

//清除选中变脸
- (void)faceDecorationViewCleanDecoration:(MDFaceDecorationView *)view;

@end

@interface MDFaceDecorationView : UIView

@property (nonatomic, weak) id<MDFaceDecorationViewDelegate> delegate;
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

- (void)updateSelectedViewItems:(NSArray*)array;//分类选择
- (void)updatePageItems:(NSArray*)array;//变脸数据

- (void)setSelectedClassWithIdentifier:(NSString *)identifer;
- (void)setSelectedClassWithIndex:(NSInteger)index;

@end
