//
//  MDRecordUtility.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/20.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordUtility.h"
#import <CoreGraphics/CoreGraphics.h>
@import Photos;

@implementation MDRecordUtility

+ (UIImage *)scaleImageWithSize:(UIImage *)superImage scaleSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    [superImage drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

+ (UIImage *)oldCompressImage:(UIImage *)anImage
{
    CGFloat maxLength = 1280;//最大长边
    CGFloat maxWidth = 720;//最大短边可配置
    
    UIImage *compressedPic = nil;
    
    CGSize imgSize = anImage.size;
    
    float width = imgSize.width * anImage.scale;
    float height = imgSize.height * anImage.scale;
    
    float longSide = width > height ? width : height;
    float shortSide = width > height ? height : width;
    
    float scale = 1.0;
    
    if (longSide > maxLength || shortSide > maxWidth) {
        scale = (maxLength / longSide) > (maxWidth / shortSide) ? (maxWidth / shortSide) : (maxLength / longSide);
    }
    
    if (scale >= 1) {
        //如果都大于1不需要压缩
        compressedPic = anImage;
    } else {
        compressedPic = [self scaleImageWithSize:anImage scaleSize:CGSizeMake((int)(width * scale), (int)(height * scale))];
    }
    return compressedPic;
}

+ (BOOL)isLongImage:(id)imageOrAsset
{
    if ([imageOrAsset isKindOfClass:[UIImage class]]) {
        UIImage *image = imageOrAsset;
        CGFloat rate = (CGFloat)image.size.height / image.size.width;
        CGFloat wRate = (CGFloat)(CGFloat)image.size.width / image.size.height;
        
        if ((rate > 3.1 && rate < 60) || (wRate > 3.1 && wRate < 60)) {
            return YES;
        }
    } else if ([imageOrAsset isKindOfClass:[PHAsset class]]) {
        PHAsset *asset = imageOrAsset;
        CGFloat rate = (CGFloat)asset.pixelHeight / asset.pixelWidth;
        CGFloat wRate = (CGFloat)asset.pixelWidth / asset.pixelHeight;
        
        if ((rate > 3.1 && rate < 60) || (wRate > 3.1 && wRate < 60)) {
            return YES;
        }
    }
    return NO;
}

+ (UIImage *)checkOrScaleImage:(UIImage *)anImage ignoreLongPic:(BOOL)ignore
{
    if (!anImage) {
        return nil;
    }
    
    if (!ignore && [self isLongImage:anImage]) {
        return anImage;
    }
    
    // [[MDContext appConfig] requireImageOpt]
    if (YES) {
        return [UIImage imageWithData: [self compressImageToData:anImage]];
    } else {
        return [self oldCompressImage:anImage];
    }
}

+ (NSData *)compressImageToData:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    CGFloat scale = image.scale;
    
    int width = image.size.width * scale;
    int height = image.size.height * scale;
    int thumbW = width % 2 == 1 ? width + 1 : width;//临时宽，将宽变作偶数
    int thumbH = height % 2 == 1 ? height + 1 : height;//临时高，将高变作偶数
    width = thumbW > thumbH ? thumbH : thumbW;//将小的一边给width，最短边
    height = thumbW > thumbH ? thumbW : thumbH;//将大的一边给height，最长边
    
    double ratio = ((double) width / height);//比例，图片短边除以长边为该图片比例
    double size;//文件大小 单位为KB
    
    if (ratio <= 1 && ratio > 0.5625) {//比例在[1,0.5625)间
        //判断最长边是否过界
        if (height < 1664) {//最长边小于1664px
            if (imageData.length / 1024 < 150) {
                return imageData;//如果文件的大小小于150KB
            }
            size = (width * height) * 1.0 / (1664 * 1664) * 150;//计算文件大小
            size = size < 80 ? 80 : size;//判断文件大小是否小于60KB
        } else if (height >= 1664 && height < 4990) {//最长边大于1664px小于4990px
            thumbW = width / 2;//最短边缩小2倍
            thumbH = height / 2;//最长边缩小2倍
            size = (thumbW * thumbH) * 1.0 / (2495 * 2495) * 300;//计算文件大小
            size = size < 100 ? 100 : size;//判断文件大小是否小于60KB
        } else if (height >= 4990 && height < 10240) {//如果最长边大于4990px小于10240px
            thumbW = width / 4;//最短边缩小2倍
            thumbH = height / 4;//最长边缩小2倍
            size = (thumbW * thumbH) * 1.0 / (2560 * 2560) * 300;//计算文件大小
            size = size < 120 ? 120 : size;//判断文件大小是否小于100KB
        } else {//最长边大于10240px
            //            int multiple = height / 1280 == 0 ? 1 : height / 1280;//最长边与1280相比的倍数
            float multiple = MAX(1, height / 1280.0);//最长边与1280相比的倍数
            thumbW = width / multiple;//最短边根据倍数压缩
            thumbH = height / multiple;//最长边根据倍数压缩
            size = (thumbW * thumbH) * 1.0 / (2560 * 2560) * 300;//计算文件大小
            size = size < 120 ? 120 : size;//判断文件大小是否小于100KB
        }
    } else if (ratio <= 0.5625 && ratio > 0.5) {//比例在[0.5625,00.5)区间
        if (height < 1280 && imageData.length / 1024 < 200) {
            return imageData;//最长边小于1280px并且文件大小在200KB内，就返回
        }
        //        int multiple = height / 1280 == 0 ? 1 : height / 1280;//倍数，最长边与1280相比
        float multiple = MAX(1, height / 1280.0);//倍数，最长边与1280相比
        thumbW = width / multiple;//最短边根据倍数压缩
        thumbH = height / multiple;//最长边根据倍数压缩
        size = (thumbW * thumbH) * 1.0 / (1440.0 * 2560.0) * 400;//计算文件大小
        size = size < 120 ? 120 : size;//判断文件大小是否小于100KB
    } else {//比例小于0.5
        float multiple = MAX(1, height / (1280.0 / ratio));//最长边乘以比例后与1280相比的结果向上取整
        thumbW = width / multiple;//最短边根据倍数压缩
        thumbH = height / multiple;//最长边根据倍数压缩
        size = ((thumbW * thumbH) * 1.0 / (1280.0 * (1280 / scale))) * 500;//计算文件大小
        size = size < 120 ? 120 : size;//判断文件大小是否小于100KB
    }
    //根据计算结果来进行压缩图片
    if (image.size.width > image.size.height) {
        image = [self scaleImageWithSize:image scaleSize:CGSizeMake(thumbH > thumbW ? thumbH : thumbW, thumbH > thumbW ? thumbW : thumbH)];
    } else {
        image = [self scaleImageWithSize:image scaleSize:CGSizeMake(thumbH > thumbW ? thumbW : thumbH, thumbH > thumbW ? thumbH : thumbW)];
    }
    //    CGFloat compress = [[MDContext appConfig] chatImageCompression];
    CGFloat compress = 0.9;
    imageData = UIImageJPEGRepresentation(image, compress);
    
    while (imageData.length / 1024.0 > size && compress > 0.1) {
        compress = compress - 0.06;
        imageData = UIImageJPEGRepresentation(image, compress);
        //        NSLog(@"compress: %f, size: %ld", compress, imageData.length);
    }
    //    NSLog(@"width: %f, height: %f\n\n", image.size.width, image.size.height);
    return imageData;
}

@end
