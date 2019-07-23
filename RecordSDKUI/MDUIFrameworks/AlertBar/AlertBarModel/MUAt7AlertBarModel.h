//
//  MUAt7AlertBarModel.h
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/15.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAlertBarModel.h"

@interface MUAt7AlertBarModel : MUAlertBarModel

@property (nonatomic, copy) NSString                *title;
@property (nonatomic, copy) NSString                *subtitle;
@property (nonatomic, copy) AlertBarDidClickBlock   clickBlock;
@property (nonatomic, copy) AlertBarDidClickBlock   closeBlock;//点击退出触发

@end
