//
//  MDMomentExpressionCellModel.h
//  MDChat
//
//  Created by lm on 2017/6/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDownLoaderModel.h"
#import <Eta/Eta.h>

@interface MDMomentExpressionCellModel : EtaModel

@property (nonatomic, copy) NSString                *resourceId;

@property (nonatomic, copy) NSString                *picUrl;

@property (nonatomic, copy) NSString                *zipUrl;

@property (nonatomic, strong) MDDownLoaderModel     *downLoadModel;

@end
