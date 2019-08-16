//
//  MDRecordEditProtocol.h
//  MomoChat
//
//  Created by RFeng on 2019/4/9.
//  Copyright © 2019年 wemomo.com. All rights reserved.
//

#ifndef MDRecordEditProtocol_h
#define MDRecordEditProtocol_h

@protocol MDMomentPainterToolViewDelegate <NSObject>

@optional
- (void)brushButtonTapped:(UIColor *)color;
- (void)imageMosaicButtonTapped:(UIColor *)color;
- (void)mosaicButtonTapped;
- (void)undoAction;

@end

@protocol MDRecordEditContainerPanel <NSObject>

- (NSArray <NSString *> *)editTitles;

@optional
- (void)editSelectWithTitle:(NSString *)title;

@end


@protocol  MDRecordStickersEditViewDelegate <NSObject>

- (void)collectionViewDidSelectDateArrayAtIndexUrlDictionary:(NSDictionary *)urlDict;

@end


@protocol MDRecordEditContainerPanelActionDelegate <NSObject, MDRecordStickersEditViewDelegate>


@property (nonatomic, strong) UIView *graffitiEditView;

@property (nonatomic, strong) UIView *filterEditView;

@property (nonatomic, strong) UIView *stickersEditView;


- (void)showGrafftieEditPanel;
// 文字贴纸
- (void)showTextStickers;
// 隐藏涂鸦面板
- (void)hideGrafftieEditPanel;
// 表情贴纸
- (void)showEmationStickersPanel;
// 展示滤镜面板
- (void)showFilterPanel;



@end

@protocol MDRecordEditContainerPanelAnimationDelegate <NSObject>

- (void)animationWillStartToChangePanelHeight:(CGFloat)height;
- (void)animationInProgressTochangePanelHeight:(CGFloat)height;
- (void)animationDidFinsh:(BOOL)finsh panelHeight:(CGFloat)height;

@end



 typedef void(^MDEditActionBlock)(id obj);


typedef void (^MDNoParmBlock)();

@protocol MDRecordTrastionDelegate <NSObject>

- (void)animationTrastionInProgressWithBottom:(CGFloat)bottom;
- (void)animationTrastionWithBottom:(CGFloat)bottom completion:(BOOL)finshed;

@end


#endif /* MDRecordEditProtocol_h */
