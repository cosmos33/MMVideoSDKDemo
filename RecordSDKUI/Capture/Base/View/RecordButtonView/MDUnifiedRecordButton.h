//
//  MDUnifiedRecordButton.h
//  MDChat
//
//  Created by 符吉胜 on 2017/6/19.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,MDUnifiedRecordButtonType)
{
    MDUnifiedRecordButtonTypeNormal,
    MDUnifiedRecordButtonTypeHigh
};

@class MDUnifiedRecordButton;

@protocol MDUnifiedRecordButtonDelegate <NSObject>

@optional
- (void)didTapRecordButton;
- (void)didLongPressBegan;
- (void)didLongPressDragExit;
- (void)didLongPressEnded:(BOOL)pointInside;
- (NSString *)getCurrentIconUrl;

@end

@interface MDUnifiedRecordButton : UIView

//MDUnifiedRecordButtonTypeNormal : 长按时的进度反馈
@property (nonatomic,assign) CGFloat progress;

@property (nonatomic,assign) BOOL active;
@property (nonatomic, weak) id<MDUnifiedRecordButtonDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame andButtonType:(MDUnifiedRecordButtonType)buttonType;

- (void)setOffsetPercentage:(CGFloat)percentage withTargetButtonType:(MDUnifiedRecordButtonType)buttonType;
- (void)setCurrentButtonType:(MDUnifiedRecordButtonType)buttonType;

@end
