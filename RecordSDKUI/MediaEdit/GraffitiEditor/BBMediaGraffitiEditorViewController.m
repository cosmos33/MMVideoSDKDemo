//
//  BBMediaGraffitiEditorViewController.m
//  BiBi
//
//  Created by YuAo on 12/11/15.
//  Copyright © 2015 sdk.com. All rights reserved.
//

#import "BBMediaGraffitiEditorViewController.h"
#import <Accelerate/Accelerate.h>
#import "WAKeyValuePersistenceStore.h"
#import "WLCanvasView.h"
#import "MDMomentPainterToolView.h"
#import "UIConst.h"
#import "UIView+Utils.h"

BOOL BBUIImageContainsVisiblePixelData(UIImage *image) {
    //0.011s on iPhone 5c
    if (!image || !image.CGImage) {
        return NO;
    } else {
        vImage_Buffer imageBuffer;
        vImage_CGImageFormat format = {
            .bitsPerComponent = 8,
            .bitsPerPixel = 32,
            .colorSpace = NULL,
            .bitmapInfo = (CGBitmapInfo)kCGImageAlphaFirst
        };
        vImage_Error error = vImageBuffer_InitWithCGImage(&imageBuffer, &format, NULL, image.CGImage, kvImageNoFlags);
        if (error != kvImageNoError) NSLog(@"vImage Error: %ld", error);
        
        vImagePixelCount histogramA[256];
        vImagePixelCount histogramR[256];
        vImagePixelCount histogramG[256];
        vImagePixelCount histogramB[256];
        vImagePixelCount *histogram[4];
        histogram[0] = histogramA;
        histogram[1] = histogramR;
        histogram[2] = histogramG;
        histogram[3] = histogramB;
        
        vImage_Error histogramError = vImageHistogramCalculation_ARGB8888 (&imageBuffer,histogram, 0);
        if (histogramError != kvImageNoError) NSLog(@"vImage Error: %ld", histogramError);
        
        if (imageBuffer.data) {
            free(imageBuffer.data);
        }
        
        BOOL fullTransparent = NO;
        if (histogram[0][0] == CGImageGetWidth(image.CGImage) * CGImageGetHeight(image.CGImage)) {
            fullTransparent = YES;
        }
        return !fullTransparent;
    }
}

@interface BBMediaGraffitiEditorViewController ()<MDMomentPainterToolViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) WLCanvasView  *canvasView;
@property (nonatomic, strong) WLCanvasView  *mosaicCanvasView;
@property (nonatomic, strong) UIButton      *undoButton;
@property (nonatomic, strong) UIButton      *completeButton;
@property (nonatomic, strong) UIButton      *cancelBtn;
@property (nonatomic, strong) MDMomentPainterToolView *toolView;
@property (nonatomic, strong) NSUndoManager  *undoManager;
@property (nonatomic, strong) dispatch_queue_t undoCreateQueue;

@end

@implementation BBMediaGraffitiEditorViewController
@synthesize undoManager = _undoManager;

+ (WAKeyValuePersistenceStore *)drawingStateStore {
    static WAKeyValuePersistenceStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[WAKeyValuePersistenceStore alloc] initWithDirectory:NSCachesDirectory name:@"BBMediaGraffitiEditor.DrawingStates" objectSerializer:[WAPersistenceObjectSerializer keyedArchiveSerializer]];
    });
    return store;
}

- (void)dealloc {
    [self.class.drawingStateStore removeAllObjects];
}

- (void)showInterfaceElements {
    [UIView animateWithDuration:0.3 animations:^{
//        [self.brushButtons setValue:@(1) forKeyPath:@"alpha"];
//        self.topToolbarView.alpha = 1;
    }];
}

