//
//  MDMomentExpressionView.h
//  MDChat
//
//  Created by Leery on 16/7/25.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDRecordHeader.h"

typedef void(^ExpressionViewSelectBlock)(NSDictionary *urlDict);

@interface MDMomentExpressionViewController : NSObject

//动态帖子
- (instancetype)initDynamicDecoratorWithSelectBlock:(ExpressionViewSelectBlock)block;
- (void)setBackGroundViewWithImage:(UIImage *)image;

//静态帖子
- (instancetype)initWithSelectBlock:(ExpressionViewSelectBlock)block;
- (void)show;
- (void)hide;
@end
