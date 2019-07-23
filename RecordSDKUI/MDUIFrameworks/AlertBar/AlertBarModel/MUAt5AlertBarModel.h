//
//  MUAt1AlertBarModel.h
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/12.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAlertBarModel.h"

@interface MUAt5AlertBarModel : MUAlertBarModel


@property (nonatomic, copy) NSString                    *title;
@property (nonatomic, copy) NSString                    *subtitle;
@property (nonatomic, copy) NSString                    *headerURL;
@property (nonatomic, copy) AlertBarDidClickBlock       clickBlock;

@end
