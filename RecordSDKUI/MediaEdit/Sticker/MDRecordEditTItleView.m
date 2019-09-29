//
//  MDRecordEditTItleView.m
//  MomoChat
//
//  Created by RFeng on 2019/4/8.
//  Copyright © 2019年 wemomo.com. All rights reserved.
//

#import "MDRecordEditTItleView.h"
#import "UIButton+Block.h"
//#import "Macro.h"
#import "UIView+Corner.h"
#import "UIConst.h"
#import "UIView+Utils.h"
#import "MDRecordContext.h"

#define KRecordTitleHMargin 28

@interface MDRecordEditTItleView()

@property (nonatomic, strong) NSArray<NSString *> *titlesArray;

@property (nonatomic, strong) UIView *moveLineView;

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, strong) UIButton *selectButton;
@end

@implementation MDRecordEditTItleView


- (instancetype)initWithTitles:(nullable NSArray<NSString *> *)titles
{
    CGRect frame = CGRectMake(0, 0, MDScreenWidth, 50);
    if (self = [super initWithFrame:frame]) {
        self.titlesArray = titles;
        [self layoutUI];
    }
    return self;
}


- (void)layoutUI
{
    [self addSubview:self.moveLineView];
    CGFloat left = KRecordTitleHMargin;
    for (NSString * title in self.titlesArray) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(left, 17, 28, 30);
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:RGBACOLOR(255, 255, 255, 0.3) forState:UIControlStateNormal];
        [button setTitleColor:RGBCOLOR(255, 255, 255)  forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:button];
        [button sizeToFit];
        __weak typeof(self) weakself = self;
        [button addAction:^(UIButton *btn) {
            [UIView animateWithDuration:0.3 animations:^{
                weakself.moveLineView.centerX = btn.centerX;
            }];
            if (weakself.didSelectBlock) {
                weakself.didSelectBlock(title);
            }
        }];
        // 更新下个按钮的起始位置
         left += (button.width + 28);
        [self.buttons addObject:button];
    }
   
    CALayer *bottomLayer = [CALayer layer];
    bottomLayer.frame = CGRectMake(KRecordTitleHMargin, self.height -[MDRecordContext onePX], self.width - KRecordTitleHMargin * 2, [MDRecordContext onePX]);
    bottomLayer.backgroundColor = RGBACOLOR(255, 255, 255, 0.2).CGColor;
    [self.layer addSublayer:bottomLayer];
    
    if (self.buttons.count <= 1) {
        self.moveLineView.hidden = YES;
    }
    [self setSelectIndex:0];
    
}

- (void)setSelectIndex:(NSUInteger)index
{
    if (self.buttons.count > index) {
        UIButton *button = [self.buttons objectAtIndex:index];
        self.selectButton.selected = NO;
        button.selected = YES;
        self.selectButton = button;
    }
}

// 设置右侧按钮
- (void)setRightButtonWithTitle:(NSString *)title  didSelectBlock:(DidSelectBlock)didSelectBlock
{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    [self.rightButton setFrame:CGRectMake(0, 20, 60, self.height)];
    NSString *rightTitle = [NSString stringWithFormat:@" %@",title];
    [self.rightButton setTitle:rightTitle forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"icon_camera_filiter_reset"] forState:UIControlStateNormal];
    [self.rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.rightButton addAction:^(UIButton *btn) {
        if (didSelectBlock) {
            didSelectBlock(title);
        }
    }];
    [self.rightButton sizeToFit];
    self.rightButton.right = self.width - KRecordTitleHMargin;
    [self addSubview:self.rightButton];
}


- (UIView *)moveLineView{
    if (!_moveLineView) {
        _moveLineView = [[UIView alloc]initWithFrame:CGRectMake(28, self.height - 2, 10, 2)];
        [_moveLineView setBackgroundColor:[UIColor whiteColor]];
        
    }
    return _moveLineView;
}

- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}




@end
