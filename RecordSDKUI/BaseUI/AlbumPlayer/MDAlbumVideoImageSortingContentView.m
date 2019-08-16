//
//  MDAlbumVideoImageSortingContentView.m
//  MDAlbumVideo
//
//  Created by sunfei on 2018/9/7.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "MDAlbumVideoImageSortingContentView.h"
#import "MDAlbumVideoDynamicEffectSelectView.h"
#import "MDAlbumVideoSwitchButtonView.h"
#import "MDAlbumVideoImageSortingView.h"
#import "MDAlbumVideoCoverContentView.h"
#import "MDPhotoLibraryProvider.h"

@interface MDAlbumVideoImageSortingContentView()

@property (nonatomic, strong) MDAlbumVideoImageSortingView                          *selectView;
@property (nonatomic, strong) MDAlbumVideoSwitchButtonView                          *switchButtonView;
@property (nonatomic, strong) MDAlbumVideoDynamicEffectSelectView                   *dynamicEffectView;
//@property (nonatomic, strong) MDAlbumVideoCoverContentView                          *albumVideoCoverContentView;
@property (nonatomic, strong) CALayer                                               *maskLayer;
@property (nonatomic, strong) MDPhotoItem                                           *lastSelectedPhotoItems;

@end

@implementation MDAlbumVideoImageSortingContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)setImages:(NSArray<MDPhotoItem *> *)images {
    _images = images;
    
    if (!self.switchButtonView.superview) {
        [self setupUI];
    }
}

- (void)setSelectedIndex:(NSInteger)index {
    [self.switchButtonView setSelectedIndex:index];
}

- (MDPhotoItem *)lastSelectedPhotoItems {
    if (!_lastSelectedPhotoItems) {
        return self.images.firstObject;
    }
    return _lastSelectedPhotoItems;
}

