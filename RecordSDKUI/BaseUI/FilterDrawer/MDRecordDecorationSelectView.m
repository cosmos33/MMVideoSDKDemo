//
//  MDRecordDecorationTabView.m
//  DecorationFilterDEMO
//
//  Created by 姜自佳 on 2017/6/2.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDRecordDecorationSelectView.h"
#import "UIConst.h"

#define  selectedColor    RGBACOLOR(0, 192.f,  255.f,  1)
#define  deSelectedColor  RGBACOLOR(255.f, 255.f, 255.f, .6f)

static CGFloat   seperatorLineHeight = 16.0;
static CGFloat   kItemFont           = 15.0;
static NSInteger kBaseTag            = 9990;

@interface MDRecordDecorationSelectView()
@property (nonatomic,strong) UIButton *currentButton;
@property (nonatomic,strong) UIScrollView * selectScrollView;

@end
@implementation MDRecordDecorationSelectView


#pragma mark -- 视图添加
- (void)addItems:( NSArray<NSString *> *)items
{
    if(!items.count){
        return;
    }
    
    NSInteger count = items.count;
    CGFloat itemWidth = MDScreenWidth/count;
    UIScrollView* scrollView = self.selectScrollView;
    [self addSubview:scrollView];
    
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger i = 0; i<count; i++) {
        
        UIView* item = [self itemWithIndex:i dataArray:items];
        [scrollView addSubview:item];
        item.frame = CGRectMake(i*itemWidth, 0, itemWidth, self.frame.size.height);
        [self addSeparatorLineWithItem:item];
    }
    scrollView.contentSize = CGSizeMake(itemWidth*count, 0);
}

#pragma mark -- creatge itemviews
- (UIView*)itemWithIndex:(NSInteger)index dataArray:(NSArray*)dataArray{
    
    NSString* title = dataArray[index];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    
    UIColor *tintColor = self.tintColor ?  self.tintColor : selectedColor;
    [button setTitleColor:tintColor forState:UIControlStateSelected];
    [button setTitleColor:deSelectedColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:kItemFont];
    button.tag = kBaseTag + index;
    [button addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}


- (void)addSeparatorLineWithItem:(__kindof UIView*)item{
    
    UIView* leftLineView = [UIView new];
    [self.selectScrollView addSubview:leftLineView];
    leftLineView.backgroundColor = RGBACOLOR(216, 216, 216, 0.15);
    leftLineView.frame = CGRectMake(item.frame.origin.x, 0.5*(item.frame.size.height-seperatorLineHeight), 0.5, seperatorLineHeight);
}

- (void)selectItem:(UIButton*)sender{
    
    NSInteger selectedIndex = sender.tag-kBaseTag;

    if(self.didSelectedItemBlock){
        self.didSelectedItemBlock(selectedIndex);
    }
    
    [self setCurrentSelectedIndex:selectedIndex];
}


- (void)setCurrentSelectedIndex:(NSInteger)index {
    
    UIButton *button = [self.selectScrollView viewWithTag:(kBaseTag + index)];
    if (self.currentButton == button) {
        return;
    }
    self.currentButton.selected = NO;
    self.currentButton.titleLabel.font = [UIFont systemFontOfSize:kItemFont];
    
    button.selected = YES;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:kItemFont];
    self.currentButton = button;
}


- (NSInteger)currentSelectedIndex
{
    if (self.currentButton == nil) {
        return -1;
    }
    
    return (self.currentButton.tag - kBaseTag);
}

#pragma mark --lazy
- (UIScrollView *)selectScrollView{
    if(!_selectScrollView){
        _selectScrollView = [UIScrollView  new];
        _selectScrollView.showsHorizontalScrollIndicator = NO;
        _selectScrollView.showsVerticalScrollIndicator = NO;
        _selectScrollView.frame = self.bounds;
        [self addSubview:_selectScrollView];
    }
    return _selectScrollView;
}


@end