- (void)hideInterfaceElements {
    [UIView animateWithDuration:0.3 animations:^{
//        [self.brushButtons setValue:@(0) forKeyPath:@"alpha"];
//        self.topToolbarView.alpha = 0;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.undoManager = [[NSUndoManager alloc] init];
    [self configureSubViews];
    [self updateUndoButton];

    //未选择画笔时，默认第一个画笔
    [self brushButtonTapped:[UIColor whiteColor]];
    //不需要马赛克
    if (!self.initialMosaicCanvasImage) {
        [self.toolView setMosaicBrushButtonHidden:YES];
    }
    
    self.undoCreateQueue = dispatch_queue_create("com.sdk.moment.edit.graffiti.undo.create", DISPATCH_QUEUE_SERIAL);
    
}

- (CGFloat)HOME_INDICATOR_HEIGHT {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;;
    } else {
        return 0.0f;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.toolView showAnimation];
    
}

- (void)configureSubViews
{
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.canvasView];
    [self.view addSubview:self.mosaicCanvasView];

    [self.view addSubview:self.toolView];
    [self.view addSubview:self.undoButton];
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.completeButton];
    
    [self.cancelBtn.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:10].active = YES;
    [self.cancelBtn.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20 + [self HOME_INDICATOR_HEIGHT]].active = YES;

    [self.completeButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-10].active = YES;
    [self.completeButton.topAnchor constraintEqualToAnchor:self.cancelBtn.topAnchor].active = YES;
}

#pragma mark -UI

- (WLCanvasView *)canvasView
{
    if (!_canvasView) {
        
        CGRect frame = CGRectIsEmpty(self.renderFrame) ? CGRectMake(0, 0, MDScreenWidth, MDScreenHeight) : self.renderFrame;
        _canvasView = [[WLCanvasView alloc] initWithFrame:frame];
        _canvasView.graphicContextScale = 2.0;
        _canvasView.contentAlpha = 1;
        _canvasView.image = self.initialGraffitiCanvasImage;

        __weak __typeof(self) weakSelf = self;
        [_canvasView setBrushTouchDownHandler:^{
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(hideInterfaceElements) object:nil];
            [weakSelf performSelector:@selector(hideInterfaceElements) withObject:nil afterDelay:0.4];
            [weakSelf createUndoStep];
        }];
        
        [_canvasView setBrushMovedToPointHandler:^(CGPoint point) {
            //Need to clean the mosaic canvas
            //Gather information
            CGSize size = weakSelf.mosaicCanvasView.frame.size;
            UIImage *mosaicCanvasImage = weakSelf.mosaicCanvasView.image;
            UIBezierPath *path = weakSelf.canvasView.currentStrokePath;
            path.lineCapStyle = kCGLineCapRound;
            path.lineWidth = weakSelf.canvasView.brushConfiguration.brushSize;
            if (path && (ABS(mosaicCanvasImage.size.width - size.width) < 0.1 /* mosaicCanvasImage has valid content */)) {
                UIGraphicsBeginImageContextWithOptions(size, NO, weakSelf.mosaicCanvasView.graphicContextScale);
                [mosaicCanvasImage drawInRect:weakSelf.mosaicCanvasView.bounds];
                [path strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                weakSelf.mosaicCanvasView.image = image;
                if (weakSelf.canvasImageUpdatedHandler) {
                    weakSelf.canvasImageUpdatedHandler(weakSelf.canvasView.image,weakSelf.mosaicCanvasView.image);
                }
            } else {
                if (weakSelf.canvasImageUpdatedHandler) {
                    weakSelf.canvasImageUpdatedHandler(weakSelf.canvasView.image,weakSelf.mosaicCanvasView.image);
                }
            }
            
        }];
        
        [_canvasView setBrushTouchUpHandler:^{
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(hideInterfaceElements) object:nil];
            [weakSelf showInterfaceElements];
        }];

    }
    
    return _canvasView;
}