- (void)setupUI {
    
    __weak typeof(self) weakself = self;
    self.switchButtonView = ({
        MDAlbumVideoSwitchButtonView *view = [[MDAlbumVideoSwitchButtonView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
//        view.titles = @[@"调序", @"动效", @"封面"];
        view.titles = @[@"调序", @"动效"];
        view.titleButtonClicked = ^(MDAlbumVideoSwitchButtonView *switchButtonView, NSInteger index) {
            __strong typeof(self) strongself = weakself;
            switch (index) {
                case 0:
                    strongself.selectView.hidden = NO;
                    strongself.dynamicEffectView.hidden = YES;
//                    strongself.albumVideoCoverContentView.hidden = YES;
                    break;
                case 1:
                    strongself.selectView.hidden = YES;
                    strongself.dynamicEffectView.hidden = NO;
//                    strongself.albumVideoCoverContentView.hidden = YES;
                    break;
                case 2:
                    strongself.selectView.hidden = YES;
                    strongself.dynamicEffectView.hidden = YES;
//                    strongself.albumVideoCoverContentView.hidden = NO;
                    break;
                    
                default:
                    break;
            }
            
            if ([strongself.delegate respondsToSelector:@selector(contentView:selectIndex:)]) {
                [strongself.delegate contentView:strongself selectIndex:index];
            }
        };
        [self addSubview:view];
        view;
    });
    
    self.selectView = ({
        MDAlbumVideoImageSortingView *selectView = [[MDAlbumVideoImageSortingView alloc] init];
        selectView.translatesAutoresizingMaskIntoConstraints = NO;
        [selectView updateImages:self.images];
        selectView.sorted = ^(NSArray<MDPhotoItem *> *images) {
            __strong typeof(self) strongself = weakself;
            strongself.images = images;
            [strongself.delegate contentView:strongself sortedImages:images];
//            [strongself.albumVideoCoverContentView updateAlbumVideoCoverContentViewWithArray:images
//                                                                                selectedItem:strongself.lastSelectedPhotoItems];
        };
        
        
        selectView.deleteItem = ^(MDPhotoItem * _Nonnull image) {
            __strong typeof(self) strongself = weakself;
            if ([strongself.delegate respondsToSelector:@selector(contentView:deleteItem:)]) {
                [strongself.delegate contentView:strongself deleteItem:image];
            };
        };
        [self addSubview:selectView];
        selectView;
    });
    
    self.dynamicEffectView = ({
        MDAlbumVideoDynamicEffectSelectView *view = [[MDAlbumVideoDynamicEffectSelectView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *models = @[
                            [[MDAlbumVideoRTLDynamicEffectModel alloc] init],
                            [[MDAlbumVideoSoftDynamicEffectModel alloc] init],
                            [[MDAlbumVideoFastDynamicEffectModel alloc] init],
                            [[MDAlbumVideoShowDynamicEffectModel alloc] init],
                            ];
        view.models = models;
        view.tapCell = ^(MDAlbumVideoDynamicEffectSelectView *view, MDAlbumVideoDynamicEffectModel *model) {
            __strong typeof(self) strongself = weakself;
            [strongself.delegate contentView:strongself musicItem:model.musicItem animationType:model.animationType];
        };
        view.hidden = YES;
        [self addSubview:view];
        view;
    });
    
//    self.albumVideoCoverContentView = ({
//        MDAlbumVideoCoverContentView *view = [[MDAlbumVideoCoverContentView alloc] initWithPhotoItems:self.images];
//        view.translatesAutoresizingMaskIntoConstraints = NO;
//        view.hidden = YES;
//        [view albumVideoCoverSelectedItem:^(MDPhotoItem *photoItem) {
//            __strong typeof(self) strongself = weakself;
//            strongself.lastSelectedPhotoItems = photoItem;
//            [strongself.delegate contentView:strongself thumImage:photoItem];
//        }];
//        [self addSubview:view];
//        view;
//    });
    
    [self.switchButtonView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:28].active = YES;
    [self.switchButtonView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.switchButtonView.topAnchor constraintEqualToAnchor:self.topAnchor constant:19].active = YES;
    [self.switchButtonView.heightAnchor constraintEqualToConstant:33].active = YES;
    
    [self.selectView.topAnchor constraintEqualToAnchor:self.switchButtonView.bottomAnchor constant:28].active = YES;
    [self.selectView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.selectView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.selectView.heightAnchor constraintEqualToConstant:115].active = YES;
    
    [self.dynamicEffectView.topAnchor constraintEqualToAnchor:self.selectView.topAnchor].active = YES;
    [self.dynamicEffectView.leftAnchor constraintEqualToAnchor:self.selectView.leftAnchor constant:0].active = YES;
    [self.dynamicEffectView.centerXAnchor constraintEqualToAnchor:self.selectView.centerXAnchor].active = YES;
    [self.dynamicEffectView.centerYAnchor constraintEqualToAnchor:self.selectView.centerYAnchor].active = YES;
    
//    [self.albumVideoCoverContentView.topAnchor constraintEqualToAnchor:self.selectView.topAnchor].active = YES;
//    [self.albumVideoCoverContentView.leftAnchor constraintEqualToAnchor:self.selectView.leftAnchor].active = YES;
//    [self.albumVideoCoverContentView.centerXAnchor constraintEqualToAnchor:self.selectView.centerXAnchor].active = YES;
//    [self.albumVideoCoverContentView.centerYAnchor constraintEqualToAnchor:self.selectView.centerYAnchor].active = YES;
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.maskLayer) {
        [self.maskLayer removeFromSuperlayer];
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    self.maskLayer = maskLayer;
    maskLayer.frame = self.bounds;
    maskLayer.path = path.CGPath;
    maskLayer.fillColor = UIColor.blackColor.CGColor;
    [self.layer insertSublayer:maskLayer atIndex:0];
}

- (void)updateImages:(NSArray<MDPhotoItem *> *)images animationType:(NSString *)animationType thumbImage:(MDPhotoItem *)thumbImage {
    [self.selectView updateImagesOnly:images];
    
    [self.dynamicEffectView selectedAnimationType:animationType];
    
    self.lastSelectedPhotoItems = thumbImage;
//    [self.albumVideoCoverContentView updateAlbumVideoCoverContentViewWithArray:images selectedItem:self.lastSelectedPhotoItems];
}

- (void)setCurrentAnimationType:(NSString *)currentAnimationType {
    self.dynamicEffectView.currentAnimationType = currentAnimationType;
}

- (NSString *)currentAnimationType {
    return self.dynamicEffectView.currentAnimationType;
}

@end
