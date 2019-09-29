//
//  UIImage+Utility.m
//  RecordSDK
//
//  Created by Allen on 10/12/13.
//  Copyright (c) 2013 RecordSDK. All rights reserved.
//

#import "UIImage+Utility.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (Utility)
- (UIImage *)autoVersionedStretchableImageWithLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight
{
    UIEdgeInsets capInsets = UIEdgeInsetsMake(topCapHeight, leftCapWidth, self.size.height -(topCapHeight+1), self.size.width-(leftCapWidth+1));
    UIImage *stretedImg = [self resizableImageWithCapInsets:capInsets];
    return stretedImg;
}

- (UIImage *)scaleImageWithWidth:(float)sWidth height:(float)sHeight
{
    CGImageRef imgRef = [self CGImage];
    
    float width = CGImageGetWidth(imgRef);
    float height = CGImageGetHeight(imgRef);
    
    int iw = 0, ih = 0;
    UIImage *dImage = nil;
    
    if (width > sWidth && height > sHeight)
    {
//        float xs = sWidth / width;
//        float ys = sHeight / height;
//        float s = MIN(xs,ys);
//        iw = width * s;
//        ih = height * s;
        
        iw = sWidth;
        ih = sHeight;
        /*
         CGSize itemSize = CGSizeMake(iw, ih);
         UIGraphicsBeginImageContext(itemSize);
         CGRect imageRect = CGRectMake(0.0, 0.0, iw, ih);
         [sImage drawInRect:imageRect];
         dImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
         UIGraphicsEndImageContext();
         */
        
        CGRect rect = CGRectMake(0, 0, iw, ih);
        CGSize imageSize = CGSizeMake(iw, ih);
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        //First fill the background with white
        CGContextSetRGBFillColor(context,0.0, 0.0, 0.0, 1.0);
        CGContextFillRect(context, rect);
        CGContextSaveGState(context);
        
        CGContextTranslateCTM(context, 0.0, ih);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, rect, imgRef);
        CGContextRestoreGState(context);
        dImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else {
        dImage = self;
    }
    
    return dImage;
}

- (UIImage *)scaleAspectFitImageWithWidth:(float)sWidth height:(float)sHeight
{
    UIImageOrientation orientation = self.imageOrientation;
    CGImageRef imgRef = [self CGImage];
    float width = CGImageGetWidth(imgRef);
    float height = CGImageGetHeight(imgRef);
    
    int iw = 0, ih = 0;
    UIImage *dImage = nil;
    
    if (width > sWidth || height > sHeight)
    {
        float xs = sWidth / width;
        float ys = sHeight / height;
        float s = MIN(xs,ys);
        iw = width * s;
        ih = height * s;
        
        CGRect rect = CGRectMake(0, 0, iw, ih);
        CGSize imageSize = CGSizeMake(iw, ih);
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        //First fill the background with white
        CGContextSetRGBFillColor(context,0.0, 0.0, 0.0, 1.0);
        CGContextFillRect(context, rect);
        CGContextSaveGState(context);
        
        CGContextTranslateCTM(context, 0.0, ih);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, rect, imgRef);
        CGContextRestoreGState(context);
        dImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else {
        dImage = self;
    }
    
    imgRef = dImage.CGImage;
    dImage = [[UIImage alloc]initWithCGImage:imgRef scale:2.0 orientation:orientation];

    return dImage;
}

