//
//  MDImageClipAndScaleViewController.m
//  MDChat
//
//  Created by Aaron on 14/11/7.
//  Copyright (c) 2014年 sdk.com. All rights reserved.
//

#import "MDImageClipAndScaleViewController.h"
#import "MDRecordHeader.h"
#import "MDNormalButtonItem.h"

@interface MDImageClipAndScaleViewController()

@property (nonatomic, strong) UIImage           *originImage;
@property (nonatomic, strong) UIImageView       *scaledImageView;
@property (nonatomic, strong) UIScrollView      *scrollView;

@property (nonatomic, assign) CGFloat           navHeight;

@end


@implementation MDImageClipAndScaleViewController

-(instancetype)initWithImage:(UIImage *)aImage
{
    self = [super init];
    if (self) {
        self.originImage = aImage;
        self.navHeight = 64;
        self.imageClipScale = 1.0;
    }
    return self;
}


- (void)setupTopBar
{
    [self setTitle:@"剪裁"];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor:RGBCOLOR(51, 50, 50)};
    
    MDNormalButtonItem *leftItem = [[MDNormalButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_tag_goback"]];
    [leftItem setTitleHighLight:YES];
    [leftItem addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarItem:leftItem];
    
    MDNormalButtonItem *rightItem = [[MDNormalButtonItem alloc] initWithTitle:@"继续"];
    [rightItem setTitleHighLight:YES];
    [rightItem addTarget:self action:@selector(operationComplete) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBarItem:rightItem];
}

-(void)gotoBack
{
    if ([self.delegate respondsToSelector:@selector(clipControllerDidCancel:)]) {
        [self.delegate clipControllerDidCancel:self];
    }
}

-(void)operationComplete
{
    if (self.scrollView.contentSize.width <= 0 || self.scrollView.contentSize.height <= 0) {
        return;
    }
    
    //获取编辑框左上角点在contentSize中的比例
    CGPoint point = CGPointZero;
    point.x = self.scrollView.contentOffset.x / self.scrollView.contentSize.width;
    point.y = self.scrollView.contentOffset.y / self.scrollView.contentSize.height;
    CGPoint finalPoint = CGPointMake(round(point.x * self.originImage.size.width) , round(point.y * self.originImage.size.height));
    
    //计算编辑框区域图片大小
    CGFloat widthFactor = MIN(1.0, self.scrollView.width/self.scrollView.contentSize.width);
    CGFloat heightFactor = MIN(1.0, self.scrollView.height/self.scrollView.contentSize.height);
    CGFloat width =  round(widthFactor * self.originImage.size.width);
    CGFloat height = round(heightFactor * self.originImage.size.height);
    CGSize finalSize = CGSizeMake(width, height);
    
    CGRect rect = CGRectZero;
    rect.origin = finalPoint;
    rect.size = finalSize;
    
    UIImage *rotateImage = [self fixOrientation:self.originImage];
    
    CGImageRef imgRef = CGImageCreateWithImageInRect(rotateImage.CGImage, rect);
    UIImage *outputImage = [[UIImage alloc]initWithCGImage:imgRef scale:1.0 orientation:UIImageOrientationUp];
    if (imgRef) {
        CGImageRelease(imgRef);
    }
    
    
    CGFloat maxResolution = 1080;
    if (outputImage.size.width > maxResolution || outputImage.size.height > maxResolution) {
        CGFloat width = 0,height = 0;
        if (outputImage.size.width >= outputImage.size.width) {
            width = maxResolution;
            height = round(width / self.imageClipScale);
        }else {
            height = maxResolution;
            width = round(height * self.imageClipScale);
        }
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [outputImage drawInRect:CGRectMake(0, 0, width, height)];
        outputImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if ([self.delegate respondsToSelector:@selector(clipController:didClipImage:)]) {
        [self.delegate clipController:self didClipImage:outputImage];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    CGFloat widthHeightRatio = self.view.width / (self.view.height - self.navHeight);
    
    BOOL landscape = NO;
    CGFloat scrollViewWidth = self.view.width;
    CGFloat scrollViewHeight = round(scrollViewWidth / self.imageClipScale);
    CGFloat maskWidth = scrollViewWidth;
    CGFloat maskHeight = (self.view.height-self.navHeight-scrollViewHeight)/2;
    if (widthHeightRatio > self.imageClipScale) {
        landscape = YES;
        scrollViewHeight = self.view.height - self.navHeight;
        scrollViewWidth = round(scrollViewHeight * self.imageClipScale);
        maskHeight = scrollViewHeight;
        maskWidth = (self.view.width-scrollViewWidth)/2.0;
    }
    
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setupTopBar];
    
    CGFloat scrollViewX = 0;
    CGFloat scrollViewY = MAX(self.navHeight, self.navHeight+maskHeight-22);
    if (landscape) {
        scrollViewX = maskWidth;
        scrollViewY = self.navHeight;
    }
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(scrollViewX, scrollViewY, scrollViewWidth, scrollViewHeight)];
    _scrollView.layer.masksToBounds = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = (id<UIScrollViewDelegate>) self;
    [self.view addSubview:_scrollView];
    self.view.clipsToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:self.originImage];
    self.scaledImageView = imageView;
    if (self.originImage.size.width >= self.originImage.size.height && self.originImage.size.height > 0) {
        CGFloat imageViewHeight = self.scrollView.height;
        CGFloat imageViewWidth = imageViewHeight*self.originImage.size.width/self.originImage.size.height;
        _scaledImageView.frame = CGRectMake(0, 0, imageViewWidth, imageViewHeight);
        _scrollView.contentSize = _scaledImageView.size;
        _scrollView.contentOffset = CGPointMake((imageViewWidth-self.scrollView.width)/2, 0);
    }
    else if (self.originImage.size.width > 0){
        CGFloat imageViewWidth = self.scrollView.width;
        CGFloat imageViewHeight = imageViewWidth*self.originImage.size.height/self.originImage.size.width;
        _scaledImageView.frame = CGRectMake(0, 0, imageViewWidth, imageViewHeight);
        _scrollView.contentSize = _scaledImageView.size;
        _scrollView.contentOffset = CGPointMake(0, (imageViewHeight-self.scrollView.height)/2);
    }
    [_scrollView addSubview:_scaledImageView];
    
    
    CGRect upMaskViewFrame = CGRectZero;
    if (!landscape) {
        if (maskHeight>22) {
            upMaskViewFrame = CGRectMake(0, self.navHeight, maskWidth, maskHeight-22);
        }
    }else {
        upMaskViewFrame = CGRectMake(0, self.navHeight, maskWidth, maskHeight);
    }
    
    UIView *upMaskView = [[UIView alloc]initWithFrame:upMaskViewFrame];
    upMaskView.backgroundColor = [UIColor blackColor];
    upMaskView.alpha = 0.55;
    [self.view addSubview:upMaskView];
    
    CGRect downMaskViewFrame = CGRectZero;
    if (!landscape) {
        downMaskViewFrame = CGRectMake(0, self.scrollView.bottom, maskWidth, self.view.height-self.scrollView.bottom);
    }else {
        downMaskViewFrame = CGRectMake(self.scrollView.right, self.navHeight, maskWidth, maskHeight);
    }
    UIView *downMaskView = [[UIView alloc]initWithFrame:downMaskViewFrame];
    downMaskView.backgroundColor = [UIColor blackColor];
    downMaskView.alpha = 0.55;
    [self.view addSubview:downMaskView];
    
    UIView *blackMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.navHeight)];
    blackMaskView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:blackMaskView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.scaledImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    self.scaledImageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
