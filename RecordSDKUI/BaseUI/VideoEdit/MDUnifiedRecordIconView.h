//
//  MDUnifiedRecordIconView.h
//  MDChat
//
//  Created by YZK on 2018/7/31.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDScrollLabelView.h"
#import "MDRecordHeader.h"

@interface MDUnifiedRecordIconView : UIView

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) MDScrollLabelView *scrollLabel;

- (instancetype)initWithFrame:(CGRect)frame
                    imageName:(NSString *)imageName
                        title:(NSString *)title
              needScrollTitle:(BOOL)needScrollTitle
                       target:(id)target
                       action:(SEL)action;

@end
