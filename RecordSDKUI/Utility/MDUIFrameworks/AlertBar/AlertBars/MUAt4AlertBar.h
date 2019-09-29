//
//  MUAt4AlertBar.h
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/15.
//  Copyright © 2016年 RecordSDK All rights reserved.
//

#import "MUAlertBar.h"

@interface MUAt4AlertBar : MUAlertBar

@property (nonatomic, strong) UILabel           *titleLabel;
@property (nonatomic, strong) UILabel           *subtitleLabel;

@property (nonatomic, strong) UIImageView       *arrorView;
@property (nonatomic, strong) UIButton          *closeButton;
@property (nonatomic, strong) UIButton          *funcButton;
@property (nonatomic, strong) UIView            *lineView;

@property (nonatomic, strong) UIImageView       *headerView;

@end
