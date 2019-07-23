//
//  MDCameraContainerViewController.m
//  MDChat
//
//  Created by lm on 2017/6/10.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDCameraContainerViewController.h"
#import "MDUnifiedRecordViewController.h"
#import "MDNewAssetContainerController.h"
#import "MDNavigationTransitionExtra.h"
#import "MDUnifiedRecordViewController+Permission.h"
//#import "MDXLuaGameHandler.h"

//goto相关
#import "MDRecordVideoResult.h"
//#import "MDReleaseFeedController.h"
#import "MDNavigationController.h"
#import "Toast/Toast.h"

@import RecordSDK;

@interface MDCameraContainerViewController ()
<MDNavigationBarAppearanceDelegate,
MDNewAssetContainerControllerDelegate,
MDUnifiedRecordViewControllerDelegate>

@property (nonatomic,strong) MDNewAssetContainerController      *pickerVC;
@property (nonatomic,strong) MDUnifiedRecordViewController      *recordVC;

@property (nonatomic,strong) UIViewController                   *currentVC;
//记录离开拍摄页 拍摄页停留的位置普通拍摄还是高级拍摄
@property (nonatomic,assign) MDUnifiedRecordLevelType           recordLevelType;
@property (nonatomic,assign) BOOL                               animating;

//@property (nonatomic,strong) MDXLuaGameHandler *gameHandler;

@end

@implementation MDCameraContainerViewController

//+ (void)actionManager:(MDActionManager *)manager action:(MDActionItem *)actionItem
//{
//    if ([actionItem.actionString isEqualToString:@"goto_live_photo"]) {
//        if ([[[MDContext currentUser] videoChatManager] checkConflictWithBizType:MDMediaBizType_VideoRecord showTip:YES]) {
//            return;
//        }
//
//        if (![MDCameraContainerViewController checkDevicePermission]) {
//            return;
//        }
//
//        NSString *path = actionItem.actionPath;
//        id obj = [path objectFromMDJSONString];
//        NSDictionary *postParam = nil;
//        if (obj && [obj isKindOfClass:[NSDictionary class]]) {
//            postParam = obj;
//        }
//
//        MDCameraContainerViewController *containerVC = [[MDCameraContainerViewController alloc] init];
//        __weak typeof(containerVC) weakContainerVC = containerVC;
//
//        MDUnifiedRecordSettingItem *settingItem = [MDUnifiedRecordSettingItem defaultConfigForSendFeed];
//        settingItem.levelType = MDUnifiedRecordLevelTypeAsset;
//        settingItem.assetLevelType = MDAssetAlbumLevelTypeAlbumVideo;
//        settingItem.onlyVideoAlbum = YES;
//        if (postParam.count > 0) {
//            settingItem.themeId = [postParam stringForKey:@"activityid" defaultValue:nil];
//            settingItem.topicId = [postParam stringForKey:@"topic_id" defaultValue:nil];
//            settingItem.lockTopic = [postParam boolForKey:@"topic_appoint" defaultValue:NO];
//        }
//
//        settingItem.completeHandler = ^(id result) {
//
//            if ([result isKindOfClass:[MDRecordVideoResult class]]) {
//                MDRecordVideoResult *videoResult = result;
//                [self releaseFeedWithVideoResult:videoResult andPostInfo:postParam];
//            }
//            [weakContainerVC dismissViewControllerAnimated:YES completion:nil];
//        };
//
//        containerVC.recordSetting = settingItem;
//
//        MDNavigationController *nav = [MDNavigationController md_NavigationControllerWithRootViewController:containerVC];
//        [MDUtility goToViewController:nav animated:YES transtionStyle:MDViewControllerTransitionStylePresented];
//    }
//}
+ (void)releaseFeedWithVideoResult:(MDRecordVideoResult *)result andPostInfo:(NSDictionary*)postParam {
//    MDReleaseFeedController *releaseFeedVC = [[MDReleaseFeedController alloc] initWithSource:MDPublishFeedSourceNearby type:MDReleaseFeedTypeNormal];
//
//    NSString *text = [postParam stringForKey:@"text" defaultValue:nil];
//    if ([[postParam stringForKey:@"activityid" defaultValue:nil] isEqualToString:@"live_room_introduction"]) {
//        releaseFeedVC.isFromLive = MDLiveSourceTypeIntro;
//    }
//    if ([text isNotEmpty]) {
//        [releaseFeedVC addText:text];
//    }
//    [releaseFeedVC addUnUploadVideo:result];
//    [[MDContext sharedAppDelegate].rootNavController pushViewController:releaseFeedVC animated:NO];
}


