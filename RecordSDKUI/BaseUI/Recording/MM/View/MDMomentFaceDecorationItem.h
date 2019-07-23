//
//  MDMomentFaceDecorationItem.h
//  MDChat
//
//  Created by 姜自佳 on 2017/5/15.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MDFaceDecorationItem;
@interface MDMomentFaceDecorationItem : UIView

- (void)setIsSelected:(BOOL)isSelected;
//点击下载时展示的动画
- (void)startDownLoadAnimate:(MDFaceDecorationItem *)item;
- (void)showResourceSelectedAnimate;
- (void)updateViewWithModel:(MDFaceDecorationItem*)itemModel;

@end
