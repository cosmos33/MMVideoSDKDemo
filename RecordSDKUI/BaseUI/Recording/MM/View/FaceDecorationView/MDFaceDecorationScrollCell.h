//
//  MDFaceDecorationScrollCell.h
//  MDChat
//
//  Created by YZK on 2017/7/25.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDFaceDecorationItem.h"

@interface MDFaceDecorationScrollCell : UICollectionViewCell

+ (NSString *)identifier;
- (void)updateWithModel:(MDFaceDecorationItem*)itemModel;

@end
