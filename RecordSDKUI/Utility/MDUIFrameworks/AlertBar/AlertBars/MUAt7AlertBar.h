//
//  MUAt7AlertBar.h
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/15.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAlertBar.h"

@interface MUAt7AlertBar : MUAlertBar

@property (nonatomic, strong) UILabel           *titleLabel;
@property (nonatomic, strong) UILabel           *subtitleLabel;

@property (nonatomic, strong) UIButton          *closeButton;
@property (nonatomic, strong) UIView            *lineView;

@end
