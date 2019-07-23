//
//  MFBarButtonItem.m
//  RecordSDK
//
//  Created by 杨玉彬 on 12-9-13.
//  Copyright (c) 2012年 RecordSDK. All rights reserved.
//

#import "MFBarButtonItem.h"
#import "UIPublic.h"

@implementation MFBarButtonItem
@synthesize navButton;

- (id)initWithBounds:(CGSize)bounds
{
    self.navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    navButton.frame = CGRectMake(0, 0, bounds.width, bounds.height);
    navButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    navButton.exclusiveTouch = YES;
    
    self = [super initWithCustomView:navButton];
    if (self) {
        return self;
    }
    return nil;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [navButton setTitle:title forState:state];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [navButton setTitleColor:color forState:state];
}


- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [navButton setImage:image forState:state];
}

- (void)setTitleHighLight:(BOOL)isHighLight
{
    [navButton setTitleColor: (isHighLight ? RGBCOLOR(59, 179, 250): RGBACOLOR(0, 0, 0, 0.5)) forState:UIControlStateNormal];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    if (image.size.width == navButton.bounds.size.width){
        [navButton setBackgroundImage:image forState:state];
    } else{
        [navButton setBackgroundImage:[image stretchableImageWithLeftCapWidth:(NSInteger) (image.size.width / 2) topCapHeight:(NSInteger) (image.size.height / 2)] forState:state];
    }
}

- (void)addTarget:(id)target action:(SEL)selector forControlEvents:(UIControlEvents)events
{
    [navButton addTarget:target action:selector forControlEvents:events];
}

- (void)dealloc {
    self.navButton = nil;
}

+ (MFBarButtonItem *)leftSpace
{
    MFBarButtonItem *space = [[MFBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = -6.f;
    return space;
}

+ (MFBarButtonItem *)rightSpace
{
    MFBarButtonItem *space = [[MFBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = -6.f;
    return space;
}

@end
