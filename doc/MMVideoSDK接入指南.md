# SDK接入指南

MMVideoSDK提供两种方式供iOS开发者选择。

* 通过cocoaspods **(推荐)**
* 手动接入

## 通过cocoapods接入

在工程的Podfile添加以下代码:

```ruby
source 'https://github.com/cosmos33/MMSpecs.git'

pod 'MMVideoSDK', '2.1.0'
```

保存并执行`pod install`。

## 手动接入

* 下载[MMVideoSDK](https://github.com/cosmos33/MMVideoSDK--iOS)
* 拖拽 `VideoSDK` 到Xcode工程内(注意勾选Copy items if needs选项)
* 添加依赖库:

    * ARKit.framework (optional)
    * AVFoundation.framework
    * CoreVideo.framework
    * CoreMedia.framework
    * CoreAudio.framework
    * CoreML.framework (optional)
    * AssetsLibrary.framework
    * Vision.framework (optional)
    * Accelerate.framework
    * Metal.framework
    * MetalKit.framework
    * CoreGraphic.framework
    * libz.tbd
    * libc++.tbd
    * libresolv.tbd
    * libiconv.tbd
  
## 工程配置

* 在info.plist中添加以下权限

```xml

* Privacy - Media Library Usage Description
* Privacy - Camera Usage Description
* Privacy - Microphone Usage Description
* Privacy - Photo Library Additions Usage Description
* Privacy - Photo Library Usage Description

```

* 进入 `EditScheme` -> `Run` -> `Options`, 更改`GPU Frame Capture` 以及 `Metal API Validation` 均为 `Disabled`
* 进入主工程`build settings`, 设置`project`以及`target`的`Enable Bitcode`为`NO`

## SDK使用

* 导入头文件

在工程AppDelegate.m 文件导入头文件

```c
    @import RecordSDK;
```

* 初始化

```c
    [MDRecordManager initSDK:@"此处替换为您的AppId"];
    if ([MDRecordManager isReady]) {
        [MDRecordManager fetchConfigUsingAppId];
    }
```
