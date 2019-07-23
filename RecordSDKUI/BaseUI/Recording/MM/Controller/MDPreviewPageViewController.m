//
//  MDPreviewPageViewController.m
//  MDChat
//
//  Created by Aaron on 14/12/2.
//  Copyright (c) 2014年 sdk.com. All rights reserved.
//

#import "MDPreviewPageViewController.h"
#import "MDImagePreviewViewController.h"
#import "MDNormalButtonItem.h"
#import "MDReturnButtonItem.h"
#import "MDRecordHeader.h"

@interface MDPreviewPageViewController()

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, assign) NSInteger      currentIndex;

@property (nonatomic, strong) UIButton      *deleteBtn;
@property (nonatomic, strong) UIButton      *gotoBtn;
@property (nonatomic, strong) UILabel       *pageLabel;

@property (nonatomic, assign) NSInteger     toIndex;
@property (nonatomic, assign) BOOL          functionDisable;
@property (nonatomic, assign) BOOL          hasShownAnimation;

@end

@implementation MDPreviewPageViewController


-(instancetype)initWithImageArray:(NSArray *)imageArray andSelectedIndex:(NSInteger)selectedIndex
{
    return [self initWithImageArray:imageArray andSelectedIndex:selectedIndex withDeleteEnable:YES];
}

-(instancetype)initWithImageArray:(NSArray *)imageArray andSelectedIndex:(NSInteger)selectedIndex withDeleteEnable:(BOOL)enableDelete
{
    self = [super init];
    if (self) {
        self.enableDelete = enableDelete;
        self.imageArray = [NSMutableArray arrayWithArray:imageArray];
        self.currentIndex = selectedIndex;
        self.hasShownAnimation = NO;
    }
    return self;
}

-(instancetype)initWithImageArray:(NSArray *)imageArray andFunctionDisable:(BOOL)flag
{
    self = [self initWithImageArray:imageArray andSelectedIndex:0 withDeleteEnable:NO];
    self.functionDisable = flag;
    
    return self;
}

-(void)setCurrentIndex:(NSInteger)currentIndex
{
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self renewPageLabel];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = NO;
    
    self.view.backgroundColor = [UIColor blackColor];

    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [[self.pageViewController view] setFrame:[[self view] bounds]];
    self.pageViewController.dataSource = (id <UIPageViewControllerDataSource>)self;
    self.pageViewController.delegate = (id <UIPageViewControllerDelegate>)self;
    
    if(self.currentIndex < self.imageArray.count && self.currentIndex > -1) {
        UIViewController *imagePreviewVC = [self controllerAtIndex:self.currentIndex];
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:imagePreviewVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    [self addChildViewController:self.pageViewController];
    [[self view] addSubview:[self.pageViewController view]];
    [self.pageViewController didMoveToParentViewController:self];
    
    MDReturnButtonItem *leftItem = [[MDReturnButtonItem alloc]initWithTitle:@"返回"];
    [leftItem addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarItem:leftItem];
    
    if (!self.functionDisable) {
        
        if (!self.enableDelete) {
            MDNormalButtonItem *rightItem = [[MDNormalButtonItem alloc] initWithTitle:@"完成"];
            [rightItem setTitleHighLight:YES];
            [rightItem addTarget:self action:@selector(operationComplete) forControlEvents:UIControlEventTouchUpInside];
            [self setRightBarItem:rightItem];
        }
    }
    
    [self.view addSubview:self.pageLabel];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.0;
    [self.view addGestureRecognizer:longPress];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self deleteImage];
    }
}

-(void)deleteImage
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除图片?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteCurrentImage];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:NULL];
}


-(UILabel *)pageLabel
{
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, MDScreenHeight - HOME_INDICATOR_HEIGHT - 30, MDScreenWidth, 16)];
        _pageLabel.backgroundColor = [UIColor clearColor];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.font = [UIFont systemFontOfSize:16];
        _pageLabel.textColor = [UIColor lightGrayColor];
        [self renewPageLabel];
    }
    return _pageLabel;
}

-(void)renewPageLabel
{
    _pageLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)self.currentIndex+1, (unsigned long)self.imageArray.count];
}

//-(void)deleteImage
//{
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"删除此张图片？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
//    alert.delegate = (id<UIAlertViewDelegate>)self;
//    [alert show];
//    [alert release];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self deleteCurrentImage];
    }
}

