//
//  MFBarButtonItem.h
//  RecordSDK
//
//  Created by 杨玉彬 on 12-9-13.
//  Copyright (c) 2012年 RecordSDK. All rights reserved.
//
//  该类为导航栏定制左右item


#import <UIKit/UIKit.h>

#define NavButtonTitleFont    16


@interface MFBarButtonItem : UIBarButtonItem{
    UIButton *navButton;

}

@property(nonatomic, retain)UIButton *navButton;

- (id)initWithBounds:(CGSize)bounds;

- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;
- (void)setImage:(UIImage *)image  forState:(UIControlState)state;
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (void)addTarget:(id)target action:(SEL)selector forControlEvents:(UIControlEvents)events;
- (void)setTitleHighLight:(BOOL)isHighLight;

+ (MFBarButtonItem *)leftSpace;
+ (MFBarButtonItem *)rightSpace;

@end
