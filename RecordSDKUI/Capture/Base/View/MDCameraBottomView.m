//
//  MDCameraButtomView.m
//  RecordScrollerViewTest
//
//  Created by lm on 2017/6/9.
//  Copyright © 2017年 lm. All rights reserved.
//

#import "MDCameraBottomView.h"

static const NSInteger kButtonBaseTag = 3700;

@interface MDCameraBottomView ()

@property (nonatomic, strong) UIButton              *firstButton;
@property (nonatomic, strong) UIButton              *secondButton;
@property (nonatomic, strong) UIButton              *thirdButton;

@property (nonatomic, strong) UIView                *buttonsView;
@property (nonatomic, strong) NSMutableArray        *availableTapArray;

@property (nonatomic, strong) NSMutableArray        *buttonList;

@property (nonatomic, strong) UIView                *tipView;

@property (nonatomic, assign) CGFloat               buttonsViewOrignX;

@property (nonatomic, strong) UIView                *backGroundView;

@property (nonatomic, assign) MDUnifiedRecordLevelType   currentButtonTap;

@end

@implementation MDCameraBottomView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.backGroundView];
        [self addSubview:self.buttonsView];
        [self addSubview:self.tipView];
        
        self.buttonList = [NSMutableArray array];
        [self.buttonList addObjectSafe:self.firstButton];
        [self.buttonList addObjectSafe:self.secondButton];
        [self.buttonList addObjectSafe:self.thirdButton];
        
        self.availableTapArray = [NSMutableArray array];
    }
    
    return self;
}

//构建更新相关视图
- (void)setAvailableTapList:(NSArray*)availableTaps {

    CGFloat startX = 0;
    for (NSNumber *tap in availableTaps) {
    
        if (![tap isKindOfClass:[NSNumber class]]) {
            continue;
        }
        
        NSInteger tapIndex = [tap integerValue];
        UIButton *button = [self.buttonList objectAtIndex:tapIndex defaultValue:nil];
        if (button) {
            button.left = startX;
            [_buttonsView addSubview:button];
            button.tag  = kButtonBaseTag + tapIndex;
            startX = button.right + 25;
            [self.availableTapArray addObjectSafe:tap];
        }
    }
    _buttonsView.width = startX - 25;
}

- (void)updateLayoutWithSelectedTap:(MDUnifiedRecordLevelType)aTapType {
    
    if (![self.availableTapArray containsObject:@(aTapType)]) {
        return;
    }
    
    self.currentButtonTap = aTapType;
    
    //调整默认button到view 中间
    UIButton *currentButton = [self.buttonList objectAtIndex:_currentButtonTap defaultValue:nil];
    
    CGFloat offset = self.width/2 - currentButton.centerX;
    self.buttonsViewOrignX = offset;
    
    [UIView animateWithDuration:0.1f animations:^{
        
        self.buttonsView.left = self.buttonsViewOrignX;
        
    } completion:^(BOOL finished) {
        
        for (int i=0; i<self.buttonList.count; i++) {
            
            UIButton *button = self.buttonList[i];
            if (i == _currentButtonTap) {
                [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
            }
        }
    }];
    
    [self layoutBackGroundView];
}

- (MDUnifiedRecordLevelType)getPreLevelType {
    
    //tapIndex 表示当前tap 在 tapList中的位置
    NSInteger tapIndex = -1;
    int i = 0;
    for (i=0; i<_availableTapArray.count; i++) {
        
        if (_currentButtonTap == [_availableTapArray[i] integerValue]) {
            tapIndex = i;
        }
    }
    
    NSNumber *preTapNum = [_availableTapArray objectAtIndex:(tapIndex-1) defaultValue:nil];
    if (!preTapNum) {
        preTapNum = @(_currentButtonTap);
    }
    
    return [preTapNum integerValue];
}

- (MDUnifiedRecordLevelType)getNextLevelType {

    //tapIndex 表示当前tap 在 tapList中的位置
    NSInteger tapIndex = _availableTapArray.count;
    for (int i=0; i<_availableTapArray.count; i++) {
        
        if (_currentButtonTap == [_availableTapArray[i] integerValue]) {
            tapIndex = i;
        }
    }
    
    NSNumber *nextTapNum = [_availableTapArray objectAtIndex:(tapIndex+1) defaultValue:nil];
    if (!nextTapNum) {
        nextTapNum = @(_currentButtonTap);
    }
    
    return [nextTapNum integerValue];
}

- (MDUnifiedRecordLevelType)getCurrentLevelType {
    return _currentButtonTap;
}

-(void)viewDidScroll:(CGFloat)scaleValue {
    
    CGFloat myViewOffset = 60*scaleValue;
    
    self.buttonsView.left = self.buttonsViewOrignX + myViewOffset;
}

- (void)layoutBackGroundView {

    //底部背景
    CGFloat finalTop = 0;
    if (_currentButtonTap != MDUnifiedRecordLevelTypeAsset) {
        finalTop = self.height;
    }
    
    [UIView animateWithDuration:0.1f animations:^{
        self.backGroundView.top = finalTop;
    }];
}

-(void)viewEndScroll:(CGFloat)scaleValue {
    
    CGFloat myViewOffset = scaleValue * 80;
    
    self.buttonsViewOrignX += myViewOffset;
    
    [UIView animateWithDuration:0.1f animations:^{
        self.buttonsView.left = self.buttonsViewOrignX;
    }];
}

-(UIButton *)firstButton {
    
    if (!_firstButton) {
        _firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_firstButton setTitle:@"相册" forState:UIControlStateNormal];
        [_firstButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_firstButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _firstButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _firstButton.frame = CGRectMake(0, 0, 32, 22);
        [_firstButton addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _firstButton;
}

-(UIButton *)secondButton {
    
    if (!_secondButton) {
        _secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_secondButton setTitle:@"拍照" forState:UIControlStateNormal];
        [_secondButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_secondButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _secondButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_secondButton sizeToFit];
        [_secondButton addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];

        _secondButton.frame = CGRectMake(self.firstButton.right+25, 0, 32, self.firstButton.height);
    }
    
    return _secondButton;
}

-(UIButton *)thirdButton {
    if (!_thirdButton) {
        _thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_thirdButton setTitle:@"拍视频" forState:UIControlStateNormal];
        [_thirdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_thirdButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_thirdButton sizeToFit];
        _thirdButton.frame = CGRectMake(self.secondButton.right+25, 0, 65, self.secondButton.height);
        [_thirdButton addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _thirdButton;
}

- (void)didClickButton:(UIButton*)button {

    if ([_delegate respondsToSelector:@selector(didClicButtonWithType:)]) {
        [_delegate didClicButtonWithType:(button.tag-kButtonBaseTag)];
    }
}

-(UIView *)tipView {
    
    if (!_tipView) {
        _tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 6.5)];
        if (IS_IPHONE_X) {
            _tipView.size = CGSizeMake(7, 3);
        }
        _tipView.centerX = self.width/2;
        _tipView.bottom = self.height - SAFEAREA_BOTTOM_MARGIN;
        _tipView.backgroundColor = [UIColor whiteColor];
    }
    
    return _tipView;
}

-(UIView *)buttonsView {
    
    if (!_buttonsView) {
        _buttonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 13, self.width, self.firstButton.height)];
    }
    
    return _buttonsView;
}

-(UIView*)backGroundView {
    
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backGroundView.backgroundColor = [UIColor blackColor];
    }
    
    return _backGroundView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