-(void)deleteCurrentImage
{
    if (self.imageArray.count <= 1) {//只有一张图
        if ([self.delegate respondsToSelector:@selector(previewPageViewController:willDeleteImageAtIndex:willPop:)]) {
            [self.delegate previewPageViewController:self willDeleteImageAtIndex:self.currentIndex willPop:YES];
        }
    }
    else {
        NSInteger deleteIndex = self.currentIndex;
        if (self.currentIndex > 0) {//被删图的左侧还有图
            [self.imageArray removeObjectAtIndex:self.currentIndex];
            self.currentIndex--;
            [self showViewControllerAtIndex:self.currentIndex direction:UIPageViewControllerNavigationDirectionReverse];
        }
        else {//被删图的左侧无图，则右侧一定有图
            [self.imageArray removeObjectAtIndex:self.currentIndex];
            [self renewPageLabel];
            [self showViewControllerAtIndex:self.currentIndex direction:UIPageViewControllerNavigationDirectionForward];
        }
        if ([self.delegate respondsToSelector:@selector(previewPageViewController:willDeleteImageAtIndex:willPop:)]) {
            [self.delegate previewPageViewController:self willDeleteImageAtIndex:deleteIndex willPop:NO];
        }
    }
}

-(void)showViewControllerAtIndex:(NSInteger)index direction:(UIPageViewControllerNavigationDirection)direction
{
    UIViewController *imagePreviewVC = [self controllerAtIndex:index];
    NSArray *array = @[imagePreviewVC];
    
    __weak __typeof(self) weakSelf = self;
    [self.pageViewController setViewControllers:array direction:direction animated:YES completion:^(BOOL finished) {
        if (finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.pageViewController setViewControllers:array direction:direction animated:NO completion:NULL];
            });
        }
    }];
}

-(void)gotoEdit
{
    if ([self.delegate respondsToSelector:@selector(previewPageViewController:willEditImage:)]) {
        UIImage *image = self.imageArray[self.currentIndex];
        [self.delegate previewPageViewController:self willEditImage:image];    }
}

-(void)gotoBack
{
    if ([self.delegate respondsToSelector:@selector(previewPageViewControllerDidCancel:)]) {
        [self.delegate previewPageViewControllerDidCancel:self];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)operationComplete
{
    if ([self.delegate respondsToSelector:@selector(previewPageViewController:didDoneWithImage:)]) {
        UIImage *image = self.imageArray[self.currentIndex];
        [self.delegate previewPageViewController:self didDoneWithImage:image];
    }
}


#pragma mark -UIPageViewControllerDataSource-
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((MDImagePreviewViewController *)viewController).index;
    if (index == 0) {
        return nil;
    }

    return [self controllerAtIndex:index-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = ((MDImagePreviewViewController *)viewController).index;
    if (index+1 >= self.imageArray.count) {
        return nil;
    }
    
    return [self controllerAtIndex:index+1];
}
#pragma mark -UIPageViewControllerDelegate-

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        MDImagePreviewViewController *controller = (MDImagePreviewViewController *)[self.pageViewController.viewControllers lastObject];
        self.currentIndex = controller.index;
        if ([self.delegate respondsToSelector:@selector(previewPageViewController:didScrollToPage:)]) {
            [self.delegate previewPageViewController:self didScrollToPage:self.currentIndex];
        }
    }
}

-(UIViewController *)controllerAtIndex:(NSInteger)index
{
    if (index >= self.imageArray.count) {
        return nil;
    }
    UIImage *image = self.imageArray[index];

    MDImagePreviewViewController *imagePreviewVC = nil;
    if (!self.hasShownAnimation && self.currentIndex == index) {
        imagePreviewVC = [[MDImagePreviewViewController alloc]initWithImage:image withAnimation:YES];
        self.hasShownAnimation = YES;
    } else {
        imagePreviewVC = [[MDImagePreviewViewController alloc]initWithImage:image];
    }
    
    
    imagePreviewVC.index = index;
    imagePreviewVC.delegate = (id<MDImagePreviewViewControllerDelegate>)self;
    return imagePreviewVC;
}

#pragma mark -MDImagePreviewViewControllerDelegate-
-(void)previewControllerDidCancel:(MDImagePreviewViewController *)controller
{
    [self gotoBack];
}

-(void)previewController:(MDImagePreviewViewController *)controller willDeleteImage:(UIImage *)image
{
    [self deleteCurrentImage];
}
@end
