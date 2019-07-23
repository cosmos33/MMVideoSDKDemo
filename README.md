# MDRecordSDK

## INTRODUCE

* 拍摄器SDK

通过在App中集成*拍摄器SDK*，可以集成拍摄器的功能，包括视频录制，视频编辑等功能。（**运行工程前，请执行pod install**）

## 接入环境

iOS版本: 9.0 +

## 导入

本SDK目前支持以Pod方式导入，同事本SDK划分为Base, Camera, Photo, Video四部分。

* Base为基础组件，必须引用
* Camera为视频录制模块
* Photo为图片处理模块
* Video为视频编辑模块

## 集成

* 仅集成 `MMVideoSDK`时，

在info.plist中添加以下权限

```xml

* Privacy - Media Library Usage Description
* Privacy - Camera Usage Description
* Privacy - Microphone Usage Description
* Privacy - Photo Library Additions Usage Description
* Privacy - Photo Library Usage Description

```

在Podfile中添加:

```ruby
    pod 'VideoSDK', '1.0.1'
```

在工程中引入 `@import RecordSDK`,  即可使用相关功能。


* 需要集成UI时

在info.plist中添加以下权限

```xml

* Privacy - Media Library Usage Description
* Privacy - Camera Usage Description
* Privacy - Microphone Usage Description
* Privacy - Photo Library Additions Usage Description
* Privacy - Photo Library Usage Description
* App Transport Security Settings

```

在Podfile中添加:

```ruby

source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

inhibit_all_warnings!
use_frameworks!

target :MDRecordSDK do
    pod 'MMFrameworks', :path => './MMFramework', :subspecs => ['Eta', 'MMFoundation']
    pod 'GPUImage', :git => 'https://github.com/NaichuanYang/GPUImage.git', :commit => '3ba128277babc67048e10c5269694aebaa8bf581'
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
    pod 'VideoSDK', '1.0.1'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end

```

在`Project_name-Bridging-Header.h`文件中，写入

```objective-c
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
#import "MDAlbumVideoSwitchButtonView.h"
@import RecordSDK;

```
新建`MDPublicSwiftHeader.h`头文件， 写入`#import <Project_name-Swift.h>`。 之后将MMFramework拖入工程根目录， 将RecordSDKUI拖入工程中， 并进入`build phases`，标记`JSONKit.m`, `MDSelectedImageItem.m`, `MDImagePreviewViewController`三个文件标记为`fno-objc-arc`， 然后执行`pod install`.

##  工程设置
1. 进入 `EditScheme` -> `Run` -> `Options`, 更改`GPU Frame Capture` 以及 `Metal API Validation` 均为 `Disabled`
2. 进入主工程`build settings`, 设置`project`以及`target`的`Enable Bitcode`为`NO`

## 初始化工程
1. 若接入UI相关内容，需要在appDelegale中调用 `[[MDRecordContext faceDecorationManager] requestFaceDecorationIfNeeded];` 预加载变脸素材
2. 在使用VideoSDK前调用

```objective-c
    [MDRecordManager initSDK:@"100cb616072fdc76c983460b8c2b470a"];
    if ([MDRecordManager isReady]) {
        [MDRecordManager fetchConfigUsingAppId];
    }
```

初始化SDK。

编译运行。

## 附录

接入SDK请参考: [接入文档](./SDK接入文档.md)

了解API请参考: [接口文档](./RecordSDK接口文档.md)

## 版本更新历史

* [1.0.1] 第一个开发版本，主要集成了Camera(视频录制), Video(视频编辑), Photo(图片处理)三个基本功能模块。支持多种贴纸滤镜及其它，变速，合成音乐，涂鸦，视频导出等相关功能。

## 常见问题

1. 如果遇到"@import"的报错问题，可以先通过在`build setting`-> `other c++ flags` 中，添加`-fcxx-modules`解决。
