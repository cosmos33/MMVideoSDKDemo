//
//  MDFaceDecorationCollectionVCL.h
//  MDChat
//
//  Created by YZK on 2017/7/26.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDFaceDecorationDataHandle.h"
#import "MDFaceDecorationItem.h"
#import "MDRecordHeader.h"

@interface MDFaceDecorationCollectionVCL : NSObject

@property (nonatomic, strong) MDFaceDecorationDataHandle *dataHandle; //由外部传入的数据处理类

@property (nonatomic, strong) UICollectionView *view;

@property (nonatomic,assign) BOOL active;

- (void)setOffsetPercentage:(CGFloat)percentage withTargetLevelType:(MDUnifiedRecordLevelType)levelType;
- (void)setCurrentLevelType:(MDUnifiedRecordLevelType)levelType;

@end
