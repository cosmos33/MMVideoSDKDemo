//
//  MDRecordEditFuntionButtonView.h
//  MomoChat
//
//  Created by RFeng on 2019/4/8.
//  Copyright © 2019年 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, MDRecordEditFuntionType) {
    MDRecordEditFuntionNone = 0,
    MDRecordEditFuntionFilter   = 1 << 0, // 滤镜
    MDRecordEditFuntionGraffiti = 1 << 1, // 涂鸦
    MDRecordEditFuntionStickers = 1 << 2,  //贴纸
    MDRecordEditFuntionWord     = 1 << 3,  //文字
    MDRecordEditFuntionClip    = 1 << 4 //裁剪
};


typedef void(^MDRecordEditFuntionBlock)(MDRecordEditFuntionType funtionType);

@interface MDRecordEditFuntionButtonView : UIView

@property (nonatomic, strong) UIButton *selectButton; 

@property (nonatomic, strong) MDRecordEditFuntionBlock funtionBlock;

- (instancetype)initWithButtonWithType:(MDRecordEditFuntionType)funtionType tapFuntionBlock:(MDRecordEditFuntionBlock)funtionBlock frame:(CGRect)frame;



- (void)setBgViewHiden:(BOOL)hiden;

@end

NS_ASSUME_NONNULL_END
