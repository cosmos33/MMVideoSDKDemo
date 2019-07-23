# MMVideoSDK相关UI接入指南

目前UI仅提供手动接入方式。

## 手动接入

* 首先下载[MMVideoSDK Demo](https://github.com/cosmos33/MMVideoSDK--iOS)
* 将文件夹 `MMFramework` 以及 `RecordSDKUI` 拖入工程中
* 在Podfile中写入:

```ruby
    source 'https://github.com/cosmos33/MMSpecs.git'

    pod 'MMFrameworks', :path => './MMFramework', :subspecs => ['Eta', 'MMFoundation']
    pod 'Toast', '~> 4.0.0'
    pod 'MBProgressHUD', '~> 1.1.0'
    pod 'MJRefresh'
    pod 'SDWebImage'
    pod 'SDWebImage/WebP'
    pod 'Masonry'
    pod 'pop'
    pod 'YYImage'
    pod 'ReactiveCocoa', '2.5'
    pod 'ZipArchive'
    pod 'VideoSDK', '1.0.3'
```

* 在`Project_name-Bridging-Header.h`文件中，写入

```c
#import "MDFaceTipManager.h"
#import "MDFaceTipItem.h"
#import "MDRecordingAdapter+MDAudioPitch.h"
#import "MDMusicEditPalletController.h"
#import "MDMusicCollectionItem.h"
#import "MDMusicResourceUtility.h"
#import "MDSMSelectIntervalProgressView.h"

#import "MDMusicBVO.h"
#import "MDFaceDecorationItem.h"
#import "MDFaceDecorationFileHelper.h"
#import "MDDownLoaderModel.h"
@import RecordSDK;

```
新建`MDPublicSwiftHeader.h`头文件， 写入`#import <Project_name-Swift.h>`。 并进入`build phases`，标记`JSONKit.m`, `MDSelectedImageItem.m`, `MDImagePreviewViewController`三个文件标记为`-fno-objc-arc`， 然后执行`pod install`.

## 工程配置

* 在info.plist中添加以下权限

```xml

* Privacy - Media Library Usage Description
* Privacy - Camera Usage Description
* Privacy - Microphone Usage Description
* Privacy - Photo Library Additions Usage Description
* Privacy - Photo Library Usage Description
* App Transport Security Settings

```

* 进入 `EditScheme` -> `Run` -> `Options`, 更改`GPU Frame Capture` 以及 `Metal API Validation` 均为 `Disabled`
* 进入主工程`build settings`, 设置`project`以及`target`的`Enable Bitcode`为`NO`

## 调用

```c

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

```
