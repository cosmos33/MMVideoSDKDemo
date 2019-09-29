//
//  MDAssetCollectionHeaderReusableView.m
//  MDChat
//
//  Created by litianpeng on 2018/10/12.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDAssetCollectionHeaderReusableView.h"
#import "MDRecordHeader.h"

@interface MDAssetCollectionHeaderReusableView()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation MDAssetCollectionHeaderReusableView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(9, 15, self.width, 17)];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [self.titleLabel setTextColor:RGBCOLOR(50, 51, 51)];
        
        [self addSubview:self.titleLabel];
    }
    return self;
}
- (void)configTitle:(NSString *)titleStr{
    self.titleLabel.text = titleStr;
}
@end
