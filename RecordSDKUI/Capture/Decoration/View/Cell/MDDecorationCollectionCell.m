//
//  MDDecorationCollectionCell.m
//  MomoChat
//
//  Created by YZK on 2019/4/13.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "MDDecorationCollectionCell.h"
#import "MDFaceDecorationItem.h"
#import "UIView+Utils.h"
#import "UIConst.h"
#import <MMFoundation/MDWeakProxy.h>
@import SDWebImage;

static const CGFloat kMDDecorationCollectionCellCornerRadius = 8.0;

@interface MDDecorationCollectionCell ()

@property (nonatomic, strong) UIImageView               *iconView;
@property (nonatomic, strong) UILabel                   *tagLabel;
@property (nonatomic, strong) UIImageView               *selectedView;
@property (nonatomic, strong) UIImageView               *downloadIcon;
@property (nonatomic, strong) CADisplayLink             *displayLink;
@property (nonatomic, strong) UIImageView               *loadingBgView;
@property (nonatomic, strong) UIImageView               *loadingView;

@end

@implementation MDDecorationCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.iconView];
        [self addSubview:self.tagLabel];
        [self addSubview:self.downloadIcon];
        [self addSubview:self.selectedView];
        
        [self.iconView addSubview:self.loadingBgView];
        [self.loadingBgView addSubview:self.loadingView];
    }
    return self;
}

#pragma mark - public

- (void)bindModel:(MDFaceDecorationItem *)item {

    [self.iconView sd_setImageWithURL:[NSURL URLWithString:item.imgUrlStr]];
    self.iconView.alpha = item.isDownloading ? 0.5f: 1.0f;
    
    self.tagLabel.hidden = item.tag.length == 0;
    if (!self.tagLabel.hidden) {
        self.tagLabel.text = item.tag;
        CGFloat width = [self.tagLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
        self.tagLabel.width = ceil(width) + 8;
        
        self.tagLabel.backgroundColor = RGBCOLOR(76, 211, 234);
    }
    
    self.downloadIcon.hidden = item.resourcePath.length > 0;
    item.isDownloading ? [self _showLoadingView] : [self _hideLoadingView];
    
    self.selectedView.hidden = !item.isSelected;
}

- (void)startDownLoadAnimate:(MDFaceDecorationItem *)item
{
    [self bindModel:item];
    [UIView animateWithDuration:0.2f animations:^{
        self.iconView.alpha = 0.5f;
    }];
}

- (void)setCellSelected:(BOOL)isSelected{//显示蓝框
    self.selectedView.hidden = isSelected;
}

#pragma mark - private

- (void)_showLoadingView
{
    self.loadingBgView.hidden = NO;
    self.displayLink.paused = NO;
}

- (void)_hideLoadingView
{
    self.loadingBgView.hidden = YES;
    self.displayLink.paused = YES;
}

#pragma mark --lazy

-(CADisplayLink *)displayLink {
    if (!_displayLink) {
         MDWeakProxy *weakProxy = [MDWeakProxy weakProxyForObject:self];
        _displayLink = [CADisplayLink displayLinkWithTarget:weakProxy selector:@selector(displayDidRefresh:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
    }
    return _displayLink;
}

- (void)displayDidRefresh:(CADisplayLink *)displayLink {
    CGAffineTransform transform = self.loadingView.transform;
    NSTimeInterval duration = 1;
    CGFloat rotationAnglePerRefresh = (2*M_PI)/(duration*60.0);
    self.loadingView.transform = CGAffineTransformRotate(transform, rotationAnglePerRefresh);
}

- (UIImageView *)iconView{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:self.bounds];
        _iconView.layer.cornerRadius = kMDDecorationCollectionCellCornerRadius;
        _iconView.layer.masksToBounds = YES;
    }
    return _iconView;
}

- (UILabel *)tagLabel{
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.5, 2, 0, 12)];
        _tagLabel.hidden = YES;
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.font = [UIFont boldSystemFontOfSize:9];
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.backgroundColor = RGBCOLOR(76, 211, 234);
        _tagLabel.layer.cornerRadius  = 6.0f;
        _tagLabel.layer.masksToBounds = YES;
    }
    return _tagLabel;
}

- (UIImageView *)selectedView{
    if (!_selectedView) {
        _selectedView = [[UIImageView alloc] initWithFrame:self.bounds];
        _selectedView.image = [UIImage imageNamed:@"icon_camera_decoration_select"];
        _selectedView.hidden = YES;
    }
    return _selectedView;
}

- (UIImageView *)downloadIcon {
    if (!_downloadIcon) {
        _downloadIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-15, self.height-15, 15, 15)];
        _downloadIcon.image = [UIImage imageNamed:@"icon_camera_decoration_download"];
        _downloadIcon.hidden = YES;
    }
    return _downloadIcon;
}

- (UIImageView *)loadingBgView{
    if (!_loadingBgView) {
        _loadingBgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _loadingBgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
        _loadingBgView.hidden = YES;
    }
    return _loadingBgView;
}

- (UIImageView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_camera_decoration_loading"]];
        _loadingView.size = CGSizeMake(15, 15);
        _loadingView.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    }
    return _loadingView;
}




@end
