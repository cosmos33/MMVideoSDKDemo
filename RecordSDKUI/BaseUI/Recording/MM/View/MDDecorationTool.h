//
//  DecorationTool.h
//  DEMo
//
//  Created by 姜自佳 on 2017/5/12.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger const kDecorationsRowCount;
extern NSInteger const kDecorationsColCount;
extern NSInteger const kMaxDecorationCount;

@interface MDDecorationTool : NSObject

+ (NSMutableArray *)getDecorationsArrayWithDecorations:(NSArray*)decoration;

@end
