//
//  MDMediaEditorBottomView.h
//  MDChat
//
//  Created by 符吉胜 on 2017/11/15.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDRecordHeader.h"

@class MDMediaEditorBottomView;

@protocol MDMediaEditorBottomViewDelegate <NSObject>

@optional
- (void)mediaEditorBottomView:(MDMediaEditorBottomView *)bottomView didClickBtn:(UIButton *)btn;
- (BOOL)shouldShowRedPotintView:(NSString *)btnTitle redPointViewTag:(NSUInteger *)tag;
- (UIImage *)selectedImageWithBtnTitle:(NSString *)btnTitle;

@end

@interface MDMediaEditorBottomView : UIView

- (instancetype)initWithButtonTitleArray:(NSArray<NSString *> *)titleArray
                          imageNameArray:(NSArray<NSString *> *)imageNameArray
                                delegate:(id<MDMediaEditorBottomViewDelegate>)delegate;

//根据按钮名找按钮
- (UIButton *)buttonWithATitle:(NSString *)title;

//设置多个按钮的alpha
- (void)setAlpha:(CGFloat)alpha forTitleArray:(NSArray<NSString *> *)titleArray;

//移除红点
- (BOOL)removeRedPointWithBtnTitle:(NSString *)title andTag:(NSUInteger)tag;

- (CGRect)absoluteFrameOfButtonWithBtnTitle:(NSString *)title;

@end
