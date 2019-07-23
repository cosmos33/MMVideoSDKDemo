//
//  MDSpecialEffectsManager.m
//  BlockTest
//
//  Created by litianpeng on 2018/8/6.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import "MDSpecialEffectsManager.h"
#import "MDRecordHeader.h"

@interface MDSpecialEffectsManager()
@property (nonatomic, strong) NSMutableArray *modelArr;
@property (nonatomic, strong) NSMutableArray *progressArr;///<保持当前progressView进度的数组

@end
@implementation MDSpecialEffectsManager
+ (CGFloat)getMargin{
    return 15;
}
- (void)saveModel:(MDSpecialEffectsProgressModel *)model withProgressArr:(NSArray *)progressArr{
    [self.modelArr addObjectSafe:model];
    [self.progressArr addObject:[progressArr mutableCopy]];
}
- (BOOL)containModel:(MDSpecialEffectsProgressModel *)model{
   return  [self.modelArr containsObject:model];
}

- (NSArray *)getSaveModel{
    return self.modelArr;
}
- (BOOL)existSpecialModel{
    if (self.modelArr.count > 0) {
        return YES;
    }
    return NO;
}
- (void)updateSpecialModelWithModel:(MDSpecialEffectsProgressModel *)model{
    MDSpecialEffectsProgressModel *saveModel = self.modelArr.lastObject;
    saveModel.colorRect = model.colorRect;
}
- (void)revocationEffects:(MDSpecialEffectsProgressModel *__autoreleasing*)model withProgressArr:(NSArray *__autoreleasing*)progressArr{
    *model = self.modelArr.lastObject;
    [self.modelArr removeLastObject];

    [self.progressArr removeLastObject];
    *progressArr = [self.progressArr.lastObject mutableCopy];

}
- (NSMutableArray*)getProgressArrWithModel:(MDSpecialEffectsProgressModel *)newModel{
    NSArray *oldArr = self.progressArr.lastObject;
    NSMutableArray *newSource = [[NSMutableArray alloc]init];
    if (oldArr) {
        [newSource addObjectsFromArray:oldArr];
    }
    if (oldArr.count == 0) {
        [newSource addObjectSafe:newModel];
        return newSource;
    }
    
    CGRect newRect = newModel.colorRect;
    for (int i =0 ; i< oldArr.count; i++) {
        MDSpecialEffectsProgressModel *oldModel = [oldArr objectAtIndex:i defaultValue:nil];
        CGRect oldRect = oldModel.colorRect;
        //6中情况
        
        if (!CGRectIntersectsRect(newRect, oldRect)) {
            //5,6 情况 完全不相交
        }
        else if (CGRectContainsRect(oldRect, newRect)&&
                 !CGRectEqualToRect(newRect, oldRect)){
            //1. 旧的包含新的
            //删除旧的
            [newSource removeObject:oldModel];
            //添加创建两个新的
            MDSpecialEffectsProgressModel *leftModel = [oldModel copy];
            CGRect leftRect = CGRectMake(CGRectGetMinX(oldRect),
                                         0,
                                         CGRectGetMinX(newRect) - CGRectGetMinX(oldRect),
                                         [self getHeightWithRect:newRect]);
            leftModel.colorRect = leftRect;
            
            MDSpecialEffectsProgressModel *rightModel = [oldModel copy];
            CGRect rightRect = CGRectMake(CGRectGetMaxX(newRect),
                                          0,
                                          CGRectGetMaxX(oldRect) - CGRectGetMaxX(newRect),
                                          [self getHeightWithRect:newRect]);
            rightModel.colorRect = rightRect;
            
            [newSource addObject:leftModel];
            [newSource addObject:rightModel];
        }
        else if (CGRectContainsRect(newRect, oldRect)){
            // 4. 新的包含旧的
            [newSource removeObject:oldModel];
        }
        else{
            // 2  3
            if (CGRectGetMinX(newRect) >= CGRectGetMinX(oldRect)) {
                //删除旧的
                [newSource removeObject:oldModel];
                //添加创建一个新的
                MDSpecialEffectsProgressModel *leftModel = [oldModel copy];
                leftModel.colorRect = CGRectMake(CGRectGetMinX(oldRect),
                                                  0,
                                                  CGRectGetMinX(newRect) - CGRectGetMinX(oldRect),
                                                  [self getHeightWithRect:newRect]);
                [newSource addObject:leftModel];
            }
            else{
                [newSource removeObject:oldModel];
                //添加创建一个新的
                MDSpecialEffectsProgressModel *rightModel = [oldModel copy];
                oldRect = CGRectMake(CGRectGetMaxX(newRect), 0, CGRectGetMaxX(oldRect) -CGRectGetMaxX(newRect), [self getHeightWithRect:newRect]);
                rightModel.colorRect = oldRect;
                [newSource addObject:rightModel];
            }
            
        }
        
    }
    [newSource addObjectSafe:newModel];
    return newSource;
}

- (CGFloat)getHeightWithRect:(CGRect)rect{
    return rect.size.height;
}

- (void)resetSpecialModel{
    [self.modelArr removeAllObjects];
    [self.progressArr removeAllObjects];
}
- (NSMutableArray *)progressArr{
    if (!_progressArr) {
        _progressArr = [[NSMutableArray alloc]init];
    }
    return _progressArr;
}
- (NSMutableArray *)modelArr{
    if (!_modelArr) {
        _modelArr = [[NSMutableArray alloc]init];
    }
    return _modelArr;
}
@end
