# SDK接入文档

## 工程配置

### 系统版本

支持iOS 9.0 及以上版本

### 开发环境

建议您使用macOS High Sierra 10.13 Xcode9.0及以上版本的开发环境。

### 项目配置

打开工程info.Plist，添加以下权限：

* Privacy - Media Library Usage Description
* Privacy - Camera Usage Description
* Privacy - Microphone Usage Description
* Privacy - Photo Library Additions Usage Description
* Privacy - Photo Library Usage Description

配置Build Setting — Build Options — Enable Bitcode, 设置为NO。

## 基本信息

### 获取SDK版本

短视频SDK提供了`MDRecordManager`来获取SDK版本的信息。

* 获取版本号

```c
+ (NSString *)version;
```

### 视频分辨率

视频分辨率指的是视频横向和纵向上的有效像素，理论上视频分辨率越高，图像越清晰。但分辨率越高也意味着文件越大，处理越耗时。移动端考虑到不同设备性能差异，建议设置分辨率720p及以下。

> **注意**, 不要直接使用屏幕像素值作为视频分辨率。

### 编码方式

目前SDK只支持硬编码。

### 支持格式

类型 | 格式
--- | ---
视频 | MP4, MOV, FLV
音频 | MP3, AAC, PCM
图片 | JPG， PNG

## SDK初始配置

* 首先通过`MDRecordManger`类调用

```c
+ (void)initSDK:(NSString *)appID;
```

方法传入appID完成SDK初始化。然后通过

```c
+ (void)fetchConfigUsingAppId;
```

拉取配置文件。可通过

```c
+ (void) addCommandListener: (SEL) mSelctor target:(id) mTarget;
```

方法注册回调函数，其中 mSelctor 需携带一个`CallbackMessage`类型的参数。 当 `CallbackMessage`的 `command` 属性值为 `COMMAND_REGISTER`时, `message`属性携带的便是`Token`.

之后可通过 `MDRecordManger` 类

```c
+ (NSString *)appToken;
```

方法获取`Token`. 该`Token`用于初始化相关功能类句柄。

* 调用`MDRecordDetectorManger`类

```c
- (void)config;
```

初始化模型加载器, 用于模型下载以及创建。

## 视频录制

### 功能介绍

短视频SDK提供基础视频录制功能，支持添加配乐，变速录制，人脸贴纸，特效滤镜等。核心类是 `MDRecordingAdapter`.

### 录制流程

#### 初始化设置

* 初始化

```c
   _adapter = [[MDRecordingAdapter alloc] initWithToken:@"Token"];
```

* 设置相机参数并初始化相机

```c
   // 设置编码格式
   [adapter setVideoCodecKey:AVVideoCodecH264];  
   // 设置码率
   [adapter setVideoBitRate:5.0 * 1024 * 1024];
   // 设置视频分辨率
   [adapter setVideoResolution:CGSizeMake(720, 1280)];
   // 设置视频缩放模式
   [adapter setVideoScaleMode:AVVideoScalingModeResizeAspectFill];
   // 设置采样分辨率
   [adapter setCameraPreset:AVCaptureSessionPreset1280x720];
   // 设置摄像头位置
   [adapter setCameraPosition:AVCaptureDevicePositionFront];;
   // 初始化摄像机
   [adapter setupRecorder];
```

* 获得预览视图, 并添加到view层级中

```c
   UIView<MLPixelBufferDisplay> *previewView = self.adapter.previewView;
   previewView.frame = containerView.frame;
   [containerView addSubview:previewView];
```

* 开启相机

```c
    // 开启相机
    [self.adapter startCapturing];

    // 关闭相机
    [self.adapter stopCapturing];
```

* 聚焦

```c
   [self.adapter focusCameraInPoint:pointInCamera];
```

* 拍照

```c
    // 设置即将拍照回调
    self.adapter.captureStillImageWillHandler = self.captureStillImageWillHandler;
    // 设置拍照完成的回调
    self.adapter.captureStillImageHandler = self.captureStillImageHandler;
    // 拍照
    [self.adapter takePhoto];
```

