//
//  ViewController.m
//  MDRecordSDK
//
//  Created by sunfei on 2018/11/29.
//  Copyright © 2018 sunfei. All rights reserved.
//

#import "ViewController.h"
#import "MDImageEditorViewController.h"
#import "ImageFixOrientationHelper.h"
#import "MDPhotoLibraryProvider.h"
#import "MDMediaEditorSettingItem.h"
#import "MDNewMediaEditorViewController.h"
#import "MDUnifiedRecordViewController.h"
#import "MDUnifiedRecordSettingItem.h"
#import "MDNewAssetContainerController.h"
#import "MDCameraContainerViewController.h"
#import "MDNavigationController.h"
#import "UINavigationController+AnimatedTransition.h"
#import "MDRecordImageResult.h"

#import "MDRecordUtility.h"

@import RecordSDK;

@import MLMediaFoundation;

#import "MDRecordSettingViewController.h"
#import "MDRecordVideoEditSettingViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MDRecordManager initSDK:@"100cb616072fdc76c983460b8c2b470a"];
    if ([MDRecordManager isReady]) {
        [MDRecordManager fetchConfigUsingAppId];
		
		NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
		NSString *dir = [cachePath stringByAppendingPathComponent:@"Logger"];
		BOOL isDir = NO;
		if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir] || !isDir) {
			[[NSFileManager defaultManager] createDirectoryAtPath:dir
									  withIntermediateDirectories:YES
													   attributes:nil
															error:nil];
		}
		
		id<MDRIRecordLogger> logger = [[MMRecordLogger alloc] initWithCachePath:dir];
		[MDRecordManager configLogger:logger];
    }
//    [MDRecordDetectorManger config];
    
    MLPlayerViewController *vc = [[MLPlayerViewController alloc] init];
    vc.player = [[AVPlayer alloc] init];
    
//    MDRecordDetectorManger *detetorManager = [[MDRecordDetectorManger alloc] init];
//    [MDRecordManager setDetectorModelsPreloader:detetorManager];
//    [MDRecordDetectorProxy sharedInstance].creator = detetorManager;
//    [MDRecordDetectorProxy sharedInstance].creator = [MDDetectorManger shared];
    
    self.navigationController.navigationBar.hidden = YES;
