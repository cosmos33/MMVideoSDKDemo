//
//  MDSpecialEffectsManager.h
//  BlockTest
//
//  Created by litianpeng on 2018/8/6.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDSpecialEffectsProgressModel.h"
@interface MDSpecialEffectsManager : NSObject
- (void)saveModel:(MDSpecialEffectsProgressModel *)model withProgressArr:(NSArray *)progressArr;
- (BOOL)containModel:(MDSpecialEffectsProgressModel *)model;
//判断是否存在特效
- (BOOL)existSpecialModel;
- (NSArray *)getSaveModel;

//结束的时候更新model
- (void)updateSpecialModelWithModel:(MDSpecialEffectsProgressModel *)model;
//并返回撤销的那个model
- (void)revocationEffects:(MDSpecialEffectsProgressModel **)model withProgressArr:(NSArray **)progressArr;
//停止动画以后, 需要调用这个方法获取正确的arr 重新布局
- (NSMutableArray*)getProgressArrWithModel:(MDSpecialEffectsProgressModel *)newModel;
- (void)resetSpecialModel;
//获取左边距 默认 15
+ (CGFloat)getMargin;
@end