* 旋转相机

```c
   [self.adapter switchCameraPosition];
```

* 设置最大录制时长

```c
    [self.adapter setMaxRecordDuration:60];
```

* 录制一段视频，多次调用可以录制多段视频

```c
    // 开始录制
    [self.adapter startRecording];
    // 完成一段录制
    [self.adapter pauseRecording];
```

* 结束录制

```c
    // 结束录制，并将录制的多段视频合并后导出整个视频文件
    [self.adapter stopVideoCaptureWithOutputURL:destUrl completionHandler:completionHandler];
```

* 删除已录制片段

```c
    // 删除最后一段录制内容
    [self.recorder deleteLastVideoSegment];

    // 清空所有已录制的视频段
    [self.recorder reset];
```

* 获取录制相关信息

```c
    // 能否启用录制
    self.adapter.isRecording;
    // 获得已录制的视频时长
    [self.adapter currentRecordingDuration];
    // 获得真实展示时长(因为有变速效果，因此这个时间跟已录制的视频真实时长可能不同)
    [self.adapter currentRecordingPresentDuration];
    // 获得录制的视频段数
    [self.adapter savedSegmentCount];
```

* 设置配乐

```c
    self.adapter.backgroundAudio = backgroundAudio;
```

* 贴纸

```c
    // 添加贴纸
    [self.adapter updateDecoration:decoration];
    // 移除贴纸
    [self.adapter removeDecoration];
    // 调整贴纸音效(对于有音效的贴纸而言)
    [self.adapter adjustStikcerVolume:mute ? .0f : 1.0f];
```

* 切换滤镜

```c
    [self.adapter configFilterA:filterA configFilterB:filterB offset:filterOffset];
```

* 设置美颜参数

```c
    // 磨皮, 参数范围0-1
    [self.adapter setSkinSmoothValue:skinSmoothFactor];
    // 美白, 参数范围0-1
    [self.adapter setSkinWhitenValue:skinWhitenFactor];
    // 大眼, 参数范围0-1
    [self.adapter setBeautyBigEyeValue:bigEyeFactor];
    // 瘦脸, 参数范围0-1
    [self.adapter setBeautyThinFaceValue:thinFaceFactor];
    // 瘦身, 参数范围0-1
    [self.adapter setBeautyThinBodyValue:thinBodyFactor];
    // 长腿, 参数范围0-1
    [self.adapter setBeautyLenghLegValue:longLegFactor];
```

* 变速

```c
   // 是否允许当前段变速, 允许传入YES
   [self.adapter speedVaryShouldAllow:isAllow];
   // 设置当前段变速因子, 取值范围 0.2 - 4.0
   [self.adapter setNextRecordSegmentSpeedVaryFactor:factor];
   // 当前段是否有变速效果
   [self.adapter hasPerSpeedEffect];
```

关于录制其它操作请参考接口文档。

## 视频编辑

### 功能介绍

短视频SDK提供基础的视频编辑相关功能。可以进行视频裁剪，添加水印，静态贴纸，配乐，时间特化，画面特效等功能。核心类是`MDVideoEditorAdapter`

### 视频编辑流程

* 初始化

```c
    _adapter = [[MDVideoEditorAdapter alloc] initWithToken:@"Token"];
```

* 获取播放视图

```c
   self.adapter.playerViewController.view.frame = self.viewController.view.bounds;
   [self.viewController addChildViewController:self.adapter.playerViewController];
   [self.viewController.view insertSubview:self.adapter.playerViewController.view atIndex:0];
   [self.adapter.playerViewController didMoveToParentViewController:self.viewController];
```

* 视频播放

```c
    // 播放
    [self.adapter play];
    // 暂停
    [self.adapter pause];
    // 停止
    [self.adapter stop];
    // 重播
    [self.adapter replay];
```

* 播放事件处理

