//
//  MDReturnButtonItem.m
//  RecordSDK
//
//  Created by 李龙翼 on 12-9-19.
//  Copyright (c) 2012年 RecordSDK. All rights reserved.
//

#import "MDReturnButtonItem.h"
#import "UIPublic.h"

@implementation MDReturnButtonItem

- (id)initWithImage:(UIImage *)image 
{
    CGSize size = CGSizeMake(32, 30);
    if (image) {
        size = CGSizeMake(image.size.width*30/image.size.height, 30);
    }
    self = [super initWithBounds:size];
    [self setImage:image forState:UIControlStateNormal];
    
    [self setImage:[UIImage imageNamed:@"UIBundle.bundle/nav_back_bg1"] forState:UIControlStateNormal];
    
    return self;
}

- (id)initWithTitle:(NSString *)aTitle
{
    //返回按钮统一样式以后只有图标没有文案
    CGSize size = CGSizeMake(32, 30);

    self = [super initWithBounds:size];
    
    [self setTitle:@"" forState:UIControlStateNormal];
    [self setTitleColor:RGBACOLOR(0, 0, 0, 0.5) forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"UIBundle.bundle/nav_back_bg1"] forState:UIControlStateNormal];
    
    return self;
}

@end
