//
//  MDMediaEditorBottomView.m
//  MDChat
//
//  Created by 符吉胜 on 2017/11/15.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMediaEditorBottomView.h"
#import "UIImage+MDUtility.h"

static const CGFloat kLeftRightMargin = 8;
static const CGFloat kButtonWH = 45;

@interface MDMediaEditorBottomView()

@property (nonatomic,strong) NSArray *titleArray;
@property (nonatomic,strong) NSArray *imageNameArray;
@property (nonatomic,strong) NSMutableArray<UIButton *> *btnArray;

@property (nonatomic,weak) id<MDMediaEditorBottomViewDelegate> delegate;

@end

@implementation MDMediaEditorBottomView

- (instancetype)initWithButtonTitleArray:(NSArray<NSString *> *)titleArray
                          imageNameArray:(NSArray<NSString *> *)imageNameArray
                                delegate:(id<MDMediaEditorBottomViewDelegate>)delegate
{
    if (self = [super init]) {
        NSAssert(titleArray.count == imageNameArray.count, @"按钮的文本和图片没有一一对应！！");
        _titleArray = titleArray;
        _imageNameArray = imageNameArray;
        _delegate = delegate;
        [self configUI];
    }
    return self;
}

- (void)configUI
{
    _btnArray = [NSMutableArray arrayWithCapacity:_titleArray.count];
    
    self.backgroundColor = [UIColor clearColor];
    self.size = CGSizeMake(MDScreenWidth, kButtonWH);
    CGFloat margin = (MDScreenWidth - (kLeftRightMargin * 2 + kButtonWH * _titleArray.count)) / (_titleArray.count - 1);
    
    for (NSInteger i = 0; i < _titleArray.count; ++i) {
        CGFloat left = kLeftRightMargin + (kButtonWH + margin) * i;
        CGRect frame = CGRectMake(left, 0, kButtonWH, kButtonWH);
        UIButton *btn = [self buttonWithFrame:frame title:_titleArray[i] image:_imageNameArray[i]];
        
        //选中效果
        if ([self.delegate respondsToSelector:@selector(selectedImageWithBtnTitle:)]) {
            UIImage *selectedImage = [self.delegate selectedImageWithBtnTitle:_titleArray[i]];
            if (selectedImage) {
                [btn setImage:selectedImage forState:UIControlStateSelected];
            }
        }
        
        //处理红点
        if ([self.delegate respondsToSelector:@selector(shouldShowRedPotintView:redPointViewTag:)]) {
            NSUInteger redPointViewTag = 0;
            BOOL shoudShow = [self.delegate shouldShowRedPotintView:_titleArray[i] redPointViewTag:&redPointViewTag];
            if (shoudShow) {
                UIImageView *redPointView = [self redPointViewLeft:(btn.width-8) withTag:redPointViewTag];
                [btn addSubview:redPointView];
            }
        }
        
        [btn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [_btnArray addObjectSafe:btn];
        [self addSubview:btn];
    }
}

- (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)text image:(NSString *)imageName
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    
    UIImage *image = [UIImage imageNamed:imageName];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:11];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    
    CGFloat space = 5;
    CGFloat titleW = [text sizeWithAttributes:@{NSFontAttributeName:btn.titleLabel.font}].width;
    CGFloat titleH = [text sizeWithAttributes:@{NSFontAttributeName:btn.titleLabel.font}].height;
    CGFloat imageW = CGRectGetWidth(btn.imageView.bounds);//imageView的宽度
    CGFloat imageH = CGRectGetHeight(btn.imageView.bounds);//imageView的高度
    
    [btn setTitleEdgeInsets:UIEdgeInsetsMake((imageH +space),-imageW, .0f, .0f)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-titleH, 0, .0f, -titleW)];
    
    return btn;
}

- (UIImageView *)redPointViewLeft:(CGFloat)left withTag:(NSUInteger)tag
{
    UIImageView *redPointView = [[UIImageView alloc] initWithFrame:CGRectMake(left, 0, 8, 8)];
    redPointView.tag = tag;
    UIImage *img = [UIImage imageWithColor:[UIColor redColor] finalSize:CGSizeMake(8, 8)];
    img = [img clipCircle];
    redPointView.image = img;
    
    return redPointView;
}

#pragma mark - event handling
- (void)didClickBtn:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(mediaEditorBottomView:didClickBtn:)]) {
        [self.delegate mediaEditorBottomView:self didClickBtn:btn];
    }
}

#pragma mark - public fuction
- (UIButton *)buttonWithATitle:(NSString *)title
{
    NSInteger index = [self.titleArray indexOfObject:title];
    return [self.btnArray objectAtIndex:index defaultValue:nil];
}

- (void)setAlpha:(CGFloat)alpha forTitleArray:(NSArray<NSString *> *)titleArray
{
    for (NSString *aTitle in titleArray) {
        UIButton *btn = [self buttonWithATitle:aTitle];
        btn.alpha = alpha;
    }
}

- (BOOL)removeRedPointWithBtnTitle:(NSString *)title andTag:(NSUInteger)tag
{
    UIButton *btn = [self buttonWithATitle:title];
    UIView *redPointView = [btn viewWithTag:tag];
    if (redPointView) {
        [redPointView removeFromSuperview];
        return YES;
    }
    return NO;
}

- (CGRect)absoluteFrameOfButtonWithBtnTitle:(NSString *)title
{
    CGRect absoluteFrame = CGRectZero;
    
    UIButton *btn = [self buttonWithATitle:title];
    absoluteFrame = [self convertRect:btn.frame toView:[MDRecordContext appWindow]];
    return absoluteFrame;
}

@end