```c
    // 播放结束回调
    __weak typeof(self) weakself = self;
    self.adapter.playToEndTime = ^(AVPlayer * _Nonnull player) {
        __strong typeof(self) self = weakself;
        if (![self.speedVaryVc isViewVisible] && self.exportTask == nil && !self.specialEffectsVc.isShow) {
            [player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [self play];
        }
    };
    // 播放进度回调
    self.adapter.playerPeriodicTimeCallback = ^(CMTime time) {
        __strong typeof(self) self = weakself;
        if ([self.musicSelectPicker viewIsShowing]) {
            [self.musicSelectPicker periodicTimeCallback:time];
        }
    };
```

* 视频处理

```c
    MDVideoEditorAdapter *adapter = self.adapter;
    // 视频裁剪时间段
    [adapter setVideoTimeRange:videoInsertTimeRange];
    // 视频旋转方向
    [adapter setVideoPerferredTransform:ideoPreferredTransform];
    // 设置重复
    [adapter setMediaSourceRepeatRange:repeatTimeRange];
    // 设置变速效果
    [adapter setTimeRangeMappingEffects:timerangeMappingEffects];
    // 设置背景音乐
    adapter.backgroundAudioURL = backgroundMusicURL;
    // 设置背景音乐截取时间
    adapter.backgroundAudioRange = backgroundMusicTimeRange;
    // 设置原音音量
    [adapter setSourceVolume:sourceAudioVolume];
    // 设置背景音音量
    [adapter setBackgroundMusicVolume:backgroundMusicVolume];
    // 设置视频源
    [adapter loadVideo:videoAsset];
    // 合成视频
    [self.adapter compositeVideoWithError:NULL];
```

**注意：** 在调用`compositeVideoWithError:`方法前，所有对视频或者配乐的编辑行为均不生效。

```c
    // 设置原音音量
    [adapter setSourceVolume:sourceAudioVolume];
    // 设置背景音音量
    [adapter setBackgroundMusicVolume:backgroundMusicVolume];
    // 合成音效.
    [self.adapter updateAudioMix];
```

**注意：** 如果仅合成音效，则调用`updateAudioMix`方法效率更高。

* 贴纸

```c
    // 添加贴纸
    [self.adapter updateDecoration:decoration];
    // 移除贴纸
    [self.adapter removeDecoration];
    // 调整贴纸音效(对于有音效的贴纸而言)
    [self.adapter adjustStikcerVolume:mute ? .0f : 1.0f];
```

* 切换滤镜

```c
    [self.adapter configFilterA:filterA configFilterB:filterB offset:filterOffset];
```

* 设置美颜参数

```c
    // 磨皮, 参数范围0-1
    [self.adapter setSkinSmoothValue:skinSmoothFactor];
    // 美白, 参数范围0-1
    [self.adapter setSkinWhitenValue:skinWhitenFactor];
    // 大眼, 参数范围0-1
    [self.adapter setBeautyBigEyeValue:bigEyeFactor];
    // 瘦脸, 参数范围0-1
    [self.adapter setBeautyThinFaceValue:thinFaceFactor];
    // 瘦身, 参数范围0-1
    [self.adapter setBeautyThinBodyValue:thinBodyFactor];
    // 长腿, 参数范围0-1
    [self.adapter setBeautyLenghLegValue:longLegFactor];
```

* 融合涂鸦图片

```c
   [self.adapter setGraffitiCanvasImage:canvasImage mosaicCanvasImage:mosaicCanvasImage];
```

* 动态贴纸

```c
   // 添加贴纸
   [self.adapter addDynamicSticker:(id)sticker];
   // 移除贴纸(与添加时候需要是同一个对象)
   [self.adapter removeDynamicSticker:(id)aSticker];
```

* 特效滤镜

