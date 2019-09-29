//
//  MDAlbumVideoImageSortingViewController.m
//  MomoChat
//
//  Created by sunfei on 2018/9/7.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MDAlbumVideoImageSortingViewController.h"
#import "MDAlbumVideoImageSortingContentView.h"
#import "MDPhotoLibraryProvider.h"
#import "MDMusicCollectionItem.h"
#import <RecordSDK/GPUImageFuzzyZoomGradualChangeFilter.h>
#import "UIConst.h"
#import "MDRecordMacro.h"

@interface MDAlbumVideoImageSortingViewController () <MDAlbumVideoImageSortingContentViewDelegate>

@property (nonatomic, strong) MDAlbumPlayerViewController *playerController;

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *playerBgView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) MDAlbumVideoImageSortingContentView *bottomView;
@property (nonatomic, strong) UIImageView *thumbImageView;

@property (nonatomic, strong) MDPhotoItem *thumbImageItem;
@property (nonatomic, strong) NSArray<MDPhotoItem *> *sortedImages;

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL animatedShow;

@property (nonatomic, assign) BOOL hasChanged;

// 是否在封面页面
@property (nonatomic, readwrite) BOOL isInThumbView;

@property (nonatomic, strong) dispatch_queue_t imageProcessQueue;

@end

@implementation MDAlbumVideoImageSortingViewController

