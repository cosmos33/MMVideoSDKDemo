//
//  MDDecorationCategoryCell.h
//  MomoChat
//
//  Created by YZK on 2019/4/12.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDFaceDecorationItem.h"

NS_ASSUME_NONNULL_BEGIN

@class MDDecorationCategoryItem;

@interface MDDecorationCategoryCell : UICollectionViewCell
- (void)bindModel:(MDDecorationCategoryItem *)item;
@end


@interface MDDecorationCategoryItem : NSObject
@property (nonatomic, strong) MDFaceDecorationClassItem *classItem;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) BOOL selected;
@end


NS_ASSUME_NONNULL_END