```c
   // 在某一时间段内添加特效滤镜
   [self.adapter addSpecialFilter:filter timeRange:timeRange];
   // 移除最后一个特效滤镜
   [self.adapter deleteLastSpecialFilter];
   // 移除所有特效滤镜
   [self.adapter deleteAllSpecialFilters];
   // 更新选中时间的特效滤镜起作用的时长
   [self.adapter updateCurrentItemWithTime:time timeRange:timeRange];
   // 是否存在特效滤镜
   [self.adapter hasSpecialFilter];
   // 所有特效滤镜
   [self.adapter specialFilters];
```

**注意：** 目前SDK默认支持 雨窗，灵魂出窍，抖动，故障，四宫格五中特效滤镜。分别为: 

```c
   MDRecordRainWindowFilter
   MDRecordSoulOutFilter
   MDRecordShakeFilter
   MDRecordTVArtifactFilter
   MDRecordMirrImageFrameFilter
```

自定义特效滤镜可以通过实现 `MDFilterLifeStyle` 协议的 `GPUImageFilter` 实现。

* 导出

```c
    // 设置导出时候要融合的图片
    self.adapter.overlayImage = customOverlay;
    // 设置导出码率
    [self.adapter setTargetBitRate:sourceBitRate];
    // 设置导出视频大小
    [self.adapter setPresentationSize:presentationSize];
    // 更新builder设置
    [self updateBuilderSetting];
    // 设置是否需要经过滤镜(建议有改动时候再设为YES以便优化效率)
    [self.adapter enableFilterEffect:YES];
    // 导出编辑后视频
    __weak typeof(self) weakSelf = self;
    self.exportTask = [self.adapter exportToURL:url progressHandler:^(double progress) {
        [weakSelf.delegate exportingWithProgress:progress];
    } completion:^(NSURL * _Nonnull url) {
        [weakSelf handleExportFinishWithUrl:url error:nil];
        completionHandler(url);
    } failure:^(NSError * _Nullable error) {
        [weakSelf handleExportFinishWithUrl:url error:error];
        failHandler(error);
    }];
    // 取消导出
    [self.exportTask cancel];
```

## 图片编辑

### 图片编辑功能介绍

图片编辑提供了图片添加滤镜，增加水印等效果。核心类是`MDImageEditorAdapter`

### 图片编辑

* 初始化

```c
    _adapter = [[MDImageEditorAdapter alloc] initWithToken:@"Token"];
```

* 加载图片

```c
    // 加载图片并设置回调，回调函数返回处理完成的结果
    [self.adapter loadImage:originImage completionHander:^(CVPixelBufferRef renderedPixelBuffer, NSError * error) {
            __strong typeof(self) strongself = weakself;
            // save to renderredPixelBuffer
            if (strongself.renderedPixelBuffer) {
                CVPixelBufferRelease(strongself.renderedPixelBuffer);
                strongself.renderedPixelBuffer = NULL;
            }
            strongself.renderedPixelBuffer = renderedPixelBuffer;
            CVPixelBufferRetain(strongself.renderedPixelBuffer);
            // show image
            [strongself.previewView presentPixelBuffer:renderedPixelBuffer];

        }];
```

* 处理图片

```c
    // 开始处理
    [self.adapter startProcess];

    // 结束处理并释放资源(仅在dealloc中调用一次即可)
    [self.adapter stopProcess];
```

* 切换滤镜

```c
    [self.adapter configFilterA:filterA configFilterB:filterB offset:filterOffset];
```

* 设置美颜参数

```c
    // 磨皮, 参数范围0-1
    [self.adapter setSkinSmoothValue:skinSmoothFactor];
    // 美白, 参数范围0-1
    [self.adapter setSkinWhitenValue:skinWhitenFactor];
    // 大眼, 参数范围0-1
    [self.adapter setBeautyBigEyeValue:bigEyeFactor];
    // 瘦脸, 参数范围0-1
    [self.adapter setBeautyThinFaceValue:thinFaceFactor];
    // 瘦身, 参数范围0-1
    [self.adapter setBeautyThinBodyValue:thinBodyFactor];
    // 长腿, 参数范围0-1
    [self.adapter setBeautyLenghLegValue:longLegFactor];
```

其它功能请参考图片处理接口文档。

