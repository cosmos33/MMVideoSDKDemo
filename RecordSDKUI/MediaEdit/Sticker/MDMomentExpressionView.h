//
//  MDMomentExpressionView.h
//  MDChat
//
//  Created by Leery on 16/7/25.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MDMomentExpressionViewDelegate <NSObject>

@required
- (void)collectionViewDidSelectDateArrayAtIndexUrlDictionary:(NSDictionary *)urlDict;

@optional
- (void)closeEventAction;

@end

@interface MDMomentExpressionView : UIView

- (instancetype)initWithDelegate:(id<MDMomentExpressionViewDelegate>)aDelegate ;
- (void)setBackGroundViewWithImage:(UIImage *)image;
- (void)setPicDatesArrayWithArray:(NSMutableArray *)array;

- (void)refreshView;
@end
