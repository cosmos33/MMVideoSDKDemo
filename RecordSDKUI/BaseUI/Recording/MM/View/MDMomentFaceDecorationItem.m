//
//  MDMomentFaceDecorationItem.m
//  MDChat
//
//  Created by 姜自佳 on 2017/5/15.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMomentFaceDecorationItem.h"
#import "MDFaceDecorationItem.h"
#import "UIImage+MDUtility.h"
#import "SDWebImage/UIButton+WebCache.h"
#import "UIView+MDSpringAnimation.h"
#import "MDRecordHeader.h"

static UIImage *seletedImg = nil;
static const CGFloat ktagLabelLeftRightMargin = 10;
static const CGFloat kLabelLeftAndRightMargin = 3;

@interface MDMomentFaceDecorationItem()

@property (nonatomic, strong) UIImageView               *bgImageView;
@property (nonatomic, strong) UIImageView               *selectedView;
@property (nonatomic, strong) UIButton                  *iconButton;
@property (nonatomic, strong) UILabel                   *tagLabel;
@property (nonatomic, strong) UIImageView               *soundIcon;
@property (nonatomic, strong) UIImageView               *downloadIcon;
@property (nonatomic, strong) CADisplayLink             *displayLink;
@property (nonatomic, strong) UIImageView               *loadingView;

@property (nonatomic, strong) UIView                    *soundIconAndTagsLabelBackgourdView;


@end

@implementation MDMomentFaceDecorationItem

- (void)updateViewWithModel:(MDFaceDecorationItem *)model{
    if (![model isKindOfClass:[MDFaceDecorationItem class]]) {
        return;
    }
    [self refreshUI:model];
}

#pragma mark --refreshUI

- (void)refreshUI:(MDFaceDecorationItem *)item {
    
    if (item.isPlaceholdItem) {
        self.iconButton.hidden =
        self.selectedView.hidden =
        self.downloadIcon.hidden =
        self.soundIconAndTagsLabelBackgourdView.hidden =
        self.tagLabel.hidden =
        self.loadingView.hidden =
        self.soundIcon.hidden = YES;
        return;
    }

    if (item.clickedToBounce) {
        [self showResourceSelectedAnimate];
        item.clickedToBounce = NO;
    }
    
    self.iconButton.hidden = ![item.imgUrlStr isNotEmpty];
#warning sunfei image
    [self.iconButton.imageView sd_setImageWithURL:[NSURL URLWithString:item.imgUrlStr]];
    self.iconButton.alpha = item.isDownloading ? 0.5f: 1.0f;
    self.tagLabel.hidden = ![item.tag isNotEmpty];
    self.tagLabel.text   =   item.tag;
    
    
    self.downloadIcon.hidden = [item.resourcePath isNotEmpty];
    
    item.isDownloading?[self showLoadingView]:
                       [self hideLoadingView];
    
    //声音图标
    self.soundIcon.hidden    = !item.haveSound;
    self.selectedView.hidden = !item.isSelected;
    self.soundIconAndTagsLabelBackgourdView.hidden = self.tagLabel.hidden;
    
    NSString *iconStr = self.tagLabel.hidden ? @"faceDecoration_soundCombine" : @"faceDecorationSound";
    UIImage *soundIconimage = [UIImage imageNamed:iconStr];
    self.soundIcon.image = soundIconimage;
    [self.soundIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(soundIconimage.size);

        if(!self.tagLabel.hidden){
            make.centerY.equalTo(self.tagLabel).offset(-0.5);
            make.left.mas_equalTo(self.soundIconAndTagsLabelBackgourdView).offset(kLabelLeftAndRightMargin);

        }else{
            make.top.equalTo(self.iconButton).offset(ktagLabelLeftRightMargin);
            make.left.mas_equalTo(self.soundIconAndTagsLabelBackgourdView);

        }
    }];
    
    
    [self.tagLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(item.haveSound){
            make.left.mas_equalTo(self.soundIcon.mas_right);
        }else{
            make.left.mas_equalTo(self.soundIconAndTagsLabelBackgourdView).offset(kLabelLeftAndRightMargin);
        }
        make.top.equalTo(self.soundIconAndTagsLabelBackgourdView).offset(1);
    }];
}


- (void)showLoadingView
{
    self.loadingView.hidden = NO;
    self.displayLink.paused = NO;
}

- (void)hideLoadingView
{
    self.loadingView.hidden = YES;
    self.displayLink.paused = YES;
}


#pragma mark --lifeCyle
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubviews];
    }
    return self;
}

