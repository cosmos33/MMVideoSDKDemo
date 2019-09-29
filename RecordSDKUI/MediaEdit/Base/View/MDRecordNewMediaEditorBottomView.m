//
//  MDRecordNewMediaEditorBottomView.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/19.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordNewMediaEditorBottomView.h"
#import "MDRecordNewMediaEditorBottomCell.h"

@interface  MDRecordNewMediaEditorBottomView ()

@property (nonatomic, copy) NSArray<NSString *> *titles;
@property (nonatomic, copy) NSArray<NSString *> *imageNames;

@end

@implementation MDRecordNewMediaEditorBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    NSArray<NSString *> *titles = @[@"滤镜", @"配乐", @"贴纸", @"文字", @"涂鸦", @"封面", @"变速", @"特效", @"人像"];
    NSArray<NSString *> *imageNames = @[@"editFilters", @"editMusic", @"editStiker", @"editText", @"editDraw", @"editThumbImage", @"editSpeedVary", @"editSpecial", @"editPersonalImage"];
    return [self initWithFrame:frame titles:titles imageNames:imageNames];
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles imageNames:(NSArray<NSString *> *)imageNames {
    self = [super initWithFrame:frame];
    if (self) {
        _titles = titles;
        _imageNames = imageNames;
        
        [self configUI];
    }
    return self;
}

- (void)configUI {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentInset = UIEdgeInsetsMake(0, 20.5, 0, 20.5);
    [self addSubview:scrollView];
    
    NSMutableArray<UIImage *> *images = [NSMutableArray array];
    for (NSString *imageName in self.imageNames) {
        [images addObject:[UIImage imageNamed:imageName]];
    }
    
    __weak typeof(self) weakself = self;
    NSMutableArray<MDRecordNewMediaEditorBottomCell *> *cells = [NSMutableArray array];
    for (int i = 0; i < images.count; i ++) {
        NSString *title = self.titles[i];
        UIImage *image = images[i];
        MDRecordNewMediaEditorBottomCell *cell = [[MDRecordNewMediaEditorBottomCell alloc] init];
        cell.translatesAutoresizingMaskIntoConstraints = NO;
        cell.title = title;
        cell.contentImage = image;
        cell.tapCallBack = ^(MDRecordNewMediaEditorBottomCell * _Nonnull cell) {
            __strong typeof(self) strongself = weakself;
            [strongself.delegate buttonClicked:strongself title:cell.title];
        };
        [cells addObject:cell];
    }
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:cells];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.spacing = 8;
    [scrollView addSubview:stackView];
    
    [scrollView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [scrollView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [scrollView.heightAnchor constraintEqualToConstant:103].active = YES;
    
    for (UIView *cell in cells) {
        [cell.widthAnchor constraintEqualToConstant:58.5].active = YES;
    }
    
    [stackView.leftAnchor constraintEqualToAnchor:scrollView.leftAnchor].active = YES;
    [stackView.rightAnchor constraintEqualToAnchor:scrollView.rightAnchor].active = YES;
    [stackView.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor].active = YES;
    [stackView.topAnchor constraintEqualToAnchor:scrollView.topAnchor].active = YES;
    [stackView.heightAnchor constraintEqualToAnchor:scrollView.heightAnchor].active = YES;
}

@end
