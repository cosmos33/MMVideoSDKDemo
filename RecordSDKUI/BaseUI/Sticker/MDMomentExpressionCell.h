//
//  MDMomentExpressionCell.h
//  MDChat
//
//  Created by Leery on 16/7/25.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDMomentExpressionCellModel.h"

#define kImageViewWidth    floorf(self.width*(51/90))

@interface MDMomentExpressionCell : UICollectionViewCell

- (void)bindModel:(id)model;
- (UIImageView *)cellContentView;

@end
