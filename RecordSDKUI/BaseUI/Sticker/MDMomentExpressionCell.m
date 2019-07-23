//
//  MDMomentExpressionCell.m
//  MDChat
//
//  Created by Leery on 16/7/25.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDMomentExpressionCell.h"
#import <MMFoundation/MMFoundation.h>
#import "SDWebImage/UIImageView+WebCache.h"

#if !__has_feature(objc_arc)
#error MDMomentExpressionCell must be built with ARC.
#endif

@interface MDMomentExpressionCell ()

@property (nonatomic ,strong) UIImageView               *expressView;
@property (nonatomic ,strong) UIActivityIndicatorView   *aiv; //菊花

@property (nonatomic, strong) CADisplayLink             *displayLink;
@property (nonatomic, strong) UIImageView               *loadingView;
@property (nonatomic, strong) UIImageView               *downloadIcon;

@end

@implementation MDMomentExpressionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self setupAllContents];
        
    }
    return self;
}

- (UIImageView *)cellContentView {
    return self.expressView;
}

- (void)bindModel:(MDMomentExpressionCellModel*)model {
    if([model isKindOfClass:[MDMomentExpressionCellModel class]]) {
        
        [self refreshAllContents:model.picUrl];
        
        if (model.downLoadModel.state == MDDownLoadStateLoading) {
            [self showLoadingView];
        } else {
            [self hideLoadingView];
        }
    }
}

- (void)setupAllContents {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.expressView];
    [self.expressView addSubview:self.loadingView];
    [self.expressView addSubview:self.aiv];
    
    [self updateAllFrames];
    
    [self.aiv startAnimating];
    [self hideActivityIndicatorWhenNeed];
}

- (void)hideActivityIndicatorWhenNeed {
    __weak __typeof(self) weakSelf = self;
#warning sunfei image
//    self.expressView.modifyBlock =  ^UIImage *(UIImage *image){
//        
//        [weakSelf.aiv stopAnimating];
//        [weakSelf.aiv removeFromSuperview];
//        return image;
//    };
}

- (void)updateAllFrames {
    self.expressView.frame = self.bounds;
    self.aiv.center = self.expressView.center;
}

- (void)refreshAllContents:(NSString *)urlString {
    if([urlString isKindOfClass:[NSString class]] && [urlString isNotEmpty]){
        __weak __typeof(self) weakSelf = self;
        [self.expressView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [weakSelf.aiv stopAnimating];
            [weakSelf.aiv removeFromSuperview];
        }];
    }
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

#pragma mark - 懒加载UI
- (UIImageView *)expressView {
    if(!_expressView) {
        _expressView = [[UIImageView alloc] initWithFrame:self.bounds];
        _expressView.contentMode = UIViewContentModeScaleAspectFit;
        _expressView.clipsToBounds = YES;
        _expressView.backgroundColor = [UIColor clearColor];
        //_expressView.backgroundColor = [UIColor colorWithHue:( arc4random() % 256 / 256.0 ) saturation:( arc4random() % 128 / 256.0 ) + 0.5 brightness:( arc4random() % 128 / 256.0 ) + 0.5 alpha:1];
        _expressView.userInteractionEnabled = NO;
    }
    return _expressView;
}

- (UIActivityIndicatorView *)aiv {
    if(!_aiv) {
        _aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _aiv.backgroundColor = [UIColor clearColor];
    }
    return _aiv;
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
        _loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _loadingView.image = [UIImage imageNamed:@"moment_play_loading"];
        _loadingView.center = self.expressView.center;
    }
    
    return _loadingView;
}

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

@end
