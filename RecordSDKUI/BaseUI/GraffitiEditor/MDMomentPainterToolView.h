//
//  MDMomentPainterToolView.h
//  MDChat
//
//  Created by wangxuan on 16/7/25.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MDMomentPainterToolViewDelegate <NSObject>

@optional
- (void)brushButtonTapped:(UIColor *)color;
- (void)imageMosaicButtonTapped:(UIColor *)color;
- (void)mosaicButtonTapped;

@end

@interface MDMomentPainterToolView : UIView

@property (nonatomic, weak) id<MDMomentPainterToolViewDelegate> delegate;

-(void)showAnimation;

- (void)setMosaicBrushButtonHidden:(BOOL)isHidden;

@end
