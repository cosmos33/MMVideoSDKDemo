//
//  MDUnifiedRecordViewController.h
//  MDChat
//
//  Created by 符吉胜 on 2017/6/2.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDViewController.h"
#import "MDUnifiedRecordContainerView.h"
#import "MDCameraBottomView.h"

@class MDUnifiedRecordSettingItem;
@class MDMomentMusicListCellModel;
@class MDUnifiedRecordModuleAggregate;

@protocol MDUnifiedRecordViewControllerDelegate <NSObject>
- (void)unifiedRecordViewControllerDidTapAlbum:(BOOL)anchorToAlbumVideo;
- (void)unifiedRecordViewControllerDidTapBackByTransition;
@end

@interface MDUnifiedRecordViewController : MDViewController
@property (nonatomic,weak) id<MDUnifiedRecordViewControllerDelegate>   aDelegate;
//使用快速初始化，解决首页滑动卡顿问题
@property (nonatomic, assign) BOOL                                      useFastInit;
@property (nonatomic, strong) MDUnifiedRecordSettingItem                *settingItem;

@property (nonatomic, strong, readonly) MDUnifiedRecordContainerView    *containerView;
@property (nonatomic, strong, readonly) MDCameraBottomView              *bottomView;

#pragma mark -仅category可以调用
@property (nonatomic,strong,readonly) MDUnifiedRecordModuleAggregate    *moduleAggregate;

- (instancetype)initWithSettingItem:(MDUnifiedRecordSettingItem *)settingItem;
- (instancetype)initWithSettingItem:(MDUnifiedRecordSettingItem *)settingItem fromAlbum:(BOOL)fromAlbum;

- (BOOL)isBottomViewHidden;
- (void)showBottomViewWithAnimation:(BOOL)isAnimated;
- (void)hideBottomViewWithAnimation:(BOOL)isAnimated;
- (void)setFromAlbum:(BOOL)fromAlbum;
#pragma mark - 仅category可以调用
- (void)handleRotate:(UIDeviceOrientation)orientation needResponse:(BOOL)needResponse;

@end
