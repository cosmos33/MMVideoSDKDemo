//
//  MDFaceDecorationClassSelecteView.m
//  DEMO
//
//  Created by 姜自佳 on 2017/5/7.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDFaceDecorationClassSelecteView.h"
#import "MDFaceDecorationItem.h"
#import "UIView+MDSpringAnimation.h"
#import "SDWebImage/UIButton+WebCache.h"
#import "MDRecordHeader.h"

static const CGFloat kItemWidth = 60;
static const CGFloat kBottomImageViewWidth = 27;//button.imageView 的大小

@interface MDFaceDecorationClassSelecteView ()

@property (nonatomic, strong) UIScrollView *selectScrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *leftSeparationView;
@property (nonatomic, strong) UIView *topLineView;


// 记录选中按钮
@property (nonatomic, strong) UIButton *currentButton;
@property (nonatomic, strong) UIButton *cleanButton;

@end

@implementation MDFaceDecorationClassSelecteView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cleanButton];
        [self addSubview:self.selectScrollView];
        [self.selectScrollView addSubview:self.containerView];
        
        [self addSubview:self.leftSeparationView];
        [self addSubview:self.topLineView];
    }
    return self;
}

#pragma mark - public method

- (void)setClassItems:(NSArray<MDFaceDecorationClassItem *> *)classItems {
    _classItems = classItems;
    NSInteger count = classItems.count;

    [self.containerView removeAllSubviews];
    
    CGFloat width = 0;
    CGFloat leftPadding = 14;
    for (int i=0; i<count; i++) {
        MDFaceDecorationClassItem *item = classItems[i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(width, 0, kItemWidth, self.height);
        
        CGFloat topEdge = (button.height-kBottomImageViewWidth)/2.0;
        CGFloat leftEdge = (button.width-kBottomImageViewWidth)/2.0;
        button.imageEdgeInsets = UIEdgeInsetsMake(topEdge, leftEdge, topEdge, leftEdge);
        
        [button addTarget:self
                   action:@selector(classBtnDidClick:)
         forControlEvents:UIControlEventTouchUpInside];
        
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        if ([item.name isNotEmpty]) {
            [button setTitle:item.name forState:UIControlStateNormal];
            [button setTitleColor:RGBACOLOR(255, 255, 255, 0.4) forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            
            CGFloat width = [item.name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:button.titleLabel.font} context:nil].size.width;
            width = ceil(width) + 36;
            button.width = width;
            button.left += leftPadding;
        }else {
            if ([item.identifier isEqualToString:kFaceClassIndentifierOfMy]) {
                [button setImage:[UIImage imageNamed:item.imgUrlStr] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:item.selectedImgUrlStr] forState:UIControlStateSelected];
            }else {
                [button sd_setImageWithURL:[NSURL URLWithString:item.imgUrlStr]
                                  forState:UIControlStateNormal
                          placeholderImage:nil
                                   options:SDWebImageRetryFailed];
                [button sd_setImageWithURL:[NSURL URLWithString:item.selectedImgUrlStr]
                                  forState:UIControlStateSelected
                          placeholderImage:nil
                                   options:SDWebImageRetryFailed];
            }
        }
        width += button.width;
        [self.containerView addSubview:button];
    }
    
    self.selectScrollView.contentSize = CGSizeMake(width+leftPadding*2, self.height);
    self.containerView.size = self.selectScrollView.contentSize;
    
    [self setCurrentButtonIndex:0];
}


- (NSInteger)currentIndex
{
    return [self.containerView.subviews indexOfObject:self.currentButton];
}

- (void)setCurrentButtonIndex:(NSInteger)index
{
    UIButton *button = [self.containerView.subviews objectAtIndex:index defaultValue:nil];
    if (!button) {
        return;
    }
    
    if (self.currentButton == button) {
        return;
    }
    [self setContentOffsetWithButton:button];
    
    self.currentButton.selected = NO;
    button.selected = YES;
    self.currentButton = button;
}