- (UIImage *) imageWithTintColor:(UIColor *)tintColor
{
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (UIImage *)imageWithSize:(CGSize)size fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor strokeWidth:(CGFloat)width gridCount:(CGSize)gridCount borderLineControl:(UIEdgeInsets)borderControl
{
    UIImage *img = nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    if (!fillColor) {
        fillColor = [UIColor clearColor];
    }
    
    if (!strokeColor) {
        strokeColor = [UIColor whiteColor];
    }
    
    BOOL opaque = NO;
    if (fillColor != [UIColor clearColor]) {
        opaque = YES;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, opaque, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,fillColor.CGColor);
    CGContextFillRect(context, rect);
    
    CGFloat itemWidth = (size.width - (gridCount.width + 1)*width) / (float)gridCount.width;
    CGFloat itemHeight = (size.height - (gridCount.height + 1)*width) / (float)gridCount.height;
    
    CGFloat fWidth = floorf(itemWidth);
    CGFloat fHeight = floorf(itemHeight);
    
    CGFloat calcutedWidth = fWidth * gridCount.width + width * (gridCount.width + 1);
    CGFloat calcutedHeight = fHeight * gridCount.height + width * (gridCount.height + 1);
    
    CGFloat leftOffset = 0;
    CGFloat rightOffset = 0;
    CGFloat topOffset = 0;
    CGFloat bottomOffset = 0;
    if (calcutedWidth != size.width){
        CGFloat offset = size.width - calcutedWidth;
        leftOffset = floorf(offset / 2.0);
        rightOffset = offset - leftOffset;
    }
    
    if (calcutedHeight != size.height){
        CGFloat offset = size.height - calcutedHeight;
        topOffset = floorf(offset / 2.0);
        bottomOffset = offset - topOffset;
    }

    NSUInteger startRow = borderControl.top > 0 ? 0 : 1;
    NSUInteger endRow = borderControl.bottom > 0 ? gridCount.height : gridCount.height-1;
    
    //draw horizontal lines
    for (NSUInteger y=startRow; y<=endRow; y++){
        CGFloat originY = width / 2.0;
        
        if (y >= 1){
            originY += topOffset;
        }
        
        if (gridCount.height == y){
            originY += bottomOffset - width / 2.0;
        }
        
        originY += (fHeight + width) * y;
        CGContextMoveToPoint(context, 0, originY);
        CGContextAddLineToPoint(context, size.width, originY);
    }
    
    NSUInteger startCol = borderControl.left > 0 ? 0 : 1;
    NSUInteger endCol = borderControl.right > 0 ? gridCount.width : gridCount.width-1;
    
    //draw vertical lines
    for (NSUInteger x=startCol; x<=endCol; x++){
        CGFloat originX = width / 2.0;
        
        if (x >= 1){
            originX += leftOffset;
        }
        
        if (gridCount.width == x){
            originX += rightOffset  - width / 2.0;
        }
        
        originX += (fWidth + width) * x;
        CGContextMoveToPoint(context, originX, 0);
        CGContextAddLineToPoint(context, originX, size.height);
    }

    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineWidth(context, width);
    CGContextStrokePath(context);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)addTwoImageToOne:(UIImage *)oneImg twoImage:(UIImage *)twoImg topleft:(CGPoint)tlPos
{
    UIGraphicsBeginImageContext(oneImg.size);
    
    [oneImg drawInRect:CGRectMake(0, 0, oneImg.size.width, oneImg.size.height)];
    [twoImg drawInRect:CGRectMake(tlPos.x, tlPos.y, oneImg.size.width, oneImg.size.height)];
    
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImg;
}

- (UIImage *)resizedImageToWidth:(CGFloat)width tiledAreaFrom:(CGFloat)from1 to:(CGFloat)to1 andFrom:(CGFloat)from2 to:(CGFloat)to2
{
    if (self.size.width >= width) {
        return self;
    }
    
    CGFloat originalWidth = self.size.width;
    CGFloat titledAreaWidth = ceilf((width - originalWidth) / 2.0);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(originalWidth + titledAreaWidth, self.size.height), NO, self.scale);
    UIImage *firstResizable = [self resizableImageWithCapInsets:UIEdgeInsetsMake(0, from1*originalWidth-1, 0, to1*originalWidth) resizingMode:UIImageResizingModeTile];
    CGFloat leftStretchedWidth = originalWidth + titledAreaWidth;
    [firstResizable drawInRect:CGRectMake(0, 0, leftStretchedWidth, self.size.height)];
    UIImage *leftPart = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, self.size.height), NO, self.scale);
    UIImage *secondResizable = [leftPart resizableImageWithCapInsets:UIEdgeInsetsMake(0, from2*leftStretchedWidth-1, 0, to2*leftStretchedWidth) resizingMode:UIImageResizingModeTile];
    [secondResizable drawInRect:CGRectMake(0, 0, width, self.size.height)];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return fullImage;
}

+ (UIImage *)getGIFStaticPhoto:(NSData *)data{
    
    UIImage *frameImage = nil;
    BOOL hasData = ([data length] > 0);
    if (!hasData) {
        //DLog(DT_all,@"Error: No animated GIF data supplied.");
        return nil;
    }
    CGImageSourceRef gImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (!gImageSource) {
        //DLog(DT_all,@"Error: Failed to `CGImageSourceCreateWithData` for animated GIF data %@", data);
        return nil;
    }
    CGImageRef frameImageRef = CGImageSourceCreateImageAtIndex(gImageSource, 0, NULL);
    if (gImageSource) {
        CFRelease(gImageSource);
    }
    if(frameImageRef){
        frameImage = [UIImage imageWithCGImage:frameImageRef];
        CFRelease(frameImageRef);
    }
    
    return frameImage;
}

