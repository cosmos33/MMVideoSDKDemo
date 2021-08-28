//
//  MDRecordVideoEditSettingViewController.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/5/29.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordVideoEditSettingViewController.h"
#import "MDRecordVideoSettingManager.h"

#import "MDRecordMacro.h"
#import "MDCameraContainerViewController.h"
#import "MDRecordVideoResult.h"
#import "MDNavigationController.h"
#import "UINavigationController+AnimatedTransition.h"
#import "MDRecordImageResult.h"
#import "MDPhotoLibraryProvider.h"
#import "MDMediaEditorSettingItem.h"
#import "MDRecordVideoResult.h"
#import "MDNewMediaEditorViewController.h"
#import "MDAssetCompressHandler.h"
//#import "MDAlbumPLayerSetting.h"

#import <MBProgressHUD/MBProgressHUD.h>
@import RecordSDK;

@interface MDRecordVideoEditSettingViewController () <MDNavigationBarAppearanceDelegate> //, MDGPUImageAlbumMovieExportDelegate>

//@property (nonatomic, strong) MDGPUImageAlbumMovieExport *exporter;
@property (nonatomic, weak) MBProgressHUD *hub;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) MDRecordVideoResult *videoResult;

@property (nonatomic, strong) MDAssetCompressHandler *handler;

@end

@implementation MDRecordVideoEditSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    self.videoResult = [[MDRecordVideoResult alloc] init];
    self.videoResult.accessSource = MDVideoRecordAccessSource_Unkonwn;
    self.videoResult.themeID = @"123";
    self.videoResult.topicID = @"123;";
    
    self.handler = [[MDAssetCompressHandler alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
}

- (void)willResignActive {
//    [self.exporter cancel];
}

- (void)setupUI {
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    self.view.backgroundColor = UIColor.blackColor;
    
    MDRecordVideoSettingManager.exportBitRate = 0;
    MDRecordVideoSettingManager.exportFrameRate = 0;
	MDRecordVideoSettingManager.cropRegion = CGRectMake(0, 0, 1, 1);
    
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    visualEffectView.frame = self.view.bounds;
    [self.view addSubview:visualEffectView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [visualEffectView.contentView addGestureRecognizer:tapGesture];
    
    UIButton *closeButton = [self createCloseButton];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView.contentView addSubview:closeButton];
    
    UILabel *headerLabel = [self titleLabelWithTitle:@"编辑设置"];
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView.contentView addSubview:headerLabel];
    
    UIView *view1 = [self itemWithTitle:@"帧率" placeholder:@"默认为30,建议范围15-30" textFiedlTag:1000];
    view1.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView.contentView addSubview:view1];
    
    UIView *view2 = [self itemWithTitle:@"码率(M)" placeholder:@"默认为0,根据视频清晰度自动计算, 单位为M, 建议1-7" textFiedlTag:1001];
    view2.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView.contentView addSubview:view2];
    
