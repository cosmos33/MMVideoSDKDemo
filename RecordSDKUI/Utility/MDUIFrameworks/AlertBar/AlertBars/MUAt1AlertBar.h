//
//  MUAt1AlertBar.h
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/12.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAlertBar.h"
//Alert Bar for At1 At2 At3
@interface MUAt1AlertBar : MUAlertBar

@property (nonatomic, strong) UIImageView       *iconView;
@property (nonatomic, strong) UILabel           *infoLabel;
@property (nonatomic, strong) UIImageView       *arrorView;
@property (nonatomic, strong) UIButton          *closeButton;
@property (nonatomic, strong) UIView            *lineView;

@end
