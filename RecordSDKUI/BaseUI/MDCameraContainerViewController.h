//
//  MDCameraContainerViewController.h
//  MDChat
//
//  Created by lm on 2017/6/10.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDViewController.h"
#import "MDUnifiedRecordSettingItem.h"
#import "MDCameraBottomView.h"
#import "MDUserFeedGuideModel.h"
@interface MDCameraContainerViewController : MDViewController

//相册与录制参数
@property (nonatomic, strong) MDUnifiedRecordSettingItem            *recordSetting;

@property (nonatomic, assign) BOOL                                  useFastInit; //使用快速初始化，解决首页滑动卡顿问题
@property (nonatomic, assign, getter=isNeedCheckConflict) BOOL      needCheckConflict;  /**< 在切换Type的时候，是否需要检测音视频冲突，默认为YES */

@property (nonatomic, assign) BOOL                                  showPictureButton; ///<是否展示拍照按钮, 默认 YES

//个人动态存在的照片
@property (nonatomic, strong) MDUserFeedGuideShowModel *userFeedShowModel;
+ (BOOL)checkDevicePermission;


@end