+ (BOOL)checkDevicePermission {
    return [MDUnifiedRecordViewController checkDevicePermission];
}

- (instancetype)init
{
    if (self = [super init]) {
        _needCheckConflict = YES;
        _showPictureButton = YES;
    }
    return self;
}

- (void)dealloc {
//    if (_gameHandler) {
//        [_gameHandler unregistGameHandler];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!_recordSetting) {
        _recordSetting = [MDUnifiedRecordSettingItem new];
        _recordSetting.accessSource = MDVideoRecordAccessSource_Feed;
        _recordSetting.levelType = MDUnifiedRecordLevelTypeNormal;
    }
    
//    if (!_gameHandler) {
//        _gameHandler = [[MDXLuaGameHandler alloc] init];
//    }
    
    [self setupChildControllers];
    
    //清理tmp目录下的视频文件
    [self clearTmpDirectory];
    //清理反转缓存目录下的文件
    [MDRecordAssetReversedManager clearCachedReversedAssets];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.currentVC beginAppearanceTransition:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.currentVC beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.currentVC endAppearanceTransition];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.currentVC endAppearanceTransition];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
    return NO;
}

- (void)setupChildControllers {
    if (self.recordSetting.levelType == MDUnifiedRecordLevelTypeAsset) {
        [self creatPickerVC:NO];
        self.pickerVC.view.hidden = NO;
        self.currentVC = self.pickerVC;
    }else {
        [self creatRecordVC:NO];
        self.recordVC.view.hidden = NO;
        self.currentVC = self.recordVC;
    }
}


- (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        if ([[file pathExtension] isEqualToString:@"mp4"]) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
        }
    }
}


#pragma mark - creator
- (MDNewAssetContainerController *)creatPickerVC:(BOOL)fromCamera{
    if (!_pickerVC) {
        BOOL couldShowTakePicture  = YES; //!(self.isNeedCheckConflict);
        if (!self.showPictureButton) {
            couldShowTakePicture = NO;
        }
        
        MDNewAssetContainerController *collectionVC = [[MDNewAssetContainerController alloc] initWithInitialItem:self.recordSetting couldShowTakePicture:couldShowTakePicture];
        collectionVC.delegate = self;
        collectionVC.fromCamera = fromCamera;
        collectionVC.userFeedShowModel = self.userFeedShowModel;
        [self addChildViewController:collectionVC];
        [self.view addSubview:collectionVC.view];
        [collectionVC didMoveToParentViewController:self];
        _pickerVC = collectionVC;
    }
    
    return _pickerVC;
}

- (MDUnifiedRecordViewController *)creatRecordVC:(BOOL)fromAlbum{
    if (!_recordVC) {
//        BOOL didShow = [[MDContext currentUser].dbStateHoldProvider hasShowedMomentRecordSpeedVaryGuide];
//        if (!didShow && self.recordSetting.levelType != MDUnifiedRecordLevelTypeAsset) {
//            NSArray *availableTaps = [self tapsByAccessSource:self.recordSetting.accessSource];
//            if ([self checkCanRecordingNeedToast:NO] && [availableTaps containsObject:@(MDUnifiedRecordLevelTypeHigh)]) {
//                [[MDContext currentUser].dbStateHoldProvider setHasShowedMomentRecordSpeedVaryGuide:YES];
//                self.recordSetting.levelType = MDUnifiedRecordLevelTypeHigh;
//            }
//        }
        if (self.recordSetting.levelType == MDUnifiedRecordLevelTypeAsset) {
            self.recordSetting.levelType = MDUnifiedRecordLevelTypeNormal;
        }
        
        _recordVC = [[MDUnifiedRecordViewController alloc] initWithSettingItem:self.recordSetting fromAlbum:fromAlbum];
        _recordVC.aDelegate = self;
        _recordVC.useFastInit = self.useFastInit;
        [self addChildViewController:_recordVC];
        [self.view addSubview:_recordVC.view];
    }
    
    return _recordVC;
}