//    self.view.backgroundColor = [UIColor orangeColor];
    
    UIImage *image = [UIImage imageNamed:@"MDRecordBGImage"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:image];
    bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgImageView];
    
    [bgImageView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [bgImageView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [bgImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [bgImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    UIImageView *homeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_icon"]];
    homeIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:homeIcon];
    [homeIcon.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [homeIcon.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:90].active = YES;
    
    UIStackView *stackView = [[UIStackView alloc] initWithFrame:self.view.bounds];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionEqualCentering;
    stackView.spacing = 15;
    [self.view addSubview:stackView];
    
    [stackView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [stackView.widthAnchor constraintEqualToConstant:200].active = YES;
    [stackView.heightAnchor constraintEqualToConstant:348].active = YES;
    [stackView.topAnchor constraintEqualToAnchor:homeIcon.bottomAnchor constant:52.5].active = YES;
    
    UIButton *(^createButton)(NSString *, NSString *, NSString *) = ^(NSString *bg, NSString *icon, NSString *text){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setBackgroundImage:[UIImage imageNamed:bg] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        // add icon view
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
        iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [button addSubview:iconImageView];
        [iconImageView.topAnchor constraintEqualToAnchor:button.topAnchor constant:24.5].active = YES;
        [iconImageView.centerXAnchor constraintEqualToAnchor:button.centerXAnchor].active = YES;
        [iconImageView.heightAnchor constraintEqualToConstant:25].active = YES;
        
        // add text
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.text = text;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:16];
        [button addSubview:label];
        [label.centerXAnchor constraintEqualToAnchor:button.centerXAnchor].active = YES;
        [label.topAnchor constraintEqualToAnchor:iconImageView.bottomAnchor constant:10].active = YES;
        [label.heightAnchor constraintEqualToConstant:22.5].active = YES;
        
        return button;
    };
    
    NSArray<NSDictionary <NSString *, NSString *> *> *buttonInfo = @[
                                                                     @{@"bg":@"recording", @"icon":@"recordingIcon", @"text":@"短视频拍摄"},
                                                                     @{@"bg":@"videoEdit", @"icon":@"videoEditIcon", @"text":@"短视频编辑"},
                                                                     @{@"bg":@"videoPlay", @"icon":@"videoPlayIcon", @"text":@"短视频播放"},
                                                                     ];
    
    for (int i = 0; i < 3; ++ i) {
        NSString *bg = buttonInfo[i][@"bg"];
        NSString *icon = buttonInfo[i][@"icon"];
        NSString *text = buttonInfo[i][@"text"];
        UIButton *button = createButton(bg, icon, text);
        button.tag = i;
        [stackView addArrangedSubview:button];
    }
    
//    VideoNewSpeedSlider *slider = [[VideoNewSpeedSlider alloc] initWithFrame:CGRectMake(0, 100, MDScreenWidth, 400)];
//    [self.view addSubview:slider];
    
//    NewFaceDecorationView *view = [[NewFaceDecorationView alloc] initWithFrame:CGRectMake(0, 100, MDScreenWidth, 400)];
//    [self.view addSubview:view];
    
//    NewMusicTrimView *view = [[NewMusicTrimView alloc] initWithFrame:CGRectMake(8, 100, MDScreenWidth - 16, 40)];
//    [self.view addSubview:view];
    
//    MDRecordSlider *slider = [[MDRecordSlider alloc] initWithFrame:CGRectZero];
//    
//    slider.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addSubview:slider];
//    [slider.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:10].active = YES;
//    [slider.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
//    [slider.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:40].active = YES;
}

- (void)buttonTapped:(UIButton *)button {
    switch (button.tag) {
        case 0: {
//            [self gotoRecord:MDUnifiedRecordLevelTypeHigh];
            MDRecordSettingViewController *vc = [[MDRecordSettingViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1: {
//            [self gotoRecord:MDUnifiedRecordLevelTypeAsset];
            MDRecordVideoEditSettingViewController *vc = [[MDRecordVideoEditSettingViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2: {
        }
            break;
            
        default:
            break;
    }
}

- (void)gotoRecord:(MDUnifiedRecordLevelType)levelType {
    if (![MDCameraContainerViewController checkDevicePermission]) {
        return;
    }
    
    MDCameraContainerViewController *containerVC = [[MDCameraContainerViewController alloc] init];
    __weak typeof(containerVC) weakContainerVC = containerVC;
    
    MDUnifiedRecordSettingItem *settingItem = [MDUnifiedRecordSettingItem defaultConfigForSendFeed];
    settingItem.levelType = levelType;
    settingItem.completeHandler = ^(id result) {
        
        if ([result isKindOfClass:[MDRecordVideoResult class]]) {
            MDRecordVideoResult *videoResult = result;
            // use result to do something ...
        } else if ([result isKindOfClass:[MDRecordImageResult class]]) {
            MDRecordImageResult *imageResult = (MDRecordImageResult *)result;
            // use result to do something ...
        }
        
        [weakContainerVC dismissViewControllerAnimated:YES completion:nil];
    };
    
    containerVC.recordSetting = settingItem;
    
    MDNavigationController *nav = [MDNavigationController md_NavigationControllerWithRootViewController:containerVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)createImageEditVC:(UIImage *)image {
    
    UIImage *compressedImage = [MDRecordUtility checkOrScaleImage:image ignoreLongPic:YES];
    
    __weak typeof(self) weakself = self;
    MDImageUploadParamModel *imageUploadParamModel = [[MDImageUploadParamModel alloc] init];
    MDImageEditorViewController *vc = [[MDImageEditorViewController alloc] initWithImage:compressedImage
                                                                           completeBlock:^(UIImage *image, BOOL isEdited) {
                                                                               [weakself.navigationController popToRootViewControllerAnimated:YES];
                                                                           }];
    
    vc.imageUploadParamModel = imageUploadParamModel;
    
    __weak MDImageEditorViewController *weakImageEditorVC = vc;
    vc.cancelBlock = ^(BOOL isEdit) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"要放弃该图片吗?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIViewController *targetController = nil;
            NSArray *controllers = [weakImageEditorVC.navigationController viewControllers];
            if (controllers.count > 2) {
                targetController = controllers[controllers.count-3];
                [weakImageEditorVC.navigationController popToViewController:targetController animated:YES];
            }else {
                [weakImageEditorVC.navigationController popViewControllerAnimated:YES];
            }
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
