//
//  MDDecorationCategoryView.h
//  MomoChat
//
//  Created by YZK on 2019/4/12.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDFaceDecorationItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDDecorationCategoryView : UIView

@property (nonatomic, copy) void (^__nullable selecteBlock)(MDFaceDecorationClassItem *model, NSInteger index, BOOL animated);

- (void)setCategoryArray:(NSArray<MDFaceDecorationClassItem*> *)array;
- (void)setCurrentCategoryWithIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setCurrentCategoryWithIdentifer:(NSString *)identifer animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
