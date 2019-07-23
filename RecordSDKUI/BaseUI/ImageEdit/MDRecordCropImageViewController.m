//
//  MDRecordCropImageViewController.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/5/30.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordCropImageViewController.h"
#import "MDNavigationTransitionDelegate.h"

@import JPImageresizerView;

@interface MDRecordCropImageViewController () <MDNavigationBarAppearanceDelegate>

@property (nonatomic, strong) JPImageresizerView *imageresizerView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIButton *recoverButton;
@property (nonatomic, strong) UIButton *resizeButton;

@end

@implementation MDRecordCropImageViewController

- (void)dealloc {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(50, 0, (40 + 30 + 30 + 10), 0);
    JPImageresizerConfigure *configuration = [JPImageresizerConfigure defaultConfigureWithResizeImage:self.image make:^(JPImageresizerConfigure *configure) {
        configure.jp_contentInsets(contentInsets);
    }];
    
    self.view.backgroundColor = configuration.bgColor;
    
    __weak typeof(self) weakself = self;
    JPImageresizerView *imageResizerView = [JPImageresizerView imageresizerViewWithConfigure:configuration
                                                                   imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
                                                                       weakself.recoverButton.enabled = isCanRecovery;
                                                                   }
                                                                imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
                                                                    weakself.resizeButton.enabled = !isPrepareToScale;
                                                                }];
    [self.view addSubview:imageResizerView];
    
    imageResizerView.frameType = JPClassicFrameType;
    
    self.imageresizerView = imageResizerView;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton setImage:[UIImage imageNamed:@"moment_return"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *resizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resizeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [resizeButton setTitle:@"完成" forState:UIControlStateNormal];
    [resizeButton setBackgroundColor:UIColor.blueColor];
    [resizeButton addTarget:self action:@selector(resizeButtonTappped:) forControlEvents:UIControlEventTouchUpInside];
    resizeButton.layer.cornerRadius = 5;
    [self.view addSubview:resizeButton];
    self.resizeButton = resizeButton;
    
    UIButton *recoverButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recoverButton.translatesAutoresizingMaskIntoConstraints = NO;
    [recoverButton setTitle:@"还原" forState:UIControlStateNormal];
    [recoverButton setBackgroundColor:UIColor.blueColor];
    [recoverButton addTarget:self action:@selector(recoverButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    recoverButton.layer.cornerRadius = 5;
    recoverButton.enabled = NO;
    [self.view addSubview:recoverButton];
    self.recoverButton = recoverButton;
    
    [resizeButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-8].active = YES;
    [resizeButton.widthAnchor constraintEqualToConstant:40].active = YES;
    
    if (@available(iOS 11.0, *)) {
        [recoverButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-8].active = YES;
        [resizeButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8].active = YES;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
        [recoverButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-8].active = YES;
        [resizeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:30].active = YES;
    }
    
    [recoverButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [recoverButton.widthAnchor constraintEqualToConstant:200].active = YES;
    [recoverButton.heightAnchor constraintEqualToConstant:40].active = YES;
    
    [backButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:8].active = YES;
    [backButton.centerYAnchor constraintEqualToAnchor:resizeButton.centerYAnchor].active = YES;
    [backButton.widthAnchor constraintEqualToConstant:40].active = YES;
}

- (void)resizeButtonTappped:(UIButton *)button {
    self.recoverButton.enabled = NO;
    __weak typeof(self) weakself = self;
    [self.imageresizerView imageresizerWithComplete:^(UIImage *resizeImage) {
        __strong typeof(self) self = weakself;
        
        if (!resizeImage) {
            // 没有对图片进行裁剪
            [self.delegate cropImageViewControllerCancelCrop:self];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            // 返回裁剪后的图片
            [self.delegate cropImageViewController:self resizedImage:resizeImage];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)backButtonTapped {
    [self.delegate cropImageViewControllerCancelCrop:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)recoverButtonTapped {
    [self.imageresizerView recovery];
    self.recoverButton.enabled = NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - MDNavigationBarAppearanceDelegate Methods

- (UINavigationBar *)md_CustomNavigationBar {
    return nil;
}

- (BOOL)md_isCurrentCustomed {
    return YES;
}

@end
