//
//  MDSMSelectIntervalProgressView.h
//  animation
//
//  Created by RFeng on 2018/5/15.
//  Copyright © 2018年 RFeng. All rights reserved.
//
#import "MDSMSelectIntervalProgressView.h"
#import "MDSheetMusicProgressView.h"

typedef NS_ENUM(NSUInteger,ChangeValueType){
    ChangeValueTypeBegin = 0,
    ChangeValueTypeEnd = 1,
};

typedef NS_ENUM(NSUInteger,TouchStatus){
    TouchStatusMove = 0,
    TouchStatusEnd = 1,
    TouchStatusCancle = 2
};

typedef void(^ValueHandleBlock)(CGFloat vaule,ChangeValueType valueType,TouchStatus status);

@interface MDSMSelectIntervalProgressView : MDSheetMusicProgressView

//  边线的颜色 如果设置在移动的时候回显示高亮色 // 设置/endLineColor 也会改变 建议直接用这两个颜色设置
@property (nonatomic,strong) UIColor *marginLineHightColor;

@property (nonatomic,strong) UIColor *marginLineColor;


@property (nonatomic,strong)   ValueHandleBlock  valueHandleBlock;



@end
