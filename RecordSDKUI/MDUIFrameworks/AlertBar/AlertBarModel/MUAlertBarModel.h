//
//  MUAlertBarModel.h
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/12.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MUAlertBarTypeAt1,
    MUAlertBarTypeAt2,
    MUAlertBarTypeAt3,
    MUAlertBarTypeAt4,
    MUAlertBarTypeAt5,
    MUAlertBarTypeAt6,
    MUAlertBarTypeAt7,
    MUAlertBarTypeAt8
}MUAlertBarType;

typedef void (^AlertBarDidClickBlock)();


@interface MUAlertBarModel : NSObject

@property (nonatomic, assign) MUAlertBarType          type;

@end
