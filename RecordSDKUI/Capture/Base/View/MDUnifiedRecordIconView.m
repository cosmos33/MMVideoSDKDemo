//
//  MDUnifiedRecordIconView.m
//  MDChat
//
//  Created by YZK on 2018/7/31.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDUnifiedRecordIconView.h"

@implementation MDUnifiedRecordIconView

- (instancetype)initWithFrame:(CGRect)frame
                    imageName:(NSString *)imageName
                        title:(NSString *)title
              needScrollTitle:(BOOL)needScrollTitle
                       target:(id)target
                       action:(SEL)action {
    self = [super initWithFrame:frame];
    if (self) {
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:tapGesture];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.frame = CGRectMake(0, 0, 30, 30);
        imageView.layer.cornerRadius = 15;
        imageView.layer.masksToBounds = YES;
        imageView.centerX = self.width/2.0;
        [self addSubview:imageView];
        self.iconView = imageView;
        
        if (!needScrollTitle) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, self.width, self.height-35)];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:11];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = title;
            label.shadowColor = RGBACOLOR(0, 0, 0, 0.2);
            label.shadowOffset = CGSizeMake(0, 1);
            [self addSubview:label];
            self.titleLabel = label;
        }else {
            MDScrollLabelView *scrollLabel = [[MDScrollLabelView alloc] initWithFrame:CGRectMake(0, 35, self.width, self.height-35)];
            scrollLabel.textColor = [UIColor whiteColor];
            scrollLabel.font = [UIFont systemFontOfSize:11];
            scrollLabel.textAlignment = NSTextAlignmentCenter;
            scrollLabel.text = title;
            scrollLabel.pauseInterval = 0;
            scrollLabel.scrollSpeed = 10;
            scrollLabel.repeat = YES;
            scrollLabel.shadowColor = RGBACOLOR(0, 0, 0, 0.2);
            scrollLabel.shadowOffset = CGSizeMake(0, 1);
            [scrollLabel observeApplicationNotifications];
            [self addSubview:scrollLabel];
            self.scrollLabel = scrollLabel;
        }
    }
    return self;
}

@end
