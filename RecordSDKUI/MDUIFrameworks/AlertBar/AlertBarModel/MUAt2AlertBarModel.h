//
//  MUAt1AlertBarModel.h
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/12.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAlertBarModel.h"

@interface MUAt2AlertBarModel : MUAlertBarModel


@property (nonatomic, copy) NSString                *title;
@property (nonatomic, copy) AlertBarDidClickBlock   clickBlock;

@end
