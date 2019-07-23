//
//  ExpressionEecorationController.m
//  DEMo
//
//  Created by 姜自佳 on 2017/5/11.
//  Copyright © 2017年 sdk. All rights reserved.
//

#import "MDFaceDecorationView.h"
#import "MDFaceDecorationPageView.h"
#import "MDFaceDecorationClassSelecteView.h"

#import "MDFaceDecorationItem.h"
#import "MDDecorationTool.h"

#import "MDRecordHeader.h"

@interface MDFaceDecorationView () <MDFaceDecorationPageViewDelegate>


@property (nonatomic,strong) MDFaceDecorationPageView          *decorationPageView;
@property (nonatomic,strong) UIPageControl                     *pageControl;
@property (nonatomic,strong) MDFaceDecorationClassSelecteView  *bottomClassSelecteView;
@property (assign,nonatomic) NSInteger currentSelectedSection;

@end

@implementation MDFaceDecorationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bottomClassSelecteView];
        [self addSubview:self.pageControl];
        [self addSubview:self.decorationPageView];
    }
    return self;
}

//更新分类数据源
- (void)updateSelectedViewItems:(NSArray*)array{
    [self.bottomClassSelecteView setClassItems:array];
}

//更新抽屉数据源
- (void)updatePageItems:(NSArray*)array{
    
    NSInteger oldSum = [self getAllPageCountWithArray:self.decorationPageView.dataArray];
    NSInteger newSum = [self getAllPageCountWithArray:array];
    
    self.decorationPageView.dataArray = array;
    [self.decorationPageView reloadData];
    
    NSInteger difference = newSum - oldSum;
    NSInteger currentClassIndex = self.bottomClassSelecteView.currentIndex;
    NSInteger myClassIndex = self.bottomClassSelecteView.myClassIndex;
    if (oldSum != 0 && difference != 0 && myClassIndex != NSNotFound && currentClassIndex>self.bottomClassSelecteView.myClassIndex) {
        //1.原来有数据 2.新旧数据页数不一样 3.有我的分类且当前分类在我的之后
        CGFloat contentOffsetX = self.decorationPageView.contentOffset.x;
        contentOffsetX += difference * self.decorationPageView.width;
        [self.decorationPageView setContentOffset:CGPointMake(contentOffsetX, 0)];
    }
    
    NSArray* arr = [array objectAtIndex:currentClassIndex kindOfClass:[NSArray class]];
    self.pageControl.numberOfPages = [arr count]/kMaxDecorationCount;
}

- (NSInteger)getAllPageCountWithArray:(NSArray<NSArray<MDFaceDecorationItem*>*> *)array {
    NSInteger sum = 0;
    for (int i=0; i<array.count; i++) {
        NSArray* subArr = [array objectAtIndex:i kindOfClass:[NSArray class]];
        sum += subArr.count;
    }
    return sum / kMaxDecorationCount;
}

- (void)setSelectedClassWithIdentifier:(NSString *)identifer {
    NSInteger index = 0;
    for (int i=0; i<self.bottomClassSelecteView.classItems.count; i++) {
        MDFaceDecorationClassItem *classItem = [self.bottomClassSelecteView.classItems objectAtIndex:i defaultValue:nil];
        if ([classItem.identifier isEqualToString:identifer]) {
            index = i;
            break;
        }
    }
    [self setSelectedClassWithIndex:index];
}

- (void)setSelectedClassWithIndex:(NSInteger)index {
    if (index<0 || index>= self.bottomClassSelecteView.classItems.count) {
        return;
    }
    [self.bottomClassSelecteView setCurrentButtonIndex:index];
    [self updatePageControlWithIndex:index];
    if ([self.decorationPageView numberOfItemsInSection:index] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:index];
        [self.decorationPageView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

#pragma mark - private

- (void)updatePageControlWithIndex:(NSInteger)index{
    self.currentSelectedSection = index;
    NSArray* arr = [self.decorationPageView.dataArray objectAtIndex:index kindOfClass:[NSArray class]];
    self.pageControl.numberOfPages =  arr.count/kMaxDecorationCount;
    self.pageControl.currentPage = 0;
}

#pragma mark - MDFaceDecorationPageViewDelegate

- (void)faceDecorationPageView:(MDFaceDecorationPageView *)pageView
                     indexPath:(NSIndexPath *)indexPath
                     withModel:(MDFaceDecorationItem *)cellModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceDecorationPageView:indexPath:withModel:)]) {
        [self.delegate faceDecorationPageView:pageView indexPath:indexPath withModel:cellModel];
    }
}

- (void)faceDecorationPageViewDidEndDecelerating:(UIScrollView *)pageView
                                  currentSection:(NSInteger)currentSection
                                       pageCount:(NSInteger)pageCount
                                currentPageIndex:(NSInteger)currentPageIndex {
    
    //设置pageControl
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.currentPage = currentPageIndex;
    
    //设置bottomClassSelecteView
    if (self.currentSelectedSection == currentSection) {
        return;
    }
    self.currentSelectedSection = currentSection;
    [self.bottomClassSelecteView setCurrentButtonIndex:currentSection];
}

#pragma mark - lazy

- (MDFaceDecorationClassSelecteView *)bottomClassSelecteView{
    if(!_bottomClassSelecteView){
        _bottomClassSelecteView = [[MDFaceDecorationClassSelecteView alloc] initWithFrame:CGRectMake(0, 0, self.width, 50)];
        _bottomClassSelecteView.bottom = self.height - HOME_INDICATOR_HEIGHT;
        
        __weak typeof(self) weakSelf = self;
        //点击某个分类
        [_bottomClassSelecteView setClickCompeletionHandler:^(UIButton *button, NSInteger index){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf updatePageControlWithIndex:index];
            
            if ([weakSelf.decorationPageView numberOfItemsInSection:index] > 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:index];
                [strongSelf.decorationPageView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            }
        }];
        
        //清除变脸
        [_bottomClassSelecteView setClearDecorationBlock:^(UIButton *button){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(faceDecorationViewCleanDecoration:)]) {
                [strongSelf.delegate faceDecorationViewCleanDecoration:strongSelf];
            }
        }];
    }
    return _bottomClassSelecteView;
}

- (UIPageControl *)pageControl {
    
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, self.width, 20)];
        _pageControl.bottom = self.bottomClassSelecteView.top;
        _pageControl.currentPage = 0;
        _pageControl.pageIndicatorTintColor        = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        _pageControl.currentPageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    }
    return _pageControl;
}

- (MDFaceDecorationPageView *)decorationPageView {
    if (_decorationPageView == nil) {
        CGSize itemSize = CGSizeMake(MDScreenWidth/kDecorationsColCount, 90);
        _decorationPageView = [[MDFaceDecorationPageView alloc] initWithItemSize:itemSize];
        _decorationPageView.frame = CGRectMake(0, 0, self.width, self.pageControl.top);
        _decorationPageView.pageDelegate = self;
    }
    return _decorationPageView;
}

- (UICollectionView *)collectionView{
    return self.decorationPageView;
}

@end