- (WLCanvasView *)mosaicCanvasView
{
    if (!_mosaicCanvasView) {
        
        CGRect frame = CGRectIsEmpty(self.renderFrame) ? CGRectMake(0, 0, MDScreenWidth, MDScreenHeight) : self.renderFrame;
        _mosaicCanvasView = [[WLCanvasView alloc] initWithFrame:frame];
        _mosaicCanvasView.graphicContextScale = 2.0;
        _mosaicCanvasView.contentAlpha = 0;
        _mosaicCanvasView.image = self.initialMosaicCanvasImage;
        _mosaicCanvasView.brushConfiguration = [WLCanvasViewBrushConfiguration configurationWithBrushMode:WLCanvasViewBrushModeDraw brushSize:16 brushColor:[UIColor blackColor]];
        
        __weak __typeof(self) weakSelf = self;
        
        [_mosaicCanvasView setBrushTouchDownHandler:^{
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(hideInterfaceElements) object:nil];
            [weakSelf performSelector:@selector(hideInterfaceElements) withObject:nil afterDelay:0.4];
            [weakSelf createUndoStep];
        }];
        
        [_mosaicCanvasView setBrushMovedToPointHandler:^(CGPoint point) {
            //Don't need to clean here, graffiti filter will clear the canvas drawing.
            if (weakSelf.canvasImageUpdatedHandler) {
                weakSelf.canvasImageUpdatedHandler(weakSelf.canvasView.image,weakSelf.mosaicCanvasView.image);
            }
        }];
        [_mosaicCanvasView setBrushTouchUpHandler:^{
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(hideInterfaceElements) object:nil];
            [weakSelf showInterfaceElements];
        }];
    }
    
    return _mosaicCanvasView;
}

- (UIButton *)undoButton
{
    if (!_undoButton) {
        UIImage *undoImage = [UIImage imageNamed:@"btn_moment_painter_undo"];
        _undoButton = [[UIButton alloc] initWithFrame:CGRectMake(MDScreenWidth - 110, 10 + [self HOME_INDICATOR_HEIGHT], 50, 50)];
        [_undoButton setImage:undoImage forState:UIControlStateNormal];
        _undoButton.alpha = 0;
        _undoButton.centerX = self.view.width *0.5f;
        
        [_undoButton addTarget:self action:@selector(undoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _undoButton;
}

- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
//        UIImage *cancelImg = [UIImage imageNamed:@"moment_return"];
//        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 11 + [self HOME_INDICATOR_HEIGHT], cancelImg.size.width +20, cancelImg.size.height +20)];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelBtn = cancelBtn;
    }
    
    return _cancelBtn;
}

- (UIButton *)completeButton
{
    if (!_completeButton) {
//        UIImage *completeImg = [UIImage imageNamed:@"media_editor_compelete"];
//        _completeButton = [[UIButton alloc] initWithFrame:CGRectMake(MDScreenWidth - 15 -completeImg.size.width, 15 + [self HOME_INDICATOR_HEIGHT], completeImg.size.width, completeImg.size.height)];
//        [_completeButton setImage:completeImg forState:UIControlStateNormal];
        
        _completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_completeButton setTitle:@"确认" forState:UIControlStateNormal];
        [_completeButton addTarget:self action:@selector(completeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _completeButton;
}

- (MDMomentPainterToolView *)toolView
{
    if (!_toolView) {
        _toolView = [[MDMomentPainterToolView alloc] initWithFrame:CGRectMake(0, MDScreenHeight - 40 - [self HOME_INDICATOR_HEIGHT], MDScreenWidth, 30)];
        _toolView.delegate = self;
    }
    
    return _toolView;
}

- (void)updateUndoButton {
    if (BBUIImageContainsVisiblePixelData(self.canvasView.image) || BBUIImageContainsVisiblePixelData(self.mosaicCanvasView.image) || self.undoManager.canUndo) {
        self.undoButton.alpha = 1;
        self.undoButton.enabled = YES;
    } else {
        self.undoButton.alpha = 0;
        self.undoButton.enabled = NO;
    }
}

#pragma mark - control

- (void)undoButtonTapped:(id)sender {
    if (self.undoManager.canUndo) {
        [self.undoManager undo];
        [self updateUndoButton];
        if (self.canvasImageUpdatedHandler) {
            self.canvasImageUpdatedHandler(self.canvasView.image,self.mosaicCanvasView.image);
        }
    } else {
        [self showClearAllDrawingsAlert];
    }
}

- (void)cancelButtonTapped:(id)sender
{
    if (self.canvasImageUpdatedHandler) {
        self.canvasImageUpdatedHandler(self.initialGraffitiCanvasImage,self.initialMosaicCanvasImage);
    }
    
    if (self.completionHandler) {
        self.completionHandler();
    }
}

- (void)completeButtonTapped:(id)sender {
    if (self.completionHandler) {
        self.completionHandler();
    }
}

#pragma mark - MDMomentPainterToolViewDelegate

- (void)brushButtonTapped:(UIColor *)color
{
    self.canvasView.userInteractionEnabled = YES;
    self.mosaicCanvasView.userInteractionEnabled = NO;
    
    self.canvasView.brushConfiguration = [WLCanvasViewBrushConfiguration configurationWithBrushMode:WLCanvasViewBrushModeDraw brushSize:6 brushColor: color];
}

- (void)imageMosaicButtonTapped:(UIColor *)color
{
    self.canvasView.userInteractionEnabled = YES;
    self.mosaicCanvasView.userInteractionEnabled = NO;
    
    self.canvasView.brushConfiguration = [WLCanvasViewBrushConfiguration configurationWithBrushMode:WLCanvasViewBrushModeDraw brushSize:16 brushColor: color];
}

- (void)mosaicButtonTapped {
    self.canvasView.userInteractionEnabled = NO;
    self.mosaicCanvasView.userInteractionEnabled = YES;
}

#pragma mark - undo

- (void)createUndoStep {
    dispatch_async(self.undoCreateQueue, ^{
        NSString *stateIdentifier = [self stateIdentifierForCurrentDrawing];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.undoManager beginUndoGrouping];
            [[self.undoManager prepareWithInvocationTarget:self] undoDrawingWithStateIdentifier:stateIdentifier];
            [self.undoManager endUndoGrouping];
            [self updateUndoButton];
        });
    });
}