+ (UIImage *)dashlineImageWithStrokeColor:(UIColor *)color imageWidth:(CGFloat)imgWidth lineWidth:(CGFloat)width dashedLength:(CGFloat)length dashedGap:(CGFloat)gap
{
    UIBezierPath * path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(imgWidth, 0)];
    [path setLineWidth:width];
    
    CGFloat dashes[] = {length, gap};
    [path setLineDash:dashes count:2 phase:0];
    [path setLineCapStyle:kCGLineCapRound];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imgWidth, width), NO, 0);
    [color setStroke];
    [path stroke];
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//截取正方形的图片 centerBool为YES  表示从中心开始截取
+ (UIImage*)getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect centerBool:(BOOL)centerBool
{
    /*如若centerBool为Yes则是由中心点取mCGRect范围的图片*/
    
    float imgWidth = image.size.width;
    float imgHeight = image.size.height;
    float viewWidth = mCGRect.size.width;
    float viewHidth = mCGRect.size.height;
    CGRect rect;
    if(centerBool)
        rect = CGRectMake((imgWidth-viewWidth)/2,(imgHeight-viewHidth)/2,viewWidth,viewHidth);
    else{
        if(viewHidth<viewWidth)
        {
            if(imgWidth<= imgHeight)
            {
                rect=CGRectMake(0, 0,imgWidth, imgWidth*viewHidth/viewWidth);
            }else
            {
                float width = viewWidth*imgHeight/viewHidth;
                float x = (imgWidth  - width)/2;
                if(x>0)
                {
                    rect = CGRectMake(x,0,  width, imgHeight);
                }else
                {
                    rect =  CGRectMake(0,  0,  imgWidth, imgWidth*viewHidth/viewWidth);
                }
            }
        }else
        {
            if(imgWidth <= imgHeight)
            {
                float height = viewHidth*imgWidth/viewWidth;
                if(height< imgHeight)
                {
                    rect =CGRectMake(0,  0, imgWidth, height);
                }else
                {
                    rect = CGRectMake(0,  0,viewWidth*imgHeight/viewHidth, imgHeight);
                }
            }else
            {
                float width = viewWidth*imgHeight/viewHidth;
                if(width< imgWidth)
                {
                    float x =  (imgWidth - width)/2;
                    rect =CGRectMake(x,  0,width, imgHeight);
                }else
                {
                    rect =CGRectMake(0,  0,imgWidth, imgHeight);
                }
            }
        }
    }
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage,rect);
    CGRect smallBounds = CGRectMake(0, 0,CGImageGetWidth(subImageRef),CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context =UIGraphicsGetCurrentContext();CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage *smallImage = [UIImage imageWithCGImage:subImageRef];
    if (subImageRef) {
        CGImageRelease(subImageRef);
    }
    UIGraphicsEndImageContext();
    
    return smallImage;
}

+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect
{
    CGFloat (^rad)(CGFloat) = ^CGFloat(CGFloat deg) {
        return deg / 180.0f * (CGFloat) M_PI;
    };
    
    // determine the orientation of the image and apply a transformation to the crop rectangle to shift it to the correct position
    CGAffineTransform rectTransform;
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    // adjust the transformation scale based on the image scale
    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);
    
    // apply the transformation to the rect to create a new, shifted rect
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    
    // use the rect to crop the image
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, transformedCropSquare);
    // create a new UIImage and set the scale and orientation appropriately
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    // memory cleanup
    CGImageRelease(imageRef);
    
    return result;
}

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize
{
    CGFloat targetWidth = newSize.width;
    CGFloat targetHeight = newSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    //CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();//CGImageGetColorSpace(imageRef);
    
    unsigned char *rawData = calloc(targetWidth *targetHeight, 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * targetWidth;
    NSUInteger bitsPerComponent = 8;
    
//    if (bitmapInfo == kCGImageAlphaNone) {
//        bitmapInfo = kCGImageAlphaNoneSkipLast;
//    }
    
    CGContextRef bitmap;
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        //bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
      bitmap = CGBitmapContextCreate(rawData, targetWidth, targetHeight,
                              bitsPerComponent, bytesPerRow, colorSpaceInfo,
                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        
    } else {
        //bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        bitmap = CGBitmapContextCreate(rawData, targetHeight, targetWidth,
                                       bitsPerComponent, bytesPerRow, colorSpaceInfo,
                                       kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    }
    
    CGColorSpaceRelease(colorSpaceInfo);
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, M_PI_2); // + 90 degrees
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, -M_PI_2); // - 90 degrees
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, -M_PI); // - 180 degrees
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    if (rawData) {
        free(rawData);
        rawData = NULL;
    }
    
    return newImage;
}

@end
