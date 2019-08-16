//
//  MDAlbumVideoDynamicEffectSelectView.m
//  MDAlbumVideo
//
//  Created by sunfei on 2018/9/7.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "MDAlbumVideoDynamicEffectSelectView.h"
#import "MDAlbumVideoDynamicEffectCollectionViewCell.h"

@interface MDAlbumVideoDynamicEffectSelectView()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *hStackView;
@property (nonatomic, strong) NSMutableArray<MDAlbumVideoDynamicEffectCollectionViewCell *> *cells;

@end

@implementation MDAlbumVideoDynamicEffectSelectView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setModels:(NSArray<MDAlbumVideoDynamicEffectModel *> *)models {
    if (_models == models) {
        return;
    }
    
    _models = models;
    
    [self updateUI];
}

- (NSMutableArray<MDAlbumVideoDynamicEffectCollectionViewCell *> *)cells {
    if (!_cells) {
        _cells = [NSMutableArray array];
    }
    return _cells;
}

- (void)updateUI {
    if (self.scrollView.superview) {
        [self.scrollView removeFromSuperview];
    }
    
    UIScrollView *scrollView = ({
        UIScrollView *view = [[UIScrollView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        
        [view.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [view.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [view.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
        [view.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
        
        view.contentInset = UIEdgeInsetsMake(0, 28, 0, 28);
        
        view;
    });
    self.scrollView = scrollView;
    
    MDAlbumVideoDynamicEffectCollectionViewCell *(^createCell)(MDAlbumVideoDynamicEffectModel *) = ^(MDAlbumVideoDynamicEffectModel *model){
        MDAlbumVideoDynamicEffectCollectionViewCell *cell = [[MDAlbumVideoDynamicEffectCollectionViewCell alloc] init];
        cell.translatesAutoresizingMaskIntoConstraints = NO;
        cell.cellModel = model;
        __weak typeof(self) weakself = self;
        cell.tapCallBack = ^(MDAlbumVideoDynamicEffectCollectionViewCell *tappedCell) {
            __strong typeof(self) strongself = weakself;
            for (MDAlbumVideoDynamicEffectCollectionViewCell *cell in strongself.cells) {
                cell.selected = tappedCell == cell;
            }
            strongself.tapCell ? strongself.tapCell(strongself, strongself.models[[strongself.cells indexOfObject:tappedCell]]) : nil;
        };
        return cell;
    };
    
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray array];
    for (MDAlbumVideoDynamicEffectModel *model in self.models) {
        MDAlbumVideoDynamicEffectCollectionViewCell *cell = createCell(model);
        [constraints addObject:[cell.widthAnchor constraintEqualToConstant:60]];
        [constraints addObject:[cell.heightAnchor constraintEqualToConstant:84]];
        [self.cells addObject:cell];
    }
    
    self.hStackView = ({
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:self.cells];
        stackView.translatesAutoresizingMaskIntoConstraints = NO;
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.spacing = 10;
        stackView.alignment = UIStackViewAlignmentCenter;
        stackView.distribution = UIStackViewDistributionFillEqually;
        [scrollView addSubview:stackView];
        
        [stackView.leftAnchor constraintEqualToAnchor:scrollView.leftAnchor].active = YES;
        [stackView.topAnchor constraintEqualToAnchor:scrollView.topAnchor].active = YES;
        [stackView.rightAnchor constraintEqualToAnchor:scrollView.rightAnchor].active = YES;
        [stackView.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor].active = YES;
        [stackView.heightAnchor constraintLessThanOrEqualToAnchor:scrollView.heightAnchor].active = YES;
        
        stackView;
    });
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)selectedAnimationType:(NSString *)animationType {
    [self setCurrentAnimationType:animationType];
//
//    int i = 0;
//    for (; i < self.models.count; ++ i) {
//        if ([self.models[i].animationType isEqualToString:animationType]) {
//            break;
//        }
//    }
//
//    MDAlbumVideoDynamicEffectCollectionViewCell *selectedCell = self.cells[i % self.cells.count];
//    [selectedCell tapAction:nil];
}

- (void)setCurrentAnimationType:(NSString *)currentAnimationType {
    
//    if ([_currentAnimationType isEqualToString:currentAnimationType]) {
//        return;
//    }
    
    _currentAnimationType = currentAnimationType;
    
    int i = 0;
    for (; i < self.models.count; ++ i) {
        MDAlbumVideoDynamicEffectCollectionViewCell *selectedCell = self.cells[i % self.cells.count];
        selectedCell.selected = [self.models[i].animationType isEqualToString:currentAnimationType];
    }
}
    

@end
