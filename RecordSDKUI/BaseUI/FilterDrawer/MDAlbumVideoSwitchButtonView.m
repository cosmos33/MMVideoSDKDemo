//
//  MDAlbumVideoSwitchButtonView.m
//  MDAlbumVideo
//
//  Created by sunfei on 2018/9/6.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "MDAlbumVideoSwitchButtonView.h"

@interface MDAlbumVideoSwitchButtonView()

@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;
@property (nonatomic, strong) UIView *moveLineView;
//@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIStackView *hStackView;

@property (nonatomic, strong) NSLayoutConstraint *moveLineLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *moveLineWidthConstraint;

@end

@implementation MDAlbumVideoSwitchButtonView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (NSMutableArray<UIButton *> *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (void)setupUI {
    
//    UIView *lineView = [[UIView alloc] init];
//    lineView.translatesAutoresizingMaskIntoConstraints = NO;
//    lineView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.1];
//    [self addSubview:lineView];
//    self.lineView = lineView;
    
    UIView *moveLineView = [[UIView alloc] init];
    moveLineView.translatesAutoresizingMaskIntoConstraints = NO;
    moveLineView.backgroundColor = UIColor.whiteColor;
    [self.hStackView addSubview:moveLineView];
    self.moveLineView = moveLineView;
    
//    [lineView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
//    [lineView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
//    [lineView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
//    [lineView.heightAnchor constraintEqualToConstant:1.0 / [UIScreen mainScreen].scale].active = YES;
    
    UIView *firstArrangedView = self.hStackView.arrangedSubviews.firstObject;
//    self.moveLineLeftConstraint = [moveLineView.leftAnchor constraintEqualToAnchor:firstArrangedView.leftAnchor];
    self.moveLineLeftConstraint = [moveLineView.centerXAnchor constraintEqualToAnchor:firstArrangedView.centerXAnchor];
    self.moveLineLeftConstraint.active = YES;
    [moveLineView.heightAnchor constraintEqualToConstant:2.0].active = YES;
    self.moveLineWidthConstraint = [moveLineView.widthAnchor constraintEqualToConstant:10];
    self.moveLineWidthConstraint.active = YES;
//    [moveLineView.bottomAnchor constraintEqualToAnchor:lineView.topAnchor].active = YES;
    [moveLineView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [self layoutIfNeeded];
}

- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [button setTitleColor:[UIColor.whiteColor colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonClicked:(UIButton *)button {
    
    for (UIButton *aButton in self.buttons) {
        aButton.selected = button == aButton;
    }
    
    self.titleButtonClicked ? self.titleButtonClicked(self, [self.buttons indexOfObject:button]) : nil;
    
    self.moveLineLeftConstraint.active = NO;
//    self.moveLineWidthConstraint.active = NO;
    
    self.moveLineLeftConstraint = [self.moveLineView.centerXAnchor constraintEqualToAnchor:button.centerXAnchor];
//    self.moveLineWidthConstraint = [self.moveLineView.widthAnchor constraintEqualToAnchor:button.widthAnchor];
    
    self.moveLineLeftConstraint.active = YES;
//    self.moveLineWidthConstraint.active = YES;
    
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:0.3 animations:^{
        __strong typeof(self) strongself = weakself;
        [strongself layoutIfNeeded];
    }];
}

- (void)setTitles:(NSArray<NSString *> *)titles {
    _titles = titles;
    
    for (int i = 0; i < titles.count; i++) {
        UIButton *button = [self createButtonWithTitle:titles[i]];
        button.selected = i == 0;
        [self.buttons addObject:button];
    }
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:self.buttons];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.spacing = 28;
    stackView.layoutMargins = UIEdgeInsetsMake(0, 14, 0, 14);
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.alignment = UIStackViewAlignmentFill;
    [self addSubview:stackView];
    self.hStackView = stackView;

    [stackView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [stackView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    
    [self setupUI];
}

- (void)setSelectedIndex:(NSInteger)index {
    if (index >= self.buttons.count) {
        return;
    }
    UIButton *selectedButton = self.buttons[index];
    [self buttonClicked:selectedButton];
}

- (NSInteger)currentSelectedIndex {
    for (UIButton *aButton in self.buttons) {
        if (aButton.selected) {
            return [self.buttons indexOfObject:aButton];
        }
    }
    return 0;
}

@end
