//
//  MDRegLoginPortraitManager.m
//  MDChat
//
//  Created by DoKeer on 2018/11/7.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDRegLoginPortraitManager.h"
#import "MDPhotoLibraryProvider.h"
#import "UIDevice-Hardware.h"
#import "MDRecordHeader.h"
#import "MBProgressHUD/MBProgressHUD.h"

@import MomoCV;

@interface MDRegLoginPortraitManager ()
@property (nonatomic, strong) MMFaceDetector *faceDetector;
@property (nonatomic, strong) MMFaceDetectOptions *options;
@end
@implementation MDRegLoginPortraitManager

- (instancetype)init
{
    if (self = [super init]) {
        [self setupFaceDetector];
    }
    return self;
}

- (void)setupFaceDetector {
    __weak typeof(self) weakSelf = self;
//    [MDContext faceDetectorManager].delegate = self;
    
//    self.faceDetector = [[MDDetectorManger shared] makeFaceDetector];
//    if (!self.faceDetector) {
//        [[MDDetectorManger shared] asyncAutoMakeFaceDetector:^(MMFaceDetector *detector) {
//            weakSelf.faceDetector = detector;
//        }];
//    }
    
    _options = [[MMFaceDetectOptions alloc] init];
    _options.orientation = MMCVImageOrientationUp;
    _options.inputHint = MMFaceDetectionInputHintStaticImage;
    _options.faceDetectionMethod = MMFaceDetectionMethodFastRCNN;
}

static void PixelBufferReleaseBytesCallback(void * CV_NULLABLE releaseRefCon, const void * CV_NULLABLE baseAddress )
{
    free(releaseRefCon);
}

- (NSArray<MDPhotoItem *> *)imageFaceRecognitionFromArray:(NSArray<MDPhotoItem *> *)items
{
    NSMutableArray *portraits = nil;
    [items enumerateObjectsUsingBlock:^(MDPhotoItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self faceFeatureWithImage:obj.nailImage]) {
            [portraits addObject:obj];
        }
        
    }];
    return portraits;
}

- (BOOL)faceFeatureWithImage:(UIImage *)photo
{
    return [self detectorFaceFeaturesWithImage:photo];
}

- (NSArray<NSValue *> *)detectorFaceFeaturePointsWithImage:(UIImage *)photo
{
    MMFaceFeature *feature = [self detectorFaceFeaturesWithImage:photo];
    return feature.landmarks104;
}

- (MMFaceFeature *)detectorFaceFeaturesWithImage:(UIImage *)photo
{
    if (!self.faceDetector) {
        return nil;
    }
    if (!photo) {
        return nil;
    }
    CGFloat deta = photo.size.width / photo.size.height;
    if (deta < 1.0/6.0 || deta > 6.0) {
        return nil;
    }
    
    CVPixelBufferRef pixelBuffer = NULL;
    CGImageRef image = photo.CGImage;
    CGSize size = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(nil,
                                                       size.width,
                                                       size.height,
                                                       8,
                                                       size.width * 4,
                                                       colorSpace,
                                                       kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, size.width, size.height), image);
    
    if (CGBitmapContextGetData(bitmapContext)) {
        size_t dataSize = CGBitmapContextGetBytesPerRow(bitmapContext) * CGBitmapContextGetHeight(bitmapContext);
        void *data = malloc(dataSize);
        memcpy(data, CGBitmapContextGetData(bitmapContext), dataSize);
        CVPixelBufferCreateWithBytes(kCFAllocatorDefault,
                                     size.width,
                                     size.height,
                                     kCVPixelFormatType_32BGRA,
                                     data,
                                     size.width * 4,
                                     PixelBufferReleaseBytesCallback,
                                     data,
                                     (__bridge CFDictionaryRef)(@{}),
                                     &pixelBuffer);
    }
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmapContext);
    
    NSParameterAssert(pixelBuffer);
    if (pixelBuffer) {
        CFAutorelease(pixelBuffer);
        NSArray<MMFaceFeature *> *faceFeatures = [self.faceDetector featuresInPixelBuffer:pixelBuffer options:_options];
        return faceFeatures.firstObject;
        
    }
    return nil;
}


- (CGSize)currentDeviceScanSize
{
    CGFloat width = 200;
    switch ([[UIDevice currentDevice] platformType]) {
        case MDRecordUIDevice4iPhone:
        case MDRecordUIDevice4SiPhone:
        case MDRecordUIDevice5iPhone:
        case MDRecordUIDevice5CiPhone:
            width = 150;
            break;
        case MDRecordUIDevice5SiPhone:
        case MDRecordUIDevice6iPhone:
        case MDRecordUIDevice6PlusiPhone:
            width = 250;
            break;

        case MDRecordUIDevice6SiPhone:
        case MDRecordUIDevice6SPlusiPhone:
        case MDRecordUIDeviceSEiPhone:
        case MDRecordUIDevice7iPhone:
        case MDRecordUIDevice7PlusiPhone:
            width = 300;
            break;

        case MDRecordUIDevice8iPhone:
        case MDRecordUIDevice8PlusiPhone:
        case MDRecordUIDeviceXiPhone:
            width = 450;
            break;
        case MDRecordUIDeviceXSiPhone:
        case MDRecordUIDeviceXSMaxiPhone:
        case MDRecordUIDeviceXRiPhone:
            width = 500;
            break;
        default:
            width = 250;
            break;
    }
    return CGSizeMake(width, width);
}

#pragma mark - public methods
+ (void)showBottomMessage:(NSString *)message toView:(UIView *)view timeOut:(NSTimeInterval)interval
{
    if (!view) {
        view = [UIApplication sharedApplication].keyWindow;
        if (!view) {
            view = [UIApplication sharedApplication].delegate.window;
        }
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabelFont = [UIFont systemFontOfSize:15];
    hud.detailsLabelText = message;
    hud.cornerRadius = 19;
    hud.margin = 10;
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    CGFloat yOffset = view.height * 0.5 - 40;
    hud.yOffset = yOffset;

    [hud hide:YES afterDelay:interval];
    
}
@end