- (NSInteger)myClassIndex {
    for (MDFaceDecorationClassItem *item in self.classItems) {
        if ([item.identifier isEqualToString:kFaceClassIndentifierOfMy]) {
            return [self.classItems indexOfObject:item];
        }
    }
    return NSNotFound;
}

#pragma mark - private method


- (void)setContentOffsetWithButton:(UIButton *)sender
{
    UIScrollView *scrollView = self.selectScrollView;
    
    CGFloat offsetX = 0;
    if (sender.left < scrollView.contentOffset.x) {
        offsetX = sender.frame.origin.x - scrollView.contentOffset.x;
    } else if (CGRectGetMaxX(sender.frame) > CGRectGetMaxX(scrollView.bounds)) {
        offsetX = CGRectGetMaxX(sender.frame) - CGRectGetMaxX(scrollView.bounds);
    }
    
    if (offsetX == 0) {
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint originOffSet = scrollView.contentOffset;
        originOffSet.x = originOffSet.x + offsetX;
        scrollView.contentOffset = originOffSet;
    }];
}

- (void)setCurrentButton:(UIButton *)currentButton
{
    if ([currentButton.titleLabel.text isNotEmpty]) {
        _currentButton = currentButton;
    }else {
        _currentButton.backgroundColor = currentButton.superview.backgroundColor;
        _currentButton = currentButton;
        _currentButton.backgroundColor = [RGBCOLOR(255, 255, 255) colorWithAlphaComponent:0.07];
    }
}

#pragma mark - event method

- (void)classBtnDidClick:(UIButton *)sender
{
    [sender.imageView springAnimation];
    
    if (self.currentButton == sender) {
        return;
    }
    
    [self setContentOffsetWithButton:sender];
    
    self.currentButton.selected = NO;
    sender.selected = YES;
    self.currentButton = sender;
    
    if (self.clickCompeletionHandler) {
        self.clickCompeletionHandler(sender,[self currentIndex]);
    }
}

//清除变脸
- (void)cleanButtonDidClicked:(UIButton *)sender
{
    [sender.imageView springAnimation];
    if (self.clearDecorationBlock) {
        self.clearDecorationBlock(sender);
    }
}

#pragma mark - UI

- (UIButton *)cleanButton
{
    if (!_cleanButton) {
        _cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cleanButton.frame = CGRectMake(0, 0, kItemWidth, self.height);
        
        CGFloat topEdge = (_cleanButton.height-20)/2.0;
        CGFloat leftEdge = (_cleanButton.width-20)/2.0;
        _cleanButton.imageEdgeInsets = UIEdgeInsetsMake(topEdge, leftEdge, topEdge, leftEdge);
        
        [_cleanButton setImage:[UIImage imageNamed:@"icon_moment_revoke_face_decoration"]
                      forState:UIControlStateNormal];
        [_cleanButton setImage:[UIImage imageNamed:@"icon_moment_revoke_face_decoration"]
                      forState:UIControlStateSelected | UIControlStateHighlighted];
        [_cleanButton setAdjustsImageWhenHighlighted:NO];
        
        [_cleanButton addTarget:self
                         action:@selector(cleanButtonDidClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanButton;
}

- (UIScrollView *)selectScrollView
{
    if (!_selectScrollView) {
        _selectScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.cleanButton.right, 0, self.width-self.cleanButton.right, self.height)];
        _selectScrollView.showsHorizontalScrollIndicator = NO;
        _selectScrollView.showsVerticalScrollIndicator = NO;
    }
    return _selectScrollView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _containerView;
}


//分割线view
- (UIView *)leftSeparationView
{
    if (!_leftSeparationView) {
        _leftSeparationView = [[UIView alloc] initWithFrame:CGRectMake(self.cleanButton.right, 0, 1, 20)];
        _leftSeparationView.centerY = self.cleanButton.centerY;
        _leftSeparationView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    }
    return _leftSeparationView;
}

//分割线view
- (UIView *)topLineView
{
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
        _topLineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    }
    return _topLineView;
}

@end