- (void)exchangeRecordSettingItemLevelTypeToAlbum:(BOOL)toAlbum{
    if (toAlbum) {
        self.recordLevelType = self.recordSetting.levelType;
        self.recordSetting.levelType = MDUnifiedRecordLevelTypeAsset;
    }else{
//        BOOL didShow = [[MDContext currentUser].dbStateHoldProvider hasShowedMomentRecordSpeedVaryGuide];
//        if (!didShow && self.recordSetting.levelType != MDUnifiedRecordLevelTypeAsset) {
//            NSArray *availableTaps = [self tapsByAccessSource:self.recordSetting.accessSource];
//            if ([self checkCanRecordingNeedToast:NO] && [availableTaps containsObject:@(MDUnifiedRecordLevelTypeHigh)]) {
//                [[MDContext currentUser].dbStateHoldProvider setHasShowedMomentRecordSpeedVaryGuide:YES];
//                self.recordSetting.levelType = MDUnifiedRecordLevelTypeHigh;
//            }
//        }
        
        if (self.recordSetting.levelType == MDUnifiedRecordLevelTypeAsset) {
            self.recordSetting.levelType = self.recordLevelType;
        }
    }
}

#pragma mark - 处理生命周期
- (void)exchangeCurrentVCLFrom:(UIViewController *)fromVCL toVCL:(UIViewController *)toVCL{
    [fromVCL beginAppearanceTransition:NO animated:YES];
    [toVCL beginAppearanceTransition:YES animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [fromVCL endAppearanceTransition];
        [toVCL endAppearanceTransition];
        self.currentVC = toVCL;
    });
}


#pragma mark - MDNewAssetContainerControllerDelegate
- (void)assetContainerPickerControllerDidTapTakePicture{
    if (self.animating) {
        return;
    }
    self.animating = YES;
    //相册页面点击打开拍摄 展示拍摄
    [self creatRecordVC:YES];
    self.recordVC.view.left = self.view.width;
    self.recordVC.view.hidden = NO;
    [self exchangeRecordSettingItemLevelTypeToAlbum:NO];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.recordVC.view.left = 0;
        self.pickerVC.view.left = -self.view.width;
    } completion:^(BOOL finished) {
        self.pickerVC.view.hidden = YES;
        self.animating = NO;
    }];
    
    [self exchangeCurrentVCLFrom:self.pickerVC toVCL:self.recordVC];
}

- (void)assetContainerPickerControllerDidTapBackByTransition{
    if (self.animating) {
        return;
    }
    self.animating = YES;
    //从拍摄页面打开的相册页面点了返回 相册消失
    self.recordVC.view.hidden = NO;
    [self exchangeRecordSettingItemLevelTypeToAlbum:NO];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.recordVC.view.left = 0;
        self.pickerVC.view.left = self.view.width;
    } completion:^(BOOL finished) {
        self.pickerVC.view.hidden = YES;
        self.animating = NO;
    }];
    
    [self exchangeCurrentVCLFrom:self.pickerVC toVCL:self.recordVC];
}

- (BOOL)assetContainerPickerControllerIsActive:(MDNewAssetContainerController *)sender{
    return sender == self.currentVC;
}