- (NSString *)stateIdentifierForCurrentDrawing {
    NSString *stateIdentifier = [NSProcessInfo processInfo].globallyUniqueString;
    self.class.drawingStateStore[[stateIdentifier stringByAppendingString:NSStringFromSelector(@selector(canvasView))]] = self.canvasView.image;
    self.class.drawingStateStore[[stateIdentifier stringByAppendingString:NSStringFromSelector(@selector(mosaicCanvasView))]] = self.mosaicCanvasView.image;
    return stateIdentifier;
}

- (void)undoDrawingWithStateIdentifier:(NSString *)stateIdentifier {
    self.canvasView.image = self.class.drawingStateStore[[stateIdentifier stringByAppendingString:NSStringFromSelector(@selector(canvasView))]];
    self.mosaicCanvasView.image = self.class.drawingStateStore[[stateIdentifier stringByAppendingString:NSStringFromSelector(@selector(mosaicCanvasView))]];
    self.class.drawingStateStore[[stateIdentifier stringByAppendingString:NSStringFromSelector(@selector(canvasView))]] = nil;
    self.class.drawingStateStore[[stateIdentifier stringByAppendingString:NSStringFromSelector(@selector(mosaicCanvasView))]] = nil;
}

- (void)showClearAllDrawingsAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"清除所有涂鸦？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"清除", nil];
    [alertView show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.undoManager removeAllActions];
        [self.canvasView clear];
        [self.mosaicCanvasView clear];
        [self updateUndoButton];
        if (self.canvasImageUpdatedHandler) {
            self.canvasImageUpdatedHandler(self.canvasView.image,self.mosaicCanvasView.image);
        }
    }
}
@end
