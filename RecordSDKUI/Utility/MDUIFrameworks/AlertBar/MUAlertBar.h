//
//  MUAlertBar.h
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/12.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUAlertBarModel.h"
#import "UIPublic.h"

@interface MUAlertBar : UIView

@property (nonatomic, copy)     AlertBarDidClickBlock   clickBlock;
@property (nonatomic, copy)     AlertBarDidClickBlock   closeBlock;
@property (nonatomic, copy)     AlertBarDidClickBlock   funcBlock;
@property (nonatomic, strong)   MUAlertBarModel         *model;

@end
