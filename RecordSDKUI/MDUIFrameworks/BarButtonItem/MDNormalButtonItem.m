//
//  MDNormalButtonItem.m
//  RecordSDK
//
//  Created by 李龙翼 on 12-9-19.
//  Copyright (c) 2012年 RecordSDK. All rights reserved.
//

#import "MDNormalButtonItem.h"
#import "UIPublic.h"

@implementation MDNormalButtonItem

- (id)initWithImage:(UIImage *)aImage
{
    CGSize size = CGSizeMake(32, 30);
    if (aImage) {
        size = CGSizeMake(aImage.size.width*30/aImage.size.height, 30);
    }
    self = [super initWithBounds:size];
    [self setImage:aImage forState:UIControlStateNormal];
    return self;
}

- (id)initWithTitle:(NSString *)aTitle
{    
    CGSize size = CGSizeZero;
    CGSize fontSize = CGSizeZero;
    NSUInteger length = [aTitle length];
    if (length == 1) {
        size = CGSizeMake(32, 30);
    }
    else if (length <= 2) {
        size = CGSizeMake(48, 30);
    }
    else {
        //基类中所使用的字体
        UIFont *font = [UIFont systemFontOfSize:NavButtonTitleFont];
        fontSize = [aTitle sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
        size = CGSizeMake(fontSize.width + 16, 30);
    }

    self = [super initWithBounds:size];
    [self setTitle:aTitle forState:UIControlStateNormal];
    [self setTitle:aTitle forState:UIControlStateHighlighted];
    [self setTitleColor:RGBACOLOR(0, 0, 0, 0.5) forState:UIControlStateNormal];
    self.title = aTitle;
    [self setBackgroundImage:[UIImage imageNamed:@"UIBundle.bundle/nav_btn_bg1"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"UIBundle.bundle/nav_btn_bg3"] forState:UIControlStateHighlighted];
    return self;
}

- (void)setTitle:(NSString *)aTitle
{
    [super setTitle:aTitle];
    
    if (aTitle.length > 0){
        NSUInteger length = aTitle.length;
        CGSize size = CGSizeZero;
        
        if (length == 1) {
            size = CGSizeMake(32, 30);
        }else if (length <= 2) {
            size = CGSizeMake(48, 30);
        }else {
            //基类中所使用的字体
            UIFont *font = [UIFont systemFontOfSize:NavButtonTitleFont];
            CGSize fontSize = [aTitle sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
            size = CGSizeMake(fontSize.width + 16, 30);
        }
       
        CGRect frame = self.navButton.frame;
        frame.size.width = size.width;
        frame.size.height = size.height;
        self.navButton.frame = frame;
    }
    
    [self setTitle:aTitle forState:UIControlStateNormal];
    [self setTitle:aTitle forState:UIControlStateHighlighted];
    
}


@end
