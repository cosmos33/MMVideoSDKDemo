//
//  SDLoopProgressView.h
//  SDProgressView
//
//  Created by aier on 15-2-19.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import "SDBaseProgressView.h"
typedef NS_ENUM(NSInteger, MDProgressDirection) {
    MDProgressDirection_CLOCKWISE = 0, //顺时针
    MDProgressDirection_ANTICLOCKWISE,  //逆时针
    MDProgressDirection_DEFAULT = MDProgressDirection_CLOCKWISE,
};
@interface SDLoopProgressView : SDBaseProgressView
@property(nonatomic,strong)UIColor * color;
@property(nonatomic,assign)CGFloat lineWidth;
@property(nonatomic,assign)MDProgressDirection direction;

@end
