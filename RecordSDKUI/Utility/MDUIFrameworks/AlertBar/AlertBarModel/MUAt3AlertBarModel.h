//
//  MUAt1AlertBarModel.h
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/12.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAlertBarModel.h"

@interface MUAt3AlertBarModel : MUAlertBarModel

@property (nonatomic, copy) AlertBarDidClickBlock   clickBlock;
@property (nonatomic, copy) AlertBarDidClickBlock   closeBlock;//点关闭按钮触发
@property (nonatomic, copy) NSString                *title;

@end
