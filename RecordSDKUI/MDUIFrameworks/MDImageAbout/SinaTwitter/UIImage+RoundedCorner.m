// UIImage+RoundedCorner.m
// Created by Trevor Harmon on 9/20/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

#import "UIImage+RoundedCorner.h"
#import "UIImage+Alpha.h"

// Private helper methods
@interface UIImage ()
//- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;
@end

@implementation UIImage (RoundedCorner)

// Creates a copy of this image with rounded corners
// If borderSize is non-zero, a transparent border of the given size will also be added
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
    // Build a context that's the same dimensions as the new size
    CGContextRef context = CGBitmapContextCreate(NULL,
            (size_t) image.size.width,
            (size_t) image.size.height,
                                                 CGImageGetBitsPerComponent(image.CGImage),
                                                 0,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 CGImageGetBitmapInfo(image.CGImage));

    // Create a clipping path with rounded corners
    CGContextBeginPath(context);
    [self addRoundedRectToPath:CGRectMake(borderSize, borderSize, image.size.width - borderSize * 2, image.size.height - borderSize * 2)
                       context:context
                     ovalWidth:cornerSize
                    ovalHeight:cornerSize];
    CGContextClosePath(context);
    CGContextClip(context);

    // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    
    // Create a CGImage from the context
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    // Create a UIImage from the CGImage
    UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage];
    CGImageRelease(clippedImage);
    
    return roundedImage;
}

- (UIImage*)imageWithRadius:(float)radius
                      width:(float)width
                     height:(float)height
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, self.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    if (!c) {
        return nil;
    }
    
    float scaleRadius = radius/(self.scale);
    CGContextBeginPath(c);
    CGContextMoveToPoint  (c, width, height/2);
    CGContextAddArcToPoint(c, width, height, width/2, height, scaleRadius);
    CGContextAddArcToPoint(c, 0,         height, 0,           height/2, scaleRadius);
    CGContextAddArcToPoint(c, 0,         0,         width/2, 0,           scaleRadius);
    CGContextAddArcToPoint(c, width, 0,         width,   height/2, scaleRadius);
    CGContextClosePath(c);
    
    CGContextClip(c);
	
    [self drawAtPoint:CGPointZero];
    UIImage *converted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return converted;
}

- (UIImage *)getEllipseImageWithImage:( UIImage *)image
{
    CGFloat inset = 0.1f;
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

- (UIImage *)imagewithRadiusForUserTitlewidth:(float)width height:(float)height

{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, self.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    if (!c) {
        return nil;
    }
    
    CGFloat radius = 14/(self.scale);
    CGContextBeginPath(c);
    CGContextMoveToPoint  (c, width, height/2);
    CGContextAddArcToPoint(c, width, height, width/2, height,   0);
    CGContextAddArcToPoint(c, 0, height, 0, height/2, 0);
    CGContextAddArcToPoint(c, 0, 0, width/2, 0, radius);
    CGContextAddArcToPoint(c, width, 0, width, height/2, radius);
    CGContextClosePath(c);
    
    CGContextClip(c);
	
    [self drawAtPoint:CGPointZero];
    UIImage *converted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return converted;
}

- (UIImage *)scaleImageWithRadius:(float)radius finalWidth:(CGFloat)fWidth finalHeight:(CGFloat)fHeight
{
    CGFloat width = MIN(self.size.width, fWidth);
    CGFloat height = MIN(self.size.height, fHeight);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0);
    CGContextRef c = UIGraphicsGetCurrentContext();
    if (!c) {
        return nil;
    }
    
    CGContextBeginPath(c);
    CGContextMoveToPoint  (c, width, height/2);
    CGContextAddArcToPoint(c, width, height, width/2, height,   radius);
    CGContextAddArcToPoint(c, 0,         height, 0,           height/2, radius);
    CGContextAddArcToPoint(c, 0,         0,         width/2, 0,           radius);
    CGContextAddArcToPoint(c, width, 0,         width,   height/2, radius);
    CGContextClosePath(c);
    
    CGContextClip(c);
	
    CGImageRef imgRef = [self CGImage];
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextSetRGBFillColor(c, 0.0, 0.0, 0.0, 0.0);
    CGContextFillRect(c, rect);
    CGContextSaveGState(c);
    
    CGContextTranslateCTM(c, 0.0, height);
    CGContextScaleCTM(c, 1.0, -1.0);
    CGContextDrawImage(c, rect, imgRef);
    CGContextRestoreGState(c);
    UIImage *converted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return converted;
}

