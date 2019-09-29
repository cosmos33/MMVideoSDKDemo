//
//  MDAssetPreviewCell.m
//  MDChat
//
//  Created by Aaron on 16/6/29.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDAssetPreviewCell.h"
#import "MDRecordHeader.h"

@interface MDAssetPreviewCell()

@property (nonatomic, strong) UIScrollView  *imageScrollView;

@end

@implementation MDAssetPreviewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self imageScrollView];
    }
    return self;
}

-(UIScrollView *)imageScrollView {
    if (!_imageScrollView) {
        _imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)];
        _imageScrollView.layer.masksToBounds = NO;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator = NO;
        _imageScrollView.maximumZoomScale = 2.0;
        _imageScrollView.minimumZoomScale = 1.0;
        _imageScrollView.backgroundColor = [UIColor blackColor];
        _imageScrollView.delegate = (id<UIScrollViewDelegate>) self;
        [self.contentView addSubview: _imageScrollView];
        [_imageScrollView addSubview:self.previewImageView];
    }
    return _imageScrollView;
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
    if(self.imageScrollView.zoomScale > self.imageScrollView.minimumZoomScale)
        [self.imageScrollView setZoomScale:self.imageScrollView.minimumZoomScale animated:YES];
    else
        [self.imageScrollView setZoomScale:self.imageScrollView.maximumZoomScale animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.previewImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    self.previewImageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

-(UIImageView *)previewImageView
{
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        _previewImageView.userInteractionEnabled = YES;
    }
    return _previewImageView;
}

@end
