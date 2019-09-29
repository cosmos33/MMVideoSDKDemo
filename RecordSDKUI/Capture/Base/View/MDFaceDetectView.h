//
//  MDFaceDetectView.h
//  MDChat
//
//  Created by xindong on 2017/11/17.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 初始化时, 不传frame会使用默认值.
 */
@interface MDFaceDetectView : UIView

@property (nonatomic, strong) NSString *text;

/// 线段长度, default is 14pt
@property (nonatomic, assign) CGFloat lineLength;

/// 线段颜色, default is white
@property (nonatomic, strong) UIColor *lineColor;

/// 线段宽度, default is 2pt
@property (nonatomic, assign) CGFloat lineWidth;

- (void)showWithText:(NSString * _Nullable)text
      hideShapeLayer:(BOOL)isHidden
           animation:(BOOL)animation;

- (void)hideRectangleView;

@end

NS_ASSUME_NONNULL_END
