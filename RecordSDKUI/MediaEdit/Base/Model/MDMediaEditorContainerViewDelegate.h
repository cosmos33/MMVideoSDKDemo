//
//  MDMediaEditorContainerViewDelegate.h
//  MDChat
//
//  Created by YZK on 2017/8/24.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDBaseSticker,MDMomentTextSticker;


@protocol MDMediaEditorContainerViewDelegate <NSObject>

- (CGRect)videoRenderFrame;
- (NSString *)doneButtonTitle;
- (NSString *)currentTopicName;
- (BOOL)shouldShowTopicView;
- (BOOL)shouldReSendVideo;
- (BOOL)isCaptureFace;

- (BOOL)isSelectedMusic;

- (void)custumContentViewTapped; //背景视图点击

- (void)doneButtonTapped; //完成按钮点击
- (void)reSendBtnTapped; //重新拍摄按钮点击
- (void)cancelButtonTapped; //取消按钮点击
- (void)showTopicSelectTable; //话题按钮点击

- (void)thinBodyBtnTapped; //瘦身按钮点击
- (void)specialEffectsBtnTapped; //特效滤镜按钮点击

- (void)filterButtonTapped;
- (void)stickerEditButtonTapped; //贴纸按钮点击
- (void)textButtonTapped; //文字按钮点击
- (void)audioMixButtonTapped; //配乐按钮点击
- (void)thumbSelectButtonTapped; //封面按钮点击
- (void)moreActionsBtnTapped; //更多按钮点击
- (void)saveButtonTapped; //下载按钮点击
- (void)speedVaryButtonTapped; //变速按钮点击
- (void)painterEditButtonTapped; //涂鸦按钮点击

- (void)arPetQualityCancelBlockEvent;

//- (void)mediaStickerNeedDelete:(MDBaseSticker *)sticker; //贴纸移动结束,需要删除贴纸
//- (void)textStickerNeedDelete:(MDMomentTextSticker *)sticker; //文字移动结束,需要删除文字
//- (void)textStickerDidTapped:(MDMomentTextSticker *)sticker; //文字贴纸点击

@end