- (UIImage *)circleClipedImage
{
    //使用短边作为内切圆的直径
    CGImageRef imgRef = self.CGImage;
    CGImageRef clipRef = nil;
    
    CGFloat originW = self.size.width;
    CGFloat originH = self.size.height;
    CGFloat finalV = originW;
    
    CGFloat delta = originH - originW;
    CGRect rect = CGRectMake(0, 0, finalV, finalV);
    
    if (delta > 0.1) {//高度大于宽度，应该使用宽度作为圆的直径
        CGRect clipRect = CGRectMake(0, delta/2.0 * self.scale, finalV*self.scale, finalV*self.scale);
        clipRef = CGImageCreateWithImageInRect(imgRef, clipRect);
    }
    else if (delta < -0.1){
        finalV = originH;
        delta = originW - originH;
        rect = CGRectMake(0, 0, finalV, finalV);
        
        CGRect clipRect = CGRectMake(delta/2.0*self.scale, 0, finalV*self.scale, finalV*self.scale);
        clipRef = CGImageCreateWithImageInRect(imgRef, clipRect);
    }
    else {
        clipRef = CGImageRetain(imgRef);
    }
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) {
        return nil;
    }
    
    //CGContextSetAllowsAntialiasing(ctx, YES);
    //CGContextSetShouldAntialias(ctx, YES);
    CGContextBeginPath(ctx);
    CGContextAddEllipseInRect(ctx, rect);
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    
    CGContextTranslateCTM(ctx, 0.0, finalV);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextDrawImage(ctx, rect, clipRef);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    if (clipRef) {
        CGImageRelease(clipRef);
    }
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)clipImageWithFinalWidth:(CGFloat)fWidth finalHeight:(CGFloat)fHeight
{
    
    CGSize selfSize = self.size;
    
    CGImageRef clipRef;
    CGRect clipRect = CGRectZero;
    
    CGRect rect = CGRectZero;
    rect.size = selfSize;
    
    float deltaW = selfSize.width/fWidth;
    float deltaH = selfSize.width/fHeight;
    
    if (deltaW < deltaH) {
        CGSize clipSize = CGSizeZero;
        clipSize.width = selfSize.width;
        clipSize.height = selfSize.width/fWidth *fHeight;
        
        float delta = (rect.size.height -clipSize.height)*0.5f;
        clipRect = CGRectMake(0, delta, clipSize.width, clipSize.height);
        clipRef = CGImageCreateWithImageInRect(self.CGImage, clipRect);
    }else {
        
        CGSize clipSize = CGSizeZero;
        clipSize.width = selfSize.height/fHeight *fWidth;
        clipSize.height = selfSize.height;
        
        float delta = (rect.size.width -clipSize.width)*0.5f;
        clipRect = CGRectMake(delta, 0, clipSize.width, clipSize.height);
        clipRef = CGImageCreateWithImageInRect(self.CGImage, clipRect);
    }
    
    UIGraphicsBeginImageContext(clipRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, clipRect, clipRef);
    UIImage* smallImage = [UIImage imageWithCGImage:clipRef];
    
    if (clipRef) {
        CFRelease(clipRef);
    }
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}


#pragma mark -
#pragma mark Private helper methods

// Adds a rectangular path to the given context and rounds its corners by the given extents
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight {
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    CGFloat fw = CGRectGetWidth(rect) / ovalWidth;
    CGFloat fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


- (UIImage *)imageWithRadius:(CGSize)size cornerRadius:(MDCornerRadius)cornerRadius

{
    UIGraphicsBeginImageContext(size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    if (!c) {
        return nil;
    }
    
    CGContextBeginPath(c);
    CGContextMoveToPoint  (c, size.width, size.height/2);
    CGContextAddArcToPoint(c, size.width, size.height, size.width/2, size.height, cornerRadius.rightBottom);
    CGContextAddArcToPoint(c, 0, size.height, 0, size.height/2, cornerRadius.leftBottom);
    CGContextAddArcToPoint(c, 0, 0, size.width/2, 0, cornerRadius.leftTop);
    CGContextAddArcToPoint(c, size.width, 0, size.width, size.height/2, cornerRadius.rightTop);
    CGContextClosePath(c);
    
    CGContextClip(c);
    
    [self drawAtPoint:CGPointZero];
    UIImage *converted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return converted;
}

@end