//    UIView *view3 = [self toggleBlurWithTitle:@"启用背景模糊: "];
//    view3.translatesAutoresizingMaskIntoConstraints = NO;
//    [visualEffectView.contentView addSubview:view3];
	
	UIView *view4 = [self itemWithTitle:@"裁剪" placeholder:@"x,y,w,h 0-1 no space" textFiedlTag:1002];
	view4.translatesAutoresizingMaskIntoConstraints = NO;
	[visualEffectView.contentView addSubview:view4];
    
    UIButton *completeButton = [self createSelectItemButtonWithTitle:@"导入编辑" tag:10010];
    completeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView.contentView addSubview:completeButton];
    
    [closeButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:24].active = YES;
    [closeButton.widthAnchor constraintEqualToConstant:32].active = YES;
    [closeButton.heightAnchor constraintEqualToAnchor:closeButton.widthAnchor].active = YES;
    
    if (@available(iOS 11.0, *)) {
        [closeButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:30].active = YES;
    } else {
        [closeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:30].active = YES;
    }
    
    [headerLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [headerLabel.centerYAnchor constraintEqualToAnchor:closeButton.centerYAnchor].active = YES;
    
    [view1.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active = YES;
    [view1.topAnchor constraintEqualToAnchor:headerLabel.bottomAnchor constant:25].active = YES;
    [view1.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [view1.heightAnchor constraintEqualToConstant:80].active = YES;
    
    [view2.leftAnchor constraintEqualToAnchor:view1.leftAnchor].active = YES;
    [view2.topAnchor constraintEqualToAnchor:view1.bottomAnchor constant:20].active = YES;
    [view2.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [view2.heightAnchor constraintEqualToConstant:80].active = YES;
    
//    [view3.leftAnchor constraintEqualToAnchor:view1.leftAnchor].active = YES;
//    [view3.topAnchor constraintEqualToAnchor:view2.bottomAnchor constant:20].active = YES;
//    [view3.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
//    [view3.heightAnchor constraintEqualToConstant:80].active = YES;
	
	[view4.leftAnchor constraintEqualToAnchor:view1.leftAnchor].active = YES;
	[view4.topAnchor constraintEqualToAnchor:view2.bottomAnchor constant:20].active = YES;
	[view4.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
	[view4.heightAnchor constraintEqualToConstant:80].active = YES;
    
    [completeButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [completeButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active = YES;
    [completeButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [completeButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-60].active = YES;
}

- (UIButton *)createCloseButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"btn_moment_music_back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)createSelectItemButtonWithTitle:(NSString *)title tag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setBackgroundColor:[[UIColor mdr_colorWithHexString:@"f5f5f5"] colorWithAlphaComponent:0.2]];
    button.tag = tag;
    button.layer.cornerRadius = 5;
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UILabel *)titleLabelWithTitle:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = UIColor.whiteColor;
    label.text = text;
    return label;
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder tag:(NSInteger)tag {
    UITextField *textField = [[UITextField alloc] init];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                      attributes:@{
                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                                                   NSForegroundColorAttributeName : UIColor.whiteColor
                                                                                   }];
    textField.textColor = UIColor.whiteColor;
    textField.font = [UIFont systemFontOfSize:15];
    textField.tag = tag;
    textField.backgroundColor = [UIColor grayColor];
    textField.backgroundColor = [[UIColor mdr_colorWithHexString:@"f5f5f5"] colorWithAlphaComponent:0.2];
    [textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    return textField;
}

- (UIView *)itemWithTitle:(NSString *)title placeholder:(NSString *)placeholder textFiedlTag:(NSInteger)tag {
    
    UILabel *titleLabel = [self titleLabelWithTitle:title];
    [titleLabel sizeToFit];
    
    UITextField *textField = [self textFieldWithPlaceholder:placeholder tag:tag];
    textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, textField]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentLeading;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.spacing = 8;
    
    [textField.leftAnchor constraintEqualToAnchor:stackView.leftAnchor].active = YES;
    [textField.rightAnchor constraintEqualToAnchor:stackView.rightAnchor].active = YES;
    [textField.heightAnchor constraintEqualToConstant:40].active = YES;
    textField.layer.cornerRadius = 5;
    
    return stackView;
}

- (UIView *)toggleBlurWithTitle:(NSString *)title {
    UILabel *titleLabel = [self titleLabelWithTitle:title];
    [titleLabel sizeToFit];
    
    UISwitch *toggle = [[UISwitch alloc] init];
    toggle.translatesAutoresizingMaskIntoConstraints = NO;
    [toggle addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventValueChanged];
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, toggle]];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    if (@available(iOS 11.0, *)) {
        stackView.spacing = UIStackViewSpacingUseSystem;
    } else {
        stackView.spacing = 8;
    }

    return stackView;
}

- (void)toggle:(UISwitch *)toggle {
    
}

- (void)closeButtonTapped:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldValueChanged:(UITextField *)textField {
    switch (textField.tag) {
        case 1000:
            MDRecordVideoSettingManager.exportFrameRate = [textField.text intValue];
            break;
            
        case 1001:
            MDRecordVideoSettingManager.exportBitRate = [textField.text floatValue] * 1024 * 1024;
            break;
			
		case 1002:
		{
			NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSArray *rect = [text componentsSeparatedByString:@","];
			if (rect.count == 4) {
				CGFloat x = [rect[0] floatValue];
				CGFloat y = [rect[1] floatValue];
				CGFloat w = [rect[2] floatValue];
				CGFloat h = [rect[3] floatValue];
				MDRecordVideoSettingManager.cropRegion = CGRectMake(x, y, w, h);
			}
		}
			break;
            
        default:
            break;
    }
}

- (void)buttonTapped:(UIButton *)button {
    [self gotoRecord:MDUnifiedRecordLevelTypeAsset];
}

- (void)gotoRecord:(MDUnifiedRecordLevelType)levelType {
    if (![MDCameraContainerViewController checkDevicePermission]) {
        return;
    }
    
    MDCameraContainerViewController *containerVC = [[MDCameraContainerViewController alloc] init];
    __weak typeof(containerVC) weakContainerVC = containerVC;
    
    MDUnifiedRecordSettingItem *settingItem = [MDUnifiedRecordSettingItem defaultConfigForSendFeed];
    //    settingItem.recordLog.enterenceType = (levelType == MDUnifiedRecordLevelTypeAsset ? MDUnifiedRecordEnterenceTypeAlbum : MDUnifiedRecordEnterenceTypeRecord);
    settingItem.levelType = levelType;
    settingItem.completeHandler = ^(id result) {
        
        if ([result isKindOfClass:[MDRecordVideoResult class]]) {
            
        } else if ([result isKindOfClass:[MDRecordImageResult class]]) {
            
//            NSMutableArray<UIImage *> *images = [NSMutableArray array];
//
//            MDRecordImageResult *photoResult = (MDRecordImageResult *)result;
//            for (MDPhotoItem *item in photoResult.photoItems) {
//                if (item.editedImage) {
//                    [images addObject:item.editedImage];
//                } else if (item.originImage) {
//                    [images addObject:item.originImage];
//                } else if (item.nailImage) {
//                    [images addObject:item.nailImage];
//                }
//            }
//
//            if (images.count <= 1) {
//                [weakContainerVC dismissViewControllerAnimated:YES completion:nil];
//                return;
//            }
//
//            NSString *localPath = [self localPathForAlbumVideo];
//
//            if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
//                [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
//            }
//
//            MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
//            hub.mode = MBProgressHUDModeAnnularDeterminate;
//            hub.label.text = @"Loading";
//            hub.backgroundView.color = [UIColor.blackColor colorWithAlphaComponent:0.3];
//            self.hub = hub;
//
//            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerStart:) userInfo:nil repeats:YES];
//
//            NSArray<MDPictureInputItem *> *inputItems = [MDPictureInputItem itemsForImages:images.copy
//                                                                              timeInterval:3.0
//                                                                                 frameRate:30];
//            if ([MDAlbumPLayerSetting.animationType isEqualToString:kAlbumPlayerAnimationTypeTemplate1] || [MDAlbumPLayerSetting.animationType isEqualToString:kAlbumPlayerAnimationTypeTemplate2]) {
//                inputItems = [inputItems arrayByAddingObject:inputItems.lastObject];
//            }
//            CGSize screenSize = UIScreen.mainScreen.bounds.size;
//            CGFloat scale = UIScreen.mainScreen.scale;
//            CGSize maxSize = CGSizeMake(720, 1280);
//            CGSize renderSize = maxSize;
//            if (renderSize.width > screenSize.width * scale) {
//                renderSize = CGSizeMake(screenSize.width * scale, screenSize.width * scale * 16.0f / 9.0f);
//            }
//
//            MDGPUImageAlbumMovieExport *exporter = [[MDGPUImageAlbumMovieExport alloc] initWithItems:inputItems
//                                                                                        sizeInPixels:renderSize
//                                                                                          audioAsset:nil
//                                                                                            audioMix:nil];
//            exporter.animationType = MDAlbumPLayerSetting.animationType;
//            self.exporter = exporter;
//            exporter.delegate = self;
//            exporter.exportURL = [NSURL fileURLWithPath:localPath];
//            [exporter exportVideo];
        }
        
        [weakContainerVC dismissViewControllerAnimated:YES completion:nil];
    };
    
    containerVC.recordSetting = settingItem;
    
    MDNavigationController *nav = [MDNavigationController md_NavigationControllerWithRootViewController:containerVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)timerStart:(NSTimer *)timer {
//    self.hub.progress = self.exporter.progress;
}

- (void)tapped:(UIGestureRecognizer *)tapGesture {
    UITextField *field1 = [self.view viewWithTag:1000];
    [field1 resignFirstResponder];
    UITextField *field2 = [self.view viewWithTag:1001];
    [field2 resignFirstResponder];
	UITextField *field3 = [self.view viewWithTag:1002];
	[field3 resignFirstResponder];
}

- (UINavigationBar *)md_CustomNavigationBar {
    return nil;
}

- (BOOL)md_isCurrentCustomed {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSString *)localPathForAlbumVideo {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"album_player_video_tmp_dir"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *localPath = [rootPath stringByAppendingPathComponent:@"tmp.mp4"];
    return localPath;
}

//- (void)albumMovieDidCancelProcessing:(MDGPUImageAlbumMovieExport *)movie {
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.hub hideAnimated:YES];
//        
//        [self.timer invalidate];
//        self.timer = nil;
//        
//        NSLog(@"export canceled");
//        self.exporter = nil;
//    });
//}
//
//- (void)albumMovieDidFinishProcessing:(MDGPUImageAlbumMovieExport *)movie {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        self.hub.progress = 1.0;
//        
//        [self.hub hideAnimated:YES];
//        
//        [self.timer invalidate];
//        self.timer = nil;
//
//        NSLog(@"export completed");
//        self.exporter = nil;
//        
//        NSString *localPath = [self localPathForAlbumVideo];
//        
//        if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
//            return;
//        }
//        
//        NSURL *videoURL = [NSURL fileURLWithPath:localPath];
//        AVAsset *asset = [AVAsset assetWithURL:videoURL];
//        [self _handleResultInfoWithOriginalURL:videoURL asset:asset];
//        [self pushToEditingVCWithAsset:asset path:localPath];
//
////        [PHPhotoLibrary saveVideoAtPath:videoURL
////                        toAlbumWithName:@"陌陌"
////                             completion:^(PHFetchResult<PHAsset *> *result, NSError *error) {
////                                 dispatch_async(dispatch_get_main_queue(), ^{
////                                     NSLog(@"error = %@", error);
////                                 });
////
////                             }];
//        
//        
//    });
//}

- (void)pushToEditingVCWithAsset:(AVAsset *)asset path:(NSString *)path {
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    MDMediaEditorSettingItem *settingItem = [[MDMediaEditorSettingItem alloc] init];
    settingItem.videoAsset = asset;
    settingItem.videoTimeRange = videoTrack.timeRange;
    settingItem.backgroundMusicURL = nil;
    settingItem.backgroundMusicTimeRange = kCMTimeRangeInvalid;
    settingItem.backgroundMusicItem = nil;
    settingItem.supportMultiSegmentsRecord = NO;
    settingItem.completeBlock = ^(id videoInfo) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
         [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    };
    
    settingItem.videoInfo = nil;
    settingItem.hideTopicEntrance = YES;
    settingItem.lockTopic = YES;
    settingItem.maxUploadDuration = 60;
    settingItem.doneButtonTitle = @"完成";
    settingItem.hasCutVideo = NO;
    settingItem.needWaterMark = NO;
    settingItem.maxThumbImageSize = 640;
    settingItem.fromAlbum = NO;
    
    MDNewMediaEditorViewController *vc = [[MDNewMediaEditorViewController alloc] initWithSettingItem:settingItem];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)_handleResultInfoWithOriginalURL:(NSURL *)mediaURL asset:(AVAsset *)asset {
    NSDictionary *resourceValues = [mediaURL resourceValuesForKeys:@[NSURLFileSizeKey,NSURLTotalFileSizeKey] error:nil];
    
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize presentationSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    presentationSize.width = ABS(presentationSize.width);
    presentationSize.height = ABS(presentationSize.height);
    
    self.videoResult.originalFileSize = [resourceValues longLongValueForKey:NSURLFileSizeKey defaultValue:0] ?: [resourceValues longLongValueForKey:NSURLTotalFileSizeKey defaultValue:0];
    self.videoResult.originalDuration = CMTimeGetSeconds(asset.duration);
    self.videoResult.originalVideoNaturalWidth = presentationSize.width;
    self.videoResult.originalVideoNaturalHeight = presentationSize.height;
    self.videoResult.originalBitRate = [track estimatedDataRate];
    self.videoResult.originalFrameRate = [track nominalFrameRate];
    
    self.videoResult.isOriginalVideoCompress =  [self.handler needCompressWithAsset:asset mediaURL:mediaURL];;
}

- (void)_handleResultInfoWithEditAsset:(AVAsset *)asset hasCutVideo:(BOOL)hasCutVideo {
    self.videoResult.isFromAlbum = YES;
    self.videoResult.isOriginalVideoCut = hasCutVideo;
    
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize presentationSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    presentationSize.width = ABS(presentationSize.width);
    presentationSize.height = ABS(presentationSize.height);
    
    self.videoResult.editVideoDuration = CMTimeGetSeconds(asset.duration);
    self.videoResult.editVideoNaturalWidth = presentationSize.width;
    self.videoResult.editVideoNaturalHeight = presentationSize.height;
    self.videoResult.editVideoBitRate = [track estimatedDataRate];
    self.videoResult.editVideoFrameRate = [track nominalFrameRate];
    
    if ([asset isKindOfClass:[AVURLAsset class]]) {
        NSURL *mediaURL = ((AVURLAsset *)asset).URL;
        NSDictionary *resourceValues = [mediaURL resourceValuesForKeys:@[NSURLFileSizeKey,NSURLTotalFileSizeKey] error:nil];
        self.videoResult.editVideoFileSize = [resourceValues longLongValueForKey:NSURLFileSizeKey defaultValue:0] ?: [resourceValues longLongValueForKey:NSURLTotalFileSizeKey defaultValue:0];
    }
}


@end
