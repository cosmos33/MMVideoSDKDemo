//
//  DecorationTool.m
//  DEMo
//
//  Created by 姜自佳 on 2017/5/12.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDDecorationTool.h"
#import "MDFaceDecorationItem.h"
#import "MDRecordHeader.h"

NSInteger const kDecorationsRowCount  = 2;  // 行数
NSInteger const kDecorationsColCount  = 4;  // 列数
NSInteger const kMaxDecorationCount   = kDecorationsColCount*kDecorationsRowCount;  // 每一页最多展示个数

@implementation MDDecorationTool

+ (NSMutableArray *)getDecorationsArrayWithDecorations:(NSArray*)decoration {
    
    NSMutableArray* marr = [NSMutableArray arrayWithArray:decoration];
    NSInteger count =  ceil(decoration.count*1.0/kMaxDecorationCount)*kMaxDecorationCount - decoration.count;
    if (decoration.count == 0) {
        count = kMaxDecorationCount;
    }
    for (NSInteger i = 0; i<count; i++) {
        MDFaceDecorationItem* item = [MDFaceDecorationItem new];
        item.isPlaceholdItem = YES;
        [marr addObjectSafe:item];
    }
    return marr;
}


@end
