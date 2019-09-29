//
//  MUAt1AlertBarModel.h
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/12.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAlertBarModel.h"

@interface MUAt6AlertBarModel : MUAlertBarModel


@property (nonatomic, copy) NSString                *title;
@property (nonatomic, copy) NSString                *subtitle;
@property (nonatomic, copy) NSString                *btnTitle;
@property (nonatomic, copy) AlertBarDidClickBlock   buttonBlock;//点击按钮触发
@property (nonatomic, copy) AlertBarDidClickBlock   closeBlock;//点击X触发

@end
