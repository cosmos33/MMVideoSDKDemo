//
//  MDImagePreviewViewController.m
//  MDChat
//
//  Created by Aaron on 14/11/7.
//  Copyright (c) 2014年 sdk.com. All rights reserved.
//

#import "MDImagePreviewViewController.h"
#import "MDRecordHeader.h"
#import <POP/POP.h>

@interface MDImagePreviewViewController()

@property (nonatomic, retain) UIImage       *previewImage;
@property (nonatomic, retain) UIImageView   *mainImageView;

@property (nonatomic, retain) UIButton      *deleteBtn;
@property (nonatomic, retain) UIButton      *gotoBtn;

@property (nonatomic, retain) UIScrollView  *imageScrollView;
@property (nonatomic, assign) BOOL          showAnimation;

@end

@implementation MDImagePreviewViewController

-(void)dealloc
{
    
    [_previewImage release];
    _previewImage = nil;
    
    [_mainImageView release];
    _mainImageView = nil;
    
    [_deleteBtn release];
    _deleteBtn = nil;
    
    [_gotoBtn release];
    _gotoBtn = nil;
    
    [_imageScrollView release];
    _imageScrollView = nil;
    
    _delegate = nil;
    
    [super dealloc];
}

-(instancetype)initWithImage:(UIImage *)aImage
{
    return [self initWithImage:aImage withAnimation:NO];
}

-(instancetype)initWithImage:(UIImage *)aImage withAnimation:(BOOL)flag
{
    self = [super init];
    if (self) {
        self.previewImage = aImage;
        self.showAnimation = flag;
    }
    return self;
}

-(UIScrollView *)imageScrollView
{
    if (!_imageScrollView) {
        _imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, MDScreenWidth, MDScreenHeight)];
        _imageScrollView.layer.masksToBounds = NO;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator = NO;
        _imageScrollView.maximumZoomScale = 2.0;
        _imageScrollView.minimumZoomScale = 1.0;
        _imageScrollView.backgroundColor = [UIColor blackColor];
        _imageScrollView.delegate = (id<UIScrollViewDelegate>) self;
        [_imageScrollView addSubview:self.mainImageView];
        //[self.view addSubview:_imageScrollView];

        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [_imageScrollView addGestureRecognizer:doubleTap];
        [doubleTap release];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [_imageScrollView addGestureRecognizer:singleTap];
        [singleTap release];
        
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
//        longPress.minimumPressDuration = 1.0;
//        [_imageScrollView addGestureRecognizer:longPress];
//        [longPress release];

    }
    return _imageScrollView;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self gotoBack];
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
    if(self.imageScrollView.zoomScale > self.imageScrollView.minimumZoomScale)
        [self.imageScrollView setZoomScale:self.imageScrollView.minimumZoomScale animated:YES];
    else
        [self.imageScrollView setZoomScale:self.imageScrollView.maximumZoomScale animated:YES];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
            [self deleteImage];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
-(void)deleteImage
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"删除图片?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if ([self.delegate respondsToSelector:@selector(previewController:willDeleteImage:)]) {
            [self.delegate previewController:self willDeleteImage:self.previewImage];
        }
    }
}
#pragma clang diagnostic pop

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mainImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    self.mainImageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

-(UIImageView *)mainImageView
{
    if (!_mainImageView) {
        CGFloat height = self.previewImage.size.height*self.previewImage.scale;
//        CGFloat navY = 44;
        
        CGFloat imageWidth = self.previewImage.size.width*self.previewImage.scale;
  
        
        height = MIN(height, CGRectGetHeight(self.view.bounds));
        CGFloat width = MIN(imageWidth, CGRectGetWidth(self.view.bounds));
        CGFloat y = (CGRectGetHeight(self.view.bounds) - height)/2.0;
        CGFloat x = (CGRectGetWidth(self.view.bounds) - width)/2.0;
        CGRect frame = CGRectMake(x, y, width, height);
        
        _mainImageView = [[UIImageView alloc]initWithFrame:frame];
        _mainImageView.image = self.previewImage;
        _mainImageView.contentMode = UIViewContentModeScaleAspectFit;
        _mainImageView.userInteractionEnabled = YES;
        

    }
    
    return _mainImageView;
}


-(void)gotoBack
{
    if ([self.delegate respondsToSelector:@selector(previewControllerDidCancel:)]) {
        [self.delegate previewControllerDidCancel:self];
    }
}


-(void)gotoEdit
{
    if ([self.delegate respondsToSelector:@selector(previewController:willEditImage:)]) {
        [self.delegate previewController:self willEditImage:self.previewImage];
    }
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageScrollView];
    
    if (self.showAnimation) {
        //放大动画
        POPSpringAnimation *animationScale = [POPSpringAnimation animation];
        animationScale.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
        animationScale.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.2, 0.2)];
        animationScale.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
        animationScale.springSpeed = 10.0;
        [self.imageScrollView pop_removeAnimationForKey:@"move"];
        [self.imageScrollView pop_addAnimation:animationScale forKey:@"move"];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTF_MUSIC_HIDE_GLOBAL_COVER object:nil];//通知音乐全局页隐藏
    //[[UIApplication sharedApplication]setStatusBarHidden:YES];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTF_MUSIC_SHOW_GLOBAL_COVER object:nil];//通知音乐全局页重现
    //[[UIApplication sharedApplication]setStatusBarHidden:NO];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%ld", (long)self.index];
}
@end
