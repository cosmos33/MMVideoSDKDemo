//
//  MUAt8AlertBarModel.h
//  RecordSDK
//
//  Created by Aaron on 16/7/28.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAlertBarModel.h"
#import <UIKit/UIKit.h>

//生成的控件为透明的mask（可点击触发关闭的区域）和它上面的蓝色气泡
typedef enum {
    MUAt8AnchorTypeTop,//尖角出现在气泡上面
    MUAt8AnchorTypeBottom,//尖角出现在气泡下面
    MUAt8AnchorTypeLeft,//尖角出现在气泡左面
    MUAt8AnchorTypeRight//尖角出现在气泡右面
}MUAt8AnchorType;

@interface MUAt8AlertBarModel : MUAlertBarModel

@property (nonatomic, copy) NSString                *title;
@property (nonatomic, copy) AlertBarDidClickBlock   closeBlock;//点击退出触发

@property (nonatomic, assign) CGRect                maskFrame;//透明遮罩（可点击触发关闭的区域）的frame，
@property (nonatomic, assign) CGPoint               anchorPoint;//mask上气泡尖角需对其的点

@property (nonatomic, assign) MUAt8AnchorType       anchorType;
@property (nonatomic, assign) CGFloat               anchorOffset;//尖角相对于气泡中心点的offset，自动处理越界

@property (nonatomic, strong) UIColor               *textColor;//文字颜色
@property (nonatomic, strong) UIColor               *backgroundColor;//引导条背景色

/// 圆角上限暂没做处理, 如果不设置该值, 会保持默认值.
@property (nonatomic, assign) CGFloat cornerRadius;

@end
