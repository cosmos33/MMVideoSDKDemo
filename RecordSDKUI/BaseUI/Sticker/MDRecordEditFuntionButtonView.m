//
//  MDRecordEditFuntionButtonView.m
//  MomoChat
//
//  Created by RFeng on 2019/4/8.
//  Copyright © 2019年 wemomo.com. All rights reserved.
//

#import "MDRecordEditFuntionButtonView.h"
#import "UIButton+Block.h"
#import "MDRecordGuideTipsManager.h"
//#import "MDVideoRecordDefine.h"


@interface MDRecordEditFuntionButtonView()

@property (nonatomic, assign) MDRecordEditFuntionType funtionType;

@property (nonatomic, strong) UIButton *filterSwitchButton;
@property (nonatomic, strong) UIButton *stickerButton;
@property (nonatomic, strong) UIButton *thinBodyButton;
@property (nonatomic, strong) UIView *bgView;
@end

@implementation MDRecordEditFuntionButtonView


- (instancetype)initWithButtonWithType:(MDRecordEditFuntionType)funtionType tapFuntionBlock:(MDRecordEditFuntionBlock)funtionBlock frame:(CGRect)frame;
{
    if(self = [super initWithFrame:frame]){
        self.funtionType = funtionType;
        self.funtionBlock = funtionBlock;
        [self layoutUI];
    }
    return self;
    
}
- (void)layoutUI
{
    [self setUpBgView];

    NSMutableArray<UIButton *> *buttonArray = [NSMutableArray array];
    
    if (self.funtionType & MDRecordEditFuntionFilter) {
        UIButton *button = [self creatButtonWithType:MDRecordEditFuntionFilter];
        [buttonArray addObject:button];
    }
    
    if (self.funtionType & MDRecordEditFuntionGraffiti) {
        UIButton *button = [self creatButtonWithType:MDRecordEditFuntionGraffiti];
        [buttonArray addObject:button];
    }
    
    if (self.funtionType & MDRecordEditFuntionStickers) {
        UIButton *button = [self creatButtonWithType:MDRecordEditFuntionStickers];
        [buttonArray addObject:button];
    }
    
    if (self.funtionType & MDRecordEditFuntionWord) {
        UIButton *button = [self creatButtonWithType:MDRecordEditFuntionWord];
        [buttonArray addObject:button];
    }
    
    if (self.funtionType & MDRecordEditFuntionClip) {
        UIButton *button = [self creatButtonWithType:MDRecordEditFuntionClip];
        [buttonArray addObject:button];
    }
    
    CGFloat margin = 40;
    CGFloat spaceing = (MDScreenWidth  - 30 * buttonArray.count - margin * 2) / (buttonArray.count - 1);
    
    for (int i = 0; i < buttonArray.count; i++) {
        UIButton *button = [buttonArray objectAtIndex:i];
        button.left = i * (spaceing + 30) + margin;
        [self addSubview:button];
    }
}

- (void)setUpBgView
{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *bgView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    UIView* bgView = [[UIView alloc] initWithFrame:self.bounds];
    bgView.frame = self.bounds;
    [self addSubview:bgView];
    _bgView = bgView;
    _bgView.hidden = YES;

}

- (UIButton *)creatButtonWithType:(MDRecordEditFuntionType)type
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame  = CGRectMake(0, 15, 30, 30);
    __weak typeof(self) weakself = self;
    switch (type) {
        case MDRecordEditFuntionFilter:{
            [button setImage:[UIImage imageNamed:@"icon_filter_normal"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"icon_filter_highLight"] forState:UIControlStateSelected];

            [button addAction:^(UIButton *btn) {
               

                if (weakself.funtionBlock) {
                    weakself.funtionBlock(type);
                }
                weakself.selectButton.selected = NO;
                btn.selected = YES;
                weakself.selectButton = btn;
            }];
            
        }
            break;
        case MDRecordEditFuntionGraffiti:{
            [button setImage:[UIImage imageNamed:@"icon_graffiti_normal"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"icon_graffiti_highLight"] forState:UIControlStateSelected];
            [button addAction:^(UIButton *btn) {
                if (weakself.funtionBlock) {
                    weakself.funtionBlock(type);
                }
                weakself.selectButton.selected = NO;
                btn.selected = YES;
                weakself.selectButton = btn;
            }];
        }

            break;
        case MDRecordEditFuntionStickers:{
            [button setImage:[UIImage imageNamed:@"icon_stickers_normal"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"icon_stickers_highLight"] forState:UIControlStateSelected];
            

            [button addAction:^(UIButton *btn) {

                if (weakself.funtionBlock) {
                    weakself.funtionBlock(type);
                }
                weakself.selectButton.selected = NO;
                btn.selected = YES;
                weakself.selectButton = btn;
            }];
            
        }
            break;
        case MDRecordEditFuntionWord:{
            [button setImage:[UIImage imageNamed:@"icon_word_normal"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"icon_word_normal"] forState:UIControlStateSelected];
            [button addAction:^(UIButton *btn) {
                if (weakself.funtionBlock) {
                    weakself.funtionBlock(type);
                }
                weakself.selectButton.selected = NO;
                btn.selected = YES;
                weakself.selectButton = btn;
            }];
        }
   
            break;
        case MDRecordEditFuntionClip:{
            [button setImage:[UIImage imageNamed:@"btn_moment_filter_switch"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"btn_moment_filter_switch"] forState:UIControlStateSelected];
        }
            break;
        default:
            break;
    }
    

    return button;
}


- (void)setBgViewHiden:(BOOL)hiden
{
    self.bgView.hidden = hiden;
}

@end