#pragma mark - MDUnifiedRecordViewControllerDelegate
- (void)unifiedRecordViewControllerDidTapAlbum:(BOOL)anchorToAlbumVideo{
    if (self.animating) {
        return;
    }
    self.animating = YES;
    //拍摄页面打开相册 展示相册
    [self creatPickerVC:YES];
    self.pickerVC.view.left = self.view.width;
    self.pickerVC.view.hidden = NO;
    [self exchangeRecordSettingItemLevelTypeToAlbum:YES];
    if(anchorToAlbumVideo){
        self.recordSetting.assetLevelType = MDAssetAlbumLevelTypeAlbumVideo;
    }else {
        self.recordSetting.assetLevelType = MDAssetAlbumLevelTypeAll;
    }
    
    [self.pickerVC anchorBySettingItem];
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerVC.view.left = 0;
        self.recordVC.view.left = -self.view.width;
    } completion:^(BOOL finished) {
        self.recordVC.view.hidden = YES;
        self.animating = NO;
    }];
    
    [self exchangeCurrentVCLFrom:self.recordVC toVCL:self.pickerVC];
}

- (void)unifiedRecordViewControllerDidTapBackByTransition{
    if (self.animating) {
        return;
    }
    self.animating = YES;
    //从相册页面打开的拍摄页面点了返回 拍摄消失
    self.pickerVC.view.hidden = NO;
    [self exchangeRecordSettingItemLevelTypeToAlbum:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerVC.view.left = 0;
        self.recordVC.view.left = self.view.width;
    } completion:^(BOOL finished) {
        self.recordVC.view.hidden = YES;
        self.animating = NO;
    }];
    
    [self exchangeCurrentVCLFrom:self.recordVC toVCL:self.pickerVC];
}

#pragma mark - MDNavigationBarAppearanceDelegate
- (UINavigationBar *)md_CustomNavigationBar {
    return nil;
}

- (MDUnifiedRecordLevelType)recordLevelType{
    if (_recordLevelType != MDUnifiedRecordLevelTypeAsset) {
        return _recordLevelType;
    }
    
    return MDUnifiedRecordLevelTypeNormal;
}

//根据入口显示可用tap
- (NSArray*)tapsByAccessSource:(MDVideoRecordAccessSource)source {
    
    NSMutableArray *availableTaps = [NSMutableArray array];
    
    switch (source) {
        case MDVideoRecordAccessSource_RegLogin:
            [availableTaps addObjectsFromArray:@[@(MDUnifiedRecordLevelTypeNormal)]];
            break;
        case MDVideoRecordAccessSource_GroupFeed:
        case MDVideoRecordAccessSource_QuickMatch:
        case MDVideoRecordAccessSource_SoulMatch:
        case MDVideoRecordAccessSource_Feed_photo:
        {
            [availableTaps addObjectsFromArray:@[@(MDUnifiedRecordLevelTypeAsset), @(MDUnifiedRecordLevelTypeNormal)]];
            break;
        }
        case MDVideoRecordAccessSource_Feed_video:
        {
            [availableTaps addObjectsFromArray: @[@(MDUnifiedRecordLevelTypeAsset), @(MDUnifiedRecordLevelTypeNormal),@(MDUnifiedRecordLevelTypeHigh)]];
            break;
        }
        default:
        {
            [availableTaps addObjectsFromArray:@[@(MDUnifiedRecordLevelTypeAsset), @(MDUnifiedRecordLevelTypeNormal), @(MDUnifiedRecordLevelTypeHigh)]];
            break;
        }
    }
    
    return availableTaps;
}

- (BOOL)checkCanRecordingNeedToast:(BOOL)toast {
    BOOL result = YES;
    
//    if ([MDUtility isiPhone4sModel]) {
//        if (toast) [[MDContext sharedIndicate] showAlertInView:[MDContext sharedAppDelegate].window withText:@"该设备无法使用视频功能" timeOut:1.5f];
//        result = NO;
//
//    } else
    if ([self.recordSetting.alertForForbidRecord isNotEmpty]) {
        if (toast) {
            [[MDRecordContext appWindow] makeToast:self.recordSetting.alertForForbidRecord duration:1.5f position:CSToastPositionCenter];
        }
        result = NO;
    }
    
    return result;
}
@end

