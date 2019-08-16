//
//  MDFilterSegmentView.m
//  MomoChat
//
//  Created by YZK on 2019/4/10.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "MDFilterSegmentView.h"
#import "MDRecordMacro.h"


@interface MDFilterSegmentView ()
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;
@property (nonatomic, strong) UIView *moveLineView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation MDFilterSegmentView

- (instancetype)initWithOrigin:(CGPoint)origin title:(NSArray<NSString *> *)titles
{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, MDScreenWidth, 50)];
    if (self) {
        self.currentIndex = -1;
        [self layoutWithTitles:titles];
    }
    return self;
}

- (void)layoutWithTitles:(NSArray<NSString *> *)titles {
    for (int i = 0; i < titles.count; i++) {
        UIButton *button = [self createButtonWithTitle:titles[i] index:i];
        button.selected = i == 0;
        [self.buttons addObject:button];
        [self addSubview:button];
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(MDScreenWidth-55-20, 0, 55, 48);
        [button setTitle:@" 重置" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"icon_camera_filiter_reset"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(resetButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 50, MDScreenWidth-15*2, 0.5)];
    lineView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.1];
    [self addSubview:lineView];
    self.lineView = lineView;
    
    if (titles.count > 1) {
        UIView *moveLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 48, 6, 2)];
        moveLineView.backgroundColor = UIColor.whiteColor;
        moveLineView.layer.cornerRadius = 0.5;
        moveLineView.layer.masksToBounds = YES;
        [self addSubview:moveLineView];
        self.moveLineView = moveLineView;
    }
    
    [self setSelectedIndex:0];
}

- (UIButton *)createButtonWithTitle:(NSString *)title index:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20+(32+20)*index, 0, 32, 48);
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [button setTitleColor:[UIColor.whiteColor colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonClicked:(UIButton *)button {
    NSInteger oldIndex = self.currentIndex;
    self.currentIndex = [self.buttons indexOfObject:button];
    if (self.currentIndex == oldIndex) {
        return;
    }
    
    for (UIButton *aButton in self.buttons) {
        aButton.selected = button == aButton;
    }
    self.titleButtonClicked ? self.titleButtonClicked(self.currentIndex) : nil;
    
    CGPoint center = [button convertPoint:button.center toView:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.moveLineView.centerX = center.x;
    }];
}

- (void)resetButtonDidClicked {
    self.resetButtonClicked ? self.resetButtonClicked(self.currentIndex) : nil;
}

- (void)setSelectedIndex:(NSInteger)index {
    if (index >= self.buttons.count) {
        return;
    }
    UIButton *selectedButton = [self.buttons objectAtIndex:index defaultValue:nil];
    [self buttonClicked:selectedButton];
}

- (NSMutableArray<UIButton *> *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

@end
