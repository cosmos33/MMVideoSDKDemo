//
//  MUAt8AlertBar.h
//  RecordSDK
//
//  Created by Aaron on 16/7/28.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAlertBar.h"
#import "MUAt8AlertBarModel.h"

@interface MUAt8AlertBar : MUAlertBar

-(instancetype)initWithModel:(MUAt8AlertBarModel *)model;
-(void)performAnimation;
-(void)closeAction;

@end
