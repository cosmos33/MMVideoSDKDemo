//
//  MUAlertBarDispatcher.h
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/4/12.
//  Copyright © 2016年 RecordSDK All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MUAt1AlertBarModel.h"
#import "MUAt2AlertBarModel.h"
#import "MUAt3AlertBarModel.h"
#import "MUAt4AlertBarModel.h"
#import "MUAt5AlertBarModel.h"
#import "MUAt6AlertBarModel.h"
#import "MUAt7AlertBarModel.h"
#import "MUAt8AlertBarModel.h"

#import "MUAt1AlertBar.h"
#import "MUAt4AlertBar.h"
#import "MUAt7AlertBar.h"
#import "MUAt8AlertBar.h"

@interface MUAlertBarDispatcher : NSObject

+(MUAlertBar *)alertBarWithModel:(MUAlertBarModel *)model;
+(void)updateAlertBar:(MUAlertBar *)bar WithModel:(MUAlertBarModel *)model;
@end