- (instancetype)initWithPlayerViewController:(MDAlbumPlayerViewController *)playerViewController {
    self = [super init];
    if (self) {
        self.playerController = playerViewController;
        
        self.imageProcessQueue = dispatch_queue_create("com.albummovie.imageprocess", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = RGBCOLOR(37, 37, 37);
}

- (void)setupUI {

    self.bottomView = ({
        MDAlbumVideoImageSortingContentView *view = [[MDAlbumVideoImageSortingContentView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.delegate = self;
        [self.view addSubview:view];
        [view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
        [view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
        [view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [view.heightAnchor constraintEqualToConstant: IS_IPHONE_X ? 205 : 195].active = YES;
        view.images = self.images;
        view;
    });
    
    [self setupButtons];
    
    self.playerBgView = ({
        UIView *view = [[UIView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:view];
        [view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
        [view.topAnchor constraintEqualToAnchor:self.stackView.bottomAnchor].active = YES;
        [view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [view.bottomAnchor constraintEqualToAnchor:self.bottomView.topAnchor constant:-28].active = YES;
        view;
    });
    
    self.thumbImageView = ({
        
        UIImageView *view = [[UIImageView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.contentMode = UIViewContentModeScaleAspectFit;
        view.backgroundColor = UIColor.blackColor;
        view.clipsToBounds = YES;
        view.hidden = YES;
        [self.playerBgView addSubview:view];
        [view.topAnchor constraintEqualToAnchor:self.playerBgView.topAnchor].active = YES;
        [view.heightAnchor constraintEqualToAnchor:self.playerBgView.heightAnchor].active = YES;
        [view.centerXAnchor constraintEqualToAnchor:self.playerBgView.centerXAnchor].active = YES;
        
        CGSize size = UIScreen.mainScreen.bounds.size;
        [view.widthAnchor constraintEqualToAnchor:view.heightAnchor multiplier:size.width / size.height].active = YES;
        view;
    });
    
    [self updateThumbImage];
}

- (void)updateThumbImage {
    MDPhotoItem *item = self.thumbImageItem;
    UIImage *image = nil;
    if (item.editedImage) {
        image = item.editedImage;
    } else if (item.originImage) {
        image = item.originImage;
    } else {
        image = item.nailImage;
    }
    
    dispatch_async(self.imageProcessQueue, ^{
        GPUImageFuzzyZoomGradualChangeFilter *filter = [[GPUImageFuzzyZoomGradualChangeFilter alloc] initWithRenderSize:CGSizeMake(720, 1280) imageSize:image.size];
        GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
        [picture addTarget:filter];
        [filter useNextFrameForImageCapture];
        [picture processImage];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.thumbImageView.image = [filter imageFromCurrentFramebuffer];
        });
    });
   
    
}

- (void)setupButtons {
    
    UIButton *(^createButton)(NSString *) = ^(NSString *title) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitleColor:[UIColor.whiteColor colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        return button;
    };
    
    self.saveButton = ({
        createButton(@"保存");
    });
    
    self.cancelButton = ({
        createButton(@"取消");
    });
    
    self.stackView = ({
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.cancelButton, self.saveButton]];
        stackView.translatesAutoresizingMaskIntoConstraints = NO;
        stackView.axis = UILayoutConstraintAxisHorizontal;
        if (@available(iOS 11, *)) {
            stackView.spacing = UIStackViewSpacingUseSystem;
        } else {
            stackView.spacing = 8;
        }
        stackView.alignment = UIStackViewAlignmentCenter;
        stackView.distribution = UIStackViewDistributionEqualCentering;
        [self.view addSubview:stackView];
        
        [stackView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:15].active = YES;
        [stackView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [stackView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant: IS_IPHONE_X ? 41 : 21].active = YES;
        [stackView.heightAnchor constraintEqualToConstant:23].active = YES;
        stackView;
    });
    
    self.saveButton.selected = YES;
    self.cancelButton.selected = NO;
}

- (void)buttonClicked:(UIButton *)button {
    if (button == self.saveButton) {
        self.isInThumbView = NO;
        [self dissmissWithAnimated:YES completion:^{
            [self.delegate didCompleteSortingController:self];
        }];
    } else {
        // 没做任何改变，直接消失不弹窗
        if (!self.hasChanged) {
            self.isInThumbView = NO;
            [self dissmissWithAnimated:YES completion:^{
                [self.delegate cancelSortingController:self];
            }];
            return;
        }
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"是否放弃?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.isInThumbView = NO;
            [self dissmissWithAnimated:YES completion:^{
                [self.delegate cancelSortingController:self];
            }];
        }];
        [alertVC addAction:action1];
        [alertVC addAction:action2];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (MDPhotoItem *)thumbImageItem {
    if (!_thumbImageItem) {
        return self.sortedImages.firstObject;
    }
    return _thumbImageItem;
}

- (NSArray<MDPhotoItem *> *)sortedImages {
    if (!_sortedImages) {
        return self.images;
    }
    return _sortedImages;
}

- (void)setImages:(NSArray<MDPhotoItem *> *)images {
    _images = images;
    
    if (!self.bottomView) {
        [self setupUI];
    }
}

- (void)setSelectedIndex:(NSInteger)index {
    [self.bottomView setSelectedIndex:index];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 这里异步进行transform动画，因为需要用到playerBgView的frame信息，这就势必需要在布局计算出其frame之后在进行动画
    if (self.isShow) {
        return;
    }
    
    self.isShow = YES;
    CGFloat scale = self.playerBgView.height / MDScreenHeight;
    [self.view addSubview:self.playerController.view];
    [UIView animateWithDuration:self.animatedShow ? 0.3f : 0.001 animations:^{
        self.playerController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.playerController.view.center = self.playerBgView.center;
    } completion:^(BOOL finished) {
        [self.view insertSubview:self.playerController.view belowSubview:self.playerBgView];
    }];
}

- (void)updateImages:(NSArray<MDPhotoItem *> *)images animationType:(NSString *)animationType thumbImage:(MDPhotoItem *)thumbImage {
    self.thumbImageItem = thumbImage;
    self.images = images;
    [self updateThumbImage];
    [self.bottomView updateImages:images animationType:animationType thumbImage:thumbImage];
}

#pragma mark - show or hide

- (void)showWithAnimatied:(BOOL)animated {
    self.animatedShow = animated;
    self.hasChanged = NO;
}

- (void)dissmissWithAnimated:(BOOL)animated {
    [self dissmissWithAnimated:animated completion:nil];
}

- (void)dissmissWithAnimated:(BOOL)animated completion:(void(^)(void))completion {
    self.thumbImageView.hidden = YES;
    self.playerController.view.hidden = NO;
    [self.view bringSubviewToFront:self.playerController.view];
    [UIView animateWithDuration:animated ? 0.3 : 0.001 animations:^{
        self.playerController.view.transform = CGAffineTransformIdentity;
        self.playerController.view.center = CGPointMake(MDScreenWidth / 2.0, MDScreenHeight / 2.0);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        self.isShow = NO;
        completion ? completion() : nil;
    }];
}

#pragma mark - MDAlbumVideoImageSortingContentViewDelegate Methods

- (void)contentView:(MDAlbumVideoImageSortingContentView *)view sortedImages:(NSArray<MDPhotoItem *> *)sortedImages {
    self.hasChanged = YES;
    self.sortedImages = sortedImages;
    [self updateThumbImage];
    [self.delegate sortingController:self sortedImages:sortedImages];
}

- (void)contentView:(MDAlbumVideoImageSortingContentView *)view musicItem:(MDMusicCollectionItem *)musicItem animationType:(NSString *)animationType {
    self.hasChanged = YES;
    [self.delegate sortingController:self musicItem:musicItem animationType:animationType];
}

- (void)contentView:(MDAlbumVideoImageSortingContentView *)view thumImage:(MDPhotoItem *)thumbImage {
    self.hasChanged = YES;
    self.thumbImageItem = thumbImage;
    [self updateThumbImage];
    [self.delegate sortingController:self thumbImage:thumbImage];
}

- (void)contentView:(MDAlbumVideoImageSortingContentView *)view selectIndex:(NSInteger)index {
    self.thumbImageView.hidden = index != 2;
    self.playerController.view.hidden = !self.thumbImageView.hidden;
    self.isInThumbView = index == 2;
    if ([self.delegate respondsToSelector:@selector(sortingController:selectIndex:)]) {
        [self.delegate sortingController:self selectIndex:index];
    }
}

- (void)setCurrentAnimationType:(NSString *)currentAnimationType {
    self.bottomView.currentAnimationType = currentAnimationType;
}

- (NSString *)currentAnimationType {
    return self.bottomView.currentAnimationType;
}

@end
