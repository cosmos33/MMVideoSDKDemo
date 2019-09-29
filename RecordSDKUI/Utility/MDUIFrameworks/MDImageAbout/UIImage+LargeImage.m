//
//  UIImage+LargeImage.m
//  RecordSDK
//
//  Created by YZK on 2018/12/20.
//  Copyright © 2018 RecordSDK. All rights reserved.
//

#import "UIImage+LargeImage.h"

const static float kBytePerMB = 1048576.0f; //1024*1024，1M的字节数
const static int   kBytesPerPixel = 4.0f; //每个像素的字节数
const static float kPixelsPerMB = kBytePerMB / kBytesPerPixel; //1M的像素数 2^18

//修改这两个参数调整性能
const static float kDestImageSizeMB = 60.0f; //压缩目标的内存大小
const static float kSourceImageTileSizeMB = 20.0f; //原图片每个分片的大小

const static float kDestTotalPixels = kDestImageSizeMB * kPixelsPerMB; //压缩目标的像素数
const static float kTileTotalPixels = kSourceImageTileSizeMB * kPixelsPerMB; //原图片每个分片的像素数
const static float kDestSeemOverlap = 2.0; //目标图片每个分片重叠2像素(防止压缩太多造成图片断裂的感觉)

@implementation UIImage (LargeImage)

static BOOL _handleEnable = NO;
+ (void)setHandleLargeImageEnable:(BOOL)enable {
    _handleEnable = enable;
}

- (UIImage *)downsize {
    CGSize sourceResolution = CGSizeZero; // 原始图片的分辨率
    sourceResolution.width = CGImageGetWidth(self.CGImage);
    sourceResolution.height = CGImageGetHeight(self.CGImage);
    
    //原始图片的全部像素数
    float sourceTotalPixels = sourceResolution.width * sourceResolution.height;
    //计算分辨率缩放的倍数
    float imageScale = kDestTotalPixels / sourceTotalPixels;
    return [self downsizeWithTargetScale:imageScale];
}

- (UIImage *)downsizeWithTargetScale:(float)imageScale {
    @autoreleasepool {
        if (imageScale>=1.0 || !_handleEnable) {
            return self;
        }
        
        CGSize sourceResolution = CGSizeZero; // 原始图片的分辨率
        sourceResolution.width = CGImageGetWidth(self.CGImage);
        sourceResolution.height = CGImageGetHeight(self.CGImage);
        
        //根据倍数计算目标的分辨率
        CGSize destResolution = CGSizeZero; // 目标图片的分辨率
        destResolution.width = (int)( sourceResolution.width * imageScale );
        destResolution.height = (int)( sourceResolution.height * imageScale );
        
        // 创建离屏位图存放输出的image像素数据，使用RGB颜色空间，因为这是iOS GPU优化的颜色空间
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        int bytesPerRow = kBytesPerPixel * destResolution.width;
        // 开辟足够的像素数据内存空间用来存放输出的图片
        void* destBitmapData = malloc( bytesPerRow * destResolution.height );
        if( destBitmapData == NULL ) {
            NSLog(@"failed to allocate space for the output image!");
            return nil;
        }
        // 创建离屏位图
        CGContextRef destContext = CGBitmapContextCreate( destBitmapData, destResolution.width, destResolution.height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast );
        // remember CFTypes assign/check for NULL. NSObjects assign/check for nil.
        if( destContext == NULL ) {
            free( destBitmapData );
            NSLog(@"failed to create the output bitmap context!");
            return nil;
        }
        // 释放颜色空间
        CGColorSpaceRelease( colorSpace );
        //翻转输出图形上下文，使其与cocoa样式方向对齐
        CGContextTranslateCTM( destContext, 0.0f, destResolution.height );
        CGContextScaleCTM( destContext, 1.0f, -1.0f );
        
        // 定义原图的分片rect图块大小，由于iOS从磁盘检索图像数据的方式，我们使用的源块宽度等于源图像的宽度(iOS必须以全宽“波段”从磁盘解码图像)。
        // 因此，我们通过将我们的图块大小设置为输入图像的整个宽度来充分利用由解码操作产生的所有像素数据。
        CGRect sourceTile = CGRectZero;
        sourceTile.size.width = sourceResolution.width;
        // 由于我们以MB为单位指定了源块的大小，以此计算输入图像宽度可以为多少像素行。
        sourceTile.size.height = (int)( kTileTotalPixels / sourceTile.size.width );
        sourceTile.origin.x = 0.0f;
        
        // 定义输出图片的分片rect图块大小，原理同原图的分片，只是乘上缩放倍数
        CGRect destTile = CGRectZero;
        destTile.size.width = destResolution.width;
        destTile.size.height = sourceTile.size.height * imageScale;
        destTile.origin.x = 0.0f;
        
        // 源重叠行数与目标重叠行数成比例。计算源图重叠行数
        int sourceSeemOverlap = (int)( ( kDestSeemOverlap / destResolution.height ) * sourceResolution.height );
        
        // 计算 组装输出图像 所需的读/写操作次数。
        int iterations = (int)( sourceResolution.height / sourceTile.size.height );
        // 如果分片图块高度不整除划分图像高度，则添加另一个迭代以考虑剩余像素。
        int remainder = (int)sourceResolution.height % (int)sourceTile.size.height;
        if( remainder ) iterations++;
        
        float sourceTileHeightMinusOverlap = sourceTile.size.height; //源图切片高度，每次y前进这么多
        sourceTile.size.height += sourceSeemOverlap; //添加重叠高度给切片源图图块高度
        destTile.size.height += kDestSeemOverlap;  //目标切片一样添加重叠高度
        
        for( int y = 0; y < iterations; ++y ) {
            @autoreleasepool {
                // 创建自动释放池用来及时释内存
                sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
                destTile.origin.y = ( destResolution.height ) - ( ( y + 1 ) * sourceTileHeightMinusOverlap * imageScale + kDestSeemOverlap );
                // 将根据rect将原图像裁剪
                CGImageRef sourceTileImageRef = CGImageCreateWithImageInRect( self.CGImage, sourceTile );
                // 如果这是最后一个图块，则其大小可能小于分片图块高度。 调整目标图块分块大小以考虑该差异。
                if( y == iterations - 1 && remainder ) {
                    float dify = destTile.size.height;
                    destTile.size.height = CGImageGetHeight( sourceTileImageRef ) * imageScale;
                    dify -= destTile.size.height;
                    destTile.origin.y += dify;
                }
                // 将分片的原图写入目标上下文
                CGContextDrawImage( destContext, destTile, sourceTileImageRef );
                CGImageRelease( sourceTileImageRef );
            }
        }
        
        CGImageRef destImageRef = CGBitmapContextCreateImage( destContext );
        if( destImageRef == NULL ) {
            NSLog(@"destImageRef is null.");
            return nil;
        }
        UIImage *destImage = [UIImage imageWithCGImage:destImageRef scale:1.0f orientation:UIImageOrientationDownMirrored];
        CGImageRelease( destImageRef );
        if( destImage == nil ) {
            NSLog(@"destImage is nil.");
            return nil;
        }
        CGContextRelease( destContext );
        return destImage;
    }
}

- (void)downsizeWithCompltion:(void (^)(UIImage *result))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [self downsize];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(image);
        });
    });
}

- (void)downsizeWithTargetScale:(float)imageScale compltion:(void (^)(UIImage *result))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [self downsizeWithTargetScale:imageScale];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(image);
        });
    });
}


@end
