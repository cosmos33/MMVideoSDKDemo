//
//  MDMoment3DTouchView.h
//  MDChat
//
//  Created by sdk on 17/03/2018.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDMoment3DTouchView;

@protocol MDMoment3DTouchViewDelegate <NSObject>

@optional

- (BOOL)touchView:(MDMoment3DTouchView *)view hitTestTouch:(CGPoint)point withView:(UIView *)view;

- (void)touchView:(MDMoment3DTouchView *)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchView:(MDMoment3DTouchView *)view touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchView:(MDMoment3DTouchView *)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchView:(MDMoment3DTouchView *)view touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end

typedef BOOL(^MD3DTouchLevelHandle)(void);

@interface MDMoment3DTouchView : UIView

@property (strong) MD3DTouchLevelHandle touchLevelHandle;

@property (assign) BOOL acceptTouct;

@property (nonatomic, weak) id<MDMoment3DTouchViewDelegate> delegate;

@end