#pragma mark --layoutSubviews
- (void)setupSubviews{
    
    [self addSubview:self.bgImageView];
    [self addSubview:self.iconButton];
    [self addSubview:self.selectedView];
    [self addSubview:self.downloadIcon];
    [self addSubview:self.soundIconAndTagsLabelBackgourdView];
    [self addSubview:self.tagLabel];
    [self addSubview:self.loadingView];
    [self addSubview:self.soundIcon];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self).multipliedBy(0.98);
        make.center.equalTo(self);
    }];

    [self.iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.iconButton.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.centerX.centerY.mas_equalTo(self.iconButton);
    }];
    
    [self.selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self).multipliedBy(0.98);
        make.center.equalTo(self);
    }];
    
    
    [self.downloadIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        CGSize size = CGSizeMake(15, 15);
        make.size.mas_equalTo(size);
        make.right.equalTo(self.iconButton.imageView).offset(size.width*0.5);
        make.bottom.equalTo(self.iconButton.imageView).offset(size.width*0.5);
    }];
    
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.soundIconAndTagsLabelBackgourdView).offset(1);
    }];
    
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGSize size = CGSizeMake(30, 30);
        make.size.mas_equalTo(size);
        make.centerX.centerY.equalTo(self);
    }];
    
    [_soundIconAndTagsLabelBackgourdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self).offset(ktagLabelLeftRightMargin);
        make.bottom.mas_equalTo(self.tagLabel).offset(1);
        make.right.mas_equalTo(self.tagLabel).offset(kLabelLeftAndRightMargin);

    }];
    
}


- (void)startDownLoadAnimate:(MDFaceDecorationItem *)item
{
    [self refreshUI:item];
  
    [UIView animateWithDuration:0.2f animations:^{
        self.downloadIcon.hidden = YES;
        self.iconButton.alpha = 0.5f;
    }];
}



- (void)showResourceSelectedAnimate{
    [self.iconButton springAnimation];
}

- (void)setIsSelected:(BOOL)isSelected{//显示蓝框
    self.selectedView.hidden = isSelected;
}


#pragma mark --lazy

-(CADisplayLink *)displayLink {
    
    if (!_displayLink) {
        MDWeakProxy *weakProxy = [MDWeakProxy weakProxyForObject:self];
        _displayLink = [CADisplayLink displayLinkWithTarget:weakProxy selector:@selector(displayDidRefresh:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    return _displayLink;
}

- (void)displayDidRefresh:(CADisplayLink *)displayLink {
    
    CGAffineTransform transform = self.loadingView.transform;
    
    NSTimeInterval duration = 1;
    CGFloat rotationAnglePerRefresh = (2*M_PI)/(duration*60.0);
    self.loadingView.transform = CGAffineTransformRotate(transform, rotationAnglePerRefresh);
}

- (UIButton *)iconButton{
    
    if(!_iconButton) {
        _iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _iconButton.adjustsImageWhenDisabled = NO;
        _iconButton.enabled = NO;
        [_iconButton addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _iconButton;
}

- (void)test:(UIButton*)sender{
    NSLog(@"%f",sender.alpha);
}
- (UIImageView *)selectedView{
    if (!_selectedView) {
        _selectedView = [UIImageView new];
        _selectedView.userInteractionEnabled = YES;
        _selectedView.layer.borderWidth = 1.0;
        _selectedView.layer.borderColor = RGBCOLOR(59, 179, 250).CGColor;
        _selectedView.layer.cornerRadius = 2;
        _selectedView.layer.masksToBounds = YES;
        [_selectedView setImage:seletedImg];
        _selectedView.hidden = YES;
    }
    
    return _selectedView;
}



- (UIImageView *)downloadIcon{
    if (!_downloadIcon) {
        _downloadIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *img = [UIImage imageNamed:@"icon_moment_download"];
        _downloadIcon.image = img;
        _downloadIcon.hidden = YES;
    }
    
    return _downloadIcon;
}


- (UIImageView *)loadingView{
    if (!_loadingView) {
        _loadingView = [UIImageView new];
        _loadingView.image = [UIImage imageNamed:@"moment_play_loading"];
        _loadingView.center = self.iconButton.center;
    }
    
    return _loadingView;
}



- (UILabel *)tagLabel{
    if (!_tagLabel) {
        UIFont *font = [UIFont boldSystemFontOfSize:8];
        _tagLabel = [UILabel new];
        _tagLabel.hidden = YES;
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.font = font;
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.layer.cornerRadius  = 2.0f;
        _tagLabel.layer.masksToBounds = YES;
    }
    
    return _tagLabel;
}



- (UIImageView *)soundIcon
{
    if (!_soundIcon) {
        _soundIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    return _soundIcon;
}

- (UIView *)soundIconAndTagsLabelBackgourdView{
    if(!_soundIconAndTagsLabelBackgourdView){
        _soundIconAndTagsLabelBackgourdView = [UIView new];
        _soundIconAndTagsLabelBackgourdView.backgroundColor = RGBCOLOR(59, 179, 250);
        _soundIconAndTagsLabelBackgourdView.layer.cornerRadius  = 2.0f;
        _soundIconAndTagsLabelBackgourdView.layer.masksToBounds = YES;
    }
    return _soundIconAndTagsLabelBackgourdView;
}

- (UIImageView *)bgImageView
{
    if (!_bgImageView) {
        
        _bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        [_bgImageView setImage:[UIImage imageNamed:@"face_decoration_item_back"]];
    }
    
    return _bgImageView;
}

@end
